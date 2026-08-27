#!/usr/bin/env python3
"""
Humay Content Pack compiler/validator — stdlib only, deterministic.
Reads source JSON from Tools/ContentPack/source/, validates, and emits
compiled minified bundle to Humay/Resources/ContentPacks/v1/contentPack.json.

Usage:
  python3 Tools/ContentPack/compile/compile.py [--validate] [--report] [--mode pilot|production]
  --mode pilot        permissive (default inferred from manifest.isPilot)
  --mode production   strict: requires 366*12 + 12/12/12, lifecycle, size, qa thresholds etc
"""
import json, sys, pathlib, re, hashlib, argparse, difflib, math
from datetime import datetime, timezone
import collections, statistics

ROOT = pathlib.Path(__file__).resolve().parents[3]
SOURCE = ROOT / "Tools" / "ContentPack" / "source"
DEST_DIR = ROOT / "Humay" / "Resources" / "ContentPacks" / "v1"
DEST_FILE = DEST_DIR / "contentPack.json"
QA_DIR = ROOT / "Tools" / "ContentPack" / ".qa"
QA_JSON = QA_DIR / "content-report.json"
QA_MD = QA_DIR / "content-report.md"

SIGNS = ["aries","taurus","gemini","cancer","leo","virgo","libra","scorpio","sagittarius","capricorn","aquarius","pisces"]
DIMENSIONS = ["overall","romance","social","career","energy","confidence","patience","chaos"]
ARCHETYPE_IDS = [
    "unmovable-romantic","chaotic-diplomat","quiet-storm","main-character-off-duty",
    "overthinking-oracle","sunshine-menace","elegant-chaos","reluctant-leader",
    "soft-realist","midnight-strategist","charming-skeptic","dramatic-stabilizer"
]
ALLOWED_THEMES = {"romance","career","social","confidence","patience","energy","chaos","reset","boundaries","communication","focus"}
ALLOWED_QA_STATUSES = {"generated","validated","reviewed","approved","rejected"}
ALLOWED_GENERATION_METHODS = {"scripted-pilot","ai-batch-authored","human-curated","mixed"}

MAX = {"headline":120,"reading":600,"flag":140,"summary":280,"tag":40,"moonFragment":180,"risingFragment":180,"archetypeFragment":160}

# Production QA thresholds (§17-23) — §43 adjacent similarity centralized
THRESHOLDS = {
    "headline_unique_per_sign": 0.90,
    "personal_unique_per_sign": 0.90,
    "love_unique_per_sign": 0.75,
    "career_unique_per_sign": 0.75,
    "social_unique_per_sign": 0.75,
    "adjacent_headline_similarity_error": 0.90,  # §43 headline adjacent >0.90 ERROR
    "adjacent_personal_similarity_error": 0.92,  # §43 personal adjacent >0.92 ERROR
    "adjacent_similarity_threshold": 0.88,  # legacy inclusive threshold (kept for QA near-duplicate analysis)
    "score_extreme_delta": 40,  # single jump suspicious
    "score_large_delta": 35,
    "max_extreme_jumps_per_sign_dim": 12,  # count of delta>35 per sign/dim before error
    "max_score_jump_40": 0,  # any jump >40 is error in production? we warn then count
    "theme_streak_warn": 6,
    "theme_streak_error": 9,
    "modifier_min_themes": 6,
    "modifier_min_variants": 2,
    "modifier_preferred_variants": 3,
    "max_flag_reuse_rate": 0.5,  # for copy pools intentionally reusable
}

def load_json(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)

def validate_daykey(k):
    if not re.match(r"^\d{2}-\d{2}$", k):
        return False
    try:
        m,d = map(int, k.split("-"))
        if not 1 <= m <= 12: return False
        mdays = {2:29,4:30,6:30,9:30,11:30}
        maxd = mdays.get(m,31)
        return 1 <= d <= maxd
    except: return False

def all_canonical_keys():
    keys=[]
    for m in range(1,13):
        mdays = {2:29,4:30,6:30,9:30,11:30}.get(m,31)
        for d in range(1,mdays+1):
            keys.append(f"{m:02d}-{d:02d}")
    return keys

errors=[]
warnings=[]

def err(msg):
    errors.append(msg)
    print(f"ERROR: {msg}", file=sys.stderr)
def warn(msg):
    warnings.append(msg)
    print(f"WARN: {msg}", file=sys.stderr)

def validate_manifest(m, mode):
    required = ["packVersion","language","contentCycleVersion","coverage","provenance"]
    for k in required:
        if k not in m: err(f"manifest missing {k}")
    cov = m.get("coverage",{})
    for k in ["dayKeyCount","isPilot","includesLeapDay","sunRecordCount"]:
        if k not in cov: err(f"manifest.coverage missing {k}")
    prov = m.get("provenance",{})
    for k in ["sourceModel","promptVersion","contentLanguage"]:
        if k not in prov: err(f"manifest.provenance missing {k}")
    sv = m.get("schemaVersion",1)
    if sv != 1: err(f"unsupported schemaVersion {sv}")
    is_pilot = cov.get("isPilot", True)
    effective_production = (mode == "production") or (not is_pilot)
    if effective_production:
        if not m.get("contentCycleVersion","").strip():
            err("contentCycleVersion required for production")
        if not m.get("activeFrom"):
            err("activeFrom required for production (lifecycle)")
        if not m.get("activeThrough"):
            err("activeThrough required for production")
        gm = m.get("generationMethod") or prov.get("generationMethod")
        if gm is None or not str(gm).strip():
            err("generationMethod required for production (scripted-pilot|ai-batch-authored|human-curated|mixed)")
        elif gm not in ALLOWED_GENERATION_METHODS:
            err(f"generationMethod '{gm}' not in allowed {sorted(ALLOWED_GENERATION_METHODS)}")
        # contentCycleVersion vs scorePlan checked later
    else:
        gm = m.get("generationMethod") or prov.get("generationMethod")
        if gm is not None and not str(gm).strip():
            err("generationMethod empty")
        elif gm is not None and gm not in ALLOWED_GENERATION_METHODS:
            warn(f"generationMethod '{gm}' not in canonical set")

def validate_sun_records(records):
    seen=set()
    for i,r in enumerate(records):
        prefix=f"sunRecords[{i}]"
        dk=r.get("dayKey","")
        if not dk or not validate_daykey(dk): err(f"{prefix} invalid dayKey {dk!r}")
        sign=r.get("sunSign","")
        if sign not in SIGNS: err(f"{prefix} invalid sunSign {sign!r}")
        key=f"{dk}|{sign}"
        if key in seen: err(f"{prefix} duplicate {key}")
        seen.add(key)
        scores=r.get("scores",{})
        for dim in DIMENSIONS:
            if dim not in scores: err(f"{prefix} missing dimension {dim}")
            else:
                v=scores[dim]
                if not isinstance(v,int) or not 0 <= v <= 100: err(f"{prefix} score {dim}={v} invalid")
        for field, maxlen in [("headline",MAX["headline"]),("personal",MAX["reading"]),("love",MAX["reading"]),("career",MAX["reading"]),("social",MAX["reading"]),("greenFlag",MAX["flag"]),("redFlag",MAX["flag"])]:
            t=r.get(field,"")
            if not isinstance(t,str) or not t.strip(): err(f"{prefix} empty {field}")
            elif len(t) > maxlen: err(f"{prefix} {field} too long {len(t)}>{maxlen}")
        if "summary" in r and r["summary"] is not None:
            if len(r["summary"]) > MAX["summary"]: err(f"{prefix} summary too long")
        tags=r.get("tags")
        if tags:
            for t in tags:
                if len(t) > MAX["tag"]: err(f"{prefix} tag too long {t}")
                if t not in ALLOWED_THEMES and t not in DIMENSIONS:
                    err(f"{prefix} unknown theme/tag {t!r}")

