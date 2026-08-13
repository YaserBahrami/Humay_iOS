const fs = require("node:fs");
const path = require("node:path");
const sharp = require("sharp");

const outputDirectory = __dirname;
fs.mkdirSync(outputDirectory, { recursive: true });

const fontPath = path.resolve(
  outputDirectory,
  "../../../../../Humay/Resources/Fonts/CormorantGaramond-Regular.otf"
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
    sage: "#678E79",
    sageWash: "#E8F0EB",
    tab: "#FFFDF9",
    tabSelected: "#F6E9E1",
    shadow: "#35281C",
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
    lavender: "#C17ADB",
    lavenderText: "#D79AE8",
    lavenderWash: "#312B48",
    gold: "#E5AA55",
    goldText: "#F0BA68",
    goldWash: "#322C2B",
    blue: "#78B1D5",
    blueText: "#8BC4E4",
    blueWash: "#223344",
    sage: "#82BDA3",
    sageWash: "#24363A",
    tab: "#20283A",
    tabSelected: "#3A4055",
    shadow: "#000000",
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
      @font-face { font-family: "Humay Editorial"; src: url("data:font/otf;base64,${editorialFont}") format("opentype"); font-weight: 400; }
      .editorial { font-family: "Humay Editorial", Georgia, serif; font-weight: 400; }
      .ui { font-family: -apple-system, BlinkMacSystemFont, "Helvetica Neue", Arial, sans-serif; }
      .mono { font-family: "SFMono-Regular", Menlo, Consolas, monospace; }
      .label { font-family: -apple-system, BlinkMacSystemFont, "Helvetica Neue", Arial, sans-serif; font-weight: 700; letter-spacing: 1.1px; }
      text { text-rendering: optimizeLegibility; }
    </style>
    <linearGradient id="hero-gradient" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="${mode === "light" ? "#202A3A" : "#202A42"}"/>
      <stop offset="1" stop-color="${mode === "light" ? "#3B3650" : "#302D4D"}"/>
    </linearGradient>
    <linearGradient id="meaning-gradient" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="${mode === "light" ? theme.coralWash : "#3A2833"}"/>
      <stop offset="1" stop-color="${mode === "light" ? theme.lavenderWash : "#312B48"}"/>
    </linearGradient>
    <linearGradient id="soft-accent" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="${theme.coral}" stop-opacity="0.82"/>
      <stop offset="1" stop-color="${theme.lavender}" stop-opacity="0.84"/>
    </linearGradient>
    <filter id="soft-shadow" x="-30%" y="-30%" width="160%" height="180%">
      <feDropShadow dx="0" dy="5" stdDeviation="10" flood-color="${theme.shadow}" flood-opacity="${mode === "light" ? "0.09" : "0"}"/>
    </filter>
    ${extraDefinitions}
  </defs>
  ${body}
</svg>`;
}

function reviewLabel(width, theme) {
  return `<text x="${width / 2}" y="18" text-anchor="middle" class="label" font-size="7.5" fill="${theme.coralText}">D3.3 · REVIEW CANDIDATE · NOT APPROVED</text>`;
}

function statusBar(width, theme, device) {
  const phone = device === "phone";
  const timeX = phone ? 22 : 24;
  const iconX = width - (phone ? 78 : 92);
  const date = phone ? "9:41" : "9:41  ·  Thu 13 Aug";
  return `<text x="${timeX}" y="31" class="ui" font-size="${phone ? 14 : 13}" font-weight="700" fill="${theme.ink}">${date}</text>
    <g transform="translate(${iconX} 19)" fill="none" stroke="${theme.ink}" stroke-width="2" stroke-linecap="round">
      <path d="M0 8h2V5h2v3h2V2h2v6"/>
      <path d="M14 4c3-3 8-3 11 0M17 7c2-2 4-2 6 0"/>
      <rect x="30" y="0" width="22" height="10" rx="3"/>
      <rect x="32" y="2" width="16" height="6" rx="2" fill="${theme.ink}" stroke="none"/>
      <path d="M53 3v4"/>
    </g>`;
}

function chevron(x, y, direction, theme, size = 5) {
  const sign = direction === "left" ? -1 : 1;
  return `<path d="M${x - sign * size} ${y - size}l${sign * size} ${size} ${-sign * size} ${size}" fill="none" stroke="${theme.ink}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>`;
}

function backHeader(theme, { wide = false } = {}) {
  if (wide) {
    return `<g aria-label="Back to Calendar, Event Detail">
      <rect x="36" y="122" width="150" height="44" rx="22" fill="transparent"/>
      ${chevron(52, 144, "left", theme, 5)}
      <text x="66" y="149" class="ui" font-size="15" font-weight="650" fill="${theme.coralText}">Calendar</text>
      <text x="210" y="151" class="editorial" font-size="34" fill="${theme.ink}">Event Detail</text>
    </g>`;
  }
  return `<g aria-label="Back to Calendar, Event Detail">
    <rect x="12" y="43" width="138" height="44" rx="22" fill="transparent"/>
    ${chevron(27, 65, "left", theme, 4.5)}
    <text x="39" y="70" class="ui" font-size="14" font-weight="600" fill="${theme.coralText}">Calendar</text>
    <text x="215" y="70" text-anchor="middle" class="ui" font-size="16" font-weight="700" fill="${theme.ink}">Event Detail</text>
  </g>`;
}

function sampleNotice(x, y, theme, width = 194) {
  return `<g aria-label="Development sample, not calculated">
    <rect x="${x}" y="${y}" width="${width}" height="23" rx="11.5" fill="${theme.secondarySurface}" stroke="${theme.hairline}" stroke-width="0.7"/>
    <path d="M${x + 10} ${y + 10}l4-4 3 3-4 4m-2-1 5 5m-7-1 3-3" fill="none" stroke="${theme.tertiary}" stroke-width="1.4" stroke-linecap="round"/>
    <text x="${x + 25}" y="${y + 15.5}" class="ui" font-size="9.4" font-weight="650" fill="${theme.secondary}">Development sample · not calculated</text>
  </g>`;
}

