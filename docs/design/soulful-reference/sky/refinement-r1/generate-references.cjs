const fs = require("node:fs");
const path = require("node:path");
const sharp = require("sharp");

const out = __dirname;
const newsreaderPath = path.resolve(out, "../../../../../Humay/Resources/Fonts/Newsreader-Variable.ttf");
const cormorantPath = path.resolve(out, "../../../../../Humay/Resources/Fonts/CormorantGaramond-Regular.otf");

for (const required of [newsreaderPath, cormorantPath]) {
  if (!fs.existsSync(required)) throw new Error(`Missing required reference font: ${required}`);
}

const newsreader = fs.readFileSync(newsreaderPath).toString("base64");
const cormorant = fs.readFileSync(cormorantPath).toString("base64");

const themes = {
  light: {
    ground: "#FBF7F1", surface: "#FFFDFC", raised: "#F7F0E8", ink: "#151B28",
    secondary: "#625F62", tertiary: "#837D7C", hairline: "#E7DED6", coral: "#F06F67",
    coralInk: "#A83F3C", peach: "#F7C7B8", lavender: "#9A82C8", lavenderInk: "#684F9D",
    gold: "#D5A253", goldInk: "#80570E", blue: "#6B9FC1", sage: "#678E79",
    hero: "#182131", hero2: "#273249", heroText: "#FFF8F0", heroSub: "#D9D3CE",
    selectedText: "#FFFFFF", tab: "#FFFDF9", tabSelected: "#F4E9E2", shadow: "#35281C"
  },
  dark: {
    ground: "#101725", surface: "#171F30", raised: "#20283A", ink: "#F5F0EA",
    secondary: "#C4BDBB", tertiary: "#A8A0A1", hairline: "#30394B", coral: "#F77476",
    coralInk: "#FF9694", peach: "#F0A79A", lavender: "#C17ADB", lavenderInk: "#D99BEA",
    gold: "#E5AA55", goldInk: "#F0BD6D", blue: "#78B1D5", sage: "#82BDA3",
    hero: "#20283A", hero2: "#352B42", heroText: "#F7F0E8", heroSub: "#D1C6C5",
    selectedText: "#101725", tab: "#20283A", tabSelected: "#3B455C", shadow: "#000000"
  }
};

const escapeText = (value) => String(value)
  .replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll('"', "&quot;");

function shell({ width, height, mode = "light", title, description, body, definitions = "" }) {
  const t = themes[mode];
  return `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}" role="img" aria-labelledby="title description">
  <title id="title">${escapeText(title)}</title>
  <desc id="description">${escapeText(description)}</desc>
  <defs>
    <style>
      @font-face { font-family: NewsreaderRef; src: url(data:font/ttf;base64,${newsreader}) format("truetype"); font-weight: 200 800; }
      @font-face { font-family: CormorantRef; src: url(data:font/otf;base64,${cormorant}) format("opentype"); font-weight: 400; }
      .editorial { font-family: NewsreaderRef, Georgia, serif; font-optical-sizing: auto; }
      .current-editorial { font-family: CormorantRef, Georgia, serif; }
      .ui { font-family: -apple-system, BlinkMacSystemFont, "Helvetica Neue", Arial, sans-serif; }
      .label { font-family: -apple-system, BlinkMacSystemFont, "Helvetica Neue", Arial, sans-serif; font-weight: 700; letter-spacing: 1.1px; }
      text { text-rendering: optimizeLegibility; }
    </style>
    <linearGradient id="hero" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="${t.hero}"/><stop offset="1" stop-color="${t.hero2}"/>
    </linearGradient>
    <linearGradient id="soft" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="${t.peach}" stop-opacity=".34"/><stop offset="1" stop-color="${t.lavender}" stop-opacity=".18"/>
    </linearGradient>
    <filter id="shadow" x="-25%" y="-25%" width="150%" height="175%">
      <feDropShadow dx="0" dy="6" stdDeviation="12" flood-color="${t.shadow}" flood-opacity="${mode === "light" ? ".09" : "0"}"/>
    </filter>
    ${definitions}
  </defs>
  ${body}
</svg>`;
}

function reviewLabel(width, t) {
  return `<text x="${width / 2}" y="15" text-anchor="middle" class="label" font-size="7.5" fill="${t.coralInk}">APPROVED VISUAL REFERENCE · R1</text>`;
}

function statusBar(width, t, device) {
  const phone = device === "phone";
  const right = width - (phone ? 80 : 96);
  return `<g aria-hidden="true">
    <text x="${phone ? 22 : 28}" y="34" class="ui" font-size="${phone ? 14 : 13}" font-weight="700" fill="${t.ink}">${phone ? "9:41" : "9:41  ·  Thu 13 Aug"}</text>
    <g transform="translate(${right} 22)" fill="none" stroke="${t.ink}" stroke-width="1.8" stroke-linecap="round">
      <path d="M0 8h2V6h2v2h2V3h2v5"/><path d="M14 4c3-3 8-3 11 0M17 7c2-2 4-2 6 0"/>
      <rect x="30" y="0" width="24" height="10" rx="3"/><rect x="32" y="2" width="18" height="6" rx="2" fill="${t.ink}" stroke="none"/>
    </g>
  </g>`;
}

function debugNote(x, y, t) {
  return `<g aria-label="Development sample, not calculated">
    <path d="M${x + 2} ${y + 8}l4-4 3 3-4 4m-1 0 5 5" fill="none" stroke="${t.tertiary}" stroke-width="1.3" stroke-linecap="round"/>
    <text x="${x + 18}" y="${y + 12}" class="ui" font-size="10" font-weight="600" fill="${t.tertiary}">Development sample · not calculated</text>
  </g>`;
}

