#!/usr/bin/env python3
"""
Humay Content Pack compiler/validator — stdlib only.

Reads source JSON from Tools/ContentPack/source/, validates, and emits
compiled minified bundle to Humay/Resources/ContentPacks/v1/contentPack.json.

Usage:
  python3 Tools/ContentPack/compile/compile.py [--validate] [--report]
  --validate  only validate, don't write
  --report    print size breakdown (implied when compiling)
"""
import json
import sys
import pathlib
import re
from datetime import datetime, timezone

ROOT = pathlib.Path(__file__).resolve().parents[3]
SOURCE = ROOT / "Tools" / "ContentPack" / "source"
DEST_DIR = ROOT / "Humay" / "Resources" / "ContentPacks" / "v1"
DEST_FILE = DEST_DIR / "contentPack.json"

SIGNS = ["aries","taurus","gemini","cancer","leo","virgo","libra","scorpio","sagittarius","capricorn","aquarius","pisces"]
DIMENSIONS = ["overall","romance","social","career","energy","confidence","patience","chaos"]
ARCHETYPE_IDS = [
    "unmovable-romantic","chaotic-diplomat","quiet-storm","main-character-off-duty",
    "overthinking-oracle","sunshine-menace","elegant-chaos","reluctant-leader",
    "soft-realist","midnight-strategist","charming-skeptic","dramatic-stabilizer"
]

MAX = {
    "headline": 120,
    "reading": 600,
    "flag": 140,
    "summary": 280,
    "tag": 40,
    "moonFragment": 180,
    "risingFragment": 180,
    "archetypeFragment": 160,
}

def load_json(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)

def validate_daykey(k):
    if not re.match(r"^\d{2}-\d{2}$", k):
        return False
    try:
        m,d = map(int, k.split("-"))
        if not 1 <= m <= 12:
            return False
        mdays = {2:29,4:30,6:30,9:30,11:30}
        maxd = mdays.get(m,31)
        return 1 <= d <= maxd
    except: return False

errors = []

def err(msg):
    errors.append(msg)
    print(f"ERROR: {msg}", file=sys.stderr)

def warn(msg):
    print(f"WARN: {msg}", file=sys.stderr)

def validate_manifest(m):
    required = ["packVersion","language","contentCycleVersion","coverage","provenance"]
    for k in required:
        if k not in m:
            err(f"manifest missing {k}")
    cov = m.get("coverage",{})
    for k in ["dayKeyCount","isPilot","includesLeapDay","sunRecordCount"]:
        if k not in cov:
            err(f"manifest.coverage missing {k}")
    prov = m.get("provenance",{})
    for k in ["sourceModel","promptVersion","contentLanguage"]:
        if k not in prov:
            err(f"manifest.provenance missing {k}")
    sv = m.get("schemaVersion",1)
    if sv != 1:
        err(f"unsupported schemaVersion {sv}")