function iPadTopNavigation(theme) {
  const labels = ["Today", "Circle", "Sky", "Chart", "Ask"];
  return `<g aria-label="Adaptive primary navigation, Sky selected" filter="url(#soft-shadow)">
    <rect x="300" y="46" width="424" height="56" rx="28" fill="${theme.tab}" stroke="${theme.hairline}"/>
    <rect x="462" y="52" width="84" height="44" rx="22" fill="${theme.tabSelected}"/>
    <path d="M323 68h18v14h-18zM328 68v14" fill="none" stroke="${theme.ink}" stroke-width="1.6"/>
    ${labels.map((label, index) => {
      const x = [376, 450, 504, 590, 674][index];
      const selected = label === "Sky";
      return `<text x="${x}" y="81" text-anchor="middle" class="ui" font-size="15" font-weight="${selected ? "750" : "600"}" fill="${selected ? theme.coralText : theme.ink}">${label}</text>`;
    }).join("")}
  </g>`;
}

function phoneTabBar(theme) {
  const items = [
    ["Today", 52, "sun"], ["Circle", 132, "people"], ["Sky", 215, "sky"], ["Chart", 298, "chart"], ["Ask", 378, "ask"]
  ];
  const symbols = {
    sun: (x) => `<circle cx="${x}" cy="862" r="6" fill="none" stroke="currentColor" stroke-width="1.7"/><path d="M${x} 850v4m0 16v4m-12-12h4m16 0h4m-20-9 3 3m14 14 3 3m0-20-3 3m-14 14-3 3" stroke="currentColor" stroke-width="1.5"/>`,
    people: (x) => `<circle cx="${x - 4}" cy="858" r="4" fill="none" stroke="currentColor" stroke-width="1.6"/><circle cx="${x + 5}" cy="859" r="3.5" fill="none" stroke="currentColor" stroke-width="1.6"/><path d="M${x - 11} 869c2-7 12-7 15 0m0-5c5-2 9 1 10 5" fill="none" stroke="currentColor" stroke-width="1.6"/>`,
    sky: (x) => `<path d="M${x} 850c1.5 7 3 8.5 10 10-7 1.5-8.5 3-10 10-1.5-7-3-8.5-10-10 7-1.5 8.5-3 10-10Z" fill="currentColor"/><path d="M${x + 11} 850c.7 3.5 1.5 4.3 5 5-3.5.7-4.3 1.5-5 5-.7-3.5-1.5-4.3-5-5 3.5-.7 4.3-1.5 5-5Z" fill="currentColor" opacity=".75"/>`,
    chart: (x) => `<circle cx="${x}" cy="861" r="9" fill="none" stroke="currentColor" stroke-width="1.5"/><path d="M${x - 7} 856l14 10m-14 0 14-10M${x} 852v18" stroke="currentColor" stroke-width="1.2"/>`,
    ask: (x) => `<path d="M${x - 10} 853h15a5 5 0 0 1 5 5v7a5 5 0 0 1-5 5h-6l-5 4v-4h-4a5 5 0 0 1-5-5v-7a5 5 0 0 1 5-5Z" fill="none" stroke="currentColor" stroke-width="1.6"/><path d="M${x - 5} 859h10m-10 5h7" stroke="currentColor" stroke-width="1.4"/>`
  };
  return `<g aria-label="Primary navigation, Sky selected" filter="url(#soft-shadow)">
    <rect x="14" y="838" width="402" height="76" rx="32" fill="${theme.tab}" stroke="${theme.hairline}"/>
    <rect x="174" y="844" width="82" height="64" rx="26" fill="${theme.tabSelected}"/>
    ${items.map(([label, x, type]) => `<g style="color:${type === "sky" ? theme.coralText : theme.ink}">${symbols[type](x)}<text x="${x}" y="897" text-anchor="middle" class="ui" font-size="10" font-weight="${type === "sky" ? "750" : "550"}" fill="${type === "sky" ? theme.coralText : theme.ink}">${label}</text></g>`).join("")}
  </g>`;
}

function methodology(x, y, label, theme, accent, anchor = "start") {
  const textX = anchor === "end" ? x - 11 : x + 11;
  const circleX = anchor === "end" ? x - 4 : x + 4;
  return `<g aria-label="${escapeText(label)} methodology">
    <circle cx="${circleX}" cy="${y + 8.5}" r="2.4" fill="${accent}"/>
    <text x="${textX}" y="${y + 12}" text-anchor="${anchor}" class="ui" font-size="9.4" font-weight="700" fill="${theme.secondary}">${escapeText(label)}</text>
  </g>`;
}