function iconGlyph(type, x, y, t) {
  const back = type === "moon" ? t.gold : type === "ingress" ? t.coral : t.lavender;
  const fill = type === "moon" ? t.goldInk : type === "ingress" ? t.coralInk : t.lavenderInk;
  let mark = "";
  if (type === "moon") {
    mark = `<circle cx="${x - 1}" cy="${y}" r="7.5" fill="${fill}"/><circle cx="${x + 3}" cy="${y - 2}" r="7.5" fill="${t.raised}"/>`;
  } else if (type === "ingress") {
    mark = `<circle cx="${x - 1}" cy="${y + 1}" r="6" fill="none" stroke="${fill}" stroke-width="1.8"/><path d="M${x + 3} ${y - 3}l7-7m-4 0h4v4" fill="none" stroke="${fill}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>`;
  } else {
    mark = `<path d="M${x - 8} ${y + 6}l8-13 8 13Z" fill="none" stroke="${fill}" stroke-width="1.8" stroke-linejoin="round"/>`;
  }
  return `<g aria-hidden="true"><circle cx="${x}" cy="${y}" r="14" fill="${back}" opacity=".13"/>${mark}</g>`;
}

function compactEventRow({ x, y, width, height, type, title, timing, method, summary, chevron = true, font = 14.5 }, t, last = false) {
  const cy = y + height / 2;
  const tx = x + 50;
  const lines = Array.isArray(title) ? title : [title];
  const titleY = y + (lines.length > 1 ? 21 : 23);
  const titleSvg = lines.map((line, i) => `<text x="${tx}" y="${titleY + i * 15}" class="ui" font-size="${font}" font-weight="700" fill="${t.ink}">${escapeText(line)}</text>`).join("");
  const metaY = y + height - 12;
  const methodX = x + width - (chevron ? 30 : 12);
  return `<g aria-label="${escapeText(lines.join(" "))}. ${escapeText(method)}. ${escapeText(timing)}.${summary ? ` ${escapeText(summary)}.` : ""}">
    ${iconGlyph(type, x + 24, cy, t)}
    ${titleSvg}
    ${summary ? `<text x="${tx}" y="${metaY - 15}" class="ui" font-size="10.5" fill="${t.secondary}">${escapeText(summary)}</text>` : ""}
    <text x="${tx}" y="${metaY}" class="ui" font-size="10.5" fill="${t.secondary}" style="font-variant-numeric:tabular-nums">${escapeText(timing)}</text>
    <circle cx="${methodX - 39}" cy="${metaY - 3.5}" r="2.5" fill="${type === "moon" ? t.gold : type === "ingress" ? t.coral : t.lavender}"/>
    <text x="${methodX - 32}" y="${metaY}" class="ui" font-size="9.8" font-weight="650" fill="${t.secondary}" text-anchor="start">${escapeText(method)}</text>
    ${chevron ? `<path d="M${x + width - 12} ${cy - 4}l4 4-4 4" fill="none" stroke="${t.tertiary}" stroke-width="1.5" stroke-linecap="round"/>` : ""}
    ${last ? "" : `<line x1="${tx}" y1="${y + height}" x2="${x + width - 10}" y2="${y + height}" stroke="${t.hairline}"/>`}
  </g>`;
}

function illustrationBody(mode, x = 0, y = 0, scale = 1) {
  const t = themes[mode];
  const moon = mode === "light" ? "#FFF2D9" : t.gold;
  const cutout = mode === "light" ? "#28344B" : "#302A40";
  return `<g transform="translate(${x} ${y}) scale(${scale})" aria-hidden="true">
    <path d="M98 56c32-40 102-48 150-18 42 26 56 78 38 119-19 44-73 69-122 54-54-16-88-74-66-155Z" fill="${t.lavender}" opacity="${mode === "light" ? ".18" : ".20"}"/>
    <path d="M62 161C121 114 225 98 321 124" fill="none" stroke="${t.blue}" stroke-width="8" stroke-linecap="round" opacity=".74"/>
    <path d="M50 173C143 188 244 183 333 147" fill="none" stroke="${t.gold}" stroke-width="5" stroke-linecap="round"/>
    <circle cx="187" cy="112" r="63" fill="${moon}"/>
    <circle cx="216" cy="91" r="67" fill="${cutout}"/>
    <path d="M89 71c3 14 7 18 21 21-14 3-18 7-21 21-3-14-7-18-21-21 14-3 18-7 21-21Z" fill="${t.coral}"/>
    <path d="M303 64c2 9 4 11 13 13-9 2-11 4-13 13-2-9-4-11-13-13 9-2 11-4 13-13Z" fill="${t.gold}"/>
    <circle cx="326" cy="146" r="9" fill="${t.coral}"/>
    <circle cx="72" cy="163" r="7" fill="${t.lavender}"/>
    <path d="M245 185c20-3 39-10 56-20" fill="none" stroke="${t.lavenderInk}" stroke-width="4" stroke-linecap="round" stroke-dasharray="1 13"/>
  </g>`;
}

function illustrationAsset(mode) {
  return shell({
    width: 420, height: 260, mode,
    title: `IllustrationCurrentSky ${mode} approved asset`,
    description: "Transparent flat-vector Lunar Compass asset preview. Symbolic only; it encodes no astronomical position.",
    body: illustrationBody(mode, 10, 12, 1.18)
  });
}

function phoneTab(t, mode) {
  const items = [["Today", 54, "☀"], ["Circle", 134, "●●"], ["Sky", 215, "✦"], ["Chart", 296, "◉"], ["Ask", 376, "▱"]];
  return `<g aria-label="Primary navigation, Sky selected" filter="url(#shadow)">
    <rect x="14" y="838" width="402" height="76" rx="34" fill="${t.tab}" fill-opacity=".97" stroke="${t.hairline}"/>
    <rect x="174" y="844" width="82" height="64" rx="27" fill="${t.tabSelected}"/>
    ${items.map(([label, x, glyph]) => `<text x="${x}" y="871" text-anchor="middle" class="ui" font-size="18" font-weight="700" fill="${label === "Sky" ? t.coral : t.ink}">${glyph}</text><text x="${x}" y="898" text-anchor="middle" class="ui" font-size="10" font-weight="${label === "Sky" ? "750" : "550"}" fill="${label === "Sky" ? t.coralInk : t.ink}">${label}</text>`).join("")}
  </g>`;
}

