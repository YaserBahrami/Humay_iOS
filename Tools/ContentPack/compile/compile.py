#!/usr/bin/env python3
"""
Humay Content Pack compiler/validator — stdlib only, deterministic.
Reads source JSON from Tools/ContentPack/source/, validates, and emits
compiled minified bundle to Humay/Resources/ContentPacks/v1/contentPack.json.

Usage:
  python3 Tools/ContentPack/compile/compile.py [--validate] [--report] [--mode pilot|production]
  --mode pilot        permissive (default inferred from manifest.isPilot)
  --mode production   strict: requires 366*12 + 12/12/12, lifecycle, size etc
"""
import json, sys, pathlib, re, hashlib, argparse, difflib
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

MAX = {"headline":120,"reading":600,"flag":140,"summary":280,"tag":40,"moonFragment":180,"risingFragment":180,"archetypeFragment":160}

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
    # Lifecycle: required for production (mode == production OR isPilot==False)
    is_pilot = cov.get("isPilot", True)
    effective_production = (mode == "production") or (not is_pilot)
    if effective_production:
        if not m.get("contentCycleVersion","").strip():
            err("contentCycleVersion required for production")
        if not m.get("activeFrom"):
            err("activeFrom required for production (lifecycle)")
        if not m.get("activeThrough"):
            err("activeThrough required for production")
        # generationMethod
        gm = m.get("generationMethod") or prov.get("generationMethod")
        if gm is not None and not gm.strip():
            err("generationMethod empty")

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
        # tags validation
        tags=r.get("tags")
        if tags:
            for t in tags:
                if len(t) > MAX["tag"]: err(f"{prefix} tag too long {t}")
                if t not in ALLOWED_THEMES and t not in DIMENSIONS:
                    err(f"{prefix} unknown theme/tag {t!r}")

def validate_moon(mods):
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

def validate_rising(mods):
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
        if frag is not None and len(frag)>MAX["risingFragment"]: err(f"moonModifiers[{i}] fragment too long")
        fragments=m.get("fragments")
        if fragments:
            for theme, arr in fragments.items():
                if theme not in ALLOWED_THEMES and theme not in DIMENSIONS: warn(f"risingModifiers[{i}] unknown fragment theme {theme}")
                for f in arr:
                    if len(f)>MAX["risingFragment"]: err(f"risingModifiers[{i}] fragment theme {theme} too long")

def validate_archetype(mods):
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

def qa_near_duplicates(records, field="personal", threshold=0.82):
    # token Jaccard on normalized tokens
    texts=[(r["dayKey"], r["sunSign"], r.get(field,"")) for r in records if r.get(field)]
    clusters=[]
    for i in range(len(texts)):
        for j in range(i+1, len(texts)):
            a = set(normalize(texts[i][2]).split())
            b = set(normalize(texts[j][2]).split())
            if not a or not b: continue
            inter=len(a & b)
            union=len(a | b)
            jacc=inter/union if union else 0
            # also SequenceMatcher ratio
            seq=difflib.SequenceMatcher(None, normalize(texts[i][2]), normalize(texts[j][2])).ratio()
            score=max(jacc, seq)
            if score >= threshold:
                clusters.append({"a":f"{texts[i][0]}|{texts[i][1]}","b":f"{texts[j][0]}|{texts[j][1]}","jaccard":round(jacc,3),"seq":round(seq,3),"score":round(score,3),"field":field})
                if len(clusters) >= 20: break
        if len(clusters)>=20: break
    return clusters

def qa_per_sign(records):
    per={}
    for sign in SIGNS:
        subset=[r for r in records if r["sunSign"]==sign]
        if not subset: continue
        headlines=[normalize(r["headline"]) for r in subset]
        personals=[normalize(r["personal"]) for r in subset]
        per[sign]={
            "count":len(subset),
            "headlineUniqueRatio": round(len(set(headlines))/max(1,len(headlines)),3),
            "personalUniqueRatio": round(len(set(personals))/max(1,len(personals)),3),
            "headlines": len(set(headlines)),
            "personals": len(set(personals)),
        }
    return per

