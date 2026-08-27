#!/usr/bin/env python3
"""
Deterministic Content Score Plan generator (Phase I.1 foundation for Phase J).

Produces a coherent 366×12 skeleton that Phase J will feed to the writing model:
  STEP1: coherent daily score/theme skeleton (this tool)
  STEP2: AI writes prose consistent with those values
  STEP3: validation + QA

This is NOT astronomical prediction. It is Humay-original entertainment scaffolding.
Sun/Moon/Rising remain the deterministic astrology identity inputs; the score plan
is the editorial arc for the year.

Usage:
  python3 Tools/ContentPack/compile/generate_score_plan.py [--output path] [--seed v1]
  --mode pilot       -> 14 days x 12 (demo)
  --mode production  -> 366 days x 12 (full, not generated in I.1)
  --check            -> validate existing file only

All scores 0...100, temporal coherence via waves/arcs, no random hash, stable SHA256 seed.
"""
import json, pathlib, hashlib, argparse, math, sys

ROOT = pathlib.Path(__file__).resolve().parents[3]
SIGNS = ["aries","taurus","gemini","cancer","leo","virgo","libra","scorpio","sagittarius","capricorn","aquarius","pisces"]
THEMES = ["romance","career","social","confidence","patience","energy","chaos","reset","boundaries","communication","focus"]
DIMENSIONS = ["overall","romance","social","career","energy","confidence","patience","chaos"]

def stable_int(key: str) -> int:
    return int(hashlib.sha256(key.encode()).hexdigest()[:16], 16)

def all_keys():
    keys=[]
    for m in range(1,13):
        mdays = {2:29,4:30,6:30,9:30,11:30}.get(m,31)
        for d in range(1,mdays+1):
            keys.append(f"{m:02d}-{d:02d}")
    return keys

def seasonal_arc(day_index: int, sign: str, dim: str, version: str) -> int:
    # Coherent waves with sign-specific phase offsets
    seed = stable_int(f"{version}|{sign}|{dim}") % 1000 / 1000.0  # 0..1
    phase = seed * 2 * math.pi
    # Primary seasonal wave (~ 45-70 day period)
    period = 40 + (stable_int(f"{sign}|{dim}|period") % 30)  # 40..70
    wave = math.sin(phase + day_index / period * 2 * math.pi) * 18
    # Secondary slower wave (~ 120-180 days)
    period2 = 120 + (stable_int(f"{sign}|{dim}|period2") % 60)
    wave2 = math.sin(phase*1.7 + day_index / period2 * 2 * math.pi) * 10
    # Small jitter
    jitter = (stable_int(f"{version}|{sign}|{dim}|{day_index}") % 11) -5  # -5..5
    base = 55 + wave + wave2 + jitter
    # Ensure romance/career have distinct arcs not just copy
    if dim == "chaos":
        # inversely related to patience with extra jitter
        pass
    clamped = max(12, min(94, int(round(base))))
    return clamped

def build_scores(day_index: int, sign: str, version: str):
    scores={}
    for dim in DIMENSIONS:
        if dim == "overall":
            continue
        if dim == "chaos":
            # chaos opposite patience + weather
            patience = scores.get("patience") or seasonal_arc(day_index, sign, "patience", version)
            chaos_raw = 100 - patience + (stable_int(f"{version}|{sign}|chaos|{day_index}") % 7) -3 + math.sin(day_index/19*2*math.pi)*6
            scores[dim]= max(8, min(92, int(round(chaos_raw))))
        else:
            scores[dim]= seasonal_arc(day_index, sign, dim, version)
    # overall weighted
    energy=scores["energy"]; social=scores["social"]; career=scores["career"]; romance=scores["romance"]; conf=scores["confidence"]; pat=scores["patience"]; chaos_inv=100-scores["chaos"]
    weighted = energy*0.9 + social*0.8 + career*0.8 + romance*0.9 + conf + pat*0.6 + chaos_inv*0.5
    overall = int(weighted/5.5) + (stable_int(f"{version}|{sign}|overall|{day_index}")%9)-4
    scores["overall"]= max(10, min(95, overall))
    return scores