function eventGlyph(kind, cx, cy, theme, scale = 1, muted = false) {
  const accent = muted ? theme.secondary : kind === "mercury" ? theme.coralText : kind === "moon" ? theme.goldText : kind === "aspect" ? theme.lavenderText : kind === "tradition" ? theme.blueText : theme.sage;
  const ring = muted ? theme.hairline : theme.secondarySurface;
  const r = 23 * scale;
  const s = scale;
  let symbol = "";
  if (kind === "moon") {
    symbol = `<circle cx="${cx - 1 * s}" cy="${cy}" r="${10 * s}" fill="${accent}"/><circle cx="${cx + 5 * s}" cy="${cy - 3 * s}" r="${10 * s}" fill="${ring}"/>`;
  } else if (kind === "aspect") {
    symbol = `<circle cx="${cx - 9 * s}" cy="${cy}" r="${5.5 * s}" fill="none" stroke="${accent}" stroke-width="${2 * s}"/><circle cx="${cx + 9 * s}" cy="${cy}" r="${5.5 * s}" fill="none" stroke="${accent}" stroke-width="${2 * s}"/><path d="M${cx - 3 * s} ${cy}h${6 * s}" stroke="${accent}" stroke-width="${2 * s}" stroke-linecap="round"/>`;
  } else if (kind === "tradition") {
    symbol = `<path d="M${cx} ${cy - 11 * s}l${11 * s} ${11 * s}-${11 * s} ${11 * s}-${11 * s}-${11 * s}Z" fill="none" stroke="${accent}" stroke-width="${2 * s}"/><circle cx="${cx}" cy="${cy}" r="${2.4 * s}" fill="${accent}"/>`;
  } else if (kind === "ingress") {
    symbol = `<circle cx="${cx - 3 * s}" cy="${cy + 4 * s}" r="${7 * s}" fill="none" stroke="${accent}" stroke-width="${2 * s}"/><path d="M${cx + 2 * s} ${cy - 3 * s}l${11 * s} ${-11 * s}m${-6 * s} 0h${6 * s}v${6 * s}" fill="none" stroke="${accent}" stroke-width="${2 * s}" stroke-linecap="round" stroke-linejoin="round"/>`;
  } else {
    symbol = `<path d="M${cx} ${cy - 11 * s}a${11 * s} ${11 * s} 0 1 0 0 ${22 * s}a${11 * s} ${11 * s} 0 1 0 0 ${-22 * s}M${cx - 13 * s} ${cy + 5 * s}h${26 * s}" fill="none" stroke="${accent}" stroke-width="${2 * s}" stroke-linecap="round"/>`;
  }
  return `<g aria-hidden="true"><circle cx="${cx}" cy="${cy}" r="${r}" fill="${ring}"/>${symbol}</g>`;
}

function heroMotif(theme, mode, x, y) {
  return `<g aria-hidden="true">
    <circle cx="${x}" cy="${y}" r="55" fill="${mode === "light" ? "#FFFFFF" : "#111827"}" opacity="0.12"/>
    <ellipse cx="${x}" cy="${y}" rx="56" ry="25" fill="none" stroke="${theme.gold}" stroke-width="1.4" opacity="0.84" transform="rotate(-18 ${x} ${y})"/>
    <ellipse cx="${x}" cy="${y}" rx="44" ry="19" fill="none" stroke="${theme.blue}" stroke-width="1" opacity="0.68" transform="rotate(32 ${x} ${y})"/>
    ${eventGlyph("mercury", x, y, theme, 1.18)}
    <path d="M${x + 46} ${y - 38}c1 5 2 6 7 7-5 1-6 2-7 7-1-5-2-6-7-7 5-1 6-2 7-7Z" fill="${theme.coral}" opacity="0.9"/>
    <circle cx="${x - 48}" cy="${y + 37}" r="2.2" fill="${theme.lavender}"/>
  </g>`;
}

function factRow({ x, y, width, label, value, detail = null, theme, last = false, valueColor = null }) {
  const detailMarkup = detail
    ? `<text x="${x + 122}" y="${y + 34}" class="ui" font-size="9.5" fill="${theme.secondary}">${escapeText(detail)}</text>`
    : "";
  return `<g aria-label="${escapeText(label)}: ${escapeText(value)}${detail ? `. ${escapeText(detail)}` : ""}">
    <text x="${x}" y="${y + 16}" class="label" font-size="7.2" fill="${theme.tertiary}">${escapeText(label.toUpperCase())}</text>
    <text x="${x + 122}" y="${y + 17}" class="ui" font-size="12.5" font-weight="700" fill="${valueColor || theme.ink}">${escapeText(value)}</text>
    ${detailMarkup}
    ${last ? "" : `<line x1="${x}" y1="${y + 49}" x2="${x + width}" y2="${y + 49}" stroke="${theme.hairline}"/>`}
  </g>`;
}

function meaningBlock({ x, y, width, height, theme, large = false }) {
  return `<g aria-label="What this means">
    <rect x="${x}" y="${y}" width="${width}" height="${height}" rx="${large ? 24 : 20}" fill="url(#meaning-gradient)" stroke="${theme.hairline}"/>
    <path d="M${x + 22} ${y + 25}h34" stroke="${theme.coralText}" stroke-width="3" stroke-linecap="round"/>
    <text x="${x + 22}" y="${y + (large ? 62 : 54)}" class="editorial" font-size="${large ? 26 : 22}" fill="${theme.ink}">A useful shift in focus.</text>
    <text x="${x + 22}" y="${y + (large ? 94 : 82)}" class="ui" font-size="${large ? 13.5 : 11.5}" fill="${theme.secondary}">Notice patterns, refine language, and give</text>
    <text x="${x + 22}" y="${y + (large ? 115 : 101)}" class="ui" font-size="${large ? 13.5 : 11.5}" fill="${theme.secondary}">small details a shape you can use.</text>
    ${large ? `<text x="${x + 22}" y="${y + 147}" class="ui" font-size="12" fill="${theme.secondary}">Humay editorial reading · concise and non-deterministic</text>` : ""}
  </g>`;
}