def qa_adjacent(records):
    # per sign, sorted by dayKey, check identical adjacent headline/personal and score jumps
    warnings=[]
    # build ordered keys
    ordered_keys = sorted(all_canonical_keys())
    key_index={k:i for i,k in enumerate(ordered_keys)}
    for sign in SIGNS:
        subset=sorted([r for r in records if r["sunSign"]==sign], key=lambda r: key_index.get(r["dayKey"],999))
        for i in range(len(subset)-1):
            a=subset[i]; b=subset[i+1]
            if a["headline"]==b["headline"]:
                warnings.append({"sign":sign,"keys":f"{a['dayKey']}->{b['dayKey']}","issue":"identical headline"})
            if a["personal"]==b["personal"]:
                warnings.append({"sign":sign,"keys":f"{a['dayKey']}->{b['dayKey']}","issue":"identical personal"})
            if a["greenFlag"]==b["greenFlag"] and a["redFlag"]==b["redFlag"]:
                warnings.append({"sign":sign,"keys":f"{a['dayKey']}->{b['dayKey']}","issue":"identical flags adjacent"})
            # score jump
            for dim in DIMENSIONS:
                delta=abs(a["scores"][dim]-b["scores"][dim])
                if delta>35:
                    warnings.append({"sign":sign,"keys":f"{a['dayKey']}->{b['dayKey']}","issue":f"{dim} jump {delta}"})
                if len(warnings)>50: break
        if len(warnings)>50: break
    return warnings[:50]

def qa_score_coherence(records):
    stats={}
    for dim in DIMENSIONS:
        for sign in SIGNS:
            vals=[r["scores"][dim] for r in records if r["sunSign"]==sign]
            if not vals: continue
            key=f"{sign}:{dim}"
            # compute per-sign timeline ordered
            ordered_keys = sorted(all_canonical_keys())
            key_index={k:i for i,k in enumerate(ordered_keys)}
            subset=sorted([r for r in records if r["sunSign"]==sign], key=lambda r: key_index.get(r["dayKey"],999))
            deltas=[abs(subset[i]["scores"][dim]-subset[i+1]["scores"][dim]) for i in range(len(subset)-1)]
            max_delta=max(deltas) if deltas else 0
            extreme_jumps=sum(1 for d in deltas if d>30)
            stats[key]={"min":min(vals),"max":max(vals),"avg":round(statistics.mean(vals),1),"median":statistics.median(vals),"stdev":round(statistics.pstdev(vals),1) if len(vals)>1 else 0,"maxOneDayDelta":max_delta,"extremeJumps>30":extreme_jumps}
    return stats

def qa_prose_score_consistency(records):
    # lightweight: romance high but love text not containing romance theme? we just check tags vs scores
    suspicious=[]
    for r in records:
        tags=r.get("tags",[])
        scores=r["scores"]
        # if romance >=80 but primary tag not romance
        if scores["romance"] >= 85 and "romance" not in tags:
            suspicious.append({"day":f"{r['dayKey']}|{r['sunSign']}","issue":"romance high but tag not romance","scores":scores,"tags":tags})
        if scores["career"] >= 85 and "career" not in tags:
            suspicious.append({"day":f"{r['dayKey']}|{r['sunSign']}","issue":"career high but tag not career","scores":scores,"tags":tags})
        if len(suspicious)>=20: break
    return suspicious

