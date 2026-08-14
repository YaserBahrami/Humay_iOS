const fs = require("node:fs");
const path = require("node:path");
const { execFileSync } = require("node:child_process");

let sharp = null;
try {
  sharp = require("sharp");
} catch {
  // macOS sips fallback keeps this generator dependency-free on a clean checkout.
}

const outputDirectory = __dirname;
const fontPath = path.resolve(
  outputDirectory,
  "../../../../../Humay/Resources/Fonts/Newsreader-Variable.ttf"
);
const editorialFont = fs.readFileSync(fontPath).toString("base64");

const themes = {
  light: {
    ground: "#FBF7F1",
    surface: "#FFFDFC",
    secondarySurface: "#F7F0E8",
    raised: "#FFF9F4",
    ink: "#151B28",
    secondary: "#625F62",
    tertiary: "#7A7575",
    hairline: "#E9E0D8",
    coral: "#F06F67",
    coralText: "#A83F3C",
    coralWash: "#FBE8E4",
    lavender: "#9A82C8",
    lavenderText: "#684F9D",
    lavenderWash: "#EEE8F5",
    gold: "#D5A253",
    goldText: "#80570E",
    goldWash: "#F6EDDC",
    blue: "#6B9FC1",
    blueText: "#356F91",
    blueWash: "#E8F0F3",
    sage: "#5F8C72",
    sageWash: "#E8F0EB",
    tab: "#FFFDF9",
    tabSelected: "#F6E9E1",
    shadow: "#35281C",
    hero: "#263247",
    heroText: "#FFF7F0",
    heroSecondary: "#D9D5D1"
  },
  dark: {
    ground: "#101725",
    surface: "#171F30",
    secondarySurface: "#20283A",
    raised: "#222B3E",
    ink: "#F5F0EA",
    secondary: "#C4BDBB",
    tertiary: "#A8A0A1",
    hairline: "#30394B",
    coral: "#F77476",
    coralText: "#FF9A98",
    coralWash: "#3A2833",
    lavender: "#B06BD4",
    lavenderText: "#D79AE8",
    lavenderWash: "#312B48",
    gold: "#E5AA55",
    goldText: "#F0BA68",
    goldWash: "#322C2B",
    blue: "#71A9D0",
    blueText: "#95C9E8",
    blueWash: "#223344",
    sage: "#77B39A",
    sageWash: "#24363A",
    tab: "#20283A",
    tabSelected: "#3A4055",
    shadow: "#000000",
    hero: "#202A42",
    heroText: "#FFF8F0",
    heroSecondary: "#C4C0C5"
  }
};