function phoneReference(mode) {
  const theme = themes[mode];
  const body = `<rect width="430" height="932" fill="${theme.ground}"/>
    ${reviewLabel(430, theme)}
    ${statusBar(430, theme, "phone")}
    ${backHeader(theme)}
    ${sampleNotice(20, 94, theme)}

    <g aria-label="Mercury enters Virgo event identity">
      <rect x="20" y="133" width="390" height="239" rx="26" fill="url(#hero-gradient)" stroke="${mode === "light" ? "#2E3748" : theme.hairline}"/>
      <path d="M270 133c-12 55 5 162 92 239h48V133Z" fill="${theme.lavender}" opacity="0.09"/>
      <text x="42" y="165" class="label" font-size="8" fill="${theme.heroSecondary}">PLANETARY INGRESS</text>
      <text x="42" y="211" class="editorial" font-size="30" fill="${theme.heroText}">Mercury enters</text>
      <text x="42" y="246" class="editorial" font-size="30" fill="${theme.heroText}">Virgo</text>
      <text x="42" y="278" class="ui" font-size="10.5" fill="${theme.heroSecondary}">Western · reference fixture</text>
      <line x1="42" y1="296" x2="244" y2="296" stroke="${theme.heroSecondary}" stroke-opacity="0.42"/>
      <text x="42" y="319" class="label" font-size="7.2" fill="${theme.heroSecondary}">TIMING</text>
      <text x="101" y="320" class="mono" font-size="13.2" font-weight="600" fill="${theme.heroText}">Fri 21:00 TRT</text>
      <text x="42" y="349" class="ui" font-size="9.4" fill="${theme.heroSecondary}">Instant timing shown as reference content.</text>
      ${heroMotif(theme, mode, 342, 224)}
    </g>

    <text x="20" y="409" class="editorial" font-size="23" fill="${theme.ink}">What this means</text>
    ${meaningBlock({ x: 20, y: 424, width: 390, height: 116, theme })}

    <text x="20" y="581" class="editorial" font-size="23" fill="${theme.ink}">Factual context</text>
    <g aria-label="Factual context" filter="url(#soft-shadow)">
      <rect x="20" y="592" width="390" height="221" rx="22" fill="${theme.surface}" stroke="${theme.hairline}"/>
      ${factRow({ x: 40, y: 608, width: 350, label: "Timing", value: "Fri 21:00 TRT", detail: "Instant reference timing", theme })}
      ${factRow({ x: 40, y: 657, width: 350, label: "Method", value: "Western", detail: "System label stays visible", theme, valueColor: theme.coralText })}
      ${factRow({ x: 40, y: 706, width: 350, label: "Involved", value: "Mercury · Virgo", detail: "Ingress fixture", theme })}
      ${factRow({ x: 40, y: 755, width: 350, label: "Event type", value: "Planetary ingress", detail: "A body changes sign", theme, last: true })}
    </g>
    <g aria-label="Event detail route context">
      <line x1="20" y1="831" x2="410" y2="831" stroke="${theme.hairline}"/>
      <text x="20" y="855" class="ui" font-size="10.5" fill="${theme.secondary}">From Current Sky or Calendar</text>
      <text x="410" y="855" text-anchor="end" class="ui" font-size="10.5" font-weight="700" fill="${theme.coralText}">READ THE EVENT</text>
    </g>
    ${phoneTabBar(theme)}`;
  return svgShell({
    width: 430,
    height: 932,
    title: `Humay Event Detail iPhone ${mode}`,
    description: `D3.3 review candidate, not approved. Editorial event detail on a 430 by 932 point iPhone canvas in ${mode} appearance.`,
    mode,
    body
  });
}