def dominant_themes(scores):
    # Top 2 dimensions -> themes
    sorted_dims = sorted([d for d in THEMES if d in DIMENSIONS or d in scores], key=lambda d: scores.get(d, 50), reverse=True)
    # But ensure we map dimensions to themes where needed; simple: use dimension names directly
    # Prefer romance/career/social/confidence etc
    # Rank by actual scores
    ranked = sorted(DIMENSIONS, key=lambda d: scores[d], reverse=True)
    primary = ranked[0]
    secondary = ranked[1] if len(ranked)>1 else ranked[0]
    # Map overall -> focus if top is overall (rare)
    if primary=="overall": primary="focus"
    if secondary=="overall": secondary="reset"
    return primary, secondary

def tone_hints(scores):
    hints=[]
    if scores["confidence"]>=75: hints.append("high social confidence")
    elif scores["confidence"]<=30: hints.append("low confidence")
    if scores["patience"]<=30: hints.append("low patience")
    elif scores["patience"]>=75: hints.append("steady patience")
    if scores["chaos"]>=70: hints.append("high chaos")
    if scores["romance"]>=75: hints.append("romance forward")
    if scores["career"]>=75: hints.append("career momentum")
    return hints[:2] if hints else ["even keel"]

def generate(version="cycle-2027-v1", mode="pilot"):
    keys = all_keys() if mode=="production" else [f"03-{d:02d}" for d in range(1,15)]
    plan=[]
    for idx, day_key in enumerate(keys):
        for sign in SIGNS:
            scores=build_scores(idx, sign, version)
            primary, secondary = dominant_themes(scores)
            hints=tone_hints(scores)
            plan.append({
                "dayKey": day_key,
                "sunSign": sign,
                "plan": {
                    "primaryTheme": primary,
                    "secondaryTheme": secondary,
                    "scores": scores,
                    "toneHints": hints
                }
            })
    return plan

def validate(plan):
    for entry in plan:
        scores=entry["plan"]["scores"]
        for dim in DIMENSIONS:
            if dim not in scores: return False, f"missing {dim}"
            v=scores[dim]
            if not 0 <= v <= 100: return False, f"{dim} {v} out of range"
    return True, "ok"

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument("--output", type=str, default=None, help="output JSON path")
    parser.add_argument("--seed", type=str, default="cycle-2027-v1", help="contentCycleVersion as stable seed")
    parser.add_argument("--mode", choices=["pilot","production"], default="pilot")
    parser.add_argument("--check", action="store_true", help="validate existing file")
    args=parser.parse_args()

    if args.check:
        # locate existing
        candidates=[ROOT/"Tools"/"ContentPack"/"source"/"scorePlan.json", ROOT/"Tools"/"ContentPack"/"source"/"scorePlan.pilot.json"]
        path=None
        for c in candidates:
            if c.exists():
                path=c; break
        if not path:
            print("No scorePlan found to check", file=sys.stderr); sys.exit(1)
        data=json.loads(path.read_text(encoding="utf-8"))
        ok,msg=validate(data)
        print(f"Score plan {path}: {msg} ({len(data)} entries)")
        sys.exit(0 if ok else 1)

    plan=generate(version=args.seed, mode=args.mode)
    ok,msg=validate(plan)
    if not ok:
        print(f"Validation failed: {msg}", file=sys.stderr); sys.exit(1)

    out = pathlib.Path(args.output) if args.output else (ROOT / "Tools" / "ContentPack" / "source" / ("scorePlan.json" if args.mode=="production" else "scorePlan.pilot.json"))
    out.parent.mkdir(parents=True, exist_ok=True)
    with open(out,"w",encoding="utf-8") as f:
        json.dump(plan,f,ensure_ascii=False,indent=2,sort_keys=True)
    print(f"Wrote score plan {len(plan)} entries ({args.mode}) → {out}")
    # deterministic check
    plan2=generate(version=args.seed, mode=args.mode)
    h1=hashlib.sha256(json.dumps(plan, sort_keys=True).encode()).hexdigest()[:12]
    h2=hashlib.sha256(json.dumps(plan2, sort_keys=True).encode()).hexdigest()[:12]
    if h1!=h2:
        print("ERROR: non-deterministic generation", file=sys.stderr); sys.exit(2)
    print(f"Deterministic SHA: {h1}")

if __name__=="__main__":
    main()
