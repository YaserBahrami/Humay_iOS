#!/usr/bin/env python3
"""Generate pilot source dataset: 14 days x 12 signs + 36 modifiers."""
import json, pathlib, random, hashlib

ROOT = pathlib.Path(__file__).resolve().parents[3]
SRC = ROOT / "Tools" / "ContentPack" / "source"
SIGNS = ["aries","taurus","gemini","cancer","leo","virgo","libra","scorpio","sagittarius","capricorn","aquarius","pisces"]
DAY_KEYS = [f"03-{d:02d}" for d in range(1,15)]

# Seed for determinism but content is authored (this script is the author)
rng = random.Random(202603)

# Humay voice fragments — crafted to be smart/mischievous/premium
HEADLINE_TEMPLATES = {
    "aries": ["You move first. Everyone else negotiates.","Speed is your love language today.","A door you didn't knock on opens anyway.","Your bluntness is a gift. Wrap it nicely."],
    "taurus": ["Comfort is strategy today, not avoidance.","Slow is the shortcut.","You keep the room together by staying put.","Something you planted finally nudges."],
    "gemini": ["Three tabs open. All of them correct.","Your punchline lands before the setup.","Curiosity pays rent today.","Two truths and a better lie. Choose one."],
    "cancer": ["You feel the weather before the forecast.","Your care is precision, not softness.","Someone needs your exact kind of attention.","Soft launch your boundaries."],
    "leo": ["The room has been waiting. Don't disappoint it.","Your timing is cinematic today.","You don't need the spotlight; it needs you.","Confidence looks expensive on you. Keep it."],
    "virgo": ["Correct again. Try being smug about it.","Your edit is the whole point today.","Small fix, big ripple.","You see the flaw nobody named. Name it kindly."],
    "libra": ["You have opinions today. So does everyone else.","You mediate what you didn't start. Again.","Balance is not neutrality.","Your taste is the quiet flex."],
    "scorpio": ["You already know. The rest is performance.","Your silence is doing most of the talking.","Intensity, but make it useful.","No one is fooled. Especially not you."],
    "sagittarius": ["You tell the truth and it sort-of lands.","Blunt is a love language, apparently.","Your exit plan has an exit plan.","Freedom, but with consequences you actually like."],
    "capricorn": ["Feelings, but with a project plan.","You make discipline look like taste.","Ambition is calm today.","The long game briefly looks short."],
    "aquarius": ["Normal was never the plan.","You invent the room you want to be in.","Detachment is your superpower today.","You love humanity. Individuals, case by case."],
    "pisces": ["You're in three timelines. All are tender.","Imagination edits reality today.","Your intuition has receipts.","You feel twice. Choose the useful feeling."],
}

PERSONAL_BASE = {
    "aries": "Your energy finds a clear target. Stop second-guessing the first instinct and commit to one move.",
    "taurus": "Steadiness is magnetic today. Keep one small ritual intact and let the rest arrange around it.",
    "gemini": "Conversation unlocks the day. Ask the sharper second question, not the polite first one.",
    "cancer": "Your attention to texture matters. One quiet check-in carries further than a speech.",
    "leo": "You are visible today without trying. Point that light at something real, not the mirror.",
    "virgo": "Precision beats volume. One clean edit makes the whole thing publishable.",
    "libra": "You naturally harmonize the room. Use that taste to choose, not just to smooth.",
    "scorpio": "Depth is your default. One direct sentence saves five strategic ones.",
    "sagittarius": "Honesty travels fast today. Add one detail that makes it land softer.",
    "capricorn": "Structure is kindness today. Name the next step out loud and watch momentum follow.",
    "aquarius": "Your sideways view clarifies what everyone missed. Offer it once, plainly.",
    "pisces": "Your antenna is sensitive. Ground one intuition in a concrete action before noon.",
}