function iPadTopNav(t) {
  const labels = ["Today", "Circle", "Sky", "Chart", "Ask"];
  return `<g aria-label="Adaptive primary navigation, Sky selected" filter="url(#shadow)">
    <rect x="300" y="48" width="424" height="54" rx="27" fill="${t.surface}" stroke="${t.hairline}"/>
    <rect x="462" y="53" width="84" height="44" rx="22" fill="${t.raised}"/>
    ${labels.map((label, i) => `<text x="${[368, 442, 504, 590, 672][i]}" y="81" text-anchor="middle" class="ui" font-size="15" font-weight="${label === "Sky" ? "750" : "600"}" fill="${label === "Sky" ? t.coralInk : t.ink}">${label}</text>`).join("")}
  </g>`;
}

function currentSkyPhone(mode) {
  const t = themes[mode];
  const events = `<g filter="url(#shadow)"><rect x="20" y="322" width="390" height="188" rx="18" fill="${t.surface}" stroke="${t.hairline}"/>
    ${compactEventRow({ x: 22, y: 322, width: 386, height: 60, type: "moon", title: "Waning gibbous Moon", timing: "Today 18:00 · TRT", method: "Astronomical", summary: "Light softens toward the next phase." }, t)}
    ${compactEventRow({ x: 22, y: 382, width: 386, height: 66, type: "ingress", title: ["Mars enters Gemini after an", "extended retrograde cycle"], timing: "14 August · date only", method: "Western" }, t)}
    ${compactEventRow({ x: 22, y: 448, width: 386, height: 62, type: "aspect", title: "Jupiter trine Saturn", timing: "Timing unavailable", method: "Vedic" }, t, true)}
  </g>`;
  return shell({ width: 430, height: 932, mode, title: `Current Sky iPhone ${mode} refinement`, description: "Approved compact Current Sky reference with short Lunar Compass hero, dense event rows, and tab clearance.", body: `
    <rect width="430" height="932" fill="${t.ground}"/>${reviewLabel(430, t)}${statusBar(430, t, "phone")}
    <text x="20" y="91" class="editorial" font-size="34" font-weight="500" fill="${t.ink}">Sky</text>
    <circle cx="388" cy="75" r="22" fill="${t.lavender}" opacity=".75"/><text x="388" y="80" text-anchor="middle" class="ui" font-size="13" font-weight="800" fill="${t.ink}">Y</text>
    ${debugNote(20, 105, t)}
    <g aria-label="Current sky hero"><rect x="20" y="132" width="390" height="140" rx="22" fill="url(#hero)"/>
      <text x="38" y="176" class="editorial" font-size="28" font-weight="520" fill="${t.heroText}">The Moon leans</text><text x="38" y="204" class="editorial" font-size="28" font-weight="520" fill="${t.heroText}">toward morning</text>
      <text x="38" y="238" class="ui" font-size="10.5" fill="${t.heroSub}">Astronomical · Europe/Istanbul</text>
      <text x="38" y="255" class="ui" font-size="10" fill="${t.heroSub}" style="font-variant-numeric:tabular-nums">Observed 09:00 TRT</text>
      ${illustrationBody(mode, 275, 146, .36)}
    </g>
    <text x="20" y="309" class="editorial" font-size="25" font-weight="520" fill="${t.ink}">Happening now</text><text x="410" y="307" text-anchor="end" class="ui" font-size="10" font-weight="700" fill="${t.secondary}">3 EVENTS</text>
    ${events}
    <g aria-label="Open Calendar" filter="url(#shadow)"><rect x="20" y="524" width="390" height="54" rx="17" fill="url(#soft)" stroke="${t.hairline}"/>
      <rect x="34" y="535" width="32" height="32" rx="9" fill="${t.surface}"/><path d="M41 542h18v16H41zM41 547h18M46 539v6M55 539v6" fill="none" stroke="${t.coralInk}" stroke-width="1.4"/>
      <text x="78" y="548" class="ui" font-size="14" font-weight="750" fill="${t.ink}">Calendar</text><text x="78" y="565" class="ui" font-size="10.5" fill="${t.secondary}">Month, week, and timeline</text><path d="M387 547l5 5-5 5" fill="none" stroke="${t.ink}" stroke-width="1.8" stroke-linecap="round"/>
    </g>
    <text x="20" y="618" class="editorial" font-size="24" font-weight="520" fill="${t.ink}">Coming up</text><text x="410" y="616" text-anchor="end" class="ui" font-size="10" font-weight="700" fill="${t.secondary}">NEXT</text>
    <g aria-label="Mercury square Uranus, Western, Friday 21:00 until Saturday 03:00"><rect x="20" y="632" width="390" height="64" rx="17" fill="${t.surface}" stroke="${t.hairline}"/>
      <rect x="32" y="641" width="42" height="46" rx="12" fill="${t.raised}"/><text x="53" y="657" text-anchor="middle" class="label" font-size="7" fill="${t.coralInk}">AUG</text><text x="53" y="679" text-anchor="middle" class="ui" font-size="17" font-weight="750" fill="${t.ink}">15</text>
      <text x="88" y="655" class="ui" font-size="14" font-weight="700" fill="${t.ink}">Mercury square Uranus</text><text x="88" y="677" class="ui" font-size="10.5" fill="${t.secondary}" style="font-variant-numeric:tabular-nums">Fri 21:00 – Sat 03:00  ·  Western</text>
    </g>
    <text x="215" y="790" text-anchor="middle" class="ui" font-size="9" fill="${t.tertiary}">Reserved scroll clearance above tab bar</text><path d="M120 800h190" stroke="${t.hairline}"/>
    ${phoneTab(t, mode)}
  `});
}