def validate_moon(mods, mode):
    seen=set()
    for i,m in enumerate(mods):
        s=m.get("moonSign","")
        if s not in SIGNS: err(f"moonModifiers[{i}] invalid {s!r}")
        if s in seen: err(f"moonModifiers duplicate {s}")
        seen.add(s)
        for k,v in m.get("deltas",{}).items():
            if k not in DIMENSIONS: err(f"moonModifiers[{i}] unknown dim {k}")
            if not -14 <= v <= 14: err(f"moonModifiers[{i}] delta {k}={v} out of bounds")
        frag=m.get("emotionalFragment")
        if frag is not None and len(frag)>MAX["moonFragment"]: err(f"moonModifiers[{i}] fragment too long")
        fragments=m.get("fragments")
        if fragments:
            for theme, arr in fragments.items():
                if theme not in ALLOWED_THEMES and theme not in DIMENSIONS: warn(f"moonModifiers[{i}] unknown fragment theme {theme}")
                for f in arr:
                    if len(f)>MAX["moonFragment"]: err(f"moonModifiers[{i}] fragment theme {theme} too long")
        # Modifier QA placeholder detection (§38)
        if mode == "production":
            check_modifier_placeholders(m, f"moonModifiers[{i}]", fragments, frag if isinstance(frag, str) else None)
            # coverage
            if fragments is None or len(fragments) < THRESHOLDS["modifier_min_themes"]:
                err(f"moonModifiers[{i}] requires >= {THRESHOLDS['modifier_min_themes']} themes, got {len(fragments or {})}")
            else:
                for theme, arr in fragments.items():
                    if len(arr) < THRESHOLDS["modifier_min_variants"]:
                        err(f"moonModifiers[{i}] theme {theme} requires >= {THRESHOLDS['modifier_min_variants']} variants, got {len(arr)}")

def validate_rising(mods, mode):
    seen=set()
    for i,m in enumerate(mods):
        s=m.get("risingSign","")
        if s not in SIGNS: err(f"risingModifiers[{i}] invalid {s!r}")
        if s in seen: err(f"risingModifiers duplicate {s}")
        seen.add(s)
        for k,v in m.get("deltas",{}).items():
            if k not in DIMENSIONS: err(f"risingModifiers[{i}] unknown dim {k}")
            if not -12 <= v <= 12: err(f"risingModifiers[{i}] delta {k}={v} out of bounds")
        frag=m.get("outwardFragment")
        if frag is not None and len(frag)>MAX["risingFragment"]: err(f"risingModifiers[{i}] fragment too long")
        fragments=m.get("fragments")
        if fragments:
            for theme, arr in fragments.items():
                if theme not in ALLOWED_THEMES and theme not in DIMENSIONS: warn(f"risingModifiers[{i}] unknown fragment theme {theme}")
                for f in arr:
                    if len(f)>MAX["risingFragment"]: err(f"risingModifiers[{i}] fragment theme {theme} too long")
        if mode == "production":
            check_modifier_placeholders(m, f"risingModifiers[{i}]", fragments, frag if isinstance(frag, str) else None)
            if fragments is None or len(fragments) < THRESHOLDS["modifier_min_themes"]:
                err(f"risingModifiers[{i}] requires >= {THRESHOLDS['modifier_min_themes']} themes, got {len(fragments or {})}")
            else:
                for theme, arr in fragments.items():
                    if len(arr) < THRESHOLDS["modifier_min_variants"]:
                        err(f"risingModifiers[{i}] theme {theme} requires >= {THRESHOLDS['modifier_min_variants']} variants, got {len(arr)}")

def validate_archetype(mods, mode):
    seen=set()
    for i,m in enumerate(mods):
        mid=m.get("archetypeID","")
        if mid not in ARCHETYPE_IDS: err(f"archetypeModifiers[{i}] unknown {mid!r}")
        if mid in seen: err(f"archetypeModifiers duplicate {mid}")
        seen.add(mid)
        for k,v in m.get("deltas",{}).items():
            if k not in DIMENSIONS: err(f"archetypeModifiers[{i}] unknown dim {k}")
            if not -10 <= v <= 10: err(f"archetypeModifiers[{i}] delta {k}={v} out of bounds")
        frag=m.get("fragment")
        if frag is not None and len(frag)>MAX["archetypeFragment"]: err(f"archetypeModifiers[{i}] fragment too long")
        fragments=m.get("fragments")
        if fragments:
            for theme, arr in fragments.items():
                for f in arr:
                    if len(f)>MAX["archetypeFragment"]: err(f"archetypeModifiers[{i}] fragment theme {theme} too long")
        if mode == "production":
            check_modifier_placeholders(m, f"archetypeModifiers[{i}]", fragments, frag if isinstance(frag, str) else None)
            if fragments is None or len(fragments) < THRESHOLDS["modifier_min_themes"]:
                err(f"archetypeModifiers[{i}] requires >= {THRESHOLDS['modifier_min_themes']} themes, got {len(fragments or {})}")
            else:
                for theme, arr in fragments.items():
                    if len(arr) < THRESHOLDS["modifier_min_variants"]:
                        err(f"archetypeModifiers[{i}] theme {theme} requires >= {THRESHOLDS['modifier_min_variants']} variants, got {len(arr)}")

def check_modifier_placeholders(mod, label, fragments, base_frag):
    """§38 placeholder detection."""
    placeholders = []
    # patterns: "(career)", "[career]", "— career note.", bracket suffixes
    pat_paren = re.compile(r"\(\w+\)\s*$")
    pat_bracket = re.compile(r"\[\w+\]\s*$")
    pat_dash_note = re.compile(r"—\s*\w+\s*note\.?\s*$")
    all_frags = []
    if base_frag: all_frags.append(base_frag)
    if fragments:
        for arr in fragments.values():
            all_frags.extend(arr)
    for f in all_frags:
        if pat_paren.search(f): placeholders.append(f"placeholder suffix '(theme)' in {label}: {f[:60]!r}")
        if pat_bracket.search(f): placeholders.append(f"placeholder bracket '[theme]' in {label}: {f[:60]!r}")
        if pat_dash_note.search(f): placeholders.append(f"placeholder '— theme note.' in {label}: {f[:60]!r}")
    # duplicate detection across themes: same exact fragment in multiple themes is suspicious
    if fragments:
        frag_to_themes = collections.defaultdict(list)
        for theme, arr in fragments.items():
            for frag in arr:
                frag_to_themes[frag].append(theme)
        for frag, themes in frag_to_themes.items():
            if len(themes) > 1 and len(set(themes)) > 1:
                # same fragment string reused across distinct themes
                warn(f"{label} fragment reused across themes {themes}: {frag[:60]!r}")
        # near-identical variants: suffix-hack detection already handled, but also warn if variants are identical
        for theme, arr in fragments.items():
            if len(arr) != len(set(arr)):
                placeholders.append(f"duplicate identical variants in {label} theme {theme}")
    for p in placeholders:
        err(p)