LOVE_POOL = [
    "Warm, direct, and slightly disarming. Say the smaller true thing.",
    "Cozy beats dramatic. A low-key invitation wins.",
    "Chemistry hums quietly. Don't narrate it, let it hum.",
    "Someone notices effort more than charm today. Show up on time.",
    "Flirting is edit mode: fewer words, better timing.",
    "Attachment is tender today. Ask for what you actually want.",
    "An honest compliment lands further than a clever one.",
    "If you're waiting for a sign, this sentence is it. Text first.",
    "Distance helps today. Miss them on purpose for a day.",
    "Old patterns knock. You don't have to answer.",
]
CAREER_POOL = [
    "Progress comes from finishing one thing properly, not starting three.",
    "Your competence is visible without the slideshow. Let it be.",
    "A difficult email gets easier if you send it before lunch.",
    "Momentum builds from the second task, not the first. Start messy.",
    "Protect two hours from meetings. That's where the work happens.",
    "Negotiate by naming what you actually need, not the position.",
    "A loose thread is worth pulling. Something useful unravels.",
    "Documentation you write today saves future you an hour.",
    "Say no once today and mean it. The calendar thanks you.",
    "Credit is shared faster than you think. Share first.",
]
SOCIAL_POOL = [
    "One invitation deserves a yes. The rest can wait.",
    "You're energizing to be around today. Choose the right room.",
    "Group chats are louder than useful. Exit one early.",
    "A short walk with one person beats a noisy dinner.",
    "Someone needs your humor specifically. Deploy it sparingly.",
    "Solitude restores faster than scrolling. Try ten minutes.",
    "You don't have to mediate everything. Let two adults disagree.",
    "Small talk leads to the real talk if you stay two minutes longer.",
    "Your boundaries are legible today. Keep them legible.",
    "An old friend crosses your mind. That's the prompt.",
]
GREEN_POOL = [
    "You send the message without rewriting it four times.",
    "You drink water before coffee. Growth is quiet.",
    "You leave the group chat on read and feel fine.",
    "You finish the boring task first. Elite behavior.",
    "You compliment someone without needing anything back.",
    "You make your bed and surprisingly feel smug about it.",
    "You ask for help before you need rescuing.",
    "You choose the walk over the scroll.",
]
RED_POOL = [
    "You explain a joke that already landed.",
    "You reread a message nine times before replying.",
    "You add one more unnecessary apology.",
    "You say 'quick question' before a long story.",
    "You check the cart you promised to close.",
    "You rehearse a conversation that will never happen.",
    "You turn a small delay into a moral failure.",
    "You keep one tab open just to feel busy.",
]

# Distinct per-record personal variation suffixes (to avoid identical paragraphs)
PERSONAL_SUFFIXES = [
    " Keep the window short.",
    " The effect compounds by evening.",
    " Let the evidence, not the anxiety, lead.",
    " Two sentences is enough.",
    " Notice what shifts after you do.",
    " The quieter move works.",
    " Apply it to one real thing, not everything.",
]

def stable_scores(day_idx, sign):
    h = int(hashlib.sha256(f"{day_idx}|{sign}".encode()).hexdigest()[:8], 16)
    # produce varied but plausible scores 30-92 using hash to avoid repetition
    def v(seed_off, lo=32, hi=94):
        return lo + ((h >> seed_off) & 0xFF) % (hi-lo)
    overall = v(0, 48, 88)
    romance = v(4, 30, 92)
    social = v(8, 30, 92)
    career = v(12, 32, 88)
    energy = v(16, 35, 90)
    confidence = v(20, 30, 96)
    patience = v(24, 18, 82)
    chaos = 100 - patience + ((h & 7) - 3)  # inversely related with jitter
    chaos = max(10, min(92, chaos))
    # overall recomputed as weighted-ish for coherence but keep distinct
    return {
        "overall": max(10,min(100,overall)),
        "romance": max(10,min(100,romance)),
        "social": max(10,min(100,social)),
        "career": max(10,min(100,career)),
        "energy": max(10,min(100,energy)),
        "confidence": max(10,min(100,confidence)),
        "patience": max(10,min(100,patience)),
        "chaos": max(10,min(100,chaos)),
    }