function currentSkyIPad(mode) {
  const t = themes[mode];
  return shell({ width: 1024, height: 1366, mode, title: `Current Sky iPad ${mode} refinement`, description: "Approved two-region iPad Current Sky reference with bounded Lunar Compass hero and compact event rows.", body: `
    <rect width="1024" height="1366" fill="${t.ground}"/>${reviewLabel(1024, t)}${statusBar(1024, t, "ipad")}${iPadTopNav(t)}
    <text x="48" y="176" class="editorial" font-size="38" font-weight="500" fill="${t.ink}">Sky</text><circle cx="950" cy="160" r="25" fill="${t.lavender}" opacity=".78"/><text x="950" y="166" text-anchor="middle" class="ui" font-size="14" font-weight="800" fill="${t.ink}">Y</text>${debugNote(48, 194, t)}
    <g aria-label="Current sky hero"><rect x="48" y="226" width="438" height="238" rx="24" fill="url(#hero)"/>
      <text x="78" y="287" class="editorial" font-size="36" font-weight="520" fill="${t.heroText}">The Moon leans</text><text x="78" y="325" class="editorial" font-size="36" font-weight="520" fill="${t.heroText}">toward morning</text>
      <text x="78" y="374" class="ui" font-size="12" fill="${t.heroSub}">Astronomical · Europe/Istanbul</text><text x="78" y="396" class="ui" font-size="11" fill="${t.heroSub}" style="font-variant-numeric:tabular-nums">Observed 09:00 TRT</text>
      ${illustrationBody(mode, 285, 258, .54)}
    </g>
    <g aria-label="Open Calendar" filter="url(#shadow)"><rect x="48" y="492" width="438" height="74" rx="19" fill="url(#soft)" stroke="${t.hairline}"/><rect x="66" y="507" width="42" height="42" rx="12" fill="${t.surface}"/><path d="M75 517h24v21H75zM75 523h24M81 513v8M93 513v8" fill="none" stroke="${t.coralInk}" stroke-width="1.6"/><text x="125" y="521" class="ui" font-size="16" font-weight="750" fill="${t.ink}">Calendar</text><text x="125" y="543" class="ui" font-size="12" fill="${t.secondary}">Month, week, and full timeline</text><path d="M456 524l6 6-6 6" fill="none" stroke="${t.ink}" stroke-width="2" stroke-linecap="round"/></g>
    <text x="530" y="245" class="editorial" font-size="32" font-weight="520" fill="${t.ink}">Happening now</text><text x="974" y="242" text-anchor="end" class="ui" font-size="10" font-weight="700" fill="${t.secondary}">3 EVENTS</text>
    <g filter="url(#shadow)"><rect x="530" y="266" width="444" height="220" rx="20" fill="${t.surface}" stroke="${t.hairline}"/>
      ${compactEventRow({ x: 534, y: 266, width: 436, height: 70, type: "moon", title: "Waning gibbous Moon", timing: "Today 18:00 · TRT", method: "Astronomical", summary: "Light softens toward the next phase.", font: 15.5 }, t)}
      ${compactEventRow({ x: 534, y: 336, width: 436, height: 78, type: "ingress", title: ["Mars enters Gemini after an", "extended retrograde cycle"], timing: "14 August · date only", method: "Western", font: 15.5 }, t)}
      ${compactEventRow({ x: 534, y: 414, width: 436, height: 72, type: "aspect", title: "Jupiter trine Saturn", timing: "Timing unavailable", method: "Vedic", font: 15.5 }, t, true)}
    </g>
    <text x="530" y="540" class="editorial" font-size="29" font-weight="520" fill="${t.ink}">Coming up</text>
    <g><line x1="554" y1="572" x2="554" y2="716" stroke="${t.hairline}" stroke-width="2"/><circle cx="554" cy="590" r="7" fill="${t.coral}"/><text x="578" y="584" class="label" font-size="8" fill="${t.coralInk}">FRI · 15 AUG</text><text x="578" y="608" class="ui" font-size="15" font-weight="700" fill="${t.ink}">Mercury square Uranus</text><text x="578" y="630" class="ui" font-size="11" fill="${t.secondary}" style="font-variant-numeric:tabular-nums">21:00 – Sat 03:00 · Western</text><circle cx="554" cy="678" r="7" fill="${t.gold}"/><text x="578" y="672" class="label" font-size="8" fill="${t.goldInk}">TUE · 22 SEP</text><text x="578" y="696" class="ui" font-size="15" font-weight="700" fill="${t.ink}">Equinox</text><text x="578" y="718" class="ui" font-size="11" fill="${t.secondary}">Date only · Astronomical</text></g>
  `});
}

function calendarHeader(t, mode, selectedMode, device) {
  const phone = device === "phone";
  if (phone) return `<g aria-label="Calendar navigation"><circle cx="42" cy="80" r="22" fill="${t.surface}" stroke="${t.hairline}"/><path d="M46 72l-8 8 8 8" fill="none" stroke="${t.ink}" stroke-width="2.2" stroke-linecap="round"/><text x="215" y="86" text-anchor="middle" class="ui" font-size="18" font-weight="700" fill="${t.ink}">Calendar</text><rect x="354" y="58" width="58" height="44" rx="18" fill="${t.surface}" stroke="${t.hairline}"/><text x="383" y="86" text-anchor="middle" class="ui" font-size="14" font-weight="650" fill="${t.coralInk}">Today</text></g>`;
  return `<g aria-label="Calendar navigation">${iPadTopNav(t)}<circle cx="42" cy="80" r="22" fill="${t.surface}" stroke="${t.hairline}"/><path d="M46 72l-8 8 8 8" fill="none" stroke="${t.ink}" stroke-width="2.2"/><text x="512" y="145" text-anchor="middle" class="ui" font-size="18" font-weight="700" fill="${t.ink}">Calendar</text><rect x="930" y="54" width="62" height="44" rx="18" fill="${t.surface}" stroke="${t.hairline}"/><text x="961" y="82" text-anchor="middle" class="ui" font-size="14" font-weight="650" fill="${t.coralInk}">Today</text></g>`;
}

function segmented(x, y, width, modeName, t) {
  const half = width / 2;
  const selectedX = modeName === "Month" ? x + 3 : x + half;
  return `<g aria-label="Calendar mode, ${modeName} selected"><rect x="${x}" y="${y}" width="${width}" height="36" rx="18" fill="${t.raised}"/><rect x="${selectedX}" y="${y + 3}" width="${half - 3}" height="30" rx="15" fill="${t.surface}" stroke="${t.hairline}"/><text x="${x + half / 2}" y="${y + 24}" text-anchor="middle" class="ui" font-size="13" font-weight="650" fill="${t.ink}">Month</text><text x="${x + half + half / 2}" y="${y + 24}" text-anchor="middle" class="ui" font-size="13" font-weight="650" fill="${t.ink}">Week</text></g>`;
}