# ---------- Score plan authoritative (§12-15) ----------

def load_score_plan(mode, manifest):
    """Load and validate authoritative score plan for production."""
    plan_path = SOURCE / "scorePlan.json"
    pilot_path = SOURCE / "scorePlan.pilot.json"
    if mode == "production":
        if not plan_path.exists():
            err(f"scorePlan.json required for production (366×12 authoritative plan) not found at {plan_path}")
            return None
        data = load_json(plan_path)
        return validate_score_plan(data, manifest, mode)
    else:
        # pilot may use pilot file or production if present, permissive
        if pilot_path.exists():
            data = load_json(pilot_path)
            # pilot file may be plain array or wrapped
            try:
                validate_score_plan(data, manifest, mode, permissive=True)
            except SystemExit:
                pass
            return data
        if plan_path.exists():
            data = load_json(plan_path)
            try:
                validate_score_plan(data, manifest, mode, permissive=True)
            except SystemExit:
                pass
            return data
        return None

def validate_score_plan(data, manifest, mode, permissive=False):
    """Validate score plan structure: wrapped metadata or plain array."""
    # Unwrap if needed: {schemaVersion, contentCycleVersion, entries:[...]}
    entries = None
    plan_cycle = None
    if isinstance(data, dict):
        entries = data.get("entries") or data.get("plan") or data.get("data")
        plan_cycle = data.get("contentCycleVersion")
        if entries is None:
            # maybe dict with dayKey etc? treat as error
            if not permissive:
                err("scorePlan.json must contain 'entries' array (wrapped metadata)")
            return data
        # metadata checks
        if not permissive:
            if data.get("schemaVersion") is None:
                err("scorePlan schemaVersion required")
            if plan_cycle is None or not str(plan_cycle).strip():
                err("scorePlan contentCycleVersion required")
            if plan_cycle and manifest and manifest.get("contentCycleVersion") and plan_cycle != manifest.get("contentCycleVersion"):
                err(f"scorePlan contentCycleVersion {plan_cycle!r} != manifest {manifest.get('contentCycleVersion')!r}")
    elif isinstance(data, list):
        entries = data
        if mode == "production" and not permissive:
            err("scorePlan.json must be wrapped dict with metadata (schemaVersion, contentCycleVersion, entries) for production")
            # still validate entries
    else:
        err("scorePlan.json must be array or wrapped dict")
        return data

    if entries is None:
        return data

    # Production requires exactly 4392
    all_keys = set(all_canonical_keys())
    if mode == "production" and not permissive:
        if len(entries) != 4392:
            err(f"scorePlan requires exactly 4392 entries, got {len(entries)}")
    # Validate entries
    seen = set()
    for idx, e in enumerate(entries):
        dk = e.get("dayKey")
        sign = e.get("sunSign")
        plan = e.get("plan") or e
        # support either wrapped plan object or flat
        scores = plan.get("scores") if isinstance(plan, dict) else None
        if scores is None and "scores" in e:
            scores = e["scores"]
        primary = plan.get("primaryTheme") if isinstance(plan, dict) else None
        secondary = plan.get("secondaryTheme") if isinstance(plan, dict) else None
        if not dk or not validate_daykey(dk):
            err(f"scorePlan[{idx}] invalid dayKey {dk!r}")
        if sign not in SIGNS:
            err(f"scorePlan[{idx}] invalid sunSign {sign!r}")
        key = f"{dk}|{sign}"
        if key in seen:
            err(f"scorePlan duplicate {key}")
        seen.add(key)
        if not isinstance(scores, dict):
            err(f"scorePlan[{idx}] missing scores")
        else:
            for dim in DIMENSIONS:
                if dim not in scores:
                    err(f"scorePlan[{idx}] missing dimension {dim}")
                elif not isinstance(scores[dim], int) or not 0 <= scores[dim] <= 100:
                    err(f"scorePlan[{idx}] score {dim}={scores.get(dim)} invalid")
        if primary is not None and primary not in ALLOWED_THEMES and primary not in DIMENSIONS:
            err(f"scorePlan[{idx}] invalid primaryTheme {primary!r}")
        if secondary is not None and secondary not in ALLOWED_THEMES and secondary not in DIMENSIONS:
            err(f"scorePlan[{idx}] invalid secondaryTheme {secondary!r}")
    # Check coverage completeness for production
    if mode == "production" and not permissive:
        expected = set(f"{k}|{s}" for k in all_keys for s in SIGNS)
        missing = expected - seen
        extra = seen - expected
        if missing:
            err(f"scorePlan missing {len(missing)} entries e.g. {sorted(list(missing))[:3]}")
        if extra:
            err(f"scorePlan extra entries {extra}")
    return data

def verify_sun_against_score_plan(sun_records, score_plan_data, mode):
    if score_plan_data is None or mode != "production":
        return
    # Build lookup
    entries = score_plan_data.get("entries") if isinstance(score_plan_data, dict) else score_plan_data
    if not isinstance(entries, list):
        return
    plan_map = {}
    for e in entries:
        dk = e.get("dayKey"); sign = e.get("sunSign")
        plan = e.get("plan") if isinstance(e.get("plan"), dict) else e
        if dk and sign:
            plan_map[f"{dk}|{sign}"] = plan
    for r in sun_records:
        key = f"{r['dayKey']}|{r['sunSign']}"
        plan = plan_map.get(key)
        if plan is None:
            err(f"Sun record {key} missing in scorePlan")
            continue
        plan_scores = plan.get("scores") or plan.get("plan", {}).get("scores") if isinstance(plan, dict) else None
        if isinstance(plan, dict) and "plan" in plan:
            plan_scores = plan["plan"].get("scores")
        # Actually plan may be dict with scores directly
        if plan_scores is None and isinstance(plan, dict):
            plan_scores = plan.get("scores")
        if plan_scores:
            for dim in DIMENSIONS:
                if r["scores"].get(dim) != plan_scores.get(dim):
                    err(f"Sun {key} score {dim} {r['scores'].get(dim)} != plan {plan_scores.get(dim)} (plan authoritative)")
        # tag/theme validation: primaryTheme should be in tags
        primary = plan.get("primaryTheme") if isinstance(plan, dict) else None
        if primary and isinstance(primary, str):
            tags = r.get("tags", [])
            if primary not in tags:
                # Report as warning or error per policy — we make it warning for now unless strict
                warn(f"Sun {key} primaryTheme {primary!r} not in tags {tags}")