function iPadReference(mode) {
  const theme = themes[mode];
  const leftX = 48;
  const leftWidth = 436;
  const rightX = 540;
  const rightWidth = 436;
  const body = `<rect width="1024" height="1366" fill="${theme.ground}"/>
    ${reviewLabel(1024, theme)}
    ${statusBar(1024, theme, "pad")}
    ${iPadTopNavigation(theme)}
    ${backHeader(theme, { wide: true })}
    ${sampleNotice(48, 184, theme, 204)}

    <g aria-label="Event identity and editorial meaning">
      <rect x="${leftX}" y="236" width="${leftWidth}" height="314" rx="28" fill="url(#hero-gradient)" stroke="${mode === "light" ? "#2E3748" : theme.hairline}"/>
      <path d="M310 236c-20 74-8 210 86 314h88V236Z" fill="${theme.lavender}" opacity="0.09"/>
      <text x="78" y="274" class="label" font-size="8.5" fill="${theme.heroSecondary}">PLANETARY INGRESS</text>
      <text x="78" y="325" class="editorial" font-size="37" fill="${theme.heroText}">Mercury enters</text>
      <text x="78" y="367" class="editorial" font-size="37" fill="${theme.heroText}">Virgo</text>
      <text x="78" y="405" class="ui" font-size="12" fill="${theme.heroSecondary}">Western · reference fixture</text>
      <line x1="78" y1="428" x2="283" y2="428" stroke="${theme.heroSecondary}" stroke-opacity="0.42"/>
      <text x="78" y="455" class="label" font-size="7.5" fill="${theme.heroSecondary}">TIMING</text>
      <text x="145" y="456" class="mono" font-size="15" font-weight="600" fill="${theme.heroText}">Fri 21:00 TRT</text>
      <text x="78" y="488" class="ui" font-size="10.5" fill="${theme.heroSecondary}">Instant timing shown as reference content.</text>
      ${heroMotif(theme, mode, 408, 353)}
    </g>

    <text x="${leftX}" y="598" class="editorial" font-size="28" fill="${theme.ink}">What this means</text>
    ${meaningBlock({ x: leftX, y: 616, width: leftWidth, height: 177, theme, large: true })}
    <g aria-label="How Event Detail relates to Calendar">
      <rect x="${leftX}" y="846" width="${leftWidth}" height="132" rx="22" fill="${theme.secondarySurface}" stroke="${theme.hairline}"/>
      <text x="${leftX + 22}" y="881" class="label" font-size="7.7" fill="${theme.coralText}">FROM CALENDAR TO DETAIL</text>
      <text x="${leftX + 22}" y="913" class="ui" font-size="14" font-weight="700" fill="${theme.ink}">Chronology opens into explanation.</text>
      <text x="${leftX + 22}" y="938" class="ui" font-size="11.5" fill="${theme.secondary}">The row gives the date; this page gives</text>
      <text x="${leftX + 22}" y="958" class="ui" font-size="11.5" fill="${theme.secondary}">meaning and the available factual basis.</text>
    </g>

    <text x="${rightX}" y="254" class="editorial" font-size="28" fill="${theme.ink}">Factual context</text>
    <g aria-label="Factual context" filter="url(#soft-shadow)">
      <rect x="${rightX}" y="273" width="${rightWidth}" height="344" rx="24" fill="${theme.surface}" stroke="${theme.hairline}"/>
      ${factRow({ x: rightX + 22, y: 294, width: rightWidth - 44, label: "Timing", value: "Fri 21:00 TRT", detail: "Instant reference timing" , theme })}
      ${factRow({ x: rightX + 22, y: 343, width: rightWidth - 44, label: "Method", value: "Western", detail: "Visible, quiet system context", theme, valueColor: theme.coralText })}
      ${factRow({ x: rightX + 22, y: 392, width: rightWidth - 44, label: "Involved", value: "Mercury · Virgo", detail: "Ingress fixture", theme })}
      ${factRow({ x: rightX + 22, y: 441, width: rightWidth - 44, label: "Event type", value: "Planetary ingress", detail: "A body changes sign", theme })}
      ${factRow({ x: rightX + 22, y: 490, width: rightWidth - 44, label: "Availability", value: "Reference only", detail: "Development sample · not calculated", theme, last: true, valueColor: theme.goldText })}
    </g>

    <g aria-label="Timing language guidance">
      <rect x="${rightX}" y="674" width="${rightWidth}" height="172" rx="22" fill="${theme.blueWash}" stroke="${theme.hairline}"/>
      <text x="${rightX + 22}" y="710" class="label" font-size="7.7" fill="${theme.blueText}">TIMING LANGUAGE</text>
      <text x="${rightX + 22}" y="744" class="editorial" font-size="24" fill="${theme.ink}">Precision stays honest.</text>
      <text x="${rightX + 22}" y="776" class="ui" font-size="11.5" fill="${theme.secondary}">Instant, range, date-only, and unavailable</text>
      <text x="${rightX + 22}" y="797" class="ui" font-size="11.5" fill="${theme.secondary}">timing use distinct labels—not guessed clocks.</text>
      <text x="${rightX + 22}" y="827" class="ui" font-size="10.5" fill="${theme.secondary}">A reference fixture never becomes a factual claim.</text>
    </g>
    <g aria-label="Supporting route context">
      <line x1="${rightX}" y1="895" x2="${rightX + rightWidth}" y2="895" stroke="${theme.hairline}"/>
      <text x="${rightX}" y="923" class="ui" font-size="11.5" fill="${theme.secondary}">Appears from Current Sky or Calendar</text>
      <text x="${rightX + rightWidth}" y="923" text-anchor="end" class="ui" font-size="11.5" font-weight="700" fill="${theme.coralText}">NATIVE BACK</text>
    </g>`;
  return svgShell({
    width: 1024,
    height: 1366,
    title: `Humay Event Detail iPad ${mode}`,
    description: `D3.3 review candidate, not approved. Bounded two-region Event Detail composition on a 1024 by 1366 point iPad canvas in ${mode} appearance.`,
    mode,
    body
  });
}

function stateIcon(kind, cx, cy, theme) {
  if (kind === "loading") {
    return `<circle cx="${cx}" cy="${cy}" r="20" fill="none" stroke="${theme.hairline}" stroke-width="4"/><path d="M${cx} ${cy - 20}a20 20 0 0 1 18 11" fill="none" stroke="${theme.lavender}" stroke-width="4" stroke-linecap="round"/>`;
  }
  if (kind === "offline") {
    return `<path d="M${cx - 20} ${cy - 7}c12-10 28-10 40 0m-32 8c7-6 17-6 24 0m-16 9c2-2 6-2 8 0M${cx - 18} ${cy - 22}l36 40" fill="none" stroke="${theme.gold}" stroke-width="3" stroke-linecap="round"/>`;
  }
  if (kind === "failed") {
    return `<path d="M${cx} ${cy - 22}l22 40h-44Z" fill="none" stroke="${theme.coral}" stroke-width="3" stroke-linejoin="round"/><path d="M${cx} ${cy - 8}v13m0 7v1" stroke="${theme.coral}" stroke-width="3" stroke-linecap="round"/>`;
  }
  if (kind === "not-found") {
    return `<circle cx="${cx}" cy="${cy}" r="21" fill="none" stroke="${theme.sage}" stroke-width="2.5"/><path d="M${cx - 8} ${cy - 5}h13m-13 8h8" stroke="${theme.sage}" stroke-width="2.5" stroke-linecap="round"/><path d="M${cx + 8} ${cy - 10}l8 8-8 8" fill="none" stroke="${theme.coral}" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>`;
  }
  if (kind === "empty") {
    return `<circle cx="${cx}" cy="${cy}" r="20" fill="none" stroke="${theme.sage}" stroke-width="2.5"/><circle cx="${cx - 2}" cy="${cy}" r="8" fill="${theme.gold}"/><circle cx="${cx + 3}" cy="${cy - 3}" r="8" fill="${theme.surface}"/><path d="M${cx + 14} ${cy - 14}c1 4 2 5 6 6-4 1-5 2-6 6-1-4-2-5-6-6 4-1 5-2 6-6Z" fill="${theme.coral}"/>`;
  }
  return `<circle cx="${cx}" cy="${cy}" r="21" fill="none" stroke="${theme.lavender}" stroke-width="3"/><path d="M${cx} ${cy - 9}v11m0 7v1" stroke="${theme.lavender}" stroke-width="3" stroke-linecap="round"/>`;
}