const weeks = [
  [{ n: 27, outside: true }, { n: 28, outside: true }, { n: 29, outside: true }, { n: 30, outside: true }, { n: 31, outside: true }, { n: 1 }, { n: 2 }],
  [3, 4, 5, 6, 7, 8, 9].map(n => ({ n })),
  [{ n: 10 }, { n: 11 }, { n: 12, lunar: true }, { n: 13, today: true }, { n: 14, selected: true, count: 3 }, { n: 15 }, { n: 16 }],
  [17, 18, 19, 20, 21, 22, 23].map(n => ({ n })),
  [24, 25, 26, 27, 28, 29, 30].map(n => ({ n })),
  [{ n: 31 }, { n: 1, outside: true }, { n: 2, outside: true }, { n: 3, outside: true }, { n: 4, outside: true }, { n: 5, outside: true }, { n: 6, outside: true }]
];

function moonMini(cx, cy, t) { return `<circle cx="${cx}" cy="${cy}" r="5" fill="${t.gold}"/><circle cx="${cx + 3}" cy="${cy - 1.5}" r="5" fill="${t.surface}"/>`; }

function monthGrid(x, y, width, rowHeight, t) {
  const cell = width / 7;
  const head = 34;
  const days = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];
  let body = `<g aria-label="August 2026 month grid"><rect x="${x}" y="${y}" width="${width}" height="${head + rowHeight * 6 + 8}" rx="20" fill="${t.surface}" stroke="${t.hairline}"/>${days.map((d, i) => `<text x="${x + cell * (i + .5)}" y="${y + 22}" text-anchor="middle" class="label" font-size="8.5" fill="${t.secondary}">${d}</text>`).join("")}<line x1="${x + 10}" y1="${y + head}" x2="${x + width - 10}" y2="${y + head}" stroke="${t.hairline}"/>`;
  weeks.forEach((week, r) => week.forEach((day, c) => {
    const cx = x + cell * (c + .5);
    const cy = y + head + rowHeight * r + rowHeight / 2;
    const color = day.outside ? t.tertiary : day.selected ? t.selectedText : t.ink;
    const opacity = day.outside ? .56 : 1;
    let state = "";
    if (day.today) state += `<circle cx="${cx}" cy="${cy - 2}" r="15" fill="none" stroke="${t.coral}" stroke-width="2"/><path d="M${cx - 5} ${cy - 20}h10" stroke="${t.coral}" stroke-width="3" stroke-linecap="round"/>`;
    if (day.selected) state += `<circle cx="${cx}" cy="${cy - 2}" r="16" fill="${t.coral}"/>`;
    if (day.lunar) state += moonMini(cx, cy + 13, t);
    if (day.count) state += `<circle cx="${cx - 4}" cy="${cy + 14}" r="2.5" fill="${t.lavender}"/><text x="${cx + 4}" y="${cy + 17}" class="ui" font-size="8" font-weight="700" fill="${t.secondary}">${day.count}</text>`;
    body += `<g aria-label="${day.n} August${day.today ? ", Today" : ""}${day.selected ? ", selected, 3 events" : ""}">${state}<text x="${cx}" y="${cy + 4}" text-anchor="middle" class="ui" font-size="13.5" font-weight="${day.today || day.selected ? "750" : "600"}" fill="${color}" opacity="${opacity}">${day.n}</text></g>`;
  }));
  body += `<text x="${x + 10}" y="${y + head + 12}" class="label" font-size="7" fill="${t.tertiary}">JUL</text><text x="${x + cell + 6}" y="${y + head + rowHeight * 5 + 13}" class="label" font-size="7" fill="${t.tertiary}">SEP</text></g>`;
  return body;
}

function agenda(x, y, width, t, compact = true) {
  const heights = compact ? [52, 56, 52] : [70, 76, 70];
  const total = heights.reduce((a, b) => a + b, 0);
  let cy = y;
  const rows = [
    { type: "ingress", title: compact ? "Mars enters Gemini" : ["Mars enters Gemini after an", "extended retrograde cycle"], timing: "14 August · date only", method: "Western" },
    { type: "aspect", title: "Mercury square Uranus", timing: "Fri 21:00 – Sat 03:00", method: "Western" },
    { type: "aspect", title: "Jupiter trine Saturn", timing: "Timing unavailable", method: "Vedic" }
  ];
  let body = `<g filter="url(#shadow)"><rect x="${x}" y="${y}" width="${width}" height="${total}" rx="18" fill="${t.surface}" stroke="${t.hairline}"/>`;
  rows.forEach((row, i) => { body += compactEventRow({ x: x + 2, y: cy, width: width - 4, height: heights[i], ...row, font: compact ? 13.5 : 15 }, t, i === rows.length - 1); cy += heights[i]; });
  return body + `</g>`;
}

function monthPhone(mode) {
  const t = themes[mode];
  return shell({ width: 430, height: 932, mode, title: `Calendar Month iPhone ${mode} refinement`, description: "Compact six-row civil month grid with visible selected-date agenda and protected tab clearance.", body: `
    <rect width="430" height="932" fill="${t.ground}"/>${reviewLabel(430, t)}${statusBar(430, t, "phone")}${calendarHeader(t, mode, "Month", "phone")}${debugNote(20, 116, t)}${segmented(20, 144, 390, "Month", t)}
    <text x="20" y="220" class="editorial" font-size="28" font-weight="520" fill="${t.ink}">August 2026</text><text x="20" y="239" class="ui" font-size="9.5" fill="${t.secondary}">Civil month · Monday first</text>
    <g aria-label="Month range controls"><circle cx="348" cy="216" r="22" fill="${t.raised}"/><path d="M352 209l-7 7 7 7" fill="none" stroke="${t.tertiary}" stroke-width="2"/><circle cx="392" cy="216" r="22" fill="${t.raised}"/><path d="M388 209l7 7-7 7" fill="none" stroke="${t.tertiary}" stroke-width="2"/></g>
    ${monthGrid(20, 252, 390, 44, t)}
    <text x="20" y="609" class="label" font-size="8.5" fill="${t.coralInk}">SELECTED DATE</text><text x="20" y="638" class="editorial" font-size="26" font-weight="520" fill="${t.ink}">Friday · 14 August</text><text x="410" y="636" text-anchor="end" class="ui" font-size="10" font-weight="700" fill="${t.secondary}">3 EVENTS</text>
    ${agenda(20, 650, 390, t, true)}
    ${phoneTab(t, mode)}
  `});
}