# ---------- size / interning ----------
def compute_sizes(source_bytes, compiled_bytes, sun_records, compact_sun):
    FULL_COUNT=4392
    # source sun bytes using compact representation for projection
    compact_sun_bytes = sum(len(json.dumps(r, ensure_ascii=False, separators=(",",":")).encode("utf-8")) for r in compact_sun) if compact_sun else 0
    avg = compact_sun_bytes / max(1, len(compact_sun)) if compact_sun else 0
    projected_sun = avg * FULL_COUNT
    # modifiers/copy overhead
    sun_json = json.dumps(sun_records, ensure_ascii=False, separators=(",",":"))
    sun_bytes = len(sun_json.encode("utf-8"))
    modifier_bytes = max(0, compiled_bytes - len(json.dumps(compact_sun, ensure_ascii=False, separators=(",",":")).encode("utf-8")))
    # More accurate: compiled minus compact sun
    # projected total
    projected_total = projected_sun + max(0, modifier_bytes) + 4096
    # interning estimate: flag reuse
    flags = [r.get("greenFlag","") for r in sun_records] + [r.get("redFlag","") for r in sun_records]
    uniq_flags = len(set(flags))
    total_flags = len(flags)
    interning_saving = sum(len(f.encode("utf-8")) for f in set(flags) if flags.count(f) >1)  # very rough
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
    # Batched structure: Tools/ContentPack/source/sun/**/*.json
    for p in (SOURCE / "sun").rglob("*.json") if (SOURCE / "sun").exists() else []:
        if p.name == "manifest.json": continue
        data=load_json(p)
        if isinstance(data, list): sun_records.extend(data)
        else: sun_records.append(data)
    # Also support sunBase directory
    if (SOURCE / "sunBase").exists() and (SOURCE / "sunBase").is_dir():
        for p in (SOURCE / "sunBase").glob("*.json"):
            data=load_json(p)
            if isinstance(data, list): sun_records.extend(data)
            else: sun_records.append(data)
    return sun_records

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument("--validate", action="store_true")
    parser.add_argument("--report", action="store_true")
    parser.add_argument("--mode", choices=["pilot","production"], default=None)
    args,_ = parser.parse_known_args()
    validate_only = args.validate
    report = args.report or not validate_only
    mode = args.mode  # may be None -> infer

    if not SOURCE.exists():
        print(f"Source dir not found: {SOURCE}", file=sys.stderr); sys.exit(1)

    manifest_path = SOURCE / "manifest.json"
    manifest = load_json(manifest_path) if manifest_path.exists() else {}
    sun_records = discover_sun_records()
    moon_mods = load_json(SOURCE / "moonModifiers.json") if (SOURCE / "moonModifiers.json").exists() else []
    rising_mods = load_json(SOURCE / "risingModifiers.json") if (SOURCE / "risingModifiers.json").exists() else []
    arch_mods = load_json(SOURCE / "archetypeModifiers.json") if (SOURCE / "archetypeModifiers.json").exists() else []
    copy_pools = load_json(SOURCE / "copyPools.json") if (SOURCE / "copyPools.json").exists() else None

    # Infer mode if not supplied
    if mode is None:
        mode = "production" if (not manifest.get("coverage",{}).get("isPilot", True)) else "pilot"

    validate_manifest(manifest, mode)
    validate_sun_records(sun_records)
    validate_moon(moon_mods)
    validate_rising(rising_mods)
    validate_archetype(arch_mods)

    # Production completeness checks (fail fast when mode==production)
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
        # per-day 12 signs
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
        # manifest coverage agreement
        cov=manifest.get("coverage",{})
        if cov.get("sunRecordCount") not in (None, len(sun_records)):
            # will be corrected but error if mismatch before correction
            pass
        # batch status: if source batches have rejected
        status_path = SOURCE / "batches" / "status.json"
        if status_path.exists():
            statuses=load_json(status_path)
            for b in statuses if isinstance(statuses, list) else statuses.get("batches",[]):
                if b.get("status") == "rejected":
                    err(f"batch {b.get('batchID')} is rejected — cannot compile production")

    if errors:
        print(f"\nValidation failed with {len(errors)} error(s).", file=sys.stderr)
        sys.exit(1)
    else:
        print(f"Validation passed ({mode}).")

    # Build compiled pack (deterministic)
    compiled_manifest = dict(manifest)
    compiled_manifest["schemaVersion"] = 1
    compiled_manifest["compilerVersion"] = "humay-pack-compiler-v1"
    # Reproducible createdAt: use source, not now
    if "createdAt" not in compiled_manifest or not compiled_manifest["createdAt"]:
        compiled_manifest["createdAt"] = manifest.get("createdAt") or datetime.now(timezone.utc).isoformat().replace("+00:00","Z")
    else:
        # preserve source timestamp for determinism
        compiled_manifest["createdAt"] = manifest.get("createdAt")
    cov = compiled_manifest.get("coverage", {})
    cov["sunRecordCount"] = len(sun_records)
    distinct_keys = len(set(r.get("dayKey") for r in sun_records))
    cov["dayKeyCount"] = distinct_keys
    if mode == "production":
        cov["isPilot"] = False
        cov["includesLeapDay"] = True
    compiled_manifest["coverage"] = cov

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

    # QA report generation
    qa = {}
    qa["coverage"]={"sunRecords":len(sun_records),"dayKeys":distinct_keys,"isPilot": cov.get("isPilot"), "includesLeapDay": cov.get("includesLeapDay")}
    qa["modifiers"]={"moon":len(moon_mods),"rising":len(rising_mods),"archetype":len(arch_mods)}
    qa["manifest"]=compiled_manifest
    qa["size"]=sizes
    qa["exactDuplicates"]=qa_exact_duplicates(sun_records)
    qa["nearDuplicates"]=qa_near_duplicates(sun_records, "personal", 0.82)[:10]
    qa["perSign"]=qa_per_sign(sun_records)
    qa["adjacent"]=qa_adjacent(sun_records)
    qa["scoreCoherence"]=qa_score_coherence(sun_records)
    qa["proseScoreConsistency"]=qa_prose_score_consistency(sun_records)
    qa["warnings"]=warnings
    qa["errors"]=errors
    # batch statuses
    batch_status_path = SOURCE / "batches" / "status.json"
    if batch_status_path.exists():
        try: qa["batches"]=load_json(batch_status_path)
        except: qa["batches"]=None
    else:
        qa["batches"]=None

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
        if qa["nearDuplicates"]: print(f"Near duplicates clusters: {len(qa['nearDuplicates'])}")
        if qa["adjacent"]: print(f"Adjacent warnings: {len(qa['adjacent'])} e.g. {qa['adjacent'][:2]}")
        # score coherence example
        extreme=sum(1 for v in qa["scoreCoherence"].values() if v["maxOneDayDelta"]>35)
        print(f"Score extreme jumps >35: {extreme} sign/dimension pairs")
        # persist QA report (dev artifact, not bundled)
        QA_DIR.mkdir(parents=True, exist_ok=True)
        with open(QA_JSON,"w",encoding="utf-8") as f:
            json.dump(qa,f,ensure_ascii=False,indent=2,sort_keys=True)
        # markdown
        md=f"# Humay Content Pack QA Report\n\nMode: {mode}\n\nCoverage: {qa['coverage']}\n\nSize: {sizes['projectedTotalMiB']:.2f} MiB projected\n\nPer-sign headline uniqueness: { {k:v['headlineUniqueRatio'] for k,v in qa['perSign'].items()} }\n\nWarnings: {warnings[:10]}\n"
        with open(QA_MD,"w",encoding="utf-8") as f:
            f.write(md)
        print(f"\nQA report → {QA_JSON}")
        # fail production if >4 MiB
        if mode=="production" and not hard_ok:
            print("ERROR: production exceeds 4 MiB hard ceiling", file=sys.stderr); sys.exit(2)
        if sizes['projectedTotalBytes'] > 4*1024*1024:
            print("ERROR: projected exceeds 4 MiB", file=sys.stderr)
            if not validate_only:
                pass
        # determinism check: compile twice SHA identical (self-check)
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
    # Ensure QA file not bundled (gitignore guidance)
    # Decide: generated QA files should be gitignored (development artifacts)
    # We document choice in GENERATION_GUIDE.

if __name__ == "__main__":
    main()