function statePreview({ x, y, width, height, kind, theme }) {
  const innerX = x + 20;
  const innerWidth = width - 40;
  if (kind === "loading") {
    return `<rect x="${innerX}" y="${y}" width="${innerWidth}" height="${height}" rx="20" fill="${theme.surface}" stroke="${theme.hairline}"/>
      <rect x="${innerX + 20}" y="${y + 20}" width="170" height="13" rx="6.5" fill="${theme.secondarySurface}"/>
      <rect x="${innerX + 20}" y="${y + 48}" width="250" height="18" rx="9" fill="${theme.secondarySurface}"/>
      ${stateIcon("loading", x + width / 2, y + 110, theme)}
      <text x="${x + width / 2}" y="${y + 155}" text-anchor="middle" class="ui" font-size="14" font-weight="700" fill="${theme.ink}">Opening event detail…</text>
      <rect x="${innerX + 20}" y="${y + 182}" width="${innerWidth - 40}" height="10" rx="5" fill="${theme.secondarySurface}"/>
      <rect x="${innerX + 20}" y="${y + 204}" width="${innerWidth - 96}" height="10" rx="5" fill="${theme.secondarySurface}"/>`;
  }
  if (kind === "cached") {
    return `<rect x="${innerX}" y="${y}" width="${innerWidth}" height="${height}" rx="20" fill="${theme.surface}" stroke="${theme.hairline}"/>
      <rect x="${innerX + 14}" y="${y + 14}" width="${innerWidth - 28}" height="58" rx="15" fill="${theme.secondarySurface}"/>
      ${stateIcon("offline", innerX + 42, y + 43, theme)}
      <text x="${innerX + 76}" y="${y + 38}" class="ui" font-size="13.5" font-weight="700" fill="${theme.ink}">Offline · saved event</text>
      <text x="${innerX + 76}" y="${y + 57}" class="ui" font-size="10.5" fill="${theme.secondary}">Showing content saved 12 Aug · 09:00</text>
      <text x="${innerX + 20}" y="${y + 108}" class="editorial" font-size="22" fill="${theme.ink}">Mercury enters Virgo</text>
      <text x="${innerX + 20}" y="${y + 136}" class="mono" font-size="10.5" fill="${theme.secondary}">Fri 21:00 TRT · Western</text>
      <line x1="${innerX + 20}" y1="${y + 158}" x2="${innerX + innerWidth - 20}" y2="${y + 158}" stroke="${theme.hairline}"/>
      <text x="${innerX + 20}" y="${y + 187}" class="ui" font-size="11.5" fill="${theme.secondary}">Saved facts stay readable; freshness stays explicit.</text>`;
  }
  const content = {
    unavailable: ["Event detail unavailable", "This event needs a connected source.", "The route remains readable without guessed facts."],
    empty: ["No saved event detail", "Reconnect to view this event.", "No recovery action is promised here."],
    failed: ["Event detail couldn’t load", "The event facts could not be loaded.", "Use native Back to return to Calendar."],
    "not-found": ["Event no longer available", "This event is not in the current source.", "Use native Back to choose another event."]
  }[kind];
  return `<rect x="${innerX}" y="${y}" width="${innerWidth}" height="${height}" rx="20" fill="${theme.surface}" stroke="${theme.hairline}"/>
    ${stateIcon(kind, x + width / 2, y + 63, theme)}
    <text x="${x + width / 2}" y="${y + 124}" text-anchor="middle" class="editorial" font-size="23" fill="${theme.ink}">${escapeText(content[0])}</text>
    <text x="${x + width / 2}" y="${y + 158}" text-anchor="middle" class="ui" font-size="12" fill="${theme.secondary}">${escapeText(content[1])}</text>
    <text x="${x + width / 2}" y="${y + 181}" text-anchor="middle" class="ui" font-size="11" fill="${theme.secondary}">${escapeText(content[2])}</text>
    ${kind === "not-found" ? `<line x1="${innerX + 28}" y1="${y + 210}" x2="${innerX + innerWidth - 28}" y2="${y + 210}" stroke="${theme.hairline}"/><text x="${x + width / 2}" y="${y + 238}" text-anchor="middle" class="ui" font-size="11" font-weight="700" fill="${theme.coralText}">Back to Calendar</text>` : ""}`;
}

function statePanel({ x, y, width, height, mode, index, name, note, kind }) {
  const theme = themes[mode];
  return `<g>
    <rect x="${x}" y="${y}" width="${width}" height="${height}" rx="28" fill="${theme.ground}" stroke="${theme.hairline}"/>
    <text x="${x + 24}" y="${y + 31}" class="label" font-size="9" fill="${theme.coralText}">${String(index).padStart(2, "0")} · ${escapeText(name.toUpperCase())}</text>
    <text x="${x + width - 24}" y="${y + 31}" text-anchor="end" class="label" font-size="8" fill="${theme.tertiary}">${mode === "light" ? "LIGHT EXAMPLE" : "DARK EXAMPLE"}</text>
    <text x="${x + 24}" y="${y + 63}" class="ui" font-size="12.5" fill="${theme.secondary}">${escapeText(note)}</text>
    ${statePreview({ x, y: y + 88, width, height: height - 112, kind, theme })}
  </g>`;
}