function escapeText(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

function svgShell({ width, height, title, description, mode, body, extraDefinitions = "" }) {
  const theme = themes[mode];
  return `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}" role="img" aria-labelledby="svg-title svg-description">
  <title id="svg-title">${escapeText(title)}</title>
  <desc id="svg-description">${escapeText(description)}</desc>
  <defs>
    <style>
      @font-face { font-family: "Humay Editorial"; src: url("data:font/ttf;base64,${editorialFont}") format("truetype"); font-weight: 300 900; }
      .editorial { font-family: "Humay Editorial", Georgia, serif; font-weight: 500; }
      .ui { font-family: -apple-system, BlinkMacSystemFont, "Helvetica Neue", Arial, sans-serif; }
      .mono { font-family: "SFMono-Regular", Menlo, Consolas, monospace; }
      .label { font-family: -apple-system, BlinkMacSystemFont, "Helvetica Neue", Arial, sans-serif; font-weight: 700; letter-spacing: 1.1px; }
      text { text-rendering: optimizeLegibility; }
    </style>
    <linearGradient id="hero-gradient" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="${theme.hero}"/>
      <stop offset="1" stop-color="${mode === "light" ? "#3B3650" : "#302D4D"}"/>
    </linearGradient>
    <linearGradient id="context-gradient" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="${mode === "light" ? "#F0E9F4" : "#292741"}"/>
      <stop offset="1" stop-color="${mode === "light" ? "#E8F1F2" : "#1E3543"}"/>
    </linearGradient>
    <linearGradient id="meaning-gradient" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="${theme.coralWash}"/>
      <stop offset="1" stop-color="${theme.lavenderWash}"/>
    </linearGradient>
    <filter id="soft-shadow" x="-30%" y="-30%" width="160%" height="180%">
      <feDropShadow dx="0" dy="5" stdDeviation="10" flood-color="${theme.shadow}" flood-opacity="${mode === "light" ? "0.09" : "0"}"/>
    </filter>
${extraDefinitions ? `    ${extraDefinitions}\n` : ""}  </defs>
  ${body}
</svg>`;
}

function statusBar(width, theme, device) {
  const phone = device === "phone";
  const timeX = phone ? 22 : 24;
  const iconX = width - (phone ? 78 : 92);
  const date = phone ? "9:41" : "9:41  ·  Thu 14 Aug";
  return `<text x="${timeX}" y="31" class="ui" font-size="${phone ? 14 : 13}" font-weight="700" fill="${theme.ink}">${date}</text>
    <g transform="translate(${iconX} 19)" fill="none" stroke="${theme.ink}" stroke-width="2" stroke-linecap="round">
      <path d="M0 8h2V5h2v3h2V2h2v6"/>
      <path d="M14 4c3-3 8-3 11 0M17 7c2-2 4-2 6 0"/>
      <rect x="30" y="0" width="22" height="10" rx="3"/>
      <rect x="32" y="2" width="16" height="6" rx="2" fill="${theme.ink}" stroke="none"/>
      <path d="M53 3v4"/>
    </g>`;
}

function wrapLine(line, maxChars) {
  const words = String(line).split(/\s+/).filter(Boolean);
  const result = [];
  let current = "";
  for (const word of words) {
    const candidate = current ? `${current} ${word}` : word;
    if (current && candidate.length > maxChars) {
      result.push(current);
      current = word;
    } else {
      current = candidate;
    }
  }
  if (current) result.push(current);
  return result.length ? result : [""];
}

function multiline(x, y, lines, { className = "ui", size = 13, fill, weight = 400, lineHeight = 19, anchor = "start", opacity = 1, maxChars } = {}) {
  const renderedLines = maxChars ? lines.flatMap((line) => wrapLine(line, maxChars)) : lines;
  return renderedLines.map((line, index) => `<text x="${x}" y="${y + index * lineHeight}" class="${className}" text-anchor="${anchor}" font-size="${size}" font-weight="${weight}" fill="${fill}" opacity="${opacity}">${escapeText(line)}</text>`).join("");
}

function label(x, y, value, theme, color = theme.coralText, size = 8.5) {
  return `<text x="${x}" y="${y}" class="label" font-size="${size}" fill="${color}">${escapeText(value.toUpperCase())}</text>`;
}

function icon(type, x, y, color, scale = 1) {
  const stroke = `stroke="${color}" fill="none" stroke-width="${1.7 * scale}" stroke-linecap="round" stroke-linejoin="round"`;
  switch (type) {
    case "note":
      return `<path d="M${x - 9 * scale} ${y - 10 * scale}h13l5 5v15h-18Z" ${stroke}/><path d="M${x + 4 * scale} ${y - 10 * scale}v6h5m-13 4h9m-9 5h7" ${stroke}/>`;
    case "lock":
      return `<path d="M${x - 7 * scale} ${y - 1 * scale}a7 7 0 0 1 14 0v9h-14Z" ${stroke}/><path d="M${x - 4 * scale} ${y - 2 * scale}v-4a4 4 0 0 1 8 0v4" ${stroke}/>`;
    case "wifi-off":
      return `<path d="M${x - 11 * scale} ${y - 5 * scale}c6-5 14-5 20 0m-16 5c4-3 8-3 12 0m-7 5 2 2" ${stroke}/><path d="M${x - 12 * scale} ${y - 12 * scale}l24 24" ${stroke}/>`;
    case "warning":
      return `<path d="M${x} ${y - 12 * scale}l12 ${22 * scale}h-${24 * scale}Z" ${stroke}/><path d="M${x} ${y - 5 * scale}v7m0 5v1" ${stroke}/>`;
    case "check":
      return `<circle cx="${x}" cy="${y}" r="10" ${stroke}/><path d="M${x - 5} ${y}l3 3 7-8" ${stroke}/>`;
    case "keyboard":
      return `<rect x="${x - 15 * scale}" y="${y - 9 * scale}" width="${30 * scale}" height="${18 * scale}" rx="3" ${stroke}/><path d="M${x - 9 * scale} ${y - 3 * scale}h2m3 0h2m3 0h2m3 0h2m-15 6h18" ${stroke}/>`;
    case "shield":
      return `<path d="M${x} ${y - 12 * scale}l10 4v7c0 6-4 10-10 13-6-3-10-7-10-13v-7Z" ${stroke}/><path d="M${x - 5 * scale} ${y}l3 3 7-8" ${stroke}/>`;
    case "star":
      return `<path d="M${x} ${y - 12 * scale}l3.5 7.5 8 .8-6 5.3 1.8 7.8-7.3-4.1-7.3 4.1 1.8-7.8-6-5.3 8-.8Z" fill="${color}" stroke="none"/>`;
    default:
      return `<circle cx="${x}" cy="${y}" r="8" ${stroke}/>`;
  }
}

function phoneTabBar(theme, selected = "Ask") {
  const items = [
    ["Today", 52, "sun"],
    ["Circle", 132, "people"],
    ["Sky", 215, "sky"],
    ["Chart", 298, "chart"],
    ["Ask", 378, "ask"]
  ];
  const selectedItem = items.find(([name]) => name === selected) || items[4];
  const selectedX = selectedItem[1] - 37;
  return `<g aria-label="Primary navigation, ${escapeText(selected)} selected" filter="url(#soft-shadow)">
    <rect x="14" y="838" width="402" height="76" rx="32" fill="${theme.tab}" stroke="${theme.hairline}"/>
    <rect x="${selectedX}" y="844" width="74" height="64" rx="26" fill="${theme.tabSelected}"/>
    ${items.map(([name, x, type]) => {
      const active = name === selected;
      const color = active ? theme.coralText : theme.ink;
      return `<g>${navIcon(type, x, 861, color)}<text x="${x}" y="897" text-anchor="middle" class="ui" font-size="10" font-weight="${active ? "750" : "550"}" fill="${color}">${name}</text></g>`;
    }).join("")}
  </g>`;
}

function navIcon(type, x, y, color) {
  const common = `stroke="${color}" fill="none" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"`;
  switch (type) {
    case "sun":
      return `<circle cx="${x}" cy="${y}" r="5.5" ${common}/><path d="M${x} ${y - 12}v3m0 15v3m-12-9h3m15 0h3m-10.5-8.5 2 2m8.5 8.5 2 2m0-12.5-2 2m-8.5 8.5-2 2" ${common}/>`;
    case "people":
      return `<circle cx="${x - 4}" cy="${y - 3}" r="4" ${common}/><circle cx="${x + 5}" cy="${y - 2}" r="3.5" ${common}/><path d="M${x - 12} ${y + 9}c2-7 12-7 15 0m0-5c5-2 9 1 10 5" ${common}/>`;
    case "sky":
      return `<path d="M${x} ${y - 11}c1.5 7 3 8.5 10 10-7 1.5-8.5 3-10 10-1.5-7-3-8.5-10-10 7-1.5 8.5-3 10-10Z" fill="${color}"/>`;
    case "chart":
      return `<circle cx="${x}" cy="${y}" r="9" ${common}/><path d="M${x - 7} ${y - 5}l14 10m-14 0 14-10M${x} ${y - 9}v18" stroke="${color}" stroke-width="1.2"/>`;
    default:
      return `<path d="M${x - 10} ${y - 8}h15a5 5 0 0 1 5 5v7a5 5 0 0 1-5 5h-6l-5 4v-4h-4a5 5 0 0 1-5-5v-7a5 5 0 0 1 5-5Z" ${common}/><path d="M${x - 5} ${y - 2}h10m-10 5h7" stroke="${color}" stroke-width="1.4"/>`;
  }
}

function iPadTopNavigation(theme, selected = "Ask") {
  const labels = ["Today", "Circle", "Sky", "Chart", "Ask"];
  const xs = [340, 430, 520, 625, 725];
  const selectedIndex = labels.indexOf(selected);
  return `<g aria-label="Adaptive primary navigation, ${escapeText(selected)} selected" filter="url(#soft-shadow)">
    <rect x="288" y="46" width="456" height="56" rx="28" fill="${theme.tab}" stroke="${theme.hairline}"/>
    <rect x="${xs[selectedIndex] - 43}" y="52" width="86" height="44" rx="22" fill="${theme.tabSelected}"/>
    ${labels.map((value, index) => `<text x="${xs[index]}" y="81" text-anchor="middle" class="ui" font-size="15" font-weight="${value === selected ? "750" : "600"}" fill="${value === selected ? theme.coralText : theme.ink}">${value}</text>`).join("")}
  </g>`;
}

function phoneHeader(theme, subtitle = "") {
  return `${statusBar(430, theme, "phone")}
    <text x="20" y="80" class="editorial" font-size="34" fill="${theme.ink}">Ask</text>
${subtitle ? `    ${label(20, 108, subtitle, theme, theme.coralText, 7.3)}\n` : ""}    <circle cx="388" cy="70" r="22" fill="url(#context-gradient)" stroke="${theme.hairline}"/>
    <text x="388" y="76" text-anchor="middle" class="ui" font-size="13" font-weight="700" fill="${theme.ink}">Y</text>`;
}

function iPadHeader(theme, subtitle = "") {
  return `${statusBar(1024, theme, "ipad")}
    ${iPadTopNavigation(theme, "Ask")}
    <text x="56" y="161" class="editorial" font-size="42" fill="${theme.ink}">Ask</text>
${subtitle ? `    ${label(56, 194, subtitle, theme, theme.coralText, 8)}\n` : ""}    <circle cx="944" cy="154" r="24" fill="url(#context-gradient)" stroke="${theme.hairline}"/>
    <text x="944" y="161" text-anchor="middle" class="ui" font-size="14" font-weight="700" fill="${theme.ink}">Y</text>`;
}

function askIllustration(x, y, scale, theme, dark = false) {
  const paper = dark ? "#F5F0EA" : "#FFFDFC";
  const paperShadow = dark ? "#D8C9C4" : "#E8D9CF";
  return `<g transform="translate(${x} ${y}) scale(${scale})" aria-label="Folded note orbiting a moon and star">
    <ellipse cx="0" cy="8" rx="78" ry="25" fill="none" stroke="${theme.gold}" stroke-width="1.5" opacity="0.68" transform="rotate(-16)"/>
    <ellipse cx="0" cy="8" rx="66" ry="20" fill="none" stroke="${theme.blue}" stroke-width="1.2" opacity="0.72" transform="rotate(30)"/>
    <circle cx="-8" cy="6" r="30" fill="${dark ? "#2C3650" : "#F9ECDD"}" stroke="${theme.lavender}" stroke-width="1.2"/>
    <path d="M-1 -20c-13 7-17 24-8 36 7 9 18 13 28 9-12-8-17-29-4-42-5-4-10-5-16-3Z" fill="${theme.gold}" opacity="0.86"/>
    <path d="M-45 -36h61l18 18v61h-79Z" fill="${paper}" stroke="${paperShadow}" stroke-width="1.3" transform="rotate(-8 -5 2)"/>
    <path d="M16 -36v18h18" fill="none" stroke="${paperShadow}" stroke-width="1.2" transform="rotate(-8 -5 2)"/>
    <path d="M-25 -7h31m-31 13h23m-23 13h16" stroke="${theme.coral}" stroke-width="2.2" stroke-linecap="round" opacity="0.84"/>
    <circle cx="51" cy="-35" r="4" fill="${theme.coral}"/>
    <circle cx="58" cy="-49" r="2.2" fill="${theme.lavender}"/>
    <path d="M-80 -18l2 5 5 2-5 2-2 5-2-5-5-2 5-2Z" fill="${theme.coral}" opacity="0.9"/>
  </g>`;
}

function surface(x, y, width, height, theme, { fill = theme.surface, radius = 22, shadow = false, stroke = theme.hairline } = {}) {
  return `<rect x="${x}" y="${y}" width="${width}" height="${height}" rx="${radius}" fill="${fill}" stroke="${stroke}" ${shadow ? 'filter="url(#soft-shadow)"' : ""}/>`;
}

function button(x, y, width, value, theme, { filled = true, disabled = false } = {}) {
  const fill = disabled ? theme.secondarySurface : filled ? theme.coral : "none";
  const stroke = disabled ? theme.hairline : filled ? theme.coral : theme.hairline;
  const color = disabled ? theme.tertiary : filled ? "#FFFFFF" : theme.coralText;
  return `<g aria-label="${escapeText(value)}">
    <rect x="${x}" y="${y}" width="${width}" height="44" rx="22" fill="${fill}" stroke="${stroke}"/>
    <text x="${x + width / 2}" y="${y + 27}" text-anchor="middle" class="ui" font-size="13" font-weight="700" fill="${color}">${escapeText(value)}</text>
  </g>`;
}

function composer(theme, { x, y, width, height = 154, lines = [], enabled = false, focused = false, keyboard = false } = {}) {
  const shownLines = lines.length ? lines : ["What would you like to ask?"];
  const textColor = lines.length ? theme.ink : theme.tertiary;
  const border = focused ? theme.coral : theme.hairline;
  const buttonWidth = 66;
  const buttonX = x + width - buttonWidth - 18;
  const buttonY = y + height - 54;
  return `<g aria-label="Question composer">
    ${surface(x, y, width, height, theme, { fill: theme.surface, radius: 22, shadow: false, stroke: border })}
    ${label(x + 20, y + 29, "YOUR QUESTION", theme, theme.tertiary, 7.2)}
    ${multiline(x + 20, y + 61, shownLines, { size: 14, fill: textColor, lineHeight: 21, maxChars: width < 450 ? 40 : 54 })}
    ${button(buttonX, buttonY, buttonWidth, "Ask", theme, { filled: enabled, disabled: !enabled })}
    <text x="${x + 20}" y="${y + height - 26}" class="ui" font-size="10.5" fill="${theme.secondary}">${keyboard ? "Ready when you are · Return keeps focus" : "Relevant context only"}</text>
  </g>`;
}

function suggestionRow(theme, x, y, width, value, accent = theme.lavender) {
  return `<g aria-label="Suggested question: ${escapeText(value)}">
    ${surface(x, y, width, 48, theme, { fill: theme.surface, radius: 16 })}
    <circle cx="${x + 22}" cy="${y + 24}" r="7" fill="${accent}" opacity="0.18" stroke="${accent}"/>
    <path d="M${x + 19} ${y + 24}h6m-3-3v6" stroke="${accent}" stroke-width="1.4" stroke-linecap="round"/>
    <text x="${x + 40}" y="${y + 29}" class="ui" font-size="12" fill="${theme.ink}">${escapeText(value)}</text>
    <path d="M${x + width - 22} ${y + 20}l4 4-4 4" fill="none" stroke="${theme.tertiary}" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  </g>`;
}

function contextSurface(theme, x, y, width, height = 142, { compact = false } = {}) {
  const narrow = width < 450;
  const headingLines = narrow ? ["Using: Western · available", "chart context"] : ["Using: Western · available chart context"];
  const detailLines = compact
    ? (narrow ? ["Only relevant astrology context is", "used for this question."] : ["Only relevant astrology context is used for this question."])
    : (narrow ? ["Only relevant astrology context is", "used for this question."] : ["Only relevant astrology context is used for this question."]);
  const detailY = y + (headingLines.length > 1 ? 98 : 86);
  return `<g aria-label="Available astrology context">
    ${surface(x, y, width, height, theme, { fill: "url(#context-gradient)", radius: 22 })}
    ${label(x + 20, y + 29, "AVAILABLE CONTEXT", theme, theme.blueText, 7.3)}
    ${multiline(x + 20, y + 60, headingLines, { size: compact ? 12.5 : 13, fill: theme.ink, lineHeight: 18, weight: 700, maxChars: narrow ? 38 : 52 })}
    ${multiline(x + 20, detailY, detailLines, { size: 11.5, fill: theme.secondary, lineHeight: 18, maxChars: narrow ? 38 : 56 })}
  </g>`;
}

function questionCard(theme, x, y, width, { sample = false, compact = false } = {}) {
  const height = compact ? 88 : 106;
  return `<g aria-label="Question identity">
    ${surface(x, y, width, height, theme, { fill: theme.surface, radius: 20, shadow: false })}
    ${sample ? `${label(x + 18, y + 25, "DEVELOPMENT SAMPLE · NOT GENERATED", theme, theme.tertiary, 6.8)}` : `${label(x + 18, y + 25, "YOUR QUESTION", theme, theme.tertiary, 6.8)}`}
    <text x="${x + 18}" y="${y + (compact ? 59 : 67)}" class="${compact ? "ui" : "editorial"}" font-size="${compact ? 16 : 19}" fill="${theme.ink}">How can I work with my Moon in Libra?</text>
  </g>`;
}

function answerSection(theme, x, y, width, title, lines, { accent = theme.lavenderText } = {}) {
  return `<g>
    <circle cx="${x + 5}" cy="${y - 5}" r="4" fill="${accent}"/>
    <text x="${x + 20}" y="${y}" class="editorial" font-size="21" fill="${theme.ink}">${escapeText(title)}</text>
    ${multiline(x + 20, y + 28, lines, { size: 12.4, fill: theme.secondary, lineHeight: 18 })}
  </g>`;
}

function basisSurface(theme, x, y, width, { compact = false, cached = false, offline = false } = {}) {
  const height = compact ? 120 : 178;
  const disclosure = cached ? "SAVED ANSWER" : offline ? "OFFLINE · SAVED ANSWER" : "WHAT THIS ANSWER USED";
  return `<g aria-label="${escapeText(disclosure)}">
    ${surface(x, y, width, height, theme, { fill: theme.raised, radius: 20 })}
    ${label(x + 20, y + 29, disclosure, theme, offline ? theme.sage : theme.lavenderText, 7.2)}
    <text x="${x + 20}" y="${y + 58}" class="ui" font-size="12" font-weight="700" fill="${theme.ink}">Moon in Libra · 14° 27′</text>
    <text x="${x + 20}" y="${y + 82}" class="ui" font-size="12" fill="${theme.secondary}">5th house · Western · Tropical</text>
    <text x="${x + 20}" y="${y + 106}" class="ui" font-size="11" fill="${theme.secondary}">Known-time development fixture</text>
    ${!compact ? button(x + 20, y + 124, 220, "Ask another question", theme, { filled: false }) : ""}
  </g>`;
}

function generatingCard(theme, x, y, width, height = 286) {
  const dark = theme === themes.dark;
  return `<g aria-label="Preparing your reading">
    ${surface(x, y, width, height, theme, { fill: "url(#hero-gradient)", radius: 26, stroke: dark ? theme.hairline : "#3F3B55" })}
    ${askIllustration(x + width / 2, y + 77, 0.72, theme, dark)}
    <text x="${x + 28}" y="${y + 174}" class="editorial" font-size="25" fill="${theme.heroText}">Reading the context you shared…</text>
    <text x="${x + 28}" y="${y + 203}" class="ui" font-size="12" fill="${theme.heroSecondary}">Putting the pieces together…</text>
    <rect x="${x + 28}" y="${y + 231}" width="${width - 56}" height="8" rx="4" fill="${theme.heroSecondary}" opacity="0.24"/>
    <rect x="${x + 28}" y="${y + 251}" width="${(width - 56) * 0.62}" height="8" rx="4" fill="${theme.heroSecondary}" opacity="0.18"/>
  </g>`;
}

function accessCard(theme, x, y, width, height = 226) {
  return `<g aria-label="Create your personal reading">
    ${surface(x, y, width, height, theme, { fill: "url(#hero-gradient)", radius: 26, stroke: theme.hairline })}
    <circle cx="${x + 42}" cy="${y + 42}" r="16" fill="${theme.gold}" opacity="0.18"/>
    ${icon("lock", x + 42, y + 42, theme.gold, 0.78)}
    ${label(x + 70, y + 45, "YOUR QUESTION IS READY", theme, theme.heroSecondary, 7.1)}
    <text x="${x + 28}" y="${y + 87}" class="editorial" font-size="26" fill="${theme.heroText}">Create this reading</text>
    ${multiline(x + 28, y + 117, ["Create this personal reading", "by watching an ad."], { size: 12, fill: theme.heroSecondary, lineHeight: 18 })}
    ${button(x + 28, y + height - 60, Math.min(220, width - 56), "Watch an ad for this answer", theme, { filled: true })}
  </g>`;
}

function premiumCard(theme, x, y, width, height = 94) {
  return `<g aria-label="Premium alternative">
    ${surface(x, y, width, height, theme, { fill: theme.surface, radius: 18 })}
    <circle cx="${x + 30}" cy="${y + 31}" r="9" fill="${theme.gold}" opacity="0.18" stroke="${theme.gold}"/>
    ${icon("star", x + 30, y + 31, theme.gold, 0.42)}
    <text x="${x + 52}" y="${y + 30}" class="ui" font-size="12.5" font-weight="700" fill="${theme.ink}">Premium alternative</text>
    ${multiline(x + 52, y + 54, ["Premium members can create included", "personal readings without this per-question", "step."], { size: 11, fill: theme.secondary, lineHeight: 16 })}
    <path d="M${x + width - 28} ${y + 42}l4 4-4 4" fill="none" stroke="${theme.tertiary}" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  </g>`;
}

function questionEntryPhone(mode) {
  const theme = themes[mode];
  const body = `<rect width="430" height="932" fill="${theme.ground}"/>
    ${phoneHeader(theme)}
    ${multiline(20, 178, ["What’s on your mind?"], { className: "editorial", size: 31, fill: theme.ink, lineHeight: 34 })}
    ${multiline(20, 202, ["Ask one honest question.", "Humay answers from the astrology context", "available for it."], { size: 12.2, fill: theme.secondary, lineHeight: 17, maxChars: 42 })}
    ${askIllustration(351, 164, 0.52, theme, mode === "dark")}
    ${composer(theme, { x: 20, y: 250, width: 390, height: 154 })}
    ${label(20, 438, "TRY A QUESTION", theme, theme.coralText, 7.4)}
    ${suggestionRow(theme, 20, 454, 390, "What should I focus on today?", theme.lavender)}
    ${suggestionRow(theme, 20, 510, 390, "How can I work with my Moon in Libra?", theme.blue)}
    ${suggestionRow(theme, 20, 566, 390, "What pattern should I notice in relationships?", theme.coral)}
    ${contextSurface(theme, 20, 634, 390, 170)}
    ${phoneTabBar(theme, "Ask")}`;
  return svgShell({
    width: 430,
    height: 932,
    title: `Humay Ask question entry ${mode}`,
    description: "Ask empty state with invitation, compact folded-note illustration, multiline composer, suggested questions and available chart context.",
    mode,
    body
  });
}

function questionEntryIPad(mode) {
  const theme = themes[mode];
  const body = `<rect width="1024" height="1366" fill="${theme.ground}"/>
    ${iPadHeader(theme)}
    <line x1="56" y1="224" x2="968" y2="224" stroke="${theme.hairline}"/>
    <g>
      ${label(56, 272, "YOUR QUESTION", theme, theme.lavenderText, 8)}
      ${multiline(56, 316, ["Bring one honest", "question to the stars."], { className: "editorial", size: 39, fill: theme.ink, lineHeight: 45, maxChars: 24 })}
      ${multiline(56, 434, ["Only relevant astrology context is used", "for this question."], { size: 14, fill: theme.secondary, lineHeight: 21, maxChars: 45 })}
      ${contextSurface(theme, 56, 512, 392, 154)}
      ${label(56, 728, "QUESTIONS THAT WORK WELL", theme, theme.coralText, 8)}
      ${suggestionRow(theme, 56, 746, 392, "What should I focus on today?", theme.lavender)}
      ${suggestionRow(theme, 56, 804, 392, "How can I work with my Moon in Libra?", theme.blue)}
      ${suggestionRow(theme, 56, 862, 392, "What pattern should I notice in relationships?", theme.coral)}
    </g>
    <g>
      ${surface(492, 260, 476, 700, theme, { fill: theme.secondarySurface, radius: 30 })}
      ${askIllustration(730, 380, 1.05, theme, mode === "dark")}
      <text x="530" y="560" class="editorial" font-size="27" fill="${theme.ink}">Start with one honest question.</text>
      ${multiline(530, 594, ["The composer stays at the center of the", "experience, with room to think before asking."], { size: 13, fill: theme.secondary, lineHeight: 20, maxChars: 46 })}
      ${composer(theme, { x: 530, y: 676, width: 400, height: 190 })}
      ${multiline(530, 908, ["Revise the question before asking.", "Nothing is generated until you ask."], { size: 11.5, fill: theme.secondary, lineHeight: 18, maxChars: 48 })}
    </g>`;
  return svgShell({
    width: 1024,
    height: 1366,
    title: `Humay Ask question entry iPad ${mode}`,
    description: "Intentional iPad Ask entry with bounded invitation and context region beside a composer-centered region.",
    mode,
    body
  });
}

function answerReadingPhone(mode) {
  const theme = themes[mode];
  const body = `<rect width="430" height="932" fill="${theme.ground}"/>
    ${phoneHeader(theme, "YOUR READING")}
    ${questionCard(theme, 20, 128, 390, { sample: true, compact: true })}
    <text x="20" y="244" class="editorial" font-size="28" fill="${theme.ink}">A gentler kind of balance</text>
    ${multiline(20, 275, ["Your Moon in Libra may feel steadier when", "you give yourself a moment to choose", "balance before responding."], { size: 12.2, fill: theme.secondary, lineHeight: 18, maxChars: 43 })}
    <line x1="20" y1="331" x2="410" y2="331" stroke="${theme.hairline}"/>
    ${answerSection(theme, 20, 360, 390, "Balance before reaction", ["Harmony does not have to mean silence.", "Let the first feeling become a conversation", "before it becomes a decision."], { accent: theme.lavenderText })}
    ${answerSection(theme, 20, 456, 390, "Make room for beauty and play", ["A small creative ritual can help you hear", "what feels true. Beauty is not a detour", "from the work."], { accent: theme.blueText })}
    ${surface(20, 542, 390, 102, theme, { fill: "url(#meaning-gradient)", radius: 22 })}
    ${label(40, 571, "TRY THIS", theme, theme.coralText, 7.3)}
    ${multiline(40, 600, ["Before a difficult choice, make one small", "beautiful thing. Then ask what leaves more", "room for honesty and ease."], { size: 12.1, fill: theme.ink, lineHeight: 18, maxChars: 43 })}
    ${basisSurface(theme, 20, 654, 390, { compact: false })}
    ${phoneTabBar(theme, "Ask")}`;
  return svgShell({
    width: 430,
    height: 932,
    title: `Humay Ask answer reading ${mode}`,
    description: "Ask answer state showing a development sample question, editorial interpretation, practical reflection and separated factual basis.",
    mode,
    body
  });
}

function answerReadingIPad(mode) {
  const theme = themes[mode];
  const body = `<rect width="1024" height="1366" fill="${theme.ground}"/>
    ${iPadHeader(theme, "YOUR READING")}
    <line x1="56" y1="224" x2="968" y2="224" stroke="${theme.hairline}"/>
    <g>
      ${questionCard(theme, 56, 272, 286, { sample: true, compact: false })}
      ${basisSurface(theme, 56, 406, 286, { compact: true })}
      ${surface(56, 594, 286, 154, theme, { fill: theme.secondarySurface, radius: 20 })}
      ${multiline(76, 657, ["Question first.", "Meaning second.", "Basis stays visible."], { className: "editorial", size: 22, fill: theme.ink, lineHeight: 28 })}
      ${multiline(76, 739, ["No conversation history is implied."], { size: 11.5, fill: theme.secondary })}
    </g>
    <g>
      ${label(402, 273, "YOUR READING", theme, theme.coralText, 8)}
      <text x="402" y="323" class="editorial" font-size="38" fill="${theme.ink}">A gentler kind of balance</text>
      ${multiline(402, 367, ["Your Moon in Libra may feel steadier when you give yourself", "a moment to choose balance before responding.", "Harmony does not have to mean silence."], { size: 14, fill: theme.secondary, lineHeight: 21, maxChars: 62 })}
      <line x1="402" y1="446" x2="968" y2="446" stroke="${theme.hairline}"/>
      ${answerSection(theme, 402, 486, 566, "Balance before reaction", ["Let the first feeling become a conversation before it becomes", "a decision. A little space can make honesty easier to hear."], { accent: theme.lavenderText })}
      ${answerSection(theme, 402, 607, 566, "Make room for beauty and play", ["A small creative ritual can help you notice what feels true.", "Beauty can be one way back to yourself, not a detour."], { accent: theme.blueText })}
      ${surface(402, 738, 566, 142, theme, { fill: "url(#meaning-gradient)", radius: 24 })}
      ${label(430, 774, "TRY THIS", theme, theme.coralText, 7.7)}
      ${multiline(430, 807, ["Before a difficult choice, make one small beautiful thing.", "Then ask what leaves more room for honesty and ease."], { size: 13.5, fill: theme.ink, lineHeight: 21, maxChars: 62 })}
      ${button(402, 906, 220, "Ask another question", theme, { filled: false })}
    </g>`;
  return svgShell({
    width: 1024,
    height: 1366,
    title: `Humay Ask answer reading iPad ${mode}`,
    description: "Intentional iPad Ask answer with question and basis rail beside a bounded editorial reading column.",
    mode,
    body
  });
}

function generatingPhone(mode) {
  const theme = themes[mode];
  const body = `<rect width="430" height="932" fill="${theme.ground}"/>
    ${phoneHeader(theme, "READING")}
    ${questionCard(theme, 20, 128, 390, { compact: true })}
    ${generatingCard(theme, 20, 242, 390, 286)}
    ${contextSurface(theme, 20, 558, 390, 172, { compact: true })}
    ${multiline(20, 766, ["Your reading will appear here when it’s ready."], { size: 11.5, fill: theme.secondary, lineHeight: 18, maxChars: 52 })}
    ${phoneTabBar(theme, "Ask")}`;
  return svgShell({
    width: 430,
    height: 932,
    title: `Humay Ask generating state ${mode}`,
    description: "Honest Ask generating state with submitted question, calm correspondence motion concept, stable skeleton and no fabricated answer text.",
    mode,
    body
  });
}

function generatingIPad(mode) {
  const theme = themes[mode];
  const body = `<rect width="1024" height="1366" fill="${theme.ground}"/>
    ${iPadHeader(theme, "READING")}
    <line x1="56" y1="224" x2="968" y2="224" stroke="${theme.hairline}"/>
    <g>
      ${questionCard(theme, 56, 272, 286, { compact: true })}
      ${contextSurface(theme, 56, 386, 286, 180, { compact: true })}
      ${surface(56, 598, 286, 146, theme, { fill: theme.secondarySurface, radius: 20 })}
      ${label(76, 628, "A QUIET PAUSE", theme, theme.lavenderText, 7.4)}
      ${multiline(76, 665, ["No made-up facts.", "No pretend progress.", "Just a considered pause."], { className: "editorial", size: 21, fill: theme.ink, lineHeight: 27 })}
    </g>
    <g>
      ${label(402, 273, "YOUR READING", theme, theme.coralText, 8)}
      ${generatingCard(theme, 402, 302, 566, 450)}
      ${multiline(402, 805, ["Your reading will appear here when it’s ready."], { size: 13, fill: theme.secondary, lineHeight: 20 })}
    </g>`;
  return svgShell({
    width: 1024,
    height: 1366,
    title: `Humay Ask generating state iPad ${mode}`,
    description: "Intentional iPad Ask generating state with question/context rail and bounded generating surface.",
    mode,
    body
  });
}

function rewardedAccessPhone(mode) {
  const theme = themes[mode];
  const body = `<rect width="430" height="932" fill="${theme.ground}"/>
    ${phoneHeader(theme, "YOUR READING")}
    ${questionCard(theme, 20, 128, 390, { compact: true })}
    ${accessCard(theme, 20, 242, 390, 236)}
    ${premiumCard(theme, 20, 500, 390, 98)}
    ${contextSurface(theme, 20, 620, 390, 172, { compact: true })}
    ${phoneTabBar(theme, "Ask")}`;
  return svgShell({
    width: 430,
    height: 932,
    title: `Humay Ask rewarded access ${mode}`,
    description: "Calm future Rewarded Access state showing one-question access with a Premium alternative and available chart context.",
    mode,
    body
  });
}

function rewardedAccessIPad(mode) {
  const theme = themes[mode];
  const body = `<rect width="1024" height="1366" fill="${theme.ground}"/>
    ${iPadHeader(theme, "YOUR READING")}
    <line x1="56" y1="224" x2="968" y2="224" stroke="${theme.hairline}"/>
    <g>
      ${questionCard(theme, 56, 272, 286, { compact: true })}
      ${contextSurface(theme, 56, 386, 286, 178, { compact: true })}
      ${surface(56, 598, 286, 170, theme, { fill: theme.secondarySurface, radius: 20 })}
      ${label(76, 628, "CACHE FIRST", theme, theme.sage, 7.4)}
      ${multiline(76, 667, ["If the exact answer is already", "valid and cached, it reopens", "without another access step."], { className: "editorial", size: 20, fill: theme.ink, lineHeight: 26 })}
    </g>
    <g>
      ${label(402, 273, "A SINGLE CALM GATE", theme, theme.coralText, 8)}
      ${accessCard(theme, 402, 302, 566, 260)}
      ${premiumCard(theme, 402, 598, 566, 104)}
      ${surface(402, 738, 566, 132, theme, { fill: theme.raised, radius: 22 })}
      ${label(430, 770, "ONE READING", theme, theme.blueText, 7.5)}
      ${multiline(430, 807, ["This step is for this question only.", "A saved reading will not ask again."], { size: 13, fill: theme.secondary, lineHeight: 20 })}
    </g>`;
  return svgShell({
    width: 1024,
    height: 1366,
    title: `Humay Ask rewarded access iPad ${mode}`,
    description: "Intentional iPad Ask access state with question/context rail and bounded future access decision.",
    mode,
    body
  });
}

function boardHeader(theme, kicker, title, detail) {
  return `${label(40, 54, kicker, theme, theme.coralText, 10)}
    <text x="40" y="102" class="editorial" font-size="43" fill="${theme.ink}">${escapeText(title)}</text>
    ${multiline(40, 134, [detail], { size: 14, fill: theme.secondary, lineHeight: 20 })}`;
}

function boardTile(theme, { x, y, width, height, kicker, title, lines, accent = theme.lavenderText, iconType = "check", dark = false }) {
  const tileTheme = dark ? themes.dark : theme;
  const fill = dark ? tileTheme.hero : tileTheme.surface;
  const text = dark ? tileTheme.heroText : tileTheme.ink;
  const secondary = dark ? tileTheme.heroSecondary : tileTheme.secondary;
  return `<g aria-label="${escapeText(title)}">
    <rect x="${x}" y="${y}" width="${width}" height="${height}" rx="24" fill="${fill}" stroke="${tileTheme.hairline}"/>
    <circle cx="${x + 32}" cy="${y + 34}" r="12" fill="${accent}" opacity="0.18"/>
    ${icon(iconType, x + 32, y + 34, accent, 0.72)}
    ${label(x + 56, y + 38, kicker, tileTheme, accent, 7.4)}
    <text x="${x + 28}" y="${y + 82}" class="editorial" font-size="25" fill="${text}">${escapeText(title)}</text>
    ${multiline(x + 28, y + 114, lines, { size: 12.5, fill: secondary, lineHeight: 19, maxChars: 42 })}
  </g>`;
}

function answerAnatomyBoard() {
  const theme = themes.light;
  const body = `<rect width="1600" height="900" fill="#EFE9E2"/>
    ${boardHeader(theme, "D5.1 · REVIEW CANDIDATE", "Answer anatomy + factual basis", "Question identity, interpretation and supplied factors remain visibly separate.")}
    <g>
      ${surface(40, 184, 610, 630, theme, { fill: theme.surface, radius: 28, shadow: true })}
      ${label(76, 226, "QUESTION IDENTITY", theme, theme.tertiary, 8)}
      <text x="76" y="273" class="editorial" font-size="25" fill="${theme.ink}">How can I work with my</text>
      <text x="76" y="305" class="editorial" font-size="25" fill="${theme.ink}">Moon in Libra?</text>
      ${label(76, 354, "DEVELOPMENT SAMPLE · NOT GENERATED", theme, theme.tertiary, 7.2)}
      <line x1="76" y1="386" x2="614" y2="386" stroke="${theme.hairline}"/>
      ${label(76, 426, "INTERPRETATION", theme, theme.lavenderText, 8)}
      <text x="76" y="467" class="editorial" font-size="24" fill="${theme.ink}">Balance before reaction</text>
      ${multiline(76, 502, ["Harmony does not have to mean silence.", "Let the first feeling become a conversation", "before it becomes a decision."], { size: 13, fill: theme.secondary, lineHeight: 20 })}
      <line x1="76" y1="580" x2="614" y2="580" stroke="${theme.hairline}"/>
      ${label(76, 620, "WHAT THIS ANSWER USED", theme, theme.blueText, 8)}
      ${multiline(76, 658, ["Moon in Libra · 14° 27′", "5th house · Western · Tropical", "Known-time development fixture"], { size: 13, fill: theme.ink, lineHeight: 22, weight: 600 })}
    </g>
    <g>
      ${label(742, 226, "REVIEW PRINCIPLE", theme, theme.coralText, 8)}
      ${boardTile(theme, { x: 742, y: 250, width: 400, height: 214, kicker: "READING", title: "Open prose", lines: ["Answer sections breathe on the", "ground. One selective cosmic", "surface may hold a reflection."], accent: theme.lavenderText, iconType: "note" })}
      ${boardTile(theme, { x: 1166, y: 250, width: 394, height: 214, kicker: "BASIS", title: "Visible factors", lines: ["Supplied facts stay compact,", "scannable and separate from", "interpretive language."], accent: theme.blueText, iconType: "shield" })}
      ${boardTile(theme, { x: 742, y: 500, width: 400, height: 214, kicker: "BOUNDARY", title: "No hidden machinery", lines: ["Only the relevant facts and", "reading sections appear here.", "Nothing extra reaches the page."], accent: theme.coralText, iconType: "lock" })}
      ${boardTile(theme, { x: 1166, y: 500, width: 394, height: 214, kicker: "VOICE", title: "May, can, notice", lines: ["Interpretation remains warm,", "specific and non-deterministic.", "No certainty score."], accent: theme.goldText, iconType: "star" })}
    </g>`;
  return svgShell({ width: 1600, height: 900, title: "Humay Ask answer anatomy board", description: "Focused board separating question identity, interpretation and supplied factual basis.", mode: "light", body });
}

function composerKeyboardBoard() {
  const theme = themes.light;
  const tiles = [
    ["EMPTY", "Start lightly", ["What would you like to ask?", "Ask action disabled by label."], theme.lavenderText, "note", false],
    ["MULTILINE", "Room to think", ["Question expands to 2–5 lines", "before its own text scrolls."], theme.blueText, "note", false],
    ["KEYBOARD OPEN", "Action stays visible", ["Composer and Ask remain above", "keyboard; safe-area inset wins."], theme.coralText, "keyboard", true],
    ["LONG QUESTION", "No word fragments", ["Full value wraps naturally.", "No invented character counter."], theme.goldText, "note", false],
    ["DISABLED", "Clear state", ["Empty draft uses a labeled", "disabled Ask action."], theme.tertiary, "lock", false],
    ["ENABLED", "Ask when ready", ["Filled coral action remains", "labeled and easy to reach."], theme.coralText, "check", false],
    ["DYNAMIC TYPE", "Text yields first", ["Heading and question grow;", "illustration gives space."], theme.lavenderText, "note", false],
    ["HARDWARE KEYBOARD", "Native focus", ["Return/Space follow native", "controls; no shortcut invented."], theme.sage, "keyboard", false]
  ];
  const panels = tiles.map(([kicker, title, lines, accent, iconType, dark], index) => {
    const x = 40 + (index % 4) * 390;
    const y = 186 + Math.floor(index / 4) * 314;
    return boardTile(theme, { x, y, width: 350, height: 268, kicker, title, lines, accent, iconType, dark });
  }).join("");
  const body = `<rect width="1600" height="900" fill="#EFE9E2"/>
    ${boardHeader(theme, "D5.1 · COMPOSER PRESSURE", "Composer + keyboard pressure", "Native multiline input, safe-area behavior and accessible focus remain part of the design.")}
    ${panels}`;
  return svgShell({ width: 1600, height: 900, title: "Humay Ask composer and keyboard pressure board", description: "Focused board showing composer states, keyboard visibility, Dynamic Type and hardware keyboard behavior.", mode: "light", body });
}

function accessCacheBoard() {
  const theme = themes.light;
  const cards = [
    ["FREE · NEEDS ACCESS", "Question ready", ["Ask freely. Review the next step", "before creating your reading."], theme.blueText, "note", false],
    ["REWARDED AVAILABLE", "One calm gate", ["Watch an ad for this answer.", "One question, one reading."], theme.goldText, "lock", true],
    ["PREMIUM", "Alternative path", ["Included Ask generation", "without this per-question step."], theme.lavenderText, "star", false],
    ["CACHED ANSWER", "Reopen", ["Exact valid answer returns", "without another ad or call."], theme.sage, "check", true],
    ["REWARD COMPLETED", "Recover fairly", ["If the reading does not finish,", "do not ask for access again."], theme.coralText, "shield", false],
    ["ACCESS IS NOT THE READING", "Truth stays separate", ["Access lets Humay create a reading;", "it does not mean one is ready."], theme.lavenderText, "note", false]
  ];
  const panels = cards.map(([kicker, title, lines, accent, iconType, dark], index) => {
    const x = 40 + (index % 3) * 520;
    const y = 182 + Math.floor(index / 3) * 310;
    return boardTile(theme, { x, y, width: 480, height: 258, kicker, title, lines, accent, iconType, dark });
  }).join("");
  const body = `<rect width="1600" height="840" fill="#EFE9E2"/>
    ${boardHeader(theme, "D5.1 · ACCESS + CACHE", "Access and cache states", "The exact valid result is cache-first; access presentation never becomes an entitlement wallet.")}
    ${panels}`;
  return svgShell({ width: 1600, height: 840, title: "Humay Ask access and cache states board", description: "Focused board covering Free access, Rewarded Access, Premium, saved reopening and fair recovery.", mode: "light", body });
}

function errorContextSafetyBoard() {
  const theme = themes.light;
  const cards = [
    ["OFFLINE · CACHED", "Saved answer", ["Show answer with Offline · saved", "disclosure and freshness."], theme.sage, "wifi-off", false],
    ["OFFLINE · NO CACHE", "Connection needed", ["A new answer needs a connection.", "Keep the question for later."], theme.blueText, "wifi-off", true],
    ["READING DIDN’T FINISH", "Humay couldn’t finish", ["Humay couldn’t finish this reading.", "Offer a calm way to try again."], theme.coralText, "warning", false],
    ["CONTEXT NEEDED", "Show the boundary", ["Explain what Humay knows and", "what context is missing."], theme.goldText, "note", true],
    ["METHOD NOT AVAILABLE", "Not available yet", ["This question needs a different", "astrology method or context."], theme.lavenderText, "shield", false],
    ["SAFETY REFUSAL", "A different kind of help", ["Decline astrology-based medical", "or other high-stakes instructions."], theme.coralText, "shield", true],
    ["READING NOT READY", "Not verified", ["This reading could not be verified.", "Keep the answer hidden until Humay", "can confirm it."], theme.tertiary, "warning", false],
    ["CERTAINTY", "May, can, notice", ["No death, illness, violence or", "financial-disaster certainty claims."], theme.goldText, "star", true]
  ];
  const panels = cards.map(([kicker, title, lines, accent, iconType, dark], index) => {
    const x = 40 + (index % 4) * 390;
    const y = 182 + Math.floor(index / 4) * 326;
    return boardTile(theme, { x, y, width: 350, height: 276, kicker, title, lines, accent, iconType, dark });
  }).join("");
  const body = `<rect width="1600" height="900" fill="#EFE9E2"/>
    ${boardHeader(theme, "D5.1 · CONTEXT + SAFETY", "Error, context and safety states", "Distinct state language keeps missing astrology context separate from a reading that did not finish.")}
    ${panels}`;
  return svgShell({ width: 1600, height: 900, title: "Humay Ask error context and safety board", description: "Focused board covering offline, unfinished readings, missing context, unsupported methodology, safety refusal and certainty boundaries.", mode: "light", body });
}

function accessibilityBoard() {
  const theme = themes.light;
  const body = `<rect width="1600" height="900" fill="#EFE9E2"/>
    ${boardHeader(theme, "D5.1 · ACCESSIBILITY PRESSURE", "Accessibility + long-content pressure", "Meaning remains available when text grows, motion is reduced or visual state cues are unavailable.")}
    <g>
      ${surface(40, 184, 730, 620, theme, { fill: theme.surface, radius: 28 })}
      ${label(76, 226, "DYNAMIC TYPE + LONG ANSWER", theme, theme.coralText, 8)}
      <text x="76" y="278" class="editorial" font-size="36" fill="${theme.ink}">Moon in Libra</text>
      ${multiline(76, 322, ["Question and answer headings wrap before", "illustration or action loses space."], { size: 15, fill: theme.secondary, lineHeight: 23 })}
      <line x1="76" y1="386" x2="734" y2="386" stroke="${theme.hairline}"/>
      ${multiline(76, 432, ["Balance before reaction", "Let the first feeling become a conversation", "before it becomes a decision."], { className: "editorial", size: 25, fill: theme.ink, lineHeight: 31 })}
      <line x1="76" y1="552" x2="734" y2="552" stroke="${theme.hairline}"/>
      ${multiline(76, 596, ["Basis values wrap in full. Suggested rows grow.", "Safety copy stays readable before art yields."], { size: 14, fill: theme.secondary, lineHeight: 22 })}
      ${label(76, 700, "NO TINY TYPE FLOOR", theme, theme.sage, 8)}
      ${multiline(76, 734, ["Long content scrolls; it is not truncated to preserve", "a mockup composition."], { size: 13, fill: theme.secondary, lineHeight: 20 })}
    </g>
    <g>
      <rect x="810" y="184" width="750" height="620" rx="28" fill="${theme.hero}" stroke="${theme.hairline}"/>
      ${label(846, 226, "VOICEOVER + FOCUS", { coralText: "#FF9A98", tertiary: "#C4C0C5" }, "#FF9A98", 8)}
      <text x="846" y="278" class="editorial" font-size="31" fill="${theme.heroText}">Reading order stays visible.</text>
      ${multiline(846, 324, ["Ask heading → question → answer heading → sections", "→ What this answer used → Ask another question"], { size: 14, fill: theme.heroSecondary, lineHeight: 22 })}
      <line x1="846" y1="390" x2="1524" y2="390" stroke="${theme.hairline}"/>
      ${icon("keyboard", 874, 445, "#FF9A98", 0.9)}
      ${multiline(910, 439, ["Composer label, value and Ask action are independently", "focusable. Hardware keyboard uses native activation."], { size: 14, fill: theme.heroText, lineHeight: 22 })}
      ${icon("star", 874, 545, "#E5AA55", 0.56)}
      ${multiline(910, 539, ["Reduce Motion removes orbit movement. Text still names", "the generating state; animation is never the only signal."], { size: 14, fill: theme.heroSecondary, lineHeight: 22 })}
      ${icon("shield", 874, 645, "#77B39A", 0.72)}
      ${multiline(910, 639, ["Offline, access, context and safety use labels plus", "symbols/text; color is not the only carrier of meaning."], { size: 14, fill: theme.heroSecondary, lineHeight: 22 })}
    </g>`;
  return svgShell({ width: 1600, height: 900, title: "Humay Ask accessibility and long content pressure board", description: "Focused board covering Dynamic Type, VoiceOver order, keyboard focus, Reduce Motion and non-color state meaning.", mode: "light", body });
}

function ipadAdaptiveBoard() {
  const theme = themes.light;
  const panels = [
    ["REGULAR PORTRAIT", "Two regions", ["Invitation/context on leading side.", "Composer remains action center."], theme.lavenderText],
    ["LANDSCAPE", "Reading rail + answer", ["Question/basis rail beside bounded", "answer. No full-width prose."], theme.blueText],
    ["NARROW SPLIT VIEW", "Collapse early", ["Hide art, move basis below, return", "to one ordered reading column."], theme.coralText],
    ["KEYBOARD PRESENT", "Safe-area first", ["Composer and Ask remain reachable.", "No action under the keyboard."], theme.goldText]
  ];
  const panelMarkup = panels.map(([kicker, title, lines, accent], index) => {
    const x = 40 + (index % 2) * 780;
    const y = 186 + Math.floor(index / 2) * 306;
    const wire = index === 0
      ? `<rect x="${x + 28}" y="${y + 134}" width="150" height="98" rx="12" fill="${theme.secondarySurface}"/><rect x="${x + 198}" y="${y + 134}" width="210" height="98" rx="12" fill="${theme.surface}" stroke="${theme.hairline}"/>`
      : index === 1
        ? `<rect x="${x + 28}" y="${y + 134}" width="130" height="98" rx="12" fill="${theme.secondarySurface}"/><rect x="${x + 178}" y="${y + 134}" width="230" height="98" rx="12" fill="${theme.surface}" stroke="${theme.hairline}"/>`
        : index === 2
          ? `<rect x="${x + 28}" y="${y + 134}" width="380" height="22" rx="11" fill="${theme.surface}" stroke="${theme.hairline}"/><rect x="${x + 28}" y="${y + 174}" width="380" height="42" rx="12" fill="${theme.surface}" stroke="${theme.hairline}"/>`
          : `<rect x="${x + 28}" y="${y + 134}" width="380" height="48" rx="12" fill="${theme.surface}" stroke="${accent}"/><rect x="${x + 28}" y="${y + 194}" width="380" height="38" rx="19" fill="${theme.coral}"/>`;
    return `<g>${surface(x, y, 730, 264, theme, { fill: theme.surface, radius: 24 })}
      ${label(x + 28, y + 38, kicker, theme, accent, 7.6)}
      <text x="${x + 28}" y="${y + 82}" class="editorial" font-size="27" fill="${theme.ink}">${escapeText(title)}</text>
      ${multiline(x + 28, y + 110, lines, { size: 12.5, fill: theme.secondary, lineHeight: 18 })}
      ${wire}
    </g>`;
  }).join("");
  const body = `<rect width="1600" height="900" fill="#EFE9E2"/>
    ${boardHeader(theme, "D5.1 · ADAPTIVE COMPOSITION", "iPad landscape + Split View", "Width follows content fit. Context and decoration yield before composer or answer readability.")}
    ${panelMarkup}`;
  return svgShell({ width: 1600, height: 900, title: "Humay Ask iPad adaptive and Split View board", description: "Focused board covering regular iPad, landscape, narrow Split View and keyboard-present composition.", mode: "light", body });
}

function illustrationBoard(mode) {
  const theme = themes[mode];
  const dark = mode === "dark";
  const body = `<rect width="800" height="600" fill="${theme.ground}"/>
    ${label(36, 48, `D5.1 · ILLUSTRATION PREVIEW · ${mode}`, theme, theme.coralText, 8.5)}
    ${askIllustration(400, 260, 1.65, theme, dark)}
    <text x="400" y="468" text-anchor="middle" class="editorial" font-size="28" fill="${theme.ink}">IllustrationAskStars</text>
    <text x="400" y="500" text-anchor="middle" class="ui" font-size="13" fill="${theme.secondary}">Folded note · moon · restrained correspondence orbit</text>
    <text x="400" y="536" text-anchor="middle" class="ui" font-size="11" fill="${theme.tertiary}">Reference-only concept · not a production asset</text>`;
  return svgShell({ width: 800, height: 600, title: `Humay Ask illustration concept ${mode}`, description: "Reference-only flat vector concept: a folded note carried by a restrained moon and star orbit.", mode, body });
}

async function writeSvgAndPng(name, svg, { width, height, scale = 1 }) {
  const svgPath = path.join(outputDirectory, `${name}.svg`);
  const pngPath = path.join(outputDirectory, `${name}.png`);
  const normalizedSvg = svg.trimEnd() + "\n";
  fs.writeFileSync(svgPath, normalizedSvg, "utf8");
  if (sharp) {
    await sharp(Buffer.from(normalizedSvg))
      .resize({ width: width * scale, height: height * scale, fit: "fill" })
      .png({ compressionLevel: 9, adaptiveFiltering: true })
      .toFile(pngPath);
  } else {
    execFileSync("/usr/bin/sips", ["-s", "format", "png", svgPath, "--out", pngPath], { stdio: "ignore" });
    if (scale !== 1) {
      execFileSync("/usr/bin/sips", ["-z", String(height * scale), String(width * scale), pngPath], { stdio: "ignore" });
    }
  }
}

async function main() {
  for (const mode of ["light", "dark"]) {
    await writeSvgAndPng(`question-entry-iphone-${mode}`, questionEntryPhone(mode), { width: 430, height: 932, scale: 2 });
    await writeSvgAndPng(`question-entry-ipad-${mode}`, questionEntryIPad(mode), { width: 1024, height: 1366, scale: 2 });
    await writeSvgAndPng(`answer-reading-iphone-${mode}`, answerReadingPhone(mode), { width: 430, height: 932, scale: 2 });
    await writeSvgAndPng(`answer-reading-ipad-${mode}`, answerReadingIPad(mode), { width: 1024, height: 1366, scale: 2 });
    await writeSvgAndPng(`generating-iphone-${mode}`, generatingPhone(mode), { width: 430, height: 932, scale: 2 });
    await writeSvgAndPng(`generating-ipad-${mode}`, generatingIPad(mode), { width: 1024, height: 1366, scale: 2 });
    await writeSvgAndPng(`rewarded-access-iphone-${mode}`, rewardedAccessPhone(mode), { width: 430, height: 932, scale: 2 });
    await writeSvgAndPng(`rewarded-access-ipad-${mode}`, rewardedAccessIPad(mode), { width: 1024, height: 1366, scale: 2 });
    await writeSvgAndPng(`illustration-ask-stars-${mode}`, illustrationBoard(mode), { width: 800, height: 600 });
  }

  await writeSvgAndPng("answer-anatomy", answerAnatomyBoard(), { width: 1600, height: 900 });
  await writeSvgAndPng("composer-keyboard", composerKeyboardBoard(), { width: 1600, height: 900 });
  await writeSvgAndPng("access-cache-states", accessCacheBoard(), { width: 1600, height: 840 });
  await writeSvgAndPng("error-context-safety", errorContextSafetyBoard(), { width: 1600, height: 900 });
  await writeSvgAndPng("accessibility-long-content", accessibilityBoard(), { width: 1600, height: 900 });
  await writeSvgAndPng("ipad-adaptive", ipadAdaptiveBoard(), { width: 1600, height: 900 });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