def validate_sun_records(records):
    seen=set()
    headlines=[]
    for i,r in enumerate(records):
        prefix=f"sunRecords[{i}]"
        dk=r.get("dayKey","")
        if not dk or not validate_daykey(dk):
            err(f"{prefix} invalid dayKey {dk!r}")
        sign=r.get("sunSign","")
        if sign not in SIGNS:
            err(f"{prefix} invalid sunSign {sign!r}")
        key=f"{dk}|{sign}"
        if key in seen:
            err(f"{prefix} duplicate {key}")
        seen.add(key)
        scores=r.get("scores",{})
        for dim in DIMENSIONS:
            if dim not in scores:
                err(f"{prefix} missing dimension {dim}")
            else:
                v=scores[dim]
                if not isinstance(v,int) or not 0 <= v <= 100:
                    err(f"{prefix} score {dim}={v} invalid")
        for field, maxlen in [("headline",MAX["headline"]),("personal",MAX["reading"]),("love",MAX["reading"]),("career",MAX["reading"]),("social",MAX["reading"]),("greenFlag",MAX["flag"]),("redFlag",MAX["flag"])]:
            t=r.get(field,"")
            if not isinstance(t,str) or not t.strip():
                err(f"{prefix} empty {field}")
            elif len(t) > maxlen:
                err(f"{prefix} {field} too long {len(t)}>{maxlen}")
        if "summary" in r and r["summary"] is not None:
            if len(r["summary"]) > MAX["summary"]:
                err(f"{prefix} summary too long")
        headlines.append(r.get("headline",""))
    # repetition QA
    if len(headlines) >= 8:
        norm=[re.sub(r"[^a-z0-9 ]","",h.lower()) for h in headlines]
        uniq=len(set(norm))
        ratio=uniq/max(1,len(norm))
        if ratio < 0.6:
            warn(f"Headline repetition: {uniq}/{len(norm)} unique (ratio {ratio:.2f} < 0.60)")
        # duplicate reading check
        from collections import Counter
        c=Counter(norm)
        dups=[k for k,v in c.items() if v>1]
        if dups:
            warn(f"Duplicate headlines: {dups[:5]}")

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
        if frag is not None and len(frag)>MAX["moonFragment"]:
            err(f"moonModifiers[{i}] fragment too long")

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
        if frag is not None and len(frag)>MAX["risingFragment"]:
            err(f"risingModifiers[{i}] fragment too long")

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
        if frag is not None and len(frag)>MAX["archetypeFragment"]:
            err(f"archetypeModifiers[{i}] fragment too long")

def compute_sizes(source_bytes, compiled_bytes, sun_records):
    # estimate full pack: 4392 Sun records
    FULL_COUNT = 4392
    pilot_count = len(sun_records)
    avg = compiled_bytes / max(1, pilot_count) if pilot_count else 0
    # static modifiers/copy size approx
    # We measure compiled_bytes includes everything; to get per-record we assume modifiers fixed
    # For projection, compute sun portion: sunRecords bytes portion
    sun_json = json.dumps(sun_records, ensure_ascii=False, separators=(",",":"))
    sun_bytes = len(sun_json.encode("utf-8"))
    modifier_bytes = compiled_bytes - sun_bytes  # rough
    # Actually compiled includes manifest etc., so approximate
    avg_sun = sun_bytes / max(1, pilot_count)
    projected_sun = avg_sun * FULL_COUNT
    projected_total = projected_sun + max(0, modifier_bytes) + 4096 # manifest overhead
    return {
        "sourceBytes": source_bytes,
        "compiledBytes": compiled_bytes,
        "sunBytes": sun_bytes,
        "modifierBytes": max(0, modifier_bytes),
        "avgSunRecordBytes": avg_sun,
        "projectedFullSunBytes": projected_sun,
        "projectedTotalBytes": projected_total,
        "projectedTotalMiB": projected_total / (1024*1024),
    }