function monthIPad(mode) {
  const t = themes[mode];
  return shell({ width: 1024, height: 1366, mode, title: `Calendar Month iPad ${mode} refinement`, description: "Compact iPad month overview with bounded civil grid and parallel selected-date agenda.", body: `
    <rect width="1024" height="1366" fill="${t.ground}"/>${reviewLabel(1024, t)}${statusBar(1024, t, "ipad")}${calendarHeader(t, mode, "Month", "ipad")}${debugNote(48, 173, t)}${segmented(48, 202, 468, "Month", t)}
    <text x="48" y="283" class="editorial" font-size="32" font-weight="520" fill="${t.ink}">August 2026</text><text x="48" y="305" class="ui" font-size="10.5" fill="${t.secondary}">Civil month · Monday first</text><g><circle cx="908" cy="275" r="22" fill="${t.raised}"/><path d="M912 268l-7 7 7 7" fill="none" stroke="${t.tertiary}" stroke-width="2"/><circle cx="958" cy="275" r="22" fill="${t.raised}"/><path d="M954 268l7 7-7 7" fill="none" stroke="${t.tertiary}" stroke-width="2"/></g>
    ${monthGrid(48, 326, 468, 52, t)}
    <text x="556" y="352" class="label" font-size="9" fill="${t.coralInk}">SELECTED DATE</text><text x="556" y="390" class="editorial" font-size="31" font-weight="520" fill="${t.ink}">Friday · 14 August</text><text x="972" y="387" text-anchor="end" class="ui" font-size="10" font-weight="700" fill="${t.secondary}">3 EVENTS</text>${agenda(556, 414, 416, t, false)}
    <text x="556" y="672" class="ui" font-size="11" fill="${t.secondary}">The Mercury interval continues into Saturday.</text><path d="M48 740h924" stroke="${t.hairline}"/><text x="48" y="770" class="ui" font-size="10.5" fill="${t.tertiary}">Europe/Istanbul · civil dates · sample not calculated</text>
  `});
}

function weekRail(x, y, width, t) {
  const days = [{ w: "MON", n: 10 }, { w: "TUE", n: 11 }, { w: "WED", n: 12, lunar: true }, { w: "THU", n: 13, today: true }, { w: "FRI", n: 14, selected: true, count: 3 }, { w: "SAT", n: 15 }, { w: "SUN", n: 16 }];
  const cell = width / 7;
  return `<g aria-label="Week dates"><rect x="${x}" y="${y}" width="${width}" height="74" rx="18" fill="${t.surface}" stroke="${t.hairline}"/>${days.map((d, i) => { const cx = x + cell * (i + .5); let state = ""; if (d.today) state += `<circle cx="${cx}" cy="${y + 44}" r="18" fill="none" stroke="${t.coral}" stroke-width="2"/><path d="M${cx - 6} ${y + 22}h12" stroke="${t.coral}" stroke-width="3" stroke-linecap="round"/>`; if (d.selected) state += `<rect x="${cx - 20}" y="${y + 21}" width="40" height="43" rx="18" fill="${t.coral}"/>`; if (d.lunar) state += moonMini(cx + 12, y + 57, t); if (d.count) state += `<circle cx="${cx + 13}" cy="${y + 56}" r="2.5" fill="${d.selected ? t.selectedText : t.lavender}"/><text x="${cx + 19}" y="${y + 59}" class="ui" font-size="7.5" font-weight="700" fill="${d.selected ? t.selectedText : t.secondary}">${d.count}</text>`; return `<g aria-label="${d.w} ${d.n}${d.today ? ", Today" : ""}${d.selected ? ", selected, 3 events" : ""}">${state}<text x="${cx}" y="${y + 14}" text-anchor="middle" class="label" font-size="8" fill="${d.today ? t.coralInk : t.secondary}">${d.w}</text><text x="${cx}" y="${y + 51}" text-anchor="middle" class="ui" font-size="18" font-weight="750" fill="${d.selected ? t.selectedText : t.ink}">${d.n}</text></g>`; }).join("")}</g>`;
}

function weekPhone(mode) {
  const t = themes[mode];
  return shell({ width: 430, height: 932, mode, title: `Calendar Week iPhone ${mode} refinement`, description: "Compact seven-day rail and early selected agenda without tall date capsules.", body: `
    <rect width="430" height="932" fill="${t.ground}"/>${reviewLabel(430, t)}${statusBar(430, t, "phone")}${calendarHeader(t, mode, "Week", "phone")}${debugNote(20, 116, t)}${segmented(20, 144, 390, "Week", t)}
    <text x="20" y="214" class="editorial" font-size="27" font-weight="520" fill="${t.ink}">10–16 August 2026</text><text x="20" y="233" class="ui" font-size="9.5" fill="${t.secondary}">Monday-first civil week</text><g><circle cx="348" cy="214" r="22" fill="${t.raised}"/><path d="M352 207l-7 7 7 7" fill="none" stroke="${t.tertiary}" stroke-width="2"/><circle cx="392" cy="214" r="22" fill="${t.raised}"/><path d="M388 207l7 7-7 7" fill="none" stroke="${t.tertiary}" stroke-width="2"/></g>
    ${weekRail(20, 252, 390, t)}
    <text x="20" y="366" class="label" font-size="8.5" fill="${t.coralInk}">SELECTED DATE</text><text x="20" y="395" class="editorial" font-size="26" font-weight="520" fill="${t.ink}">Friday · 14 August</text><text x="410" y="393" text-anchor="end" class="ui" font-size="10" font-weight="700" fill="${t.secondary}">3 EVENTS</text>${agenda(20, 408, 390, t, true)}
    <text x="20" y="628" class="editorial" font-size="22" font-weight="520" fill="${t.ink}">Later this week</text><g aria-label="Wednesday lunar event and Sunday quiet sky"><circle cx="27" cy="654" r="5" fill="${t.gold}"/><text x="42" y="658" class="ui" font-size="11.5" font-weight="650" fill="${t.ink}">Wed · Waning gibbous Moon at 18:00</text><circle cx="27" cy="684" r="5" fill="none" stroke="${t.sage}" stroke-width="2"/><text x="42" y="688" class="ui" font-size="11.5" fill="${t.secondary}">Sun · Quiet sky</text></g>
    ${phoneTab(t, mode)}
  `});
}