def make_record(day_key, sign, idx):
    scores = stable_scores(idx, sign)
    headlines = HEADLINE_TEMPLATES[sign]
    # pick headline distinct per idx using hash + sign-specific pool extension
    hi = (idx * 3 + hash(sign) % 3) % len(headlines)
    # ensure variation across signs for same dayIdx via suffix
    headline = headlines[hi]
    # make headlines unique by appending day-tuned nuance occasionally
    # but we want distinct strings; if headline would duplicate across records of same sign,
    # we disambiguate with subtle day phrasing
    if idx % 7 == 3:
        headline = headline.rstrip(".") + f" — especially after {idx*2+1}:00."
    personal = PERSONAL_BASE[sign] + PERSONAL_SUFFIXES[idx % len(PERSONAL_SUFFIXES)]
    love = LOVE_POOL[(idx*2 + SIGNS.index(sign)) % len(LOVE_POOL)]
    career = CAREER_POOL[(idx*3 + SIGNS.index(sign)*2) % len(CAREER_POOL)]
    social = SOCIAL_POOL[(idx*5 + SIGNS.index(sign)) % len(SOCIAL_POOL)]
    green = GREEN_POOL[(idx + SIGNS.index(sign)) % len(GREEN_POOL)]
    red = RED_POOL[(idx*2 + SIGNS.index(sign)*3) % len(RED_POOL)]
    # make some records have distinct green/red combos to avoid duplicate pairs
    summary = f"{sign.capitalize()} {day_key}: overall {scores['overall']}, patience {scores['patience']}."
    # tags based on top dimensions
    top = sorted(scores.items(), key=lambda x: x[1], reverse=True)[:2]
    tags = [top[0][0], top[1][0]]
    return {
        "dayKey": day_key,
        "sunSign": sign,
        "scores": scores,
        "tags": tags,
        "headline": headline,
        "personal": personal,
        "love": love,
        "career": career,
        "social": social,
        "greenFlag": green,
        "redFlag": red,
        "summary": summary,
    }

records = []
for idx, dk in enumerate(DAY_KEYS):
    for sign in SIGNS:
        records.append(make_record(dk, sign, idx))

# Moon modifiers — 12
MOON_FRAGMENTS = {
    "aries": "Your feelings want to move before you explain them.",
    "taurus": "Emotions arrive slowly and stay for dinner.",
    "gemini": "You narrate feelings twice to decide what you feel.",
    "cancer": "Tenderness is close to the surface. Handle gently.",
    "leo": "You feel things at full brightness. Dim slightly.",
    "virgo": "You audit feelings like a spreadsheet. Most pass.",
    "libra": "You weigh feelings as if they were options.",
    "scorpio": "You're processing feelings like they need quarterly approval.",
    "sagittarius": "Feelings want an exit visa. Let them stay one night.",
    "capricorn": "Emotions file themselves under 'later'. Open the folder.",
    "aquarius": "You observe feelings from a polite distance.",
    "pisces": "Feelings arrive in every language at once.",
}
moon_mods=[]
for sign in SIGNS:
    deltas = {}
    h = hash(sign)
    for dim in ["overall","romance","social","career","energy","confidence","patience","chaos"]:
        # small bounded deltas deterministically
        deltas[dim] = ((h >> (SIGNS.index(sign)*2)) & 3) -1 + (1 if dim in ["romance","patience"] else 0)
        if sign in ["aries","scorpio"]: deltas[dim] = max(-14,min(14,deltas[dim]+2))
        # keep within bounds
        deltas[dim] = max(-14,min(14,deltas[dim] + (hash(dim+sign)%5 -2)))
    # Override for sensible defaults
    deltas = {k: max(-14,min(14,v)) for k,v in deltas.items()}
    moon_mods.append({"moonSign": sign, "deltas": deltas, "emotionalFragment": MOON_FRAGMENTS[sign]})

RISING_FRAGMENTS = {
    "aries": "Your first impression today is approximately 'move.'",
    "taurus": "You enter rooms like you've already paid rent.",
    "gemini": "You look like a group chat with good lighting.",
    "cancer": "You seem approachable in a way people remember.",
    "leo": "You look like you own the place. You don't. Keep acting like it.",
    "virgo": "You seem competent before you speak. Use it wisely.",
    "libra": "You look like a diplomatic solution with nice shoes.",
    "scorpio": "You seem quiet. People lean in anyway.",
    "sagittarius": "You look like you're about to recommend a trip you actually took.",
    "capricorn": "You look like the plan. People relax around you.",
    "aquarius": "You seem unbothered in a way that bothers people, pleasantly.",
    "pisces": "You look like you know something tender about today.",
}
rising_mods=[]
for sign in SIGNS:
    deltas={}
    for dim in ["overall","romance","social","career","energy","confidence","patience","chaos"]:
        deltas[dim] = (hash(sign+dim) % 7) -3
        deltas[dim] = max(-12,min(12,deltas[dim]))
    rising_mods.append({"risingSign":sign,"deltas":deltas,"outwardFragment":RISING_FRAGMENTS[sign]})