function stateBoard() {
  const panels = [
    { x: 40, y: 166, mode: "light", index: 1, name: "Loading", kind: "loading", note: "Stable shell; no fake event payload." },
    { x: 560, y: 166, mode: "dark", index: 2, name: "Unavailable", kind: "unavailable", note: "Source limitation stays explicit." },
    { x: 1080, y: 166, mode: "light", index: 3, name: "Offline with cache", kind: "cached", note: "Saved detail remains visible with freshness." },
    { x: 40, y: 624, mode: "dark", index: 4, name: "Offline without cache", kind: "empty", note: "No saved payload; no invented recovery control." },
    { x: 560, y: 624, mode: "light", index: 5, name: "Failed", kind: "failed", note: "Failure copy; retry remains pipeline-owned." },
    { x: 1080, y: 624, mode: "dark", index: 6, name: "Event not found", kind: "not-found", note: "Distinct from source failure; native Back stays available." }
  ].map((panel) => statePanel({ ...panel, width: 480, height: 408 })).join("");
  return svgShell({
    width: 1600,
    height: 1080,
    title: "Humay Event Detail state board",
    description: "D3.3 review candidate, not approved. Event Detail state treatments for loading, unavailable, offline with and without cache, failed, and event not found.",
    mode: "light",
    body: `<rect width="1600" height="1080" fill="#EFE9E2"/>
      <text x="40" y="53" class="label" font-size="10.5" fill="${themes.light.coralText}">D3.3 · REVIEW CANDIDATE — NOT APPROVED</text>
      <text x="40" y="99" class="editorial" font-size="42" fill="${themes.light.ink}">Event Detail state language</text>
      <text x="40" y="128" class="ui" font-size="14.5" fill="${themes.light.secondary}">Shared shell, explicit availability, natural copy, and no unsupported Retry or provider-debug UI.</text>
      ${panels}`
  });
}

function stressPanel({ x, mode, label, note, body }) {
  const theme = themes[mode];
  return `<g>
    <rect x="${x}" y="137" width="350" height="700" rx="26" fill="${theme.ground}" stroke="${theme.hairline}"/>
    <text x="${x + 22}" y="170" class="label" font-size="8.5" fill="${theme.coralText}">${escapeText(label)}</text>
    <text x="${x + 22}" y="197" class="ui" font-size="11" fill="${theme.secondary}">${escapeText(note)}</text>
    ${body(theme, x + 22, 232)}
  </g>`;
}

