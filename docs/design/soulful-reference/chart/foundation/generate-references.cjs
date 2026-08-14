const fs = require("node:fs");
const path = require("node:path");
const { execFileSync } = require("node:child_process");

let sharp = null;
try {
  sharp = require("sharp");
} catch {
  // Sips fallback keeps the generator usable on a clean macOS checkout.
}

const outputDirectory = __dirname;
fs.mkdirSync(outputDirectory, { recursive: true });

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
    <linearGradient id="preview-gradient" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="${mode === "light" ? "#F1E8F3" : "#292741"}"/>
      <stop offset="1" stop-color="${mode === "light" ? "#E7F0F1" : "#1E3543"}"/>
    </linearGradient>
    <linearGradient id="meaning-gradient" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="${theme.coralWash}"/>
      <stop offset="1" stop-color="${theme.lavenderWash}"/>
    </linearGradient>
    <filter id="soft-shadow" x="-30%" y="-30%" width="160%" height="180%">
      <feDropShadow dx="0" dy="5" stdDeviation="10" flood-color="${theme.shadow}" flood-opacity="${mode === "light" ? "0.09" : "0"}"/>
    </filter>
    ${extraDefinitions}
  </defs>
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

function iconMarkup(type, x, y, color) {
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

function phoneTabBar(theme, selected = "Chart") {
  const items = [
    ["Today", 52, "sun"],
    ["Circle", 132, "people"],
    ["Sky", 215, "sky"],
    ["Chart", 298, "chart"],
    ["Ask", 378, "ask"]
  ];
  return `<g aria-label="Primary navigation, ${escapeText(selected)} selected" filter="url(#soft-shadow)">
    <rect x="14" y="838" width="402" height="76" rx="32" fill="${theme.tab}" stroke="${theme.hairline}"/>
    <rect x="${selected === "Chart" ? 258 : 174}" y="844" width="82" height="64" rx="26" fill="${theme.tabSelected}"/>
    ${items.map(([label, x, type]) => {
      const active = label === selected;
      const color = active ? theme.coralText : theme.ink;
      return `<g style="color:${color}">${iconMarkup(type, x, 861, color)}<text x="${x}" y="897" text-anchor="middle" class="ui" font-size="10" font-weight="${active ? "750" : "550"}" fill="${color}">${label}</text></g>`;
    }).join("")}
  </g>`;
}

function iPadTopNavigation(theme, selected = "Chart") {
  const labels = ["Today", "Circle", "Sky", "Chart", "Ask"];
  const xs = [340, 430, 520, 625, 725];
  const selectedIndex = labels.indexOf(selected);
  return `<g aria-label="Adaptive primary navigation, ${escapeText(selected)} selected" filter="url(#soft-shadow)">
    <rect x="288" y="46" width="456" height="56" rx="28" fill="${theme.tab}" stroke="${theme.hairline}"/>
    <rect x="${xs[selectedIndex] - 43}" y="52" width="86" height="44" rx="22" fill="${theme.tabSelected}"/>
    ${labels.map((label, index) => {
      const active = label === selected;
      const color = active ? theme.coralText : theme.ink;
      return `<g><text x="${xs[index]}" y="81" text-anchor="middle" class="ui" font-size="15" font-weight="${active ? "750" : "600"}" fill="${color}">${label}</text></g>`;
    }).join("")}
  </g>`;
}

function chevron(x, y, direction, theme, size = 5) {
  const sign = direction === "left" ? -1 : 1;
  return `<path d="M${x - sign * size} ${y - size}l${sign * size} ${size} ${-sign * size} ${size}" fill="none" stroke="${theme.ink}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>`;
}

function backHeader(theme, { phone = true, origin = "Chart", title = "Chart" } = {}) {
  if (phone) {
    return `<g aria-label="Back to ${escapeText(origin)}, ${escapeText(title)}">
      <rect x="12" y="43" width="138" height="44" rx="22" fill="transparent"/>
      ${chevron(27, 65, "left", theme, 4.5)}
      <text x="39" y="70" class="ui" font-size="14" font-weight="600" fill="${theme.coralText}">${escapeText(origin)}</text>
      <text x="215" y="70" text-anchor="middle" class="ui" font-size="16" font-weight="700" fill="${theme.ink}">${escapeText(title)}</text>
    </g>`;
  }
  return `<g aria-label="Back to ${escapeText(origin)}, ${escapeText(title)}">
    <rect x="48" y="122" width="170" height="44" rx="22" fill="transparent"/>
    ${chevron(66, 144, "left", theme, 5)}
    <text x="84" y="149" class="ui" font-size="15" font-weight="650" fill="${theme.coralText}">${escapeText(origin)}</text>
    <text x="250" y="151" class="editorial" font-size="34" fill="${theme.ink}">${escapeText(title)}</text>
  </g>`;
}

function sampleNotice(x, y, theme, width = 210) {
  return `<g aria-label="Development sample, not calculated">
    <rect x="${x}" y="${y}" width="${width}" height="23" rx="11.5" fill="${theme.secondarySurface}" stroke="${theme.hairline}" stroke-width="0.7"/>
    <path d="M${x + 10} ${y + 10}l4-4 3 3-4 4m-2-1 5 5m-7-1 3-3" fill="none" stroke="${theme.tertiary}" stroke-width="1.4" stroke-linecap="round"/>
    <text x="${x + 25}" y="${y + 15.5}" class="ui" font-size="9.4" font-weight="650" fill="${theme.secondary}">Development sample · not calculated</text>
  </g>`;
}

function label(x, y, text, theme, color = theme.coralText, size = 8.5) {
  return `<text x="${x}" y="${y}" class="label" font-size="${size}" fill="${color}">${escapeText(text.toUpperCase())}</text>`;
}

function button(x, y, width, text, theme, filled = true) {
  return `<g aria-label="${escapeText(text)}">
    <rect x="${x}" y="${y}" width="${width}" height="44" rx="22" fill="${filled ? theme.coral : "transparent"}" stroke="${filled ? theme.coral : theme.hairline}"/>
    <text x="${x + width / 2}" y="${y + 27}" text-anchor="middle" class="ui" font-size="13" font-weight="700" fill="${filled ? "#FFFFFF" : theme.coralText}">${escapeText(text)}</text>
  </g>`;
}

function abstractPreview({ x, y, width, height, theme, mode, labelText = "ILLUSTRATIVE PREVIEW" }) {
  const cx = x + width * 0.56;
  const cy = y + height * 0.53;
  const r = Math.min(width, height) * 0.28;
  return `<g aria-label="${escapeText(labelText)}. Not a personalized natal chart.">
    <rect x="${x}" y="${y}" width="${width}" height="${height}" rx="22" fill="url(#preview-gradient)" stroke="${theme.hairline}"/>
    <circle cx="${cx}" cy="${cy}" r="${r * 1.25}" fill="none" stroke="${theme.lavender}" stroke-width="1" opacity="0.38"/>
    <ellipse cx="${cx}" cy="${cy}" rx="${r * 1.42}" ry="${r * 0.42}" fill="none" stroke="${theme.gold}" stroke-width="1.4" opacity="0.72" transform="rotate(-20 ${cx} ${cy})"/>
    <ellipse cx="${cx}" cy="${cy}" rx="${r * 1.18}" ry="${r * 0.34}" fill="none" stroke="${theme.blue}" stroke-width="1" opacity="0.72" transform="rotate(28 ${cx} ${cy})"/>
    <circle cx="${cx}" cy="${cy}" r="${r * 0.62}" fill="${mode === "light" ? "#FFFDFC" : "#162335"}" opacity="0.82" stroke="${theme.coral}" stroke-width="1.4"/>
    <path d="M${cx} ${cy - r * 0.48}v${r * 0.96}M${cx - r * 0.48} ${cy}h${r * 0.96}" stroke="${theme.coral}" stroke-width="1" opacity="0.7"/>
    <circle cx="${cx + r * 0.92}" cy="${cy - r * 0.64}" r="3" fill="${theme.coral}"/>
    <circle cx="${cx - r * 1.05}" cy="${cy + r * 0.52}" r="2.2" fill="${theme.lavender}"/>
    <path d="M${x + 20} ${y + height - 27}h24" stroke="${theme.coralText}" stroke-width="2.5" stroke-linecap="round"/>
    <text x="${x + 20}" y="${y + height - 11}" class="label" font-size="7.2" fill="${theme.secondary}">${escapeText(labelText)}</text>
  </g>`;
}

function readinessRow({ x, y, width, title, value, detail, color, theme, last = false }) {
  return `<g aria-label="${escapeText(title)}: ${escapeText(value)}. ${escapeText(detail)}">
    <circle cx="${x + 8}" cy="${y + 9}" r="4" fill="${color}"/>
    <text x="${x + 22}" y="${y + 13}" class="ui" font-size="12.5" font-weight="700" fill="${theme.ink}">${escapeText(title)}</text>
    <text x="${x + width - 10}" y="${y + 13}" text-anchor="end" class="ui" font-size="12" font-weight="700" fill="${color}">${escapeText(value)}</text>
    <text x="${x + 22}" y="${y + 32}" class="ui" font-size="10.5" fill="${theme.secondary}">${escapeText(detail)}</text>
    ${last ? "" : `<line x1="${x}" y1="${y + 48}" x2="${x + width}" y2="${y + 48}" stroke="${theme.hairline}"/>`}
  </g>`;
}

function accessCard({ x, y, width, height, theme, mode, locked = true }) {
  const compactCopy = width <= 400;
  const detail = locked
    ? (compactCopy ? "Exact placements. Honest basis." : "Exact placements, houses and a basis you can inspect.")
    : "Cached facts open without another access event.";
  return `<g aria-label="Precision access explanation">
    <rect x="${x}" y="${y}" width="${width}" height="${height}" rx="22" fill="url(#hero-gradient)" stroke="${mode === "light" ? "#30394A" : theme.hairline}"/>
    <circle cx="${x + 30}" cy="${y + 32}" r="12" fill="${theme.gold}" opacity="0.18"/>
    <path d="M${x + 25} ${y + 31}a5 5 0 0 1 10 0v7h-10Zm2-1v-3a3 3 0 0 1 6 0v3" fill="none" stroke="${theme.gold}" stroke-width="1.5" stroke-linecap="round"/>
    ${label(x + 52, y + 26, locked ? "PRECISION PATH" : "CACHED RESULT", theme, theme.heroSecondary, 7.1)}
    <text x="${x + 20}" y="${y + 61}" class="editorial" font-size="${width > 500 ? 24 : 21}" fill="${theme.heroText}">${locked ? "What precision unlocks" : "Ready to reopen"}</text>
    <text x="${x + 20}" y="${y + 87}" class="ui" font-size="${width > 500 ? 12.5 : 11.5}" fill="${theme.heroSecondary}">${detail}</text>
    ${locked ? button(x + width - 150, y + height - 58, 130, "Explore access", theme, false) : ""}
  </g>`;
}

function polar(cx, cy, radius, angleDegrees) {
  const angle = angleDegrees * Math.PI / 180;
  return { x: cx + Math.cos(angle) * radius, y: cy + Math.sin(angle) * radius };
}

function wheel({ cx, cy, radius, theme, knownTime = true, selected = "Moon", compact = false }) {
  const signs = ["ARI", "TAU", "GEM", "CAN", "LEO", "VIR", "LIB", "SCO", "SAG", "CAP", "AQU", "PIS"];
  const planetData = [
    ["Su", -24, theme.goldText],
    ["Mo", 164, theme.coralText],
    ["Me", 38, theme.blueText],
    ["Ve", 106, theme.lavenderText],
    ["Ma", 218, theme.coralText],
    ["Ju", 286, theme.goldText],
    ["Sa", 330, theme.sage]
  ];
  const pointMap = {};
  let markup = `<g aria-label="Western natal wheel, ${knownTime ? "known-time fixture with houses" : "date basis without houses"}">
    <circle cx="${cx}" cy="${cy}" r="${radius}" fill="${theme.surface}" stroke="${theme.hairline}" stroke-width="1.4"/>
    <circle cx="${cx}" cy="${cy}" r="${radius * 0.82}" fill="${knownTime ? theme.secondarySurface : theme.ground}" stroke="${theme.hairline}"/>
    <circle cx="${cx}" cy="${cy}" r="${radius * 0.62}" fill="${theme.surface}" stroke="${theme.hairline}"/>
  `;

  for (let index = 0; index < 12; index += 1) {
    const start = -90 + index * 30;
    const end = start + 30;
    const p1 = polar(cx, cy, radius, start);
    const p2 = polar(cx, cy, radius, end);
    const mid = polar(cx, cy, radius * 0.91, start + 15);
    markup += `<path d="M${cx} ${cy}L${p1.x.toFixed(2)} ${p1.y.toFixed(2)}A${radius} ${radius} 0 0 1 ${p2.x.toFixed(2)} ${p2.y.toFixed(2)}Z" fill="${index % 2 === 0 ? theme.secondarySurface : theme.surface}" fill-opacity="0.48" stroke="${theme.hairline}" stroke-width="0.7"/>
      <text x="${mid.x.toFixed(2)}" y="${(mid.y + (compact ? 2.5 : 3.5)).toFixed(2)}" text-anchor="middle" class="ui" font-size="${compact ? 6.3 : 8.3}" font-weight="700" fill="${theme.secondary}">${signs[index]}</text>`;
  }

  if (knownTime) {
    for (let index = 0; index < 12; index += 1) {
      const point = polar(cx, cy, radius * 0.81, -90 + index * 30);
      markup += `<line x1="${cx}" y1="${cy}" x2="${point.x.toFixed(2)}" y2="${point.y.toFixed(2)}" stroke="${theme.hairline}" stroke-width="0.8" opacity="0.82"/>`;
      const house = polar(cx, cy, radius * 0.54, -90 + index * 30 + 15);
      markup += `<text x="${house.x.toFixed(2)}" y="${(house.y + 2.5).toFixed(2)}" text-anchor="middle" class="mono" font-size="${compact ? 5.5 : 7}" fill="${theme.tertiary}">${index + 1}</text>`;
    }
  }

  for (const [name, angle, color] of planetData) {
    pointMap[name] = polar(cx, cy, radius * 0.55, angle - 90);
  }
  const aspectPairs = [["Su", "Mo"], ["Me", "Sa"], ["Ve", "Ma"]];
  for (const [first, second] of aspectPairs) {
    const a = pointMap[first];
    const b = pointMap[second];
    markup += `<line x1="${a.x.toFixed(2)}" y1="${a.y.toFixed(2)}" x2="${b.x.toFixed(2)}" y2="${b.y.toFixed(2)}" stroke="${theme.lavenderText}" stroke-width="${compact ? 0.75 : 1.1}" opacity="0.46"/>`;
  }
  for (const [name, angle, color] of planetData) {
    const point = pointMap[name];
    const isSelected = selected === (name === "Mo" ? "Moon" : name);
    markup += `<g aria-label="${name === "Mo" ? "Moon" : name} marker">
      ${isSelected ? `<circle cx="${point.x.toFixed(2)}" cy="${point.y.toFixed(2)}" r="${compact ? 10 : 13}" fill="none" stroke="${theme.goldText}" stroke-width="1.5"/>` : ""}
      <circle cx="${point.x.toFixed(2)}" cy="${point.y.toFixed(2)}" r="${compact ? 5 : 6.5}" fill="${theme.surface}" stroke="${color}" stroke-width="${compact ? 1.4 : 1.8}"/>
      <text x="${point.x.toFixed(2)}" y="${(point.y + (compact ? 2 : 2.6)).toFixed(2)}" text-anchor="middle" class="ui" font-size="${compact ? 5.5 : 7.2}" font-weight="750" fill="${color}">${name}</text>
    </g>`;
  }
  markup += `<circle cx="${cx}" cy="${cy}" r="${radius * 0.18}" fill="${theme.ground}" stroke="${theme.hairline}"/>
    <text x="${cx}" y="${cy - 2}" text-anchor="middle" class="label" font-size="${compact ? 5.6 : 7}" fill="${theme.coralText}">WESTERN</text>
    <text x="${cx}" y="${cy + 10}" text-anchor="middle" class="ui" font-size="${compact ? 6.5 : 8.5}" fill="${theme.secondary}">${knownTime ? "HOUSES SHOWN" : "NO HOUSES"}</text>
  </g>`;
  return markup;
}

function miniPlacement({ x, y, width, title, value, detail, color, theme }) {
  return `<g aria-label="${escapeText(title)} ${escapeText(value)}. ${escapeText(detail)}">
    <rect x="${x}" y="${y}" width="${width}" height="84" rx="18" fill="${theme.surface}" stroke="${theme.hairline}"/>
    <circle cx="${x + 20}" cy="${y + 24}" r="5" fill="${color}"/>
    <text x="${x + 34}" y="${y + 29}" class="label" font-size="7.2" fill="${theme.tertiary}">${escapeText(title.toUpperCase())}</text>
    <text x="${x + 18}" y="${y + 57}" class="ui" font-size="14" font-weight="700" fill="${theme.ink}">${escapeText(value)}</text>
    <text x="${x + 18}" y="${y + 73}" class="mono" font-size="8.8" fill="${theme.secondary}">${escapeText(detail)}</text>
  </g>`;
}

function factRow({ x, y, width, title, value, detail, theme, valueColor = theme.ink, last = false }) {
  return `<g aria-label="${escapeText(title)}: ${escapeText(value)}. ${escapeText(detail)}">
    <text x="${x}" y="${y + 12}" class="label" font-size="7.2" fill="${theme.tertiary}">${escapeText(title.toUpperCase())}</text>
    <text x="${x + 118}" y="${y + 13}" class="ui" font-size="12.5" font-weight="700" fill="${valueColor}">${escapeText(value)}</text>
    <text x="${x + 118}" y="${y + 31}" class="ui" font-size="10" fill="${theme.secondary}">${escapeText(detail)}</text>
    ${last ? "" : `<line x1="${x}" y1="${y + 47}" x2="${x + width}" y2="${y + 47}" stroke="${theme.hairline}"/>`}
  </g>`;
}

function noteBlock({ x, y, width, height, theme, title, headline, body, mode }) {
  return `<g aria-label="${escapeText(title)}">
    <rect x="${x}" y="${y}" width="${width}" height="${height}" rx="22" fill="url(#meaning-gradient)" stroke="${theme.hairline}"/>
    <path d="M${x + 22} ${y + 25}h34" stroke="${theme.coralText}" stroke-width="3" stroke-linecap="round"/>
    ${label(x + 22, y + 49, title, theme, theme.coralText, 7.2)}
    <text x="${x + 22}" y="${y + 82}" class="editorial" font-size="${width > 400 ? 25 : 21}" fill="${theme.ink}">${escapeText(headline)}</text>
    ${body.map((line, index) => `<text x="${x + 22}" y="${y + 111 + index * 19}" class="ui" font-size="${width > 400 ? 12.5 : 11.5}" fill="${theme.secondary}">${escapeText(line)}</text>`).join("")}
  </g>`;
}

function overviewPhone(mode) {
  const theme = themes[mode];
  const body = `<rect width="430" height="932" fill="${theme.ground}"/>
    ${statusBar(430, theme, "phone")}
    <text x="20" y="80" class="editorial" font-size="34" fill="${theme.ink}">Chart</text>
    ${label(20, 111, "PERSONAL CELESTIAL STRUCTURE", theme, theme.coralText, 7.3)}
    <text x="20" y="149" class="editorial" font-size="31" fill="${theme.ink}">Your personal sky map</text>
    <text x="20" y="181" class="ui" font-size="12.4" fill="${theme.secondary}">A place to explore the patterns, placements and</text>
    <text x="20" y="200" class="ui" font-size="12.4" fill="${theme.secondary}">basis behind a precision chart.</text>
    ${sampleNotice(20, 224, theme, 210)}
    <g aria-label="Free Chart entry, illustrative preview not a personal chart">
      <rect x="20" y="262" width="390" height="178" rx="25" fill="${theme.surface}" stroke="${theme.hairline}" filter="url(#soft-shadow)"/>
      <text x="42" y="296" class="label" font-size="7.4" fill="${theme.tertiary}">FREE ENTRY</text>
      <text x="42" y="329" class="editorial" font-size="23" fill="${theme.ink}">A map of your sky.</text>
      <text x="42" y="357" class="ui" font-size="11.5" fill="${theme.secondary}">Precision later reveals placements</text>
      <text x="42" y="375" class="ui" font-size="11.5" fill="${theme.secondary}">when the basis is ready.</text>
      ${button(42, 388, 148, "See what unlocks", theme, false)}
      ${abstractPreview({ x: 252, y: 278, width: 138, height: 142, theme, mode, labelText: "NOT YOUR CHART" })}
    </g>
    <g aria-label="Birth-data readiness">
      <rect x="20" y="460" width="390" height="210" rx="22" fill="${theme.surface}" stroke="${theme.hairline}"/>
      ${label(42, 490, "BIRTH-DATA READINESS", theme, theme.tertiary, 7.4)}
      ${readinessRow({ x: 42, y: 509, width: 346, title: "Birth date", value: "Supplied", detail: "Date-valid facts may be available later.", color: theme.sage, theme })}
      ${readinessRow({ x: 42, y: 567, width: 346, title: "Birth time", value: "Unknown", detail: "Ascendant and houses stay unavailable.", color: theme.goldText, theme })}
      ${readinessRow({ x: 42, y: 625, width: 346, title: "Birth place", value: "Not added", detail: "Place-dependent precision needs location.", color: theme.coralText, theme, last: true })}
    </g>
    ${accessCard({ x: 20, y: 675, width: 390, height: 133, theme, mode })}
    ${phoneTabBar(theme, "Chart")}`;
  return svgShell({
    width: 430,
    height: 932,
    title: `Humay Chart Overview Free entry ${mode}`,
    description: "Chart Overview Free entry reference. Educational preview only; no personalized natal chart is calculated.",
    mode,
    body
  });
}

function overviewIPad(mode) {
  const theme = themes[mode];
  const body = `<rect width="1024" height="1366" fill="${theme.ground}"/>
    ${statusBar(1024, theme, "ipad")}
    ${iPadTopNavigation(theme, "Chart")}
    <text x="56" y="166" class="editorial" font-size="43" fill="${theme.ink}">Your personal sky map</text>
    <text x="56" y="200" class="ui" font-size="14" fill="${theme.secondary}">Chart gives personal celestial structure without pretending missing inputs are known.</text>
    ${sampleNotice(56, 225, theme, 210)}
    <g aria-label="Chart overview iPad leading content">
      <rect x="56" y="270" width="410" height="276" rx="26" fill="${theme.surface}" stroke="${theme.hairline}" filter="url(#soft-shadow)"/>
      ${label(84, 307, "FREE ENTRY", theme, theme.tertiary, 8)}
      <text x="84" y="347" class="editorial" font-size="29" fill="${theme.ink}">Start with the structure.</text>
      <text x="84" y="382" class="ui" font-size="13" fill="${theme.secondary}">Explore what placements, patterns and</text>
      <text x="84" y="403" class="ui" font-size="13" fill="${theme.secondary}">basis could look like after precision.</text>
      ${button(84, 448, 154, "See what unlocks", theme, false)}
      <line x1="84" y1="510" x2="438" y2="510" stroke="${theme.hairline}"/>
      <text x="84" y="532" class="ui" font-size="11.5" fill="${theme.secondary}">No calculation runs from this Free preview.</text>
    </g>
    <g aria-label="Chart overview iPad trailing preview">
      <rect x="510" y="270" width="458" height="470" rx="28" fill="${theme.surface}" stroke="${theme.hairline}"/>
      ${abstractPreview({ x: 536, y: 296, width: 406, height: 300, theme, mode, labelText: "ILLUSTRATIVE · NOT YOUR CHART" })}
      <text x="536" y="641" class="editorial" font-size="28" fill="${theme.ink}">Precision, when ready</text>
      <text x="536" y="676" class="ui" font-size="13" fill="${theme.secondary}">Exact placements and time-sensitive structure</text>
      <text x="536" y="697" class="ui" font-size="13" fill="${theme.secondary}">need a supported birth basis and access path.</text>
    </g>
    <g aria-label="Birth-data readiness and future access">
      <rect x="56" y="582" width="410" height="282" rx="26" fill="${theme.surface}" stroke="${theme.hairline}"/>
      ${label(84, 620, "BIRTH-DATA READINESS", theme, theme.tertiary, 8)}
      ${readinessRow({ x: 84, y: 640, width: 354, title: "Birth date", value: "Supplied", detail: "Date-valid facts may remain available.", color: theme.sage, theme })}
      ${readinessRow({ x: 84, y: 698, width: 354, title: "Birth time", value: "Unknown", detail: "Ascendant and houses stay withheld.", color: theme.goldText, theme })}
      ${readinessRow({ x: 84, y: 756, width: 354, title: "Birth place", value: "Not added", detail: "Place-dependent precision needs location.", color: theme.coralText, theme, last: true })}
      <text x="84" y="840" class="ui" font-size="11.5" fill="${theme.secondary}">Adding time/place expands the chart; it does not complete you.</text>
    </g>
    ${accessCard({ x: 510, y: 770, width: 458, height: 145, theme, mode })}
    <text x="56" y="1002" class="label" font-size="8" fill="${theme.tertiary}">NEXT LAYER</text>
    <text x="56" y="1037" class="editorial" font-size="29" fill="${theme.ink}">Big Three · placements · patterns</text>
    <text x="56" y="1070" class="ui" font-size="13" fill="${theme.secondary}">Future destinations stay visible without fabricating their contents.</text>`;
  return svgShell({
    width: 1024,
    height: 1366,
    title: `Humay Chart Overview Free entry iPad ${mode}`,
    description: "iPad Chart Overview Free entry with deliberate two-region composition and explicit no-calculation boundary.",
    mode,
    body
  });
}

function loadedPhone(mode) {
  const theme = themes[mode];
  const body = `<rect width="430" height="932" fill="${theme.ground}"/>
    ${statusBar(430, theme, "phone")}
    <text x="20" y="80" class="editorial" font-size="34" fill="${theme.ink}">Western chart</text>
    ${sampleNotice(20, 94, theme, 210)}
    <g aria-label="Chart identity and basis">
      <rect x="20" y="132" width="390" height="70" rx="20" fill="${theme.surface}" stroke="${theme.hairline}"/>
      ${label(40, 159, "WESTERN · TROPICAL", theme, theme.coralText, 7.1)}
      <text x="40" y="185" class="ui" font-size="12" fill="${theme.secondary}">14 March 1994  ·  Known-time fixture</text>
      <circle cx="382" cy="166" r="5" fill="${theme.gold}"/>
    </g>
    ${wheel({ cx: 215, cy: 331, radius: 116, theme, knownTime: true, selected: "Moon", compact: true })}
    <text x="20" y="474" class="editorial" font-size="26" fill="${theme.ink}">Key placements</text>
    <text x="410" y="474" text-anchor="end" class="ui" font-size="11" font-weight="700" fill="${theme.coralText}">ALL PLACEMENTS  ›</text>
    ${miniPlacement({ x: 20, y: 492, width: 187, title: "SUN", value: "Aquarius", detail: "22° 11′", color: theme.goldText, theme })}
    ${miniPlacement({ x: 223, y: 492, width: 187, title: "MOON", value: "Libra", detail: "14° 27′", color: theme.coralText, theme })}
    ${miniPlacement({ x: 20, y: 586, width: 187, title: "ASCENDANT", value: "Gemini", detail: "03° 02′", color: theme.blueText, theme })}
    ${miniPlacement({ x: 223, y: 586, width: 187, title: "HIGHLIGHT", value: "Sun trine Moon", detail: "Major aspect · sample", color: theme.lavenderText, theme })}
    <g aria-label="Basis disclosure">
      <rect x="20" y="692" width="390" height="106" rx="20" fill="${theme.secondarySurface}" stroke="${theme.hairline}"/>
      ${label(40, 721, "BASIS", theme, theme.tertiary, 7.2)}
      <text x="40" y="750" class="ui" font-size="11.5" fill="${theme.secondary}">Exact time + place assumed for this development fixture.</text>
      <text x="40" y="774" class="ui" font-size="11.5" fill="${theme.secondary}">Houses and Ascendant are not shown in unknown-time states.</text>
    </g>
    ${phoneTabBar(theme, "Chart")}`;
  return svgShell({
    width: 430,
    height: 932,
    title: `Humay Western loaded Chart iPhone ${mode}`,
    description: "Development-sample Western Chart overview with readable natal wheel, key placements, restrained aspect highlight and basis disclosure.",
    mode,
    body
  });
}

function loadedIPad(mode) {
  const theme = themes[mode];
  const body = `<rect width="1024" height="1366" fill="${theme.ground}"/>
    ${statusBar(1024, theme, "ipad")}
    ${iPadTopNavigation(theme, "Chart")}
    ${backHeader(theme, { phone: false, origin: "Chart", title: "Western chart" })}
    ${sampleNotice(56, 177, theme, 210)}
    <g aria-label="Western chart wheel region">
      <rect x="56" y="222" width="444" height="744" rx="28" fill="${theme.surface}" stroke="${theme.hairline}" filter="url(#soft-shadow)"/>
      ${label(84, 261, "WESTERN · TROPICAL", theme, theme.coralText, 8)}
      <text x="84" y="292" class="ui" font-size="13" fill="${theme.secondary}">14 March 1994  ·  Known-time fixture</text>
      ${wheel({ cx: 278, cy: 572, radius: 208, theme, knownTime: true, selected: "Moon", compact: false })}
      <text x="84" y="904" class="ui" font-size="11.5" fill="${theme.secondary}">Wheel is paired with a spoken placement list.</text>
    </g>
    <g aria-label="Western chart detail region">
      <rect x="538" y="222" width="430" height="744" rx="28" fill="${theme.surface}" stroke="${theme.hairline}"/>
      ${label(568, 261, "KEY PLACEMENTS", theme, theme.tertiary, 8)}
      <text x="568" y="301" class="editorial" font-size="32" fill="${theme.ink}">The shape of this chart</text>
      <text x="568" y="334" class="ui" font-size="13" fill="${theme.secondary}">A readable summary before the complete placement list.</text>
      ${miniPlacement({ x: 568, y: 371, width: 370, title: "SUN", value: "Aquarius", detail: "22° 11′ · sample", color: theme.goldText, theme })}
      ${miniPlacement({ x: 568, y: 465, width: 370, title: "MOON", value: "Libra", detail: "14° 27′ · selected", color: theme.coralText, theme })}
      ${miniPlacement({ x: 568, y: 559, width: 370, title: "ASCENDANT", value: "Gemini", detail: "03° 02′ · known-time", color: theme.blueText, theme })}
      <line x1="568" y1="668" x2="938" y2="668" stroke="${theme.hairline}"/>
      ${label(568, 700, "SELECTED HIGHLIGHT", theme, theme.tertiary, 7.6)}
      <text x="568" y="735" class="editorial" font-size="25" fill="${theme.ink}">Sun trine Moon</text>
      <text x="568" y="765" class="ui" font-size="12.5" fill="${theme.secondary}">Major aspect · development sample only.</text>
      ${button(568, 813, 164, "All placements", theme, false)}
      <text x="568" y="914" class="ui" font-size="11.5" fill="${theme.secondary}">Basis: exact time + place assumed. Methodology remains</text>
      <text x="568" y="934" class="ui" font-size="11.5" fill="${theme.secondary}">outside this visual fixture.</text>
    </g>`;
  return svgShell({
    width: 1024,
    height: 1366,
    title: `Humay Western loaded Chart iPad ${mode}`,
    description: "iPad Western Chart loaded development sample with deliberate wheel plus placement/detail composition.",
    mode,
    body
  });
}

function placementPhone(mode) {
  const theme = themes[mode];
  const body = `<rect width="430" height="932" fill="${theme.ground}"/>
    ${statusBar(430, theme, "phone")}
    ${backHeader(theme, { phone: true, origin: "Western chart", title: "Placement detail" })}
    ${sampleNotice(20, 94, theme, 210)}
    <text x="20" y="150" class="editorial" font-size="34" fill="${theme.ink}">Moon in Libra</text>
    <text x="20" y="180" class="ui" font-size="12" fill="${theme.secondary}">One placement, two reading layers.</text>
    <g aria-label="Moon in Libra fact layer">
      <rect x="20" y="210" width="390" height="250" rx="24" fill="${theme.surface}" stroke="${theme.hairline}" filter="url(#soft-shadow)"/>
      ${label(42, 241, "FACT", theme, theme.coralText, 7.6)}
      <circle cx="383" cy="239" r="7" fill="${theme.coralWash}" stroke="${theme.coralText}"/>
      <path d="M380 239a3 3 0 0 1 6 0v4h-6Z" fill="none" stroke="${theme.coralText}" stroke-width="1"/>
      ${factRow({ x: 42, y: 264, width: 346, title: "Body", value: "Moon", detail: "Normalized Western point", theme })}
      ${factRow({ x: 42, y: 312, width: 346, title: "Sign", value: "Libra", detail: "Tropical zodiac · sample", theme })}
      ${factRow({ x: 42, y: 360, width: 346, title: "Degree", value: "14° 27′", detail: "Exact value · technical role", theme, valueColor: theme.coralText })}
      ${factRow({ x: 42, y: 408, width: 346, title: "House", value: "5th", detail: "Known-time fixture only", theme, last: true })}
    </g>
    ${noteBlock({ x: 20, y: 474, width: 390, height: 202, theme, mode, title: "WHAT THIS MAY MEAN", headline: "Room for response.", body: ["Moon in Libra can look for balance", "before it chooses a direction. The", "interpretation explains this factor; it", "does not invent omitted calculation facts."] })}
    <g aria-label="Reliability and basis">
      <rect x="20" y="700" width="390" height="118" rx="20" fill="${theme.secondarySurface}" stroke="${theme.hairline}"/>
      ${label(42, 731, "RELIABILITY + BASIS", theme, theme.tertiary, 7.2)}
      <text x="42" y="762" class="ui" font-size="12" font-weight="700" fill="${theme.sage}">Exact · known-time fixture</text>
      <text x="42" y="786" class="ui" font-size="11" fill="${theme.secondary}">Western tropical sample · exact time + place assumed.</text>
    </g>
    ${phoneTabBar(theme, "Chart")}`;
  return svgShell({
    width: 430,
    height: 932,
    title: `Humay Moon in Libra Placement Detail iPhone ${mode}`,
    description: "Placement Detail reference separating fact, reliability/basis and interpretation for a development-sample Moon in Libra.",
    mode,
    body
  });
}

function placementIPad(mode) {
  const theme = themes[mode];
  const body = `<rect width="1024" height="1366" fill="${theme.ground}"/>
    ${statusBar(1024, theme, "ipad")}
    ${iPadTopNavigation(theme, "Chart")}
    ${backHeader(theme, { phone: false, origin: "Western chart", title: "Moon in Libra" })}
    ${sampleNotice(56, 177, theme, 210)}
    <g aria-label="Placement fact region">
      <rect x="56" y="222" width="420" height="700" rx="28" fill="${theme.surface}" stroke="${theme.hairline}"/>
      ${label(86, 263, "FACT", theme, theme.coralText, 8)}
      <text x="86" y="316" class="editorial" font-size="36" fill="${theme.ink}">Moon in Libra</text>
      <text x="86" y="348" class="ui" font-size="13" fill="${theme.secondary}">Western · tropical · selected placement</text>
      <circle cx="414" cy="270" r="22" fill="${theme.coralWash}"/>
      <path d="M407 271a7 7 0 0 1 14 0v9h-14Z" fill="none" stroke="${theme.coralText}" stroke-width="1.8"/>
      ${factRow({ x: 86, y: 410, width: 350, title: "Body", value: "Moon", detail: "Normalized Western point", theme })}
      ${factRow({ x: 86, y: 458, width: 350, title: "Sign", value: "Libra", detail: "Tropical zodiac · sample", theme })}
      ${factRow({ x: 86, y: 506, width: 350, title: "Degree", value: "14° 27′", detail: "Exact value · technical role", theme, valueColor: theme.coralText })}
      ${factRow({ x: 86, y: 554, width: 350, title: "House", value: "5th", detail: "Known-time fixture only", theme })}
      ${factRow({ x: 86, y: 602, width: 350, title: "Reliability", value: "Exact", detail: "Time + place basis assumed", theme, valueColor: theme.sage, last: true })}
      <line x1="86" y1="696" x2="436" y2="696" stroke="${theme.hairline}"/>
      <text x="86" y="731" class="ui" font-size="11.5" fill="${theme.secondary}">Development sample · not calculated</text>
      <text x="86" y="756" class="ui" font-size="11.5" fill="${theme.secondary}">Houses and Ascendant are withheld when time is unknown.</text>
    </g>
    <g aria-label="Placement interpretation region">
      <rect x="512" y="222" width="456" height="700" rx="28" fill="${theme.surface}" stroke="${theme.hairline}"/>
      ${noteBlock({ x: 540, y: 252, width: 400, height: 245, theme, mode, title: "WHAT THIS MAY MEAN", headline: "Room for response.", body: ["Moon in Libra can look for balance", "before it chooses a direction. The", "interpretation explains this supplied", "factor without inventing another one."] })}
      ${label(540, 554, "WHY THIS LAYER IS SEPARATE", theme, theme.tertiary, 7.4)}
      <text x="540" y="590" class="ui" font-size="13" fill="${theme.secondary}">Facts answer what the chart contains.</text>
      <text x="540" y="613" class="ui" font-size="13" fill="${theme.secondary}">Meaning answers how Humay may explain it.</text>
      <line x1="540" y1="655" x2="940" y2="655" stroke="${theme.hairline}"/>
      ${label(540, 690, "NEXT", theme, theme.tertiary, 7.4)}
      <text x="540" y="726" class="editorial" font-size="27" fill="${theme.ink}">See all placements</text>
      <text x="540" y="760" class="ui" font-size="12.5" fill="${theme.secondary}">The full list remains the accessible equivalent of the wheel.</text>
      ${button(540, 810, 170, "Back to Western", theme, false)}
    </g>`;
  return svgShell({
    width: 1024,
    height: 1366,
    title: `Humay Moon in Libra Placement Detail iPad ${mode}`,
    description: "iPad Placement Detail reference with fact and interpretation regions, reliability, basis and future placement navigation.",
    mode,
    body
  });
}

function unknownTimePhone(mode) {
  const theme = themes[mode];
  const body = `<rect width="430" height="932" fill="${theme.ground}"/>
    ${statusBar(430, theme, "phone")}
    <text x="20" y="80" class="editorial" font-size="32" fill="${theme.ink}">Chart, with room</text>
    <text x="20" y="113" class="editorial" font-size="32" fill="${theme.ink}">for uncertainty</text>
    ${sampleNotice(20, 137, theme, 210)}
    <g aria-label="Unknown birth time explanation">
      <rect x="20" y="175" width="390" height="132" rx="24" fill="${theme.goldWash}" stroke="${theme.gold}" stroke-opacity="0.5"/>
      <circle cx="51" cy="208" r="12" fill="${theme.gold}" opacity="0.18"/>
      <path d="M51 201v9m0 7v1" stroke="${theme.goldText}" stroke-width="2" stroke-linecap="round"/>
      ${label(78, 208, "BIRTH TIME UNKNOWN", theme, theme.goldText, 7.4)}
      <text x="42" y="246" class="editorial" font-size="22" fill="${theme.ink}">Some sky facts can still begin here.</text>
      <text x="42" y="273" class="ui" font-size="11.5" fill="${theme.secondary}">We keep time-dependent parts honest instead of guessing.</text>
    </g>
    <g aria-label="Known date-valid facts">
      <rect x="20" y="329" width="390" height="166" rx="22" fill="${theme.surface}" stroke="${theme.hairline}"/>
      ${label(42, 360, "KNOWN WITH SUPPLIED INPUT", theme, theme.sage, 7.2)}
      ${factRow({ x: 42, y: 379, width: 346, title: "Birth date", value: "14 March 1994", detail: "Calendar fact supplied", theme })}
      ${factRow({ x: 42, y: 427, width: 346, title: "Example", value: "Sun · Aquarius", detail: "Date-valid only where method supports it", theme, valueColor: theme.sage, last: true })}
    </g>
    <g aria-label="Unavailable time-dependent facts">
      <rect x="20" y="517" width="390" height="164" rx="22" fill="${theme.surface}" stroke="${theme.hairline}"/>
      ${label(42, 548, "NOT AVAILABLE YET", theme, theme.coralText, 7.2)}
      ${readinessRow({ x: 42, y: 566, width: 346, title: "Ascendant", value: "Withheld", detail: "Needs sufficient birth time + place.", color: theme.coralText, theme })}
      ${readinessRow({ x: 42, y: 624, width: 346, title: "Houses", value: "Withheld", detail: "No fake house ring is shown.", color: theme.coralText, theme, last: true })}
    </g>
    <g aria-label="What adding time and place unlocks">
      <rect x="20" y="703" width="390" height="105" rx="20" fill="${theme.secondarySurface}" stroke="${theme.hairline}"/>
      ${label(42, 732, "WHAT ADDING DATA UNLOCKS", theme, theme.tertiary, 7.1)}
      <text x="42" y="761" class="ui" font-size="11.3" fill="${theme.secondary}">Adding time and place expands the chart;</text>
      <text x="42" y="780" class="ui" font-size="11.3" fill="${theme.secondary}">it never makes you incomplete.</text>
    </g>
    ${phoneTabBar(theme, "Chart")}`;
  return svgShell({
    width: 430,
    height: 932,
    title: `Humay Chart unknown birth-time state iPhone ${mode}`,
    description: "Unknown birth-time Chart state with date-valid facts, withheld Ascendant and houses, no fake wheel and supportive next-input guidance.",
    mode,
    body
  });
}

function unknownTimeIPad(mode) {
  const theme = themes[mode];
  const body = `<rect width="1024" height="1366" fill="${theme.ground}"/>
    ${statusBar(1024, theme, "ipad")}
    ${iPadTopNavigation(theme, "Chart")}
    <text x="56" y="166" class="editorial" font-size="43" fill="${theme.ink}">Chart, with room for uncertainty</text>
    <text x="56" y="200" class="ui" font-size="14" fill="${theme.secondary}">Known facts stay useful; time-dependent facts stay qualified.</text>
    ${sampleNotice(56, 225, theme, 210)}
    <g aria-label="Unknown-time partial sky explanation">
      <rect x="56" y="270" width="420" height="540" rx="28" fill="${theme.surface}" stroke="${theme.hairline}" filter="url(#soft-shadow)"/>
      ${label(86, 310, "BIRTH TIME UNKNOWN", theme, theme.goldText, 8)}
      <text x="86" y="356" class="editorial" font-size="29" fill="${theme.ink}">The edges stay honest.</text>
      <text x="86" y="390" class="ui" font-size="13" fill="${theme.secondary}">A partial sky cue replaces a fake wheel.</text>
      <g aria-hidden="true">
        <circle cx="267" cy="558" r="135" fill="none" stroke="${theme.hairline}" stroke-width="1.2"/>
        <ellipse cx="267" cy="558" rx="170" ry="62" fill="none" stroke="${theme.gold}" stroke-width="1.5" opacity="0.78" transform="rotate(-18 267 558)"/>
        <ellipse cx="267" cy="558" rx="128" ry="44" fill="none" stroke="${theme.blue}" stroke-width="1" opacity="0.72" transform="rotate(29 267 558)"/>
        <circle cx="267" cy="558" r="56" fill="${theme.goldWash}" stroke="${theme.goldText}"/>
        <text x="267" y="554" text-anchor="middle" class="label" font-size="7" fill="${theme.goldText}">DATE BASIS</text>
        <text x="267" y="570" text-anchor="middle" class="ui" font-size="10" fill="${theme.secondary}">NO HOUSES</text>
      </g>
      <text x="86" y="758" class="ui" font-size="11.5" fill="${theme.secondary}">No Ascendant. No house ring. No guessed time.</text>
    </g>
    <g aria-label="Known and unavailable facts">
      <rect x="512" y="270" width="456" height="540" rx="28" fill="${theme.surface}" stroke="${theme.hairline}"/>
      ${label(542, 310, "KNOWN WITH SUPPLIED INPUT", theme, theme.sage, 8)}
      ${factRow({ x: 542, y: 338, width: 396, title: "Birth date", value: "14 March 1994", detail: "Calendar fact supplied", theme })}
      ${factRow({ x: 542, y: 386, width: 396, title: "Example", value: "Sun · Aquarius", detail: "Date-valid only where method supports it", theme, valueColor: theme.sage })}
      <line x1="542" y1="462" x2="938" y2="462" stroke="${theme.hairline}"/>
      ${label(542, 501, "NOT AVAILABLE YET", theme, theme.coralText, 8)}
      ${readinessRow({ x: 542, y: 522, width: 396, title: "Ascendant", value: "Withheld", detail: "Needs sufficient birth time + place.", color: theme.coralText, theme })}
      ${readinessRow({ x: 542, y: 580, width: 396, title: "Houses", value: "Withheld", detail: "House system and time are not supplied.", color: theme.coralText, theme })}
      ${readinessRow({ x: 542, y: 638, width: 396, title: "Birth place", value: "Not added", detail: "Place-dependent facts remain unavailable.", color: theme.goldText, theme, last: true })}
      <text x="542" y="757" class="ui" font-size="12" fill="${theme.secondary}">Adding time and place expands the chart;</text>
      <text x="542" y="779" class="ui" font-size="12" fill="${theme.secondary}">it does not define the person.</text>
    </g>`;
  return svgShell({
    width: 1024,
    height: 1366,
    title: `Humay Chart unknown birth-time state iPad ${mode}`,
    description: "iPad unknown birth-time Chart state using a partial-sky cue, known date-valid facts and explicit withheld time-dependent facts.",
    mode,
    body
  });
}

function wheelAnatomyBoard() {
  const theme = themes.light;
  const body = `<rect width="1600" height="960" fill="#EFE9E2"/>
    ${label(40, 54, "D4.1 · FOCUSED BOARD", theme, theme.coralText, 10)}
    <text x="40" y="100" class="editorial" font-size="43" fill="${theme.ink}">Natal-wheel anatomy</text>
    <text x="40" y="132" class="ui" font-size="14" fill="${theme.secondary}">Meaning-bearing layers stay readable, bounded and equivalent to a spoken placement list.</text>
    <rect x="40" y="170" width="620" height="710" rx="28" fill="${theme.ground}" stroke="${theme.hairline}"/>
    ${wheel({ cx: 350, cy: 520, radius: 230, theme, knownTime: true, selected: "Moon", compact: false })}
    ${label(82, 835, "KNOWN-TIME FIXTURE · HOUSES SHOWN", theme, theme.tertiary, 8)}
    <g>
      <rect x="710" y="170" width="400" height="330" rx="26" fill="${theme.surface}" stroke="${theme.hairline}"/>
      ${label(744, 210, "LAYER ORDER", theme, theme.coralText, 8)}
      ${anatomyRow({ x: 744, y: 242, color: theme.goldText, title: "Zodiac ring", detail: "Readable signs around the outside." })}
      ${anatomyRow({ x: 744, y: 294, color: theme.coralText, title: "Planet markers", detail: "Shape + text + color, never color alone." })}
      ${anatomyRow({ x: 744, y: 346, color: theme.lavenderText, title: "Aspect lines", detail: "Selected major links only; no web wall." })}
      ${anatomyRow({ x: 744, y: 398, color: theme.blueText, title: "House ring", detail: "Only when time/place/method allow." })}
      ${anatomyRow({ x: 744, y: 450, color: theme.sage, title: "Text list", detail: "Equivalent meaning-bearing representation." })}
    </g>
    <g>
      <rect x="1160" y="170" width="400" height="710" rx="26" fill="${theme.surface}" stroke="${theme.hairline}"/>
      ${label(1194, 210, "VOICEOVER EQUIVALENT", theme, theme.coralText, 8)}
      <text x="1194" y="254" class="editorial" font-size="28" fill="${theme.ink}">Western chart</text>
      <text x="1194" y="286" class="ui" font-size="12.5" fill="${theme.secondary}">Known-time fixture · houses shown.</text>
      ${accessibleFact({ x: 1194, y: 328, title: "Sun", value: "Aquarius, 22° 11′", detail: "Reliable sample fact" })}
      ${accessibleFact({ x: 1194, y: 432, title: "Moon", value: "Libra, 14° 27′", detail: "Selected placement" })}
      ${accessibleFact({ x: 1194, y: 536, title: "Ascendant", value: "Gemini, 03° 02′", detail: "Known-time fixture only" })}
      <line x1="1194" y1="664" x2="1526" y2="664" stroke="${theme.hairline}"/>
      <text x="1194" y="703" class="ui" font-size="12" fill="${theme.secondary}">Decorative rings hide from VoiceOver.</text>
      <text x="1194" y="726" class="ui" font-size="12" fill="${theme.secondary}">Every marker has a spoken list route.</text>
    </g>`;
  return svgShell({
    width: 1600,
    height: 960,
    title: "Humay Chart natal-wheel anatomy board",
    description: "Focused Chart board showing zodiac, planet, aspect, house and VoiceOver-equivalent layers.",
    mode: "light",
    body
  });
}

function anatomyRow({ x, y, color, title, detail }) {
  return `<g><circle cx="${x + 7}" cy="${y + 5}" r="5" fill="${color}"/><text x="${x + 22}" y="${y + 9}" class="ui" font-size="13" font-weight="700" fill="#151B28">${escapeText(title)}</text><text x="${x + 22}" y="${y + 29}" class="ui" font-size="11" fill="#625F62">${escapeText(detail)}</text></g>`;
}

function accessibleFact({ x, y, title, value, detail }) {
  return `<g aria-label="${escapeText(title)}: ${escapeText(value)}. ${escapeText(detail)}"><text x="${x}" y="${y}" class="label" font-size="7.2" fill="#7A7575">${escapeText(title.toUpperCase())}</text><text x="${x}" y="${y + 28}" class="ui" font-size="15" font-weight="700" fill="#151B28">${escapeText(value)}</text><text x="${x}" y="${y + 49}" class="ui" font-size="11" fill="#625F62">${escapeText(detail)}</text></g>`;
}

function typographyBoard() {
  const theme = themes.light;
  const body = `<rect width="1600" height="900" fill="#EFE9E2"/>
    ${label(40, 54, "D4.1 · FOCUSED BOARD", theme, theme.coralText, 10)}
    <text x="40" y="100" class="editorial" font-size="43" fill="${theme.ink}">Typography + data hierarchy</text>
    <text x="40" y="132" class="ui" font-size="14" fill="${theme.secondary}">Chart is denser than Today; hierarchy carries precision without tiny type.</text>
    <g>
      <rect x="40" y="176" width="470" height="625" rx="26" fill="${theme.surface}" stroke="${theme.hairline}"/>
      ${label(72, 218, "EDITORIAL / MEANING", theme, theme.coralText, 8)}
      <text x="72" y="277" class="editorial" font-size="38" fill="${theme.ink}">A shape you can use.</text>
      <text x="72" y="317" class="ui" font-size="14" fill="${theme.secondary}">Newsreader frames the Chart story,</text>
      <text x="72" y="339" class="ui" font-size="14" fill="${theme.secondary}">interpretation and section meaning.</text>
      <line x1="72" y1="385" x2="478" y2="385" stroke="${theme.hairline}"/>
      ${label(72, 424, "SYSTEM / FACTS", theme, theme.tertiary, 8)}
      <text x="72" y="465" class="ui" font-size="17" font-weight="700" fill="${theme.ink}">Moon in Libra</text>
      <text x="72" y="494" class="ui" font-size="14" fill="${theme.secondary}">SF Pro/system for labels, placements, controls.</text>
      <text x="72" y="544" class="ui" font-size="17" font-weight="700" fill="${theme.ink}">Exact · known-time fixture</text>
      <text x="72" y="573" class="ui" font-size="14" fill="${theme.secondary}">Reliability stays readable, not hidden in metadata.</text>
      <line x1="72" y1="622" x2="478" y2="622" stroke="${theme.hairline}"/>
      ${label(72, 659, "WORDMARK ONLY", theme, theme.tertiary, 8)}
      <text x="72" y="700" class="ui" font-size="14" fill="${theme.secondary}">Cormorant Garamond does not enter Chart UI.</text>
    </g>
    <g>
      <rect x="550" y="176" width="470" height="625" rx="26" fill="${theme.surface}" stroke="${theme.hairline}"/>
      ${label(582, 218, "TECHNICAL FACTS", theme, theme.lavenderText, 8)}
      <text x="582" y="283" class="mono" font-size="31" fill="${theme.ink}">14° 27′</text>
      <text x="582" y="316" class="ui" font-size="14" fill="${theme.secondary}">SF Mono/system only for degree-heavy,</text>
      <text x="582" y="338" class="ui" font-size="14" fill="${theme.secondary}">coordinate-heavy or tightly aligned values.</text>
      <line x1="582" y1="386" x2="988" y2="386" stroke="${theme.hairline}"/>
      ${label(582, 425, "CERTAINTY STATES", theme, theme.tertiary, 8)}
      ${certaintyRow({ x: 582, y: 468, color: theme.sage, title: "Exact", value: "14° 27′", detail: "Known basis" })}
      ${certaintyRow({ x: 582, y: 535, color: theme.goldText, title: "Approximate", value: "around 14°", detail: "Tolerance retained" })}
      ${certaintyRow({ x: 582, y: 602, color: theme.coralText, title: "Unavailable", value: "Not available", detail: "Reason visible" })}
      ${certaintyRow({ x: 582, y: 669, color: theme.blueText, title: "Date-only valid", value: "Sun · Aquarius", detail: "Methodology basis shown" })}
    </g>
    <g>
      <rect x="1060" y="176" width="500" height="625" rx="26" fill="#202A42" stroke="#30394B"/>
      ${label(1094, 218, "PRESSURE STUDY", { tertiary: "#C4C0C5", coralText: "#FF9A98" }, "#FF9A98", 8)}
      <text x="1094" y="279" class="editorial" font-size="31" fill="#FFF7F0">Facts before flourish.</text>
      <text x="1094" y="321" class="ui" font-size="14" fill="#C4C0C5">At larger text sizes, cards stack,</text>
      <text x="1094" y="343" class="ui" font-size="14" fill="#C4C0C5">degree values wrap, and meaning moves</text>
      <text x="1094" y="365" class="ui" font-size="14" fill="#C4C0C5">below the complete fact basis.</text>
      <line x1="1094" y1="410" x2="1526" y2="410" stroke="#30394B"/>
      <text x="1094" y="450" class="ui" font-size="17" font-weight="700" fill="#FFF7F0">Moon · Libra · 14° 27′</text>
      <text x="1094" y="480" class="ui" font-size="13" fill="#C4C0C5">House 5th · known-time fixture only</text>
      <text x="1094" y="510" class="ui" font-size="13" fill="#C4C0C5">Exact · basis and provenance visible</text>
      <line x1="1094" y1="554" x2="1526" y2="554" stroke="#30394B"/>
      <text x="1094" y="598" class="editorial" font-size="25" fill="#FFF7F0">No 10 pt data wall.</text>
      <text x="1094" y="630" class="ui" font-size="13" fill="#C4C0C5">The hierarchy survives translation, Dynamic Type</text>
      <text x="1094" y="652" class="ui" font-size="13" fill="#C4C0C5">and accessibility pressure.</text>
    </g>`;
  return svgShell({
    width: 1600,
    height: 900,
    title: "Humay Chart typography and data hierarchy board",
    description: "Focused Chart typography board mapping Newsreader, SF Pro/system, monospaced digits and SF Mono technical roles with certainty pressure.",
    mode: "light",
    body
  });
}

function certaintyRow({ x, y, color, title, value, detail }) {
  return `<g><circle cx="${x + 6}" cy="${y + 5}" r="5" fill="${color}"/><text x="${x + 22}" y="${y + 9}" class="ui" font-size="14" font-weight="700" fill="#151B28">${escapeText(title)}</text><text x="${x + 180}" y="${y + 9}" class="mono" font-size="12" fill="#151B28">${escapeText(value)}</text><text x="${x + 22}" y="${y + 31}" class="ui" font-size="11" fill="#625F62">${escapeText(detail)}</text></g>`;
}

function accessBoard() {
  const theme = themes.light;
  const cards = [
    ["FREE PREVIEW", "Explain value", "No natal calculation. Abstract preview only.", theme.blueText],
    ["PRECISION LOCKED", "Future access", "Rewarded/Premium path stays separate from truth.", theme.goldText],
    ["GENERATION AVAILABLE", "One action", "Access may start later; result not yet calculated.", theme.coralText],
    ["LOADED / CACHED", "Reopen", "Valid artifact opens without another access event.", theme.sage],
    ["OFFLINE CACHED", "Saved locally", "Freshness and basis remain visible.", theme.lavenderText],
    ["PROVIDER FAILURE", "Recover fairly", "Access recovery is later ARCH-007 work.", theme.coralText]
  ];
  const cardsMarkup = cards.map(([title, headline, detail, color], index) => {
    const x = 40 + (index % 3) * 520;
    const y = 180 + Math.floor(index / 3) * 292;
    return `<g aria-label="${escapeText(title)}">
      <rect x="${x}" y="${y}" width="480" height="244" rx="26" fill="${theme.surface}" stroke="${theme.hairline}"/>
      <circle cx="${x + 34}" cy="${y + 36}" r="9" fill="${color}"/>
      ${label(x + 58, y + 40, title, theme, color, 7.8)}
      <text x="${x + 28}" y="${y + 91}" class="editorial" font-size="28" fill="${theme.ink}">${escapeText(headline)}</text>
      <text x="${x + 28}" y="${y + 130}" class="ui" font-size="13" fill="${theme.secondary}">${escapeText(detail)}</text>
      <line x1="${x + 28}" y1="${y + 164}" x2="${x + 452}" y2="${y + 164}" stroke="${theme.hairline}"/>
      <text x="${x + 28}" y="${y + 202}" class="ui" font-size="11.5" fill="${theme.tertiary}">Access presentation ≠ calculation truth</text>
    </g>`;
  }).join("");
  const body = `<rect width="1600" height="840" fill="#EFE9E2"/>
    ${label(40, 54, "D4.1 · FOCUSED BOARD", theme, theme.coralText, 10)}
    <text x="40" y="100" class="editorial" font-size="43" fill="${theme.ink}">Free → precision access concepts</text>
    <text x="40" y="132" class="ui" font-size="14" fill="${theme.secondary}">Access states explain what can happen; they never fabricate what calculation produced.</text>
    ${cardsMarkup}`;
  return svgShell({
    width: 1600,
    height: 840,
    title: "Humay Chart access and precision concepts board",
    description: "Focused Chart access board covering Free preview, precision lock, generation availability, cached reopen, offline cache and provider failure.",
    mode: "light",
    body
  });
}

function stateBoard() {
  const states = [
    ["LOADING", "Stable shell", "No fake facts", "light", "loading"],
    ["FREE PREVIEW", "Learn first", "No natal result", "dark", "preview"],
    ["PRECISION LOCKED", "Explain access", "No wheel claim", "light", "lock"],
    ["GENERATION AVAILABLE", "Action ready", "Result pending", "dark", "ready"],
    ["LOADED", "Facts visible", "Reliability + basis", "light", "loaded"],
    ["CACHED", "Reopen", "No new access", "dark", "cached"],
    ["OFFLINE CACHED", "Saved result", "Freshness visible", "light", "offline"],
    ["OFFLINE NO CACHE", "Unavailable", "No paid queue", "dark", "empty"],
    ["UNKNOWN TIME", "Partial basis", "No houses", "light", "unknown"],
    ["MISSING PLACE", "Input needed", "Place facts withheld", "dark", "place"],
    ["UNSUPPORTED METHOD", "Method gate", "No guessed output", "light", "method"],
    ["FAILED", "Honest recovery", "Provider/data issue", "dark", "failed"]
  ];
  const panels = states.map(([title, headline, detail, mode, kind], index) => {
    const theme = themes[mode];
    const x = 40 + (index % 3) * 520;
    const y = 170 + Math.floor(index / 3) * 184;
    const color = kind === "loaded" || kind === "cached" || kind === "offline" ? theme.sage : kind === "unknown" || kind === "place" ? theme.goldText : kind === "failed" ? theme.coralText : theme.lavenderText;
    return `<g aria-label="${escapeText(title)} state concept">
      <rect x="${x}" y="${y}" width="480" height="154" rx="22" fill="${theme.ground}" stroke="${theme.hairline}"/>
      <circle cx="${x + 30}" cy="${y + 33}" r="10" fill="${color}" opacity="0.2" stroke="${color}"/>
      ${stateIcon(kind, x + 30, y + 33, color)}
      ${label(x + 58, y + 37, `${String(index + 1).padStart(2, "0")} · ${title}`, theme, color, 7.4)}
      <text x="${x + 28}" y="${y + 83}" class="editorial" font-size="23" fill="${theme.ink}">${escapeText(headline)}</text>
      <text x="${x + 28}" y="${y + 116}" class="ui" font-size="11.5" fill="${theme.secondary}">${escapeText(detail)}</text>
      <text x="${x + 452}" y="${y + 124}" text-anchor="end" class="label" font-size="6.4" fill="${theme.tertiary}">CONCEPTUAL ONLY</text>
    </g>`;
  }).join("");
  const body = `<rect width="1600" height="930" fill="#EFE9E2"/>
    ${label(40, 54, "D4.1 · STATE BOARD", themes.light, themes.light.coralText, 10)}
    <text x="40" y="100" class="editorial" font-size="43" fill="${themes.light.ink}">Chart state language</text>
    <text x="40" y="132" class="ui" font-size="14" fill="${themes.light.secondary}">Representative concepts only; future typed contracts own production truth.</text>
    ${panels}`;
  return svgShell({
    width: 1600,
    height: 930,
    title: "Humay Chart state board",
    description: "Chart state board showing loading, Free, precision, cached, offline, unknown-time, methodology and failed concepts.",
    mode: "light",
    body
  });
}

function stateIcon(kind, x, y, color) {
  if (kind === "loading") return `<path d="M${x - 7} ${y}a7 7 0 1 0 14 0" fill="none" stroke="${color}" stroke-width="1.5" stroke-linecap="round"/>`;
  if (kind === "lock") return `<path d="M${x - 6} ${y}a6 6 0 0 1 12 0v6h-12Zm2-1v-3a4 4 0 0 1 8 0v3" fill="none" stroke="${color}" stroke-width="1.5"/>`;
  if (kind === "unknown") return `<path d="M${x} ${y - 8}v8m0 5v1" stroke="${color}" stroke-width="2" stroke-linecap="round"/>`;
  if (kind === "method") return `<path d="M${x} ${y - 8}l8 14h-16Z" fill="none" stroke="${color}" stroke-width="1.5" stroke-linejoin="round"/><path d="M${x} ${y - 3}v4m0 3v1" stroke="${color}" stroke-width="1.5"/>`;
  if (kind === "failed") return `<path d="M${x - 6} ${y - 6}l12 12m0-12L${x - 6} ${y + 6}" stroke="${color}" stroke-width="1.8" stroke-linecap="round"/>`;
  if (kind === "offline") return `<path d="M${x - 8} ${y + 2}h16m-13-5 3-4 3 4m-9 5 3 4m6-4-3 4" fill="none" stroke="${color}" stroke-width="1.4" stroke-linecap="round"/>`;
  if (kind === "place") return `<path d="M${x} ${y + 8}s-7-7-7-12a7 7 0 0 1 14 0c0 5-7 12-7 12Z" fill="none" stroke="${color}" stroke-width="1.5"/><circle cx="${x}" cy="${y - 4}" r="2" fill="${color}"/>`;
  return `<circle cx="${x}" cy="${y}" r="7" fill="none" stroke="${color}" stroke-width="1.6"/><path d="M${x - 4} ${y}l3 3 6-7" fill="none" stroke="${color}" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/>`;
}

function accessibilityBoard() {
  const theme = themes.light;
  const body = `<rect width="1600" height="900" fill="#EFE9E2"/>
    ${label(40, 54, "D4.1 · FOCUSED BOARD", theme, theme.coralText, 10)}
    <text x="40" y="100" class="editorial" font-size="43" fill="${theme.ink}">Accessibility + long-content pressure</text>
    <text x="40" y="132" class="ui" font-size="14" fill="${theme.secondary}">Wheel never becomes an inaccessible image; content yields before certainty does.</text>
    <g>
      <rect x="40" y="176" width="710" height="620" rx="28" fill="${theme.surface}" stroke="${theme.hairline}"/>
      ${label(74, 218, "DYNAMIC TYPE", theme, theme.coralText, 8)}
      <text x="74" y="271" class="editorial" font-size="36" fill="${theme.ink}">Moon in Libra</text>
      <text x="74" y="318" class="ui" font-size="21" font-weight="700" fill="${theme.ink}">14° 27′ · exact</text>
      <text x="74" y="353" class="ui" font-size="17" fill="${theme.secondary}">Known-time fixture only</text>
      <line x1="74" y1="393" x2="716" y2="393" stroke="${theme.hairline}"/>
      <text x="74" y="435" class="editorial" font-size="26" fill="${theme.ink}">Meaning moves below facts.</text>
      <text x="74" y="472" class="ui" font-size="14" fill="${theme.secondary}">No degree row truncation. No tiny 10 pt label wall.</text>
      <text x="74" y="514" class="ui" font-size="14" fill="${theme.secondary}">Long placement names wrap; cards stack under pressure.</text>
      <line x1="74" y1="554" x2="716" y2="554" stroke="${theme.hairline}"/>
      ${label(74, 594, "MOTION + CONTRAST", theme, theme.tertiary, 8)}
      <text x="74" y="631" class="ui" font-size="14" fill="${theme.secondary}">Reduce Motion: static wheel/list. Increase Contrast:</text>
      <text x="74" y="654" class="ui" font-size="14" fill="${theme.secondary}">stronger outlines, grouping and selection cues.</text>
    </g>
    <g>
      <rect x="790" y="176" width="770" height="620" rx="28" fill="#202A42" stroke="#30394B"/>
      ${label(824, 218, "VOICEOVER + INPUT", { tertiary: "#C4C0C5", coralText: "#FF9A98" }, "#FF9A98", 8)}
      <text x="824" y="271" class="editorial" font-size="31" fill="#FFF7F0">Western chart, known-time fixture.</text>
      <text x="824" y="315" class="ui" font-size="14" fill="#C4C0C5">Spoken summary: 7 placements, 3 selected aspects,</text>
      <text x="824" y="338" class="ui" font-size="14" fill="#C4C0C5">houses shown; sample values, not calculated.</text>
      <line x1="824" y1="383" x2="1524" y2="383" stroke="#30394B"/>
      ${accessibleFact({ x: 824, y: 424, title: "Moon", value: "Libra · 14° 27′", detail: "Selected row · exact sample" })}
      ${accessibleFact({ x: 824, y: 522, title: "House", value: "5th", detail: "Known-time fixture only" })}
      <line x1="824" y1="634" x2="1524" y2="634" stroke="#30394B"/>
      <text x="824" y="677" class="ui" font-size="14" fill="#FFF7F0">44 pt targets · native rows · pointer/keyboard path</text>
      <text x="824" y="705" class="ui" font-size="14" fill="#C4C0C5">Decorative rings hidden; text list carries meaning.</text>
    </g>`;
  return svgShell({
    width: 1600,
    height: 900,
    title: "Humay Chart accessibility pressure board",
    description: "Chart accessibility board covering Dynamic Type, VoiceOver equivalent, long content, Reduce Motion, Increase Contrast and pointer/keyboard behavior.",
    mode: "light",
    body
  });
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
    await writeSvgAndPng(`iphone-${mode}`, overviewPhone(mode), { width: 430, height: 932, scale: 2 });
    await writeSvgAndPng(`ipad-${mode}`, overviewIPad(mode), { width: 1024, height: 1366, scale: 2 });
    await writeSvgAndPng(`western-loaded-iphone-${mode}`, loadedPhone(mode), { width: 430, height: 932, scale: 2 });
    await writeSvgAndPng(`western-loaded-ipad-${mode}`, loadedIPad(mode), { width: 1024, height: 1366, scale: 2 });
    await writeSvgAndPng(`placement-detail-iphone-${mode}`, placementPhone(mode), { width: 430, height: 932, scale: 2 });
    await writeSvgAndPng(`placement-detail-ipad-${mode}`, placementIPad(mode), { width: 1024, height: 1366, scale: 2 });
    await writeSvgAndPng(`unknown-time-iphone-${mode}`, unknownTimePhone(mode), { width: 430, height: 932, scale: 2 });
    await writeSvgAndPng(`unknown-time-ipad-${mode}`, unknownTimeIPad(mode), { width: 1024, height: 1366, scale: 2 });
  }
  await writeSvgAndPng("wheel-anatomy", wheelAnatomyBoard(), { width: 1600, height: 960 });
  await writeSvgAndPng("typography-data-hierarchy", typographyBoard(), { width: 1600, height: 900 });
  await writeSvgAndPng("access-precision", accessBoard(), { width: 1600, height: 840 });
  await writeSvgAndPng("states", stateBoard(), { width: 1600, height: 930 });
  await writeSvgAndPng("accessibility-pressure", accessibilityBoard(), { width: 1600, height: 900 });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