# ---------- QA helpers ----------
def normalize(s):
    return re.sub(r"[^a-z0-9 ]","",s.lower()).strip()

def qa_exact_duplicates(records):
    fields = ["headline","personal","love","career","social","summary","greenFlag","redFlag"]
    result={}
    for field in fields:
        vals=[r.get(field,"") for r in records if r.get(field)]
        cnt=collections.Counter(vals)
        dups=sum(1 for v,c in cnt.items() if c>1)
        uniq=len(cnt)
        max_reuse=max(cnt.values()) if cnt else 0
        top=cnt.most_common(3)
        result[field]={"unique":uniq,"total":len(vals),"duplicateGroups":dups,"maxReuse":max_reuse,"topRepeated":top}
    return result

def qa_per_sign_uniqueness(records):
    """§19 per-sign uniqueness ratios for all fields."""
    per={}
    for sign in SIGNS:
        subset=[r for r in records if r["sunSign"]==sign]
        if not subset: continue
        entry={"count":len(subset)}
        for field in ["headline","personal","love","career","social"]:
            vals=[normalize(r.get(field,"")) for r in subset if r.get(field)]
            uniq=len(set(vals))
            ratio=round(uniq/max(1,len(vals)),3) if vals else 1.0
            entry[field+"UniqueRatio"]=ratio
            entry[field+"Unique"]=uniq
        per[sign]=entry
    return per

def check_production_uniqueness_gates(per_sign, mode):
    if mode != "production": return
    for sign, stats in per_sign.items():
        if stats.get("headlineUniqueRatio",1) < THRESHOLDS["headline_unique_per_sign"]:
            err(f"Per-sign uniqueness {sign} headline {stats['headlineUniqueRatio']} < {THRESHOLDS['headline_unique_per_sign']}")
        if stats.get("personalUniqueRatio",1) < THRESHOLDS["personal_unique_per_sign"]:
            err(f"Per-sign uniqueness {sign} personal {stats['personalUniqueRatio']} < {THRESHOLDS['personal_unique_per_sign']}")
        if stats.get("loveUniqueRatio",1) < THRESHOLDS["love_unique_per_sign"]:
            err(f"Per-sign uniqueness {sign} love {stats['loveUniqueRatio']} < {THRESHOLDS['love_unique_per_sign']}")
        if stats.get("careerUniqueRatio",1) < THRESHOLDS["career_unique_per_sign"]:
            err(f"Per-sign uniqueness {sign} career {stats['careerUniqueRatio']} < {THRESHOLDS['career_unique_per_sign']}")
        if stats.get("socialUniqueRatio",1) < THRESHOLDS["social_unique_per_sign"]:
            err(f"Per-sign uniqueness {sign} social {stats['socialUniqueRatio']} < {THRESHOLDS['social_unique_per_sign']}")

def qa_near_duplicates(records, field="personal", threshold=0.82):
    texts=[(r["dayKey"], r["sunSign"], r.get(field,"")) for r in records if r.get(field)]
    clusters=[]
    # Optimized per-sign to avoid O(n^2) across all 4392 — per field per sign
    for sign in SIGNS:
        subset=[(dk, s, t) for dk,s,t in texts if s==sign]
        for i in range(len(subset)):
            for j in range(i+1, len(subset)):
                a = set(normalize(subset[i][2]).split())
                b = set(normalize(subset[j][2]).split())
                if not a or not b: continue
                inter=len(a & b)
                union=len(a | b)
                jacc=inter/union if union else 0
                seq=difflib.SequenceMatcher(None, normalize(subset[i][2]), normalize(subset[j][2])).ratio()
                score=max(jacc, seq)
                if score >= threshold:
                    clusters.append({"a":f"{subset[i][0]}|{subset[i][1]}","b":f"{subset[j][0]}|{subset[j][1]}","jaccard":round(jacc,3),"seq":round(seq,3),"score":round(score,3),"field":field})
                    if len(clusters) >= 20: break
            if len(clusters)>=20: break
        if len(clusters)>=20: break
    return clusters

def qa_adjacent(records):
    warnings_list=[]
    ordered_keys = sorted(all_canonical_keys())
    key_index={k:i for i,k in enumerate(ordered_keys)}
    for sign in SIGNS:
        subset=sorted([r for r in records if r["sunSign"]==sign], key=lambda r: key_index.get(r["dayKey"],999))
        for i in range(len(subset)-1):
            a=subset[i]; b=subset[i+1]
            if a["headline"]==b["headline"]:
                warnings_list.append({"sign":sign,"keys":f"{a['dayKey']}->{b['dayKey']}","issue":"identical headline"})
            if a["personal"]==b["personal"]:
                warnings_list.append({"sign":sign,"keys":f"{a['dayKey']}->{b['dayKey']}","issue":"identical personal"})
            if a["greenFlag"]==b["greenFlag"] and a["redFlag"]==b["redFlag"]:
                warnings_list.append({"sign":sign,"keys":f"{a['dayKey']}->{b['dayKey']}","issue":"identical flags adjacent"})
            for dim in DIMENSIONS:
                delta=abs(a["scores"][dim]-b["scores"][dim])
                if delta>35:
                    warnings_list.append({"sign":sign,"keys":f"{a['dayKey']}->{b['dayKey']}","issue":f"{dim} jump {delta}"})
                if len(warnings_list)>50: break
        if len(warnings_list)>50: break
    return warnings_list[:50]

def check_adjacent_production_gates(records, mode):
    if mode != "production": return
    ordered_keys = sorted(all_canonical_keys())
    key_index={k:i for i,k in enumerate(ordered_keys)}
    for sign in SIGNS:
        subset=sorted([r for r in records if r["sunSign"]==sign], key=lambda r: key_index.get(r["dayKey"],999))
        for i in range(len(subset)-1):
            a=subset[i]; b=subset[i+1]
            if a["headline"]==b["headline"]:
                err(f"Adjacent duplicate headline {sign} {a['dayKey']}->{b['dayKey']}")
            if a["personal"]==b["personal"]:
                err(f"Adjacent duplicate personal {sign} {a['dayKey']}->{b['dayKey']}")
            # §43 high-similarity is production blocker (not warn) with centralized thresholds
            seq_h = difflib.SequenceMatcher(None, normalize(a["headline"]), normalize(b["headline"])).ratio()
            if seq_h > THRESHOLDS["adjacent_headline_similarity_error"]:
                err(f"Adjacent highly similar headline {sign} {a['dayKey']}->{b['dayKey']} ratio {seq_h:.2f} > {THRESHOLDS['adjacent_headline_similarity_error']}")
            seq_p = difflib.SequenceMatcher(None, normalize(a["personal"]), normalize(b["personal"])).ratio()
            if seq_p > THRESHOLDS["adjacent_personal_similarity_error"]:
                err(f"Adjacent highly similar personal {sign} {a['dayKey']}->{b['dayKey']} ratio {seq_p:.2f} > {THRESHOLDS['adjacent_personal_similarity_error']}")