function stressBoard() {
  const panels = [
    stressPanel({
      x: 40,
      mode: "light",
      label: "01 · TITLE + TIMING",
      note: "Long identity wraps before facts disappear.",
      body: (theme, x, y) => `<rect x="${x}" y="${y}" width="306" height="270" rx="20" fill="${theme.surface}" stroke="${theme.hairline}"/>
        ${eventGlyph("ingress", x + 43, y + 45, theme, 0.74)}
        <text x="${x + 78}" y="${y + 39}" class="label" font-size="7" fill="${theme.coralText}">PLANETARY INGRESS</text>
        <text x="${x + 78}" y="${y + 70}" class="ui" font-size="15" font-weight="700" fill="${theme.ink}">Mars enters Sagittarius</text>
        <text x="${x + 78}" y="${y + 91}" class="ui" font-size="15" font-weight="700" fill="${theme.ink}">after an extended cycle</text>
        <text x="${x + 22}" y="${y + 130}" class="label" font-size="7" fill="${theme.tertiary}">DATE-ONLY TIMING</text>
        <text x="${x + 22}" y="${y + 153}" class="mono" font-size="11" fill="${theme.secondary}">Date only · 27 November</text>
        <line x1="${x + 22}" y1="${y + 178}" x2="${x + 284}" y2="${y + 178}" stroke="${theme.hairline}"/>
        <text x="${x + 22}" y="${y + 208}" class="label" font-size="7" fill="${theme.tertiary}">RANGE TIMING</text>
        <text x="${x + 22}" y="${y + 231}" class="mono" font-size="11" fill="${theme.secondary}">Fri 21:00 – Sat 03:00</text>
        ${methodology(x + 22, y + 244, "Western", theme, theme.coral)}`
    }),
    stressPanel({
      x: 430,
      mode: "dark",
      label: "02 · EVENT CLASSES",
      note: "Glyph supports identity; text carries meaning.",
      body: (theme, x, y) => `<g aria-label="Lunar phase, aspect, and tradition-specific examples">
        ${stressEventRow({ x, y, theme, kind: "moon", title: "Full Moon", meta: "Lunar phase · Astronomical", color: theme.goldText })}
        ${stressEventRow({ x, y: y + 102, theme, kind: "aspect", title: "Venus trine Jupiter", meta: "Aspect · Western", color: theme.lavenderText })}
        ${stressEventRow({ x, y: y + 204, theme, kind: "tradition", title: "Tradition-specific event", meta: "Vedic · methodology label", color: theme.blueText })}
        <rect x="${x}" y="${y + 328}" width="306" height="124" rx="18" fill="${theme.secondarySurface}" stroke="${theme.hairline}"/>
        <text x="${x + 18}" y="${y + 360}" class="label" font-size="7.2" fill="${theme.tertiary}">SYMBOL RULE</text>
        <text x="${x + 18}" y="${y + 389}" class="ui" font-size="12" fill="${theme.secondary}">No glyph wall. Event name, type,</text>
        <text x="${x + 18}" y="${y + 410}" class="ui" font-size="12" fill="${theme.secondary}">system, and timing remain textual.</text>
      </g>`
    }),
    stressPanel({
      x: 820,
      mode: "light",
      label: "03 · CONTENT DENSITY",
      note: "Sparse facts and longer meaning share one shell.",
      body: (theme, x, y) => `<g aria-label="Long interpretation and sparse or dense factual context">
        <rect x="${x}" y="${y}" width="306" height="308" rx="20" fill="${theme.surface}" stroke="${theme.hairline}"/>
        <text x="${x + 18}" y="${y + 31}" class="label" font-size="7.2" fill="${theme.coralText}">LONGER INTERPRETATION</text>
        <text x="${x + 18}" y="${y + 64}" class="editorial" font-size="22" fill="${theme.ink}">Meaning can breathe.</text>
        <text x="${x + 18}" y="${y + 95}" class="ui" font-size="11.5" fill="${theme.secondary}">The editorial layer grows to three or</text>
        <text x="${x + 18}" y="${y + 115}" class="ui" font-size="11.5" fill="${theme.secondary}">four lines without swallowing facts.</text>
        <line x1="${x + 18}" y1="${y + 143}" x2="${x + 288}" y2="${y + 143}" stroke="${theme.hairline}"/>
        <text x="${x + 18}" y="${y + 173}" class="label" font-size="7.2" fill="${theme.tertiary}">SPARSE FACTS</text>
        <text x="${x + 18}" y="${y + 198}" class="ui" font-size="12.5" font-weight="700" fill="${theme.ink}">Type · Lunar phase</text>
        <text x="${x + 18}" y="${y + 222}" class="ui" font-size="12.5" fill="${theme.secondary}">Timing unavailable</text>
        <line x1="${x + 18}" y1="${y + 241}" x2="${x + 288}" y2="${y + 241}" stroke="${theme.hairline}"/>
        <text x="${x + 18}" y="${y + 267}" class="label" font-size="7.2" fill="${theme.tertiary}">DENSE FACTS</text>
        <text x="${x + 18}" y="${y + 289}" class="ui" font-size="11" fill="${theme.secondary}">Bodies · phase · visibility · source note</text>
      </g>`
    }),
    stressPanel({
      x: 1210,
      mode: "dark",
      label: "04 · ACCESSIBILITY PRESSURE",
      note: "Large type collapses regions before truncation.",
      body: (theme, x, y) => `<g aria-label="Dynamic Type and methodology pressure">
        <rect x="${x}" y="${y}" width="306" height="374" rx="20" fill="${theme.surface}" stroke="${theme.hairline}"/>
        <text x="${x + 18}" y="${y + 43}" class="editorial" font-size="29" fill="${theme.ink}">Event detail</text>
        <text x="${x + 18}" y="${y + 82}" class="ui" font-size="20" font-weight="700" fill="${theme.ink}">Fri 21:00 – Sat 03:00</text>
        <text x="${x + 18}" y="${y + 113}" class="ui" font-size="17" font-weight="700" fill="${theme.ink}">Timing unavailable</text>
        <line x1="${x + 18}" y1="${y + 137}" x2="${x + 288}" y2="${y + 137}" stroke="${theme.hairline}"/>
        <text x="${x + 18}" y="${y + 174}" class="label" font-size="7.2" fill="${theme.tertiary}">METHODOLOGY PRESSURE</text>
        <text x="${x + 18}" y="${y + 207}" class="ui" font-size="18" font-weight="700" fill="${theme.coralText}">Astronomical</text>
        <text x="${x + 18}" y="${y + 233}" class="ui" font-size="18" font-weight="700" fill="${theme.coralText}">Western · Vedic</text>
        <rect x="${x + 18}" y="${y + 270}" width="270" height="56" rx="14" fill="${theme.secondarySurface}" stroke="${theme.hairline}"/>
        <text x="${x + 34}" y="${y + 294}" class="ui" font-size="11.5" fill="${theme.secondary}">44 pt targets remain. Meaningful</text>
        <text x="${x + 34}" y="${y + 313}" class="ui" font-size="11.5" fill="${theme.secondary}">labels stay readable; art hides first.</text>
      </g>`
    })
  ].join("");
  return svgShell({
    width: 1600,
    height: 900,
    title: "Humay Event Detail stress board",
    description: "D3.3 review candidate, not approved. Event Detail stress evidence for long titles, lunar phase, aspects, tradition-specific events, timing precision, content density, methodology pressure, and Dynamic Type.",
    mode: "light",
    body: `<rect width="1600" height="900" fill="#EFE9E2"/>
      <text x="40" y="53" class="label" font-size="10.5" fill="${themes.light.coralText}">D3.3 · REVIEW CANDIDATE — NOT APPROVED</text>
      <text x="40" y="99" class="editorial" font-size="42" fill="${themes.light.ink}">Event Detail stress evidence</text>
      <text x="40" y="128" class="ui" font-size="14.5" fill="${themes.light.secondary}">Long identity, event-class variation, mixed timing, sparse/dense facts, and large-type pressure share one explanatory shell.</text>
      ${panels}`
  });
}

function stressEventRow({ x, y, theme, kind, title, meta, color }) {
  return `<g>
    <rect x="${x}" y="${y}" width="306" height="82" rx="18" fill="${theme.surface}" stroke="${theme.hairline}"/>
    ${eventGlyph(kind, x + 38, y + 41, theme, 0.67)}
    <text x="${x + 72}" y="${y + 36}" class="ui" font-size="13.5" font-weight="700" fill="${theme.ink}">${escapeText(title)}</text>
    <text x="${x + 72}" y="${y + 58}" class="ui" font-size="10.5" fill="${color}">${escapeText(meta)}</text>
  </g>`;
}

async function writeSvgAndPng(name, svg, pngWidth) {
  const svgPath = path.join(outputDirectory, `${name}.svg`);
  const pngPath = path.join(outputDirectory, `${name}.png`);
  const normalizedSvg = svg.replace(/[ \t]+\n/g, "\n");
  fs.writeFileSync(svgPath, normalizedSvg);
  await sharp(Buffer.from(normalizedSvg))
    .resize({ width: pngWidth, withoutEnlargement: false })
    .png({ compressionLevel: 9, adaptiveFiltering: true })
    .toFile(pngPath);
}

async function main() {
  await writeSvgAndPng("iphone-light", phoneReference("light"), 860);
  await writeSvgAndPng("iphone-dark", phoneReference("dark"), 860);
  await writeSvgAndPng("ipad-light", iPadReference("light"), 2048);
  await writeSvgAndPng("ipad-dark", iPadReference("dark"), 2048);
  await writeSvgAndPng("states", stateBoard(), 1600);
  await writeSvgAndPng("stress", stressBoard(), 1600);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