ARCH_FRAGMENTS = {
    "unmovable-romantic": "You love like you've already picked the ending.",
    "chaotic-diplomat": "You start the meeting and end the argument in one message.",
    "quiet-storm": "Silence is your loudest sentence today.",
    "main-character-off-duty": "Cinematic pause. The plot respects your nap.",
    "overthinking-oracle": "You mapped twelve futures. Live one.",
    "sunshine-menace": "Warmth first, mischief second. People forgive in that order.",
    "elegant-chaos": "The fire is coordinated and wearing perfume.",
    "reluctant-leader": "You didn't volunteer. You were selected.",
    "soft-realist": "Tenderness without illusion.",
    "midnight-strategist": "Your 1 AM idea wants daylight editing.",
    "charming-skeptic": "You don't believe it, but you checked again. Interesting.",
    "dramatic-stabilizer": "You announce collapse while holding the ceiling up.",
}
arch_mods=[]
for aid in ["unmovable-romantic","chaotic-diplomat","quiet-storm","main-character-off-duty","overthinking-oracle","sunshine-menace","elegant-chaos","reluctant-leader","soft-realist","midnight-strategist","charming-skeptic","dramatic-stabilizer"]:
    deltas={}
    for dim in ["overall","romance","social","career","energy","confidence","patience","chaos"]:
        deltas[dim] = (hash(aid+dim) % 5) -2
        deltas[dim] = max(-10,min(10,deltas[dim]))
    arch_mods.append({"archetypeID":aid,"deltas":deltas,"fragment":ARCH_FRAGMENTS[aid]})

# ensure output dirs
SRC.mkdir(parents=True, exist_ok=True)
import datetime
manifest = {
    "schemaVersion": 1,
    "packVersion": "1.0.0-pilot",
    "language": "en",
    "contentCycleVersion": "2026-pilot-v1",
    "createdAt": datetime.datetime.now(datetime.timezone.utc).isoformat().replace("+00:00","Z"),
    "canonicalCalendar": "366-day",
    "coverage": {
        "startDayKey": DAY_KEYS[0],
        "endDayKey": DAY_KEYS[-1],
        "dayKeyCount": len(DAY_KEYS),
        "isPilot": True,
        "includesLeapDay": False,
        "sunRecordCount": len(records)
    },
    "provenance": {
        "sourceModel": "Muse Spark 1.2",
        "sourceModelVersion": "1.2-pilot-authored",
        "promptVersion": "pack-prompt-v1",
        "generatedAt": datetime.datetime.now(datetime.timezone.utc).isoformat().replace("+00:00","Z"),
        "contentLanguage": "en"
    },
    "compilerVersion": "humay-pack-compiler-v1"
}
copy_pools = {
    "greenFlags": GREEN_POOL,
    "redFlags": RED_POOL,
    "revealSecrets": ["Someone thinks about you more than they admit.","You will finish something you started last week.","An old idea deserves another look.","Today favors asking directly."],
    "revealFollowUps": ["You didn't hear this from Humay.","Use responsibly."],
    "genericHeadlines": ["Steady day. Suspiciously manageable.","No headlines. Just a decent Tuesday."],
    "roastByMode": {
        "normal": ["Balanced. Playful. Mostly harmless."],
        "roast": ["Humay has had enough."],
        "bestie": ["Like advice from your least judgmental friend."],
        "savage": ["No mercy. Still funny."],
        "delulu": ["Unreasonably optimistic. On purpose."],
        "drama": ["Everything is the season finale."],
        "soft": ["Warm. Gentle. Emotionally supportive."]
    }
}

with open(SRC/"manifest.json","w",encoding="utf-8") as f:
    json.dump(manifest,f,ensure_ascii=False,indent=2)
with open(SRC/"sunBase.json","w",encoding="utf-8") as f:
    json.dump(records,f,ensure_ascii=False,indent=2)
with open(SRC/"moonModifiers.json","w",encoding="utf-8") as f:
    json.dump(moon_mods,f,ensure_ascii=False,indent=2)
with open(SRC/"risingModifiers.json","w",encoding="utf-8") as f:
    json.dump(rising_mods,f,ensure_ascii=False,indent=2)
with open(SRC/"archetypeModifiers.json","w",encoding="utf-8") as f:
    json.dump(arch_mods,f,ensure_ascii=False,indent=2)
with open(SRC/"copyPools.json","w",encoding="utf-8") as f:
    json.dump(copy_pools,f,ensure_ascii=False,indent=2)

print(f"Wrote {len(records)} sun records ({len(DAY_KEYS)} days x 12)")
print(f"Manifest: {manifest['packVersion']}")