function weekIPad(mode) {
  const t = themes[mode];
  return shell({ width: 1024, height: 1366, mode, title: `Calendar Week iPad ${mode} refinement`, description: "Full-width compact week rail with selected agenda and retained iPad week chronology.", body: `
    <rect width="1024" height="1366" fill="${t.ground}"/>${reviewLabel(1024, t)}${statusBar(1024, t, "ipad")}${calendarHeader(t, mode, "Week", "ipad")}${debugNote(48, 173, t)}${segmented(48, 202, 468, "Week", t)}
    <text x="48" y="283" class="editorial" font-size="31" font-weight="520" fill="${t.ink}">10–16 August 2026</text><text x="48" y="304" class="ui" font-size="10.5" fill="${t.secondary}">Monday-first civil week</text><g><circle cx="908" cy="275" r="22" fill="${t.raised}"/><path d="M912 268l-7 7 7 7" fill="none" stroke="${t.tertiary}" stroke-width="2"/><circle cx="958" cy="275" r="22" fill="${t.raised}"/><path d="M954 268l7 7-7 7" fill="none" stroke="${t.tertiary}" stroke-width="2"/></g>
    ${weekRail(48, 326, 924, t)}
    <text x="48" y="450" class="label" font-size="9" fill="${t.coralInk}">SELECTED DATE</text><text x="48" y="488" class="editorial" font-size="31" font-weight="520" fill="${t.ink}">Friday · 14 August</text><text x="508" y="485" text-anchor="end" class="ui" font-size="10" font-weight="700" fill="${t.secondary}">3 EVENTS</text>${agenda(48, 510, 460, t, false)}
    <text x="556" y="482" class="editorial" font-size="29" font-weight="520" fill="${t.ink}">Across the week</text><g><line x1="574" y1="520" x2="574" y2="715" stroke="${t.hairline}" stroke-width="2"/><circle cx="574" cy="545" r="7" fill="${t.gold}"/><text x="598" y="540" class="label" font-size="8" fill="${t.goldInk}">WED · 12 AUG</text><text x="598" y="566" class="ui" font-size="15" font-weight="700" fill="${t.ink}">Waning gibbous Moon</text><text x="598" y="588" class="ui" font-size="11" fill="${t.secondary}">Exact · 18:00 TRT</text><circle cx="574" cy="632" r="7" fill="${t.coral}"/><text x="598" y="627" class="label" font-size="8" fill="${t.coralInk}">FRI · 14 AUG</text><text x="598" y="653" class="ui" font-size="15" font-weight="700" fill="${t.ink}">3 celestial events</text><circle cx="574" cy="704" r="7" fill="none" stroke="${t.sage}" stroke-width="2"/><text x="598" y="699" class="label" font-size="8" fill="${t.sage}">SUN · 16 AUG</text><text x="598" y="725" class="ui" font-size="15" font-weight="700" fill="${t.ink}">Quiet sky this day</text></g>
  `});
}

function typographyComparison() {
  const t = themes.light;
  const contexts = [
    ["SKY", "The Moon leans toward morning", "A compact hero with useful events close behind."],
    ["CALENDAR", "August 2026", "Civil month · Monday first"],
    ["TODAY", "Your day opens softly", "Editorial warmth above practical guidance."],
    ["COMPATIBILITY", "A steady kind of gravity", "82 · Strong resonance"]
  ];
  const rows = contexts.map((c, i) => { const y = 230 + i * 150; return `<text x="70" y="${y - 48}" class="label" font-size="10" fill="${t.coralInk}">${c[0]}</text><rect x="70" y="${y - 30}" width="590" height="118" rx="18" fill="${t.surface}" stroke="${t.hairline}"/><rect x="740" y="${y - 30}" width="590" height="118" rx="18" fill="${t.surface}" stroke="${t.hairline}"/><text x="98" y="${y + 20}" class="editorial" font-size="34" font-weight="520" fill="${t.ink}">${c[1]}</text><text x="98" y="${y + 53}" class="ui" font-size="14" fill="${t.secondary}">${c[2]}</text><text x="768" y="${y + 20}" class="current-editorial" font-size="38" fill="${t.ink}">${c[1]}</text><text x="768" y="${y + 53}" class="ui" font-size="14" fill="${t.secondary}">${c[2]}</text>`; }).join("");
  return shell({ width: 1400, height: 900, mode: "light", title: "Humay typography comparison", description: "Newsreader and Cormorant Garamond pressure-tested across Sky, Calendar, Today, and Compatibility.", body: `<rect width="1400" height="900" fill="${t.ground}"/>${reviewLabel(1400, t)}<text x="70" y="78" class="editorial" font-size="42" font-weight="520" fill="${t.ink}">Editorial typography pressure test</text><text x="70" y="110" class="ui" font-size="15" fill="${t.secondary}">Approved global system · Sky / Calendar / Today / Compatibility</text><text x="70" y="166" class="label" font-size="12" fill="${t.ink}">A · NEWSREADER — ADOPTED</text><text x="740" y="166" class="label" font-size="12" fill="${t.ink}">B · CORMORANT GARAMOND — WORDMARK</text>${rows}<text x="70" y="866" class="ui" font-size="13" font-weight="650" fill="${t.coralInk}">Newsreader carries editorial UI. Cormorant carries the wordmark. SF Pro remains body/UI.</text>` });
}