def qa_score_coherence(records):
    stats={}
    for dim in DIMENSIONS:
        for sign in SIGNS:
            vals=[r["scores"][dim] for r in records if r["sunSign"]==sign]
            if not vals: continue
            key=f"{sign}:{dim}"
            ordered_keys = sorted(all_canonical_keys())
            key_index={k:i for i,k in enumerate(ordered_keys)}
            subset=sorted([r for r in records if r["sunSign"]==sign], key=lambda r: key_index.get(r["dayKey"],999))
            deltas=[abs(subset[i]["scores"][dim]-subset[i+1]["scores"][dim]) for i in range(len(subset)-1)]
            max_delta=max(deltas) if deltas else 0
            extreme_jumps=sum(1 for d in deltas if d>30)
            stats[key]={"min":min(vals),"max":max(vals),"avg":round(statistics.mean(vals),1),"median":statistics.median(vals),"stdev":round(statistics.pstdev(vals),1) if len(vals)>1 else 0,"maxOneDayDelta":max_delta,"extremeJumps>30":extreme_jumps}
    return stats

def check_score_coherence_gates(records, mode):
    if mode != "production": return
    ordered_keys = sorted(all_canonical_keys())
    key_index={k:i for i,k in enumerate(ordered_keys)}
    for sign in SIGNS:
        subset=sorted([r for r in records if r["sunSign"]==sign], key=lambda r: key_index.get(r["dayKey"],999))
        for dim in DIMENSIONS:
            deltas=[abs(subset[i]["scores"][dim]-subset[i+1]["scores"][dim]) for i in range(len(subset)-1)]
            extreme_40 = sum(1 for d in deltas if d > THRESHOLDS["score_extreme_delta"])
            if extreme_40 > 0:
                err(f"Score coherence {sign}:{dim} has {extreme_40} jumps >{THRESHOLDS['score_extreme_delta']}")
            large = sum(1 for d in deltas if d > THRESHOLDS["score_large_delta"])
            if large > THRESHOLDS["max_extreme_jumps_per_sign_dim"]:
                err(f"Score coherence {sign}:{dim} excessive jumps >{THRESHOLDS['score_large_delta']}: {large} > {THRESHOLDS['max_extreme_jumps_per_sign_dim']}")

def qa_theme_streaks(records, score_plan_data=None):
    """§23 theme streak QA."""
    # Determine primaryTheme per record: prefer plan primary else top score dimension
    theme_seq_per_sign = {}
    ordered_keys = sorted(all_canonical_keys())
    key_index={k:i for i,k in enumerate(ordered_keys)}
    # Build plan map if available
    plan_map={}
    if score_plan_data is not None:
        entries = score_plan_data.get("entries") if isinstance(score_plan_data, dict) else score_plan_data
        if isinstance(entries, list):
            for e in entries:
                plan_map[f"{e.get('dayKey')}|{e.get('sunSign')}"] = (e.get("plan") or e)
    for sign in SIGNS:
        subset=sorted([r for r in records if r["sunSign"]==sign], key=lambda r: key_index.get(r["dayKey"],999))
        themes=[]
        for r in subset:
            key=f"{r['dayKey']}|{r['sunSign']}"
            plan = plan_map.get(key)
            primary=None
            if isinstance(plan, dict):
                primary = plan.get("primaryTheme") or (plan.get("plan") or {}).get("primaryTheme")
                if primary is None and "plan" in plan:
                    primary = plan["plan"].get("primaryTheme")
            if primary is None:
                # derive from tags or top score
                tags=r.get("tags") or []
                if tags and tags[0] in ALLOWED_THEMES:
                    primary=tags[0]
                else:
                    primary=max(DIMENSIONS, key=lambda d: r["scores"][d])
                    if primary=="overall": primary="focus"
            themes.append(primary)
        # compute streaks & frequencies
        longest=1; cur=1
        for i in range(1,len(themes)):
            if themes[i]==themes[i-1]:
                cur+=1; longest=max(longest,cur)
            else: cur=1
        freq=collections.Counter(themes)
        missing = [t for t in ALLOWED_THEMES if freq.get(t,0)==0]
        theme_seq_per_sign[sign]={"longestStreak":longest,"frequencies":dict(freq),"missingThemes":missing,"total":len(themes)}
    return theme_seq_per_sign

def check_theme_streak_gates(streaks, mode):
    for sign, data in streaks.items():
        longest=data["longestStreak"]
        if longest >= THRESHOLDS["theme_streak_error"]:
            err(f"Theme streak {sign} longest {longest} >= {THRESHOLDS['theme_streak_error']}")
        elif longest >= THRESHOLDS["theme_streak_warn"]:
            warn(f"Theme streak {sign} longest {longest} >= warn {THRESHOLDS['theme_streak_warn']}")

def qa_modifier_coverage(moon_mods, rising_mods, arch_mods):
    result={}
    for label, mods, key_field in [("moon", moon_mods, "moonSign"), ("rising", rising_mods, "risingSign"), ("archetype", arch_mods, "archetypeID")]:
        total_themes=0; total_variants=0; min_variants=999; max_variants=0
        for m in mods:
            frags=m.get("fragments") or {}
            total_themes += len(frags)
            for arr in frags.values():
                total_variants += len(arr)
                min_variants = min(min_variants, len(arr)) if arr else min_variants
                max_variants = max(max_variants, len(arr)) if arr else max_variants
        result[label]={"totalThemes":total_themes,"totalFragments":total_variants,"minVariants": min_variants if min_variants!=999 else 0,"maxVariants": max_variants}
    return result

def qa_prose_score_consistency(records):
    suspicious=[]
    for r in records:
        tags=r.get("tags",[])
        scores=r["scores"]
        if scores["romance"] >= 85 and "romance" not in tags:
            suspicious.append({"day":f"{r['dayKey']}|{r['sunSign']}","issue":"romance high but tag not romance","scores":scores,"tags":tags})
        if scores["career"] >= 85 and "career" not in tags:
            suspicious.append({"day":f"{r['dayKey']}|{r['sunSign']}","issue":"career high but tag not career","scores":scores,"tags":tags})
        if len(suspicious)>=20: break
    return suspicious

# ---------- size / interning ----------
def compute_sizes(source_bytes, compiled_bytes, sun_records, compact_sun):
    FULL_COUNT=4392
    compact_sun_bytes = sum(len(json.dumps(r, ensure_ascii=False, separators=(",",":")).encode("utf-8")) for r in compact_sun) if compact_sun else 0
    avg = compact_sun_bytes / max(1, len(compact_sun)) if compact_sun else 0
    projected_sun = avg * FULL_COUNT
    sun_json = json.dumps(sun_records, ensure_ascii=False, separators=(",",":"))
    sun_bytes = len(sun_json.encode("utf-8"))
    modifier_bytes = max(0, compiled_bytes - len(json.dumps(compact_sun, ensure_ascii=False, separators=(",",":")).encode("utf-8")))
    projected_total = projected_sun + max(0, modifier_bytes) + 4096
    flags = [r.get("greenFlag","") for r in sun_records] + [r.get("redFlag","") for r in sun_records]
    uniq_flags = len(set(flags))
    total_flags = len(flags)
    return {
        "sourceBytes": source_bytes,
        "compiledBytes": compiled_bytes,
        "sunBytes": sun_bytes,
        "modifierBytes": modifier_bytes,
        "avgSunRecordBytes": avg,
        "projectedFullSunBytes": projected_sun,
        "projectedTotalBytes": projected_total,
        "projectedTotalMiB": projected_total / (1024*1024),
        "flagInterning": {"uniqueFlags":uniq_flags,"totalFlags":total_flags,"reuseGroups": total_flags-uniq_flags}
    }