def main():
    validate_only = "--validate" in sys.argv
    report = "--report" in sys.argv or not validate_only

    if not SOURCE.exists():
        print(f"Source dir not found: {SOURCE}", file=sys.stderr)
        sys.exit(1)

    # Load source pieces
    manifest_path = SOURCE / "manifest.json"
    sun_path = SOURCE / "sunBase.json"
    # support sunBase directory as alternative
    sun_records = []
    if sun_path.exists():
        sun_records = load_json(sun_path)
    else:
        # collect Sun/*.json
        for p in (SOURCE / "sunBase").glob("*.json") if (SOURCE / "sunBase").exists() else []:
            arr = load_json(p)
            if isinstance(arr, list): sun_records.extend(arr)
            else: sun_records.append(arr)

    manifest = load_json(manifest_path) if manifest_path.exists() else {}
    moon_mods = load_json(SOURCE / "moonModifiers.json") if (SOURCE / "moonModifiers.json").exists() else []
    rising_mods = load_json(SOURCE / "risingModifiers.json") if (SOURCE / "risingModifiers.json").exists() else []
    arch_mods = load_json(SOURCE / "archetypeModifiers.json") if (SOURCE / "archetypeModifiers.json").exists() else []
    copy_pools = load_json(SOURCE / "copyPools.json") if (SOURCE / "copyPools.json").exists() else None

    # Validate
    validate_manifest(manifest)
    validate_sun_records(sun_records)
    validate_moon(moon_mods)
    validate_rising(rising_mods)
    validate_archetype(arch_mods)

    if errors:
        print(f"\nValidation failed with {len(errors)} error(s).", file=sys.stderr)
        sys.exit(1)
    else:
        print("Validation passed.")

    # Build compiled pack (deterministic key order, minified)
    # Enrich manifest with compilerVersion etc.
    compiled_manifest = dict(manifest)
    compiled_manifest["schemaVersion"] = 1
    compiled_manifest["compilerVersion"] = "humay-pack-compiler-v1"
    if "createdAt" not in compiled_manifest:
        compiled_manifest["createdAt"] = datetime.now(timezone.utc).isoformat().replace("+00:00","Z")
    # Ensure coverage counts match
    cov = compiled_manifest.get("coverage", {})
    cov["sunRecordCount"] = len(sun_records)
    # dayKeyCount: distinct keys
    distinct_keys = len(set(r.get("dayKey") for r in sun_records))
    cov["dayKeyCount"] = distinct_keys
    compiled_manifest["coverage"] = cov

    # Compact transform for bundled size: short keys + score deltas as ordered arrays
    ORDER = ["overall","romance","social","career","energy","confidence","patience","chaos"]
    def compact_scores(d): return [d.get(k,50) for k in ORDER]
    def compact_deltas(d): return [d.get(k,0) for k in ORDER]
    compact_sun = []
    for r in sorted(sun_records, key=lambda r: (r["dayKey"], r["sunSign"])):
        cr = {
            "k": r["dayKey"],
            "s": r["sunSign"],
            "sc": compact_scores(r["scores"]),
            "h": r["headline"],
            "p": r["personal"],
            "l": r["love"],
            "c": r["career"],
            "so": r["social"],
            "g": r["greenFlag"],
            "r": r["redFlag"],
        }
        if r.get("tags"): cr["t"] = r["tags"]
        if r.get("summary"): cr["su"] = r["summary"]
        if r.get("influenceWeight") is not None: cr["w"] = r["influenceWeight"]
        compact_sun.append(cr)
    compact_moon = []
    for m in sorted(moon_mods, key=lambda m: m["moonSign"]):
        cr = {"m": m["moonSign"], "d": compact_deltas(m.get("deltas",{}))}
        if m.get("emotionalFragment"): cr["f"] = m["emotionalFragment"]
        if m.get("affinityTags"): cr["at"] = m["affinityTags"]
        compact_moon.append(cr)
    compact_rising = []
    for m in sorted(rising_mods, key=lambda m: m["risingSign"]):
        cr = {"rs": m["risingSign"], "d": compact_deltas(m.get("deltas",{}))}
        if m.get("outwardFragment"): cr["f"] = m["outwardFragment"]
        if m.get("affinityTags"): cr["at"] = m["affinityTags"]
        compact_rising.append(cr)
    compact_arch = []
    for m in sorted(arch_mods, key=lambda m: m["archetypeID"]):
        cr = {"a": m["archetypeID"], "d": compact_deltas(m.get("deltas",{}))}
        if m.get("fragment"): cr["f"] = m["fragment"]
        if m.get("preferredTags"): cr["pt"] = m["preferredTags"]
        compact_arch.append(cr)

    pack = {
        "manifest": compiled_manifest,
        "sunRecords": compact_sun,
        "moonModifiers": compact_moon,
        "risingModifiers": compact_rising,
        "archetypeModifiers": compact_arch,
    }
    if copy_pools is not None:
        pack["copyPools"] = copy_pools

    # Serialize compiled
    compiled_data = json.dumps(pack, ensure_ascii=False, separators=(",",":"), sort_keys=True).encode("utf-8")
    # Source bytes: sum of raw source files
    source_bytes = 0
    for p in SOURCE.rglob("*.json"):
        source_bytes += p.stat().st_size

    # Compute sizes using compact representation
    compact_for_size = [json.dumps(r, ensure_ascii=False, separators=(",",":")) for r in compact_sun]
    compact_sun_bytes = sum(len(s.encode("utf-8")) for s in compact_for_size)
    # recompute sizes with compact average
    avg_compact = compact_sun_bytes / max(1, len(compact_sun))
    projected_sun_compact = avg_compact * 4392
    # modifiers/copy overhead is compiled total minus compact sun + overhead adjustment
    raw_sizes = compute_sizes(source_bytes, len(compiled_data), sun_records)
    # override with compact-aware projection
    sizes = dict(raw_sizes)
    sizes["avgSunRecordBytes"] = avg_compact
    sizes["projectedFullSunBytes"] = projected_sun_compact
    sizes["projectedTotalBytes"] = projected_sun_compact + sizes["modifierBytes"] + 4096
    sizes["projectedTotalMiB"] = sizes["projectedTotalBytes"] / (1024*1024)
    # Enforce duplication QA already done above (warn only)
    # Report
    if report:
        print("\n— Size report —")
        print(f"Source pilot size:              {sizes['sourceBytes']} bytes ({sizes['sourceBytes']/1024:.1f} KiB)")
        print(f"Compiled pilot size:            {sizes['compiledBytes']} bytes ({sizes['compiledBytes']/1024:.1f} KiB)")
        print(f"  Sun records bytes:            {sizes['sunBytes']} bytes")
        print(f"  Modifiers/copy overhead:      {sizes['modifierBytes']} bytes")
        print(f"Avg bytes per Sun record:       {sizes['avgSunRecordBytes']:.0f}")
        print(f"Projected full 4392 Sun bytes:  {sizes['projectedFullSunBytes']:.0f} bytes ({sizes['projectedFullSunBytes']/1024:.1f} KiB)")
        print(f"Projected TOTAL full pack:      {sizes['projectedTotalBytes']:.0f} bytes ({sizes['projectedTotalMiB']:.2f} MiB)")
        target_ok = sizes['projectedTotalBytes'] <= 3*1024*1024
        pref_ok = sizes['projectedTotalBytes'] <= 2*1024*1024
        print(f"Target ≤2 MiB: {'PASS' if pref_ok else 'FAIL'}")
        print(f"Ceiling ≤3 MiB: {'PASS' if target_ok else 'FAIL'}")
        if not target_ok:
            print("ERROR: projected pack exceeds 3 MiB ceiling — redesign schema.", file=sys.stderr)
            # still fail
            if not validate_only:
                # don't write if exceeds ceiling? Still write but exit non-zero
                pass

    if validate_only:
        # check ceiling
        if report and sizes['projectedTotalBytes'] > 3*1024*1024:
            sys.exit(2)
        sys.exit(0)

    # Write compiled
    DEST_DIR.mkdir(parents=True, exist_ok=True)
    with open(DEST_FILE, "wb") as f:
        f.write(compiled_data)
    # also write pretty manifest for inspection
    print(f"\nCompiled → {DEST_FILE} ({len(compiled_data)} bytes)")
    if sizes['projectedTotalBytes'] > 3*1024*1024:
        print("ERROR: projected exceeds 3 MiB", file=sys.stderr)
        sys.exit(2)
    if sizes['projectedTotalBytes'] > 2*1024*1024:
        warn("Projected exceeds 2 MiB preferred target")

if __name__ == "__main__":
    main()