function stateStudy(kind) {
  const width = 1200, height = 680;
  const samples = kind === "month"
    ? [["Normal", {}], ["Today", { today: true }], ["Selected", { selected: true }], ["Today + selected", { today: true, selected: true }], ["1 lunar event", { lunar: true }], ["3 events", { count: 3 }], ["Outside month", { outside: true }]]
    : [["Normal", {}], ["Today", { today: true }], ["Selected", { selected: true }], ["Today + selected", { today: true, selected: true }], ["Lunar event", { lunar: true }], ["3 events", { count: 3 }], ["Quiet", { quiet: true }]];
  const sample = (label, state, cx, cy, t, index) => {
    const date = 10 + index;
    const selectedColor = state.selected ? t.selectedText : t.ink;
    let marks = "";
    if (kind === "week") marks += `<text x="${cx}" y="${cy - 25}" text-anchor="middle" class="label" font-size="8" fill="${state.today ? t.coralInk : t.secondary}">${["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"][index]}</text>`;
    if (state.today) marks += `<circle cx="${cx}" cy="${cy}" r="19" fill="none" stroke="${t.coral}" stroke-width="2"/><path d="M${cx - 6} ${cy - 23}h12" stroke="${t.coral}" stroke-width="3" stroke-linecap="round"/>`;
    if (state.selected) marks += `<circle cx="${cx}" cy="${cy}" r="18" fill="${t.coral}"/>${state.today ? `<path d="M${cx - 6} ${cy - 23}h12" stroke="${t.coralInk}" stroke-width="3" stroke-linecap="round"/>` : ""}`;
    if (state.outside) marks += `<text x="${cx - 20}" y="${cy - 25}" class="label" font-size="7" fill="${t.tertiary}">SEP</text>`;
    if (state.lunar) marks += moonMini(cx + 16, cy + 14, t);
    if (state.count) marks += `<circle cx="${cx + 13}" cy="${cy + 14}" r="3" fill="${t.lavender}"/><text x="${cx + 20}" y="${cy + 17}" class="ui" font-size="8" font-weight="700" fill="${t.secondary}">${state.count}</text>`;
    if (state.quiet) marks += `<circle cx="${cx + 15}" cy="${cy + 14}" r="4" fill="none" stroke="${t.sage}" stroke-width="1.7"/>`;
    return `<g aria-label="${label}">${marks}<text x="${cx}" y="${cy + 5}" text-anchor="middle" class="ui" font-size="17" font-weight="700" fill="${state.outside ? t.tertiary : selectedColor}" opacity="${state.outside ? ".6" : "1"}">${date}</text><text x="${cx}" y="${cy + 52}" text-anchor="middle" class="ui" font-size="9.5" fill="${t.secondary}">${label}</text></g>`;
  };
  const panel = (mode, x) => {
    const t = themes[mode];
    const positions = samples.map((_, i) => [x + 82 + (i % 4) * 132, 265 + Math.floor(i / 4) * 160]);
    return `<rect x="${x}" y="100" width="580" height="520" rx="28" fill="${t.ground}"/><text x="${x + 40}" y="154" class="editorial" font-size="30" font-weight="520" fill="${t.ink}">${kind === "month" ? "Month date states" : "Week date states"} · ${mode}</text><text x="${x + 40}" y="184" class="ui" font-size="11" fill="${t.secondary}">${kind === "month" ? "44 pt civil row · compact visible state" : "60 pt visual rail · 44 pt minimum target"}</text>${samples.map(([label, state], i) => sample(label, state, positions[i][0], positions[i][1], t, i)).join("")}`;
  };
  return shell({ width, height, mode: "light", title: `${kind} date-state study`, description: `Compact ${kind} state comparison in Light and Dark, preserving 44 point targets and non-color semantics.`, body: `<rect width="1200" height="680" fill="#EDE7E1"/>${reviewLabel(1200, themes.light)}${panel("light", 20)}${panel("dark", 600)}<text x="600" y="654" text-anchor="middle" class="ui" font-size="11" font-weight="650" fill="#625F62">Visible shapes remain compact; invisible interaction regions remain at least 44 × 44 pt.</text>` });
}

async function write(name, svg, pngWidth) {
  const svgPath = path.join(out, `${name}.svg`);
  const pngPath = path.join(out, `${name}.png`);
  fs.writeFileSync(svgPath, svg);
  await sharp(Buffer.from(svg)).resize({ width: pngWidth }).png({ compressionLevel: 9, adaptiveFiltering: true }).toFile(pngPath);
}

async function main() {
  const outputs = [
    ["IllustrationCurrentSky-light", illustrationAsset("light"), 840], ["IllustrationCurrentSky-dark", illustrationAsset("dark"), 840],
    ["current-sky-iphone-light", currentSkyPhone("light"), 860], ["current-sky-iphone-dark", currentSkyPhone("dark"), 860],
    ["current-sky-ipad-light", currentSkyIPad("light"), 2048], ["current-sky-ipad-dark", currentSkyIPad("dark"), 2048],
    ["calendar-month-iphone-light", monthPhone("light"), 860], ["calendar-month-iphone-dark", monthPhone("dark"), 860],
    ["calendar-month-ipad-light", monthIPad("light"), 2048], ["calendar-month-ipad-dark", monthIPad("dark"), 2048],
    ["calendar-week-iphone-light", weekPhone("light"), 860], ["calendar-week-iphone-dark", weekPhone("dark"), 860],
    ["calendar-week-ipad-light", weekIPad("light"), 2048], ["calendar-week-ipad-dark", weekIPad("dark"), 2048],
    ["typography-comparison", typographyComparison(), 2100], ["month-date-state-study", stateStudy("month"), 1800], ["week-date-state-study", stateStudy("week"), 1800]
  ];
  for (const [name, svg, width] of outputs) await write(name, svg, width);
  console.log(`Generated ${outputs.length} SVG/PNG reference pairs in ${out}`);
}

main().catch((error) => { console.error(error); process.exitCode = 1; });