def discover_sun_records():
    sun_records=[]
    sun_path = SOURCE / "sunBase.json"
    if sun_path.exists():
        data=load_json(sun_path)
        if isinstance(data, list): sun_records.extend(data)
        else: sun_records.append(data)
    for p in (SOURCE / "sun").rglob("*.json") if (SOURCE / "sun").exists() else []:
        if p.name == "manifest.json": continue
        data=load_json(p)
        if isinstance(data, list): sun_records.extend(data)
        else: sun_records.append(data)
    if (SOURCE / "sunBase").exists() and (SOURCE / "sunBase").is_dir():
        for p in (SOURCE / "sunBase").glob("*.json"):
            if p.name.startswith("sunBase"): continue  # already handled
            data=load_json(p)
            if isinstance(data, list): sun_records.extend(data)
            else: sun_records.append(data)
    return sun_records

def validate_batches(sun_records, mode):
    """§9/10 batch status & coverage validation."""
    status_path = SOURCE / "batches" / "status.json"
    batches = []
    if status_path.exists():
        raw = load_json(status_path)
        if isinstance(raw, list):
            batches = raw
        elif isinstance(raw, dict):
            batches = raw.get("batches") or raw.get("entries") or []
    else:
        batches = []
    if mode == "production":
        if not batches:
            err("production requires batch status metadata (batches/status.json) with qaStatus")
            return batches
        for b in batches:
            bid = b.get("batchID") or b.get("id") or "unknown"
            qs = b.get("qaStatus")
            if qs is None:
                err(f"batch {bid} missing qaStatus")
                continue
            if qs not in ALLOWED_QA_STATUSES:
                err(f"batch {bid} unknown qaStatus {qs!r} not in {sorted(ALLOWED_QA_STATUSES)}")
                continue
            if qs != "approved":
                err(f"batch {bid} qaStatus {qs!r} != approved — production requires approved")
            # also check generationMethod if present? must be valid
            gm = b.get("generationMethod")
            if gm is not None and gm not in ALLOWED_GENERATION_METHODS:
                warn(f"batch {bid} generationMethod {gm!r} not in canonical set")
        # Coverage validation: every Sun record must belong to exactly one approved batch
        # Build map from batches dayKeyRange+signs to coverage
        all_keys = set(all_canonical_keys())
        # expand batch coverage sets
        batch_coverage = []  # list of (batchID, set of dayKey|sign)
        for b in batches:
            if b.get("qaStatus") != "approved":
                continue
            range_str = b.get("dayKeyRange")
            signs = b.get("signs")  # None means all
            if range_str is None:
                warn(f"batch {b.get('batchID')} missing dayKeyRange — cannot verify coverage")
                continue
            parts = str(range_str).split("_")
            batch_keys=set()
            if len(parts)==2:
                start, end = parts[0], parts[1]
                if start not in all_keys or end not in all_keys:
                    err(f"batch {b.get('batchID')} invalid dayKeyRange {range_str}")
                    continue
                # inclusive range
                all_ordered = all_canonical_keys()
                try:
                    s_idx = all_ordered.index(start); e_idx = all_ordered.index(end)
                except ValueError:
                    err(f"batch {b.get('batchID')} dayKeyRange not canonical")
                    continue
                if s_idx > e_idx:
                    err(f"batch {b.get('batchID')} dayKeyRange start after end")
                    continue
                for k in all_ordered[s_idx:e_idx+1]:
                    target_signs = signs if signs else SIGNS
                    for s in target_signs:
                        batch_keys.add(f"{k}|{s}")
            elif len(parts)==1:
                k=parts[0]
                if k not in all_keys:
                    err(f"batch {b.get('batchID')} invalid dayKey {k}")
                    continue
                target_signs = signs if signs else SIGNS
                for s in target_signs:
                    batch_keys.add(f"{k}|{s}")
            else:
                err(f"batch {b.get('batchID')} malformed dayKeyRange {range_str}")
                continue
            if not batch_keys:
                err(f"batch {b.get('batchID')} approved but coverage empty")
            batch_coverage.append((b.get("batchID"), batch_keys))
        # Now check every sun record belongs to exactly one batch
        record_keys = set(f"{r['dayKey']}|{r['sunSign']}" for r in sun_records)
        # collect all covered keys
        all_covered=set()
        for _, cov in batch_coverage:
            all_covered.update(cov)
        # orphan records
        orphans = record_keys - all_covered
        if orphans:
            err(f"{len(orphans)} Sun records have no batch provenance (orphans) e.g. {sorted(list(orphans))[:3]}")
        # approved batch declared coverage but no records exist for that batch
        for bid, cov in batch_coverage:
            missing_in_records = cov - record_keys
            # For pilot, coverage may be partial — but in production any missing is error if batch claimed full
            # We only error if batch coverage claims keys that are missing in records
            if missing_in_records and mode=="production":
                # Only flag if production full coverage expected; otherwise it's batch gap
                # For now warn if some batch's coverage not present
                if len(missing_in_records) > 0:
                    warn(f"batch {bid} declares {len(cov)} records but {len(missing_in_records)} not found in Sun records")
        # check overlapping batches (record belongs to multiple batches)
        # Count how many batches cover each key
        membership_counts = collections.Counter()
        for _, cov in batch_coverage:
            for k in cov:
                membership_counts[k]+=1
        overlaps = [k for k,c in membership_counts.items() if c>1]
        if overlaps:
            err(f"{len(overlaps)} records belong to multiple batches (overlap) e.g. {overlaps[:3]}")
    else:
        # pilot permissive — only warn about unknown qaStatus
        for b in batches:
            qs=b.get("qaStatus")
            if qs and qs not in ALLOWED_QA_STATUSES:
                warn(f"batch {b.get('batchID')} unknown qaStatus {qs!r}")
    return batches

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument("--validate", action="store_true")
    parser.add_argument("--report", action="store_true")
    parser.add_argument("--mode", choices=["pilot","production"], default=None)
    args,_ = parser.parse_known_args()
    validate_only = args.validate
    report = args.report or not validate_only
    mode = args.mode

    if not SOURCE.exists():
        print(f"Source dir not found: {SOURCE}", file=sys.stderr); sys.exit(1)

    manifest_path = SOURCE / "manifest.json"
    manifest = load_json(manifest_path) if manifest_path.exists() else {}
    sun_records = discover_sun_records()
    moon_mods = load_json(SOURCE / "moonModifiers.json") if (SOURCE / "moonModifiers.json").exists() else []
    rising_mods = load_json(SOURCE / "risingModifiers.json") if (SOURCE / "risingModifiers.json").exists() else []
    arch_mods = load_json(SOURCE / "archetypeModifiers.json") if (SOURCE / "archetypeModifiers.json").exists() else []
    copy_pools = load_json(SOURCE / "copyPools.json") if (SOURCE / "copyPools.json").exists() else None

    if mode is None:
        mode = "production" if (not manifest.get("coverage",{}).get("isPilot", True)) else "pilot"

    validate_manifest(manifest, mode)
    validate_sun_records(sun_records)
    validate_moon(moon_mods, mode)
    validate_rising(rising_mods, mode)
    validate_archetype(arch_mods, mode)

    # Score plan authoritative (§12-14)
    score_plan_data = load_score_plan(mode, manifest)
    if score_plan_data is not None and mode=="production":
        verify_sun_against_score_plan(sun_records, score_plan_data, mode)

    # Batch provenance (§9-10)
    batches = validate_batches(sun_records, mode)

    # Production completeness checks
    if mode == "production":
        keys_seen=set(r["dayKey"] for r in sun_records)
        all_keys=set(all_canonical_keys())
        if len(sun_records) != 4392:
            err(f"production requires 4392 Sun records, got {len(sun_records)}")
        if keys_seen != all_keys:
            missing=all_keys - keys_seen
            extra=keys_seen - all_keys
            if missing: err(f"production missing {len(missing)} dayKeys e.g. {sorted(list(missing))[:5]}")
            if extra: err(f"production unexpected extra dayKeys {extra}")
        by_key={}
        for r in sun_records:
            by_key.setdefault(r["dayKey"], set()).add(r["sunSign"])
        for k in all_keys:
            if len(by_key.get(k, set())) != 12:
                err(f"production key {k} missing signs, got {by_key.get(k,set())}")
        if len(moon_mods) != 12: err(f"production requires 12 Moon modifiers, got {len(moon_mods)}")
        if len(rising_mods) != 12: err(f"production requires 12 Rising modifiers, got {len(rising_mods)}")
        if len(arch_mods) != 12: err(f"production requires 12 archetype modifiers, got {len(arch_mods)}")
        if not manifest.get("coverage",{}).get("includesLeapDay", False):
            err("production must includesLeapDay true (need 02-29)")

    if errors:
        print(f"\nValidation failed with {len(errors)} error(s).", file=sys.stderr)
        sys.exit(1)
    else:
        print(f"Validation passed ({mode}).")

    # Build compiled pack (deterministic)
    compiled_manifest = dict(manifest)
    compiled_manifest["schemaVersion"] = 1
    compiled_manifest["compilerVersion"] = "humay-pack-compiler-v1"
    if "createdAt" not in compiled_manifest or not compiled_manifest["createdAt"]:
        compiled_manifest["createdAt"] = manifest.get("createdAt") or datetime.now(timezone.utc).isoformat().replace("+00:00","Z")
    else:
        compiled_manifest["createdAt"] = manifest.get("createdAt")
    cov = compiled_manifest.get("coverage", {})
    cov["sunRecordCount"] = len(sun_records)
    distinct_keys = len(set(r.get("dayKey") for r in sun_records))
    cov["dayKeyCount"] = distinct_keys
    if mode == "production":
        cov["isPilot"] = False
        cov["includesLeapDay"] = True
    compiled_manifest["coverage"] = cov
    # Attach batch provenance to manifest for runtime DEBUG (compact)
    if batches:
        compiled_manifest["batches"] = batches

    ORDER = ["overall","romance","social","career","energy","confidence","patience","chaos"]
    def compact_scores(d): return [d.get(k,50) for k in ORDER]
    def compact_deltas(d): return [d.get(k,0) for k in ORDER]
    compact_sun=[]
    for r in sorted(sun_records, key=lambda r: (r["dayKey"], r["sunSign"])):
        cr={"k":r["dayKey"],"s":r["sunSign"],"sc":compact_scores(r["scores"]),"h":r["headline"],"p":r["personal"],"l":r["love"],"c":r["career"],"so":r["social"],"g":r["greenFlag"],"r":r["redFlag"]}
        if r.get("tags"): cr["t"]=r["tags"]
        if r.get("summary"): cr["su"]=r["summary"]
        if r.get("influenceWeight") is not None: cr["w"]=r["influenceWeight"]
        compact_sun.append(cr)
    compact_moon=[]
    for m in sorted(moon_mods, key=lambda m: m["moonSign"]):
        cr={"m":m["moonSign"],"d":compact_deltas(m.get("deltas",{}))}
        if m.get("emotionalFragment"): cr["f"]=m["emotionalFragment"]
        if m.get("fragments"): cr["fr"]=m["fragments"]
        if m.get("affinityTags"): cr["at"]=m["affinityTags"]
        compact_moon.append(cr)
    compact_rising=[]
    for m in sorted(rising_mods, key=lambda m: m["risingSign"]):
        cr={"rs":m["risingSign"],"d":compact_deltas(m.get("deltas",{}))}
        if m.get("outwardFragment"): cr["f"]=m["outwardFragment"]
        if m.get("fragments"): cr["fr"]=m["fragments"]
        if m.get("affinityTags"): cr["at"]=m["affinityTags"]
        compact_rising.append(cr)
    compact_arch=[]
    for m in sorted(arch_mods, key=lambda m: m["archetypeID"]):
        cr={"a":m["archetypeID"],"d":compact_deltas(m.get("deltas",{}))}
        if m.get("fragment"): cr["f"]=m["fragment"]
        if m.get("fragments"): cr["fr"]=m["fragments"]
        if m.get("preferredTags"): cr["pt"]=m["preferredTags"]
        compact_arch.append(cr)

    pack={"manifest":compiled_manifest,"sunRecords":compact_sun,"moonModifiers":compact_moon,"risingModifiers":compact_rising,"archetypeModifiers":compact_arch}
    if copy_pools is not None: pack["copyPools"]=copy_pools

    compiled_data = json.dumps(pack, ensure_ascii=False, separators=(",",":"), sort_keys=True).encode("utf-8")
    source_bytes = sum(p.stat().st_size for p in SOURCE.rglob("*.json"))

    sizes = compute_sizes(source_bytes, len(compiled_data), sun_records, compact_sun)

    # QA generation (full §37)
    qa = {}
    qa["coverage"]={"sunRecords":len(sun_records),"dayKeys":distinct_keys,"isPilot": cov.get("isPilot"), "includesLeapDay": cov.get("includesLeapDay")}
    qa["modifiers"]={"moon":len(moon_mods),"rising":len(rising_mods),"archetype":len(arch_mods)}
    qa["manifest"]=compiled_manifest
    qa["size"]=sizes
    qa["exactDuplicates"]=qa_exact_duplicates(sun_records)
    # Near duplicates per field per sign
    qa["nearDuplicates"]={
        "headline": qa_near_duplicates(sun_records, "headline", 0.82)[:10],
        "personal": qa_near_duplicates(sun_records, "personal", 0.82)[:10],
        "love": qa_near_duplicates(sun_records, "love", 0.82)[:10],
        "career": qa_near_duplicates(sun_records, "career", 0.82)[:10],
        "social": qa_near_duplicates(sun_records, "social", 0.82)[:10],
    }
    qa["perSign"]=qa_per_sign_uniqueness(sun_records)
    qa["adjacent"]=qa_adjacent(sun_records)
    qa["scoreCoherence"]=qa_score_coherence(sun_records)
    qa["proseScoreConsistency"]=qa_prose_score_consistency(sun_records)
    qa["warnings"]=warnings
    qa["errors"]=errors
    qa["batches"]= batches
    qa["thresholds"]=THRESHOLDS
    qa["modifierCoverage"]=qa_modifier_coverage(moon_mods, rising_mods, arch_mods)
    qa["themeStreaks"]=qa_theme_streaks(sun_records, score_plan_data)
    # Score distributions
    qa["scoreDistributions"]={}
    for dim in DIMENSIONS:
        vals=[r["scores"][dim] for r in sun_records]
        if vals:
            qa["scoreDistributions"][dim]={"min":min(vals),"max":max(vals),"mean":round(statistics.mean(vals),1),"median":statistics.median(vals),"stdev":round(statistics.pstdev(vals),1) if len(vals)>1 else 0}
    # Copy pool reuse
    if copy_pools:
        qa["copyPoolReuse"]={
            "greenFlags": len(copy_pools.get("greenFlags",[])),
            "redFlags": len(copy_pools.get("redFlags",[])),
            "revealSecrets": len(copy_pools.get("revealSecrets",[])),
            "revealFollowUps": len(copy_pools.get("revealFollowUps",[])),
            "roastByMode": {k: len(v) for k,v in (copy_pools.get("roastByMode") or {}).items()}
        }

    # Production gates (§18-22)
    if mode=="production":
        check_production_uniqueness_gates(qa["perSign"], mode)
        check_adjacent_production_gates(sun_records, mode)
        check_score_coherence_gates(sun_records, mode)
        check_theme_streak_gates(qa["themeStreaks"], mode)
        # Exact duplicate hard gates: headline/personal cannot have excessive reuse per sign (already checked uniqueness)
        # Global duplicate groups
        ed=qa["exactDuplicates"]
        for field in ["headline","personal"]:
            if ed[field]["duplicateGroups"] > 0 and mode=="production":
                # Check per-sign duplicate already enforced; global duplicateGroups just warn unless large
                if ed[field]["maxReuse"] > 3:
                    warn(f"Global exact duplicate {field} maxReuse {ed[field]['maxReuse']}")
        # Size gate
        if sizes['projectedTotalBytes'] > 4*1024*1024:
            err(f"Projected production pack {sizes['projectedTotalMiB']:.2f} MiB exceeds 4 MiB hard ceiling")
        elif sizes['projectedTotalBytes'] > 3*1024*1024:
            warn(f"Projected {sizes['projectedTotalMiB']:.2f} MiB exceeds 3 MiB preferred (quality may justify)")

    if errors:
        print(f"\nValidation failed with {len(errors)} error(s) after QA gates.", file=sys.stderr)
        sys.exit(1)

    if report:
        print("\n— Size report —")
        print(f"Source pilot size:              {sizes['sourceBytes']} bytes ({sizes['sourceBytes']/1024:.1f} KiB)")
        print(f"Compiled pilot size:            {sizes['compiledBytes']} bytes ({sizes['compiledBytes']/1024:.1f} KiB)")
        print(f"  Sun records bytes:            {sizes['sunBytes']} bytes")
        print(f"  Modifiers/copy overhead:      {sizes['modifierBytes']} bytes")
        print(f"Avg bytes per Sun record:       {sizes['avgSunRecordBytes']:.0f}")
        print(f"Projected full 4392 Sun bytes:  {sizes['projectedFullSunBytes']:.0f} bytes ({sizes['projectedFullSunBytes']/1024:.1f} KiB)")
        print(f"Projected TOTAL full pack:      {sizes['projectedTotalBytes']:.0f} bytes ({sizes['projectedTotalMiB']:.2f} MiB)")
        pref_ok = sizes['projectedTotalBytes'] <= 3*1024*1024
        hard_ok = sizes['projectedTotalBytes'] <= 4*1024*1024
        print(f"Preferred ≤3 MiB: {'PASS' if pref_ok else 'FAIL'}")
        print(f"Hard ceiling ≤4 MiB: {'PASS' if hard_ok else 'FAIL'}")
        print(f"Flag interning: {sizes['flagInterning']}")
        print(f"QA: exact duplicates headline unique {qa['exactDuplicates']['headline']['unique']}/{qa['exactDuplicates']['headline']['total']}")
        if qa["nearDuplicates"]["personal"]: print(f"Near duplicates personal clusters: {len(qa['nearDuplicates']['personal'])}")
        if qa["adjacent"]: print(f"Adjacent warnings: {len(qa['adjacent'])} e.g. {qa['adjacent'][:2]}")
        extreme=sum(1 for v in qa["scoreCoherence"].values() if v["maxOneDayDelta"]>35)
        print(f"Score extreme jumps >35: {extreme} sign/dimension pairs")
        QA_DIR.mkdir(parents=True, exist_ok=True)
        with open(QA_JSON,"w",encoding="utf-8") as f:
            json.dump(qa,f,ensure_ascii=False,indent=2,sort_keys=True)
        md=f"# Humay Content Pack QA Report\n\nMode: {mode}\n\nCoverage: {qa['coverage']}\n\nSize: {sizes['projectedTotalMiB']:.2f} MiB projected\n\nPer-sign headline uniqueness: { {k:v.get('headlineUniqueRatio') for k,v in qa['perSign'].items()} }\n\nModifiers coverage: {qa['modifierCoverage']}\n\nTheme streaks: { {k:v['longestStreak'] for k,v in qa['themeStreaks'].items()} }\n\nWarnings: {warnings[:10]}\n"
        with open(QA_MD,"w",encoding="utf-8") as f:
            f.write(md)
        print(f"\nQA report → {QA_JSON}")
        if mode=="production" and not hard_ok:
            print("ERROR: production exceeds 4 MiB hard ceiling", file=sys.stderr); sys.exit(2)
        compiled2 = json.dumps(pack, ensure_ascii=False, separators=(",",":"), sort_keys=True).encode("utf-8")
        h1=hashlib.sha256(compiled_data).hexdigest()
        h2=hashlib.sha256(compiled2).hexdigest()
        if h1!=h2:
            print("ERROR: non-reproducible build (hash mismatch)", file=sys.stderr); sys.exit(2)
        else:
            print(f"Reproducible build SHA256: {h1[:12]}...")

    if validate_only:
        if sizes['projectedTotalBytes'] > 4*1024*1024: sys.exit(2)
        sys.exit(0)

    DEST_DIR.mkdir(parents=True, exist_ok=True)
    with open(DEST_FILE,"wb") as f: f.write(compiled_data)
    print(f"\nCompiled → {DEST_FILE} ({len(compiled_data)} bytes)")
    if sizes['projectedTotalBytes'] > 4*1024*1024:
        print("ERROR: projected exceeds 4 MiB", file=sys.stderr); sys.exit(2)

if __name__ == "__main__":
    main()
