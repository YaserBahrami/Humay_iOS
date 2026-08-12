const fs = require("node:fs");
const path = require("node:path");
const sharp = require("sharp");

const outputDirectory = __dirname;
const elementDirectory = path.join(outputDirectory, "elements");
fs.mkdirSync(elementDirectory, { recursive: true });

const fontPath = path.resolve(
  outputDirectory,
  "../../../../../Humay/Resources/Fonts/CormorantGaramond-Regular.otf"
);
const editorialFont = fs.readFileSync(fontPath).toString("base64");

const calendarAssetDirectory = path.resolve(
  outputDirectory,
  "../../../../../Humay/Resources/Assets.xcassets/Illustrations/IllustrationCalendarCelestial.imageset"
);

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
    peach: "#F7C7B8",
    lavender: "#9A82C8",
    lavenderText: "#684F9D",
    softLavender: "#E8E0F1",
    gold: "#D5A253",
    goldText: "#80570E",
    blue: "#6B9FC1",
    blueText: "#356F91",
    sage: "#678E79",
    heroStart: "#151B28",
    heroEnd: "#293142",
    heroText: "#FFF8F0",
    heroSecondary: "#D7D1D1",
    calendarStart: "#FBE6DA",
    calendarEnd: "#EEE6F5",
    tab: "#FFFDF9",
    tabSelected: "#F6E9E1",
    shadow: "#35281C"
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
    coralText: "#FF8F8D",
    peach: "#F0A79A",
    lavender: "#C17ADB",
    lavenderText: "#C17ADB",
    softLavender: "#473653",
    gold: "#E5AA55",
    goldText: "#E5AA55",
    blue: "#78B1D5",
    blueText: "#78B1D5",
    sage: "#82BDA3",
    heroStart: "#20283A",
    heroEnd: "#33283D",
    heroText: "#F7F0E8",
    heroSecondary: "#D1C6C5",
    calendarStart: "#33272E",
    calendarEnd: "#29283D",
    tab: "#20283A",
    tabSelected: "#3A4055",
    shadow: "#000000"
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
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}" role="img" aria-labelledby="svg-title svg-description">
  <title id="svg-title">${escapeText(title)}</title>
  <desc id="svg-description">${escapeText(description)}</desc>
  <defs>
    <style>
      @font-face { font-family: "Humay Editorial"; src: url("data:font/otf;base64,${editorialFont}") format("opentype"); font-weight: 400; }
      .editorial { font-family: "Humay Editorial", Georgia, serif; font-weight: 400; }
      .ui { font-family: -apple-system, BlinkMacSystemFont, "Helvetica Neue", Arial, sans-serif; }
      .mono { font-family: "SFMono-Regular", Menlo, Consolas, monospace; }
      .label { font-family: -apple-system, BlinkMacSystemFont, "Helvetica Neue", Arial, sans-serif; font-weight: 700; letter-spacing: 1.15px; }
      text { text-rendering: optimizeLegibility; }
    </style>
    <linearGradient id="hero-gradient" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="${theme.heroStart}"/>
      <stop offset="1" stop-color="${theme.heroEnd}"/>
    </linearGradient>
    <linearGradient id="calendar-gradient" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="${theme.calendarStart}"/>
      <stop offset="1" stop-color="${theme.calendarEnd}"/>
    </linearGradient>
    <linearGradient id="profile-gradient" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="${theme.blue}" stop-opacity="0.82"/>
      <stop offset="1" stop-color="${theme.lavender}" stop-opacity="0.92"/>
    </linearGradient>
    <filter id="soft-shadow" x="-30%" y="-30%" width="160%" height="180%">
      <feDropShadow dx="0" dy="5" stdDeviation="10" flood-color="${theme.shadow}" flood-opacity="${mode === "light" ? "0.10" : "0.00"}"/>
    </filter>
    ${extraDefinitions}
  </defs>
  ${body}
</svg>`;
}

function reviewLabel(width, theme) {
  return `<text x="${width / 2}" y="18" text-anchor="middle" class="label" font-size="7.5" fill="${theme.coralText}">REVIEW CANDIDATE · NOT APPROVED</text>`;
}

function statusBar(width, theme, device) {
  const isPhone = device === "phone";
  const timeX = isPhone ? 22 : 24;
  const iconX = width - (isPhone ? 78 : 92);
  const date = isPhone ? "9:41" : "9:41  ·  Thu 13 Aug";
  return `
    <text x="${timeX}" y="31" class="ui" font-size="${isPhone ? 14 : 13}" font-weight="700" fill="${theme.ink}">${date}</text>
    <g transform="translate(${iconX} 19)" fill="none" stroke="${theme.ink}" stroke-width="2" stroke-linecap="round">
      <path d="M0 8h2V5h2v3h2V2h2v6"/>
      <path d="M14 4c3-3 8-3 11 0M17 7c2-2 4-2 6 0"/>
      <rect x="30" y="0" width="22" height="10" rx="3"/>
      <rect x="32" y="2" width="16" height="6" rx="2" fill="${theme.ink}" stroke="none"/>
      <path d="M53 3v4"/>
    </g>`;
}

function profileButton(x, y, theme, size = 44) {
  return `<g aria-label="Profile and settings">
    <circle cx="${x + size / 2}" cy="${y + size / 2}" r="${size / 2}" fill="url(#profile-gradient)"/>
    <circle cx="${x + size / 2}" cy="${y + size / 2}" r="${size / 2 - 0.5}" fill="none" stroke="${theme.hairline}"/>
    <text x="${x + size / 2}" y="${y + size / 2 + 5}" text-anchor="middle" class="ui" font-size="14" font-weight="800" fill="${theme.ink}">Y</text>
  </g>`;
}

function sampleNotice(x, y, theme, wide = false) {
  const width = wide ? 218 : 222;
  return `<g aria-label="Development sample, not calculated">
    <rect x="${x}" y="${y}" width="${width}" height="25" rx="12.5" fill="${theme.secondarySurface}" stroke="${theme.hairline}" stroke-width="0.7"/>
    <path d="M${x + 11} ${y + 11}l4-4 3 3-4 4m-2-1 5 5m-7-1 3-3" fill="none" stroke="${theme.tertiary}" stroke-width="1.5" stroke-linecap="round"/>
    <text x="${x + 26}" y="${y + 17}" class="ui" font-size="10.5" font-weight="650" fill="${theme.secondary}">Development sample · not calculated</text>
  </g>`;
}

function celestialArt(x, y, scale, theme, mode) {
  const moon = mode === "light" ? "#FFF0D9" : theme.gold;
  const shadow = mode === "light" ? theme.heroEnd : "#30263A";
  return `<g transform="translate(${x} ${y}) scale(${scale})" aria-hidden="true">
    <circle cx="0" cy="0" r="74" fill="${theme.lavender}" opacity="${mode === "light" ? "0.13" : "0.16"}"/>
    <ellipse cx="0" cy="2" rx="84" ry="32" fill="none" stroke="${theme.blue}" stroke-width="2" opacity="0.45" transform="rotate(-16)"/>
    <ellipse cx="0" cy="2" rx="102" ry="45" fill="none" stroke="${theme.gold}" stroke-width="2.5" opacity="0.92" transform="rotate(14)"/>
    <circle cx="0" cy="0" r="40" fill="${moon}"/>
    <circle cx="17" cy="-5" r="42" fill="${shadow}" opacity="0.94"/>
    <circle cx="-80" cy="-20" r="5" fill="${theme.coral}"/>
    <circle cx="90" cy="28" r="6" fill="${theme.lavender}"/>
    <circle cx="58" cy="-51" r="3.5" fill="${theme.gold}"/>
    <path d="M-56-58c1.5 8 3.5 10 11 11-7.5 1-9.5 3-11 11-1.5-8-3.5-10-11-11 7.5-1 9.5-3 11-11Z" fill="none" stroke="${theme.coral}" stroke-width="2"/>
    <path d="M73 53c1 6 2.5 7.5 8.5 8.5-6 1-7.5 2.5-8.5 8.5-1-6-2.5-7.5-8.5-8.5 6-1 7.5-2.5 8.5-8.5Z" fill="none" stroke="${theme.gold}" stroke-width="1.7"/>
  </g>`;
}

function eventGlyph(type, x, y, theme, background) {
  const common = `<circle cx="${x}" cy="${y}" r="18" fill="${theme.secondarySurface}"/>`;
  if (type === "moon") {
    return `${common}<circle cx="${x}" cy="${y}" r="9" fill="${theme.goldText}"/><circle cx="${x + 5}" cy="${y - 2}" r="9" fill="${theme.secondarySurface}"/>`;
  }
  if (type === "ingress") {
    return `${common}<circle cx="${x - 2}" cy="${y + 2}" r="6.5" fill="none" stroke="${theme.coralText}" stroke-width="2"/><path d="M${x + 3} ${y - 3}l8-8m-5 0h5v5" fill="none" stroke="${theme.coralText}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>`;
  }
  return `${common}<path d="M${x - 9} ${y + 6}l9-15 9 15Z" fill="none" stroke="${theme.lavenderText}" stroke-width="2" stroke-linejoin="round"/><circle cx="${x}" cy="${y + 2}" r="2.5" fill="${theme.lavenderText}"/>`;
}

function badge(x, y, label, theme, accent, width) {
  return `<g>
    <rect x="${x}" y="${y}" width="${width}" height="18" rx="9" fill="${accent}" fill-opacity="0.12"/>
    <text x="${x + width / 2}" y="${y + 12.5}" text-anchor="middle" class="ui" font-size="8.5" font-weight="700" fill="${theme.ink}">${escapeText(label)}</text>
  </g>`;
}

function phoneEventRow({ y, height, type, titleLines, summary, timing, system, systemWidth, accent }, theme, isLast) {
  const x = 20;
  const iconY = y + height / 2;
  let lineY = y + 23;
  const title = titleLines.map((line, index) =>
    `<text x="72" y="${lineY + index * 16}" class="ui" font-size="14" font-weight="700" fill="${theme.ink}">${escapeText(line)}</text>`
  ).join("");
  let detailY = lineY + titleLines.length * 16 + 1;
  const summaryText = summary
    ? `<text x="72" y="${detailY}" class="ui" font-size="10.5" fill="${theme.secondary}">${escapeText(summary)}</text>`
    : "";
  if (summary) detailY += 16;
  const badgeX = 374 - systemWidth;
  return `<g aria-label="${escapeText(titleLines.join(" "))}, ${escapeText(timing)}, ${escapeText(system)}">
    ${eventGlyph(type, 46, iconY, theme, theme.surface)}
    ${title}
    ${summaryText}
    <text x="72" y="${detailY}" class="mono" font-size="9.4" font-weight="600" fill="${theme.secondary}">${escapeText(timing)}</text>
    ${badge(badgeX, detailY - 13.2, system, theme, accent, systemWidth)}
    <path d="M388 ${iconY - 4}l4 4-4 4" fill="none" stroke="${theme.tertiary}" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/>
    ${isLast ? "" : `<line x1="72" y1="${y + height}" x2="402" y2="${y + height}" stroke="${theme.hairline}"/>`}
  </g>`;
}

function calendarDataUri(mode) {
  const file = path.join(calendarAssetDirectory, `${mode}.svg`);
  return `data:image/svg+xml;base64,${fs.readFileSync(file).toString("base64")}`;
}

function phoneTabBar(theme, mode) {
  const items = [
    ["Today", 52, "sun"],
    ["Circle", 132, "people"],
    ["Sky", 215, "sky"],
    ["Chart", 298, "chart"],
    ["Ask", 378, "ask"]
  ];
  const symbols = {
    sun: (x) => `<circle cx="${x}" cy="862" r="6" fill="none" stroke="currentColor" stroke-width="1.7"/><path d="M${x} 850v4m0 16v4m-12-12h4m16 0h4m-20-9 3 3m14 14 3 3m0-20-3 3m-14 14-3 3" stroke="currentColor" stroke-width="1.5"/>`,
    people: (x) => `<circle cx="${x - 4}" cy="858" r="4" fill="none" stroke="currentColor" stroke-width="1.6"/><circle cx="${x + 5}" cy="859" r="3.5" fill="none" stroke="currentColor" stroke-width="1.6"/><path d="M${x - 11} 869c2-7 12-7 15 0m0-5c5-2 9 1 10 5" fill="none" stroke="currentColor" stroke-width="1.6"/>`,
    sky: (x) => `<path d="M${x} 850c1.5 7 3 8.5 10 10-7 1.5-8.5 3-10 10-1.5-7-3-8.5-10-10 7-1.5 8.5-3 10-10Z" fill="currentColor"/><path d="M${x + 11} 850c.7 3.5 1.5 4.3 5 5-3.5.7-4.3 1.5-5 5-.7-3.5-1.5-4.3-5-5 3.5-.7 4.3-1.5 5-5Z" fill="currentColor" opacity=".75"/>`,
    chart: (x) => `<circle cx="${x}" cy="861" r="9" fill="none" stroke="currentColor" stroke-width="1.5"/><path d="M${x - 7} 856l14 10m-14 0 14-10M${x} 852v18" stroke="currentColor" stroke-width="1.2"/>`,
    ask: (x) => `<path d="M${x - 10} 853h15a5 5 0 0 1 5 5v7a5 5 0 0 1-5 5h-6l-5 4v-4h-4a5 5 0 0 1-5-5v-7a5 5 0 0 1 5-5Z" fill="none" stroke="currentColor" stroke-width="1.6"/><path d="M${x - 5} 859h10m-10 5h7" stroke="currentColor" stroke-width="1.4"/>`
  };
  return `<g aria-label="Primary navigation, Sky selected" filter="url(#soft-shadow)">
    <rect x="14" y="838" width="402" height="76" rx="32" fill="${theme.tab}" fill-opacity="${mode === "light" ? "0.97" : "0.96"}" stroke="${theme.hairline}"/>
    <rect x="174" y="844" width="82" height="64" rx="26" fill="${theme.tabSelected}"/>
    ${items.map(([label, x, type]) => `<g style="color:${type === "sky" ? theme.coralText : theme.ink}">${symbols[type](x)}<text x="${x}" y="897" text-anchor="middle" class="ui" font-size="10" font-weight="${type === "sky" ? "750" : "550"}" fill="${type === "sky" ? theme.coralText : theme.ink}">${label}</text></g>`).join("")}
  </g>`;
}

function phoneReference(mode) {
  const theme = themes[mode];
  const happeningCard = `<g filter="url(#soft-shadow)">
    <rect x="20" y="354" width="390" height="206" rx="20" fill="${theme.surface}" stroke="${theme.hairline}"/>
    ${phoneEventRow({ y: 354, height: 72, type: "moon", titleLines: ["Waning gibbous Moon"], summary: "Light softens toward the next phase.", timing: "Exact · Today 18:00 TRT", system: "Astronomical", systemWidth: 76, accent: theme.blue }, theme, false)}
    ${phoneEventRow({ y: 426, height: 76, type: "ingress", titleLines: ["Mars enters Gemini after an", "extended retrograde cycle"], summary: null, timing: "Date only · 14 August", system: "Western", systemWidth: 52, accent: theme.coral }, theme, false)}
    ${phoneEventRow({ y: 502, height: 58, type: "aspect", titleLines: ["Jupiter trine Saturn"], summary: null, timing: "Unavailable · timing not supplied", system: "Vedic", systemWidth: 44, accent: theme.lavender }, theme, true)}
  </g>`;

  const body = `
    <rect width="430" height="932" fill="${theme.ground}"/>
    ${reviewLabel(430, theme)}
    ${statusBar(430, theme, "phone")}
    <g aria-label="Sky header">
      <text x="20" y="98" class="editorial" font-size="36" fill="${theme.ink}">Sky</text>
      ${profileButton(366, 58, theme)}
    </g>
    ${sampleNotice(20, 116, theme)}

    <g aria-label="Current celestial hero, illustrative copy">
      <rect x="20" y="150" width="390" height="158" rx="24" fill="url(#hero-gradient)" stroke="${mode === "light" ? "#2E3748" : theme.hairline}"/>
      <path d="M280 150c-18 42-10 105 38 158h92V150Z" fill="${theme.lavender}" opacity="0.08"/>
      <text x="40" y="177" class="label" font-size="8.5" fill="${theme.lavender}">ILLUSTRATIVE EDITORIAL</text>
      <text x="40" y="211" class="editorial" font-size="27" fill="${theme.heroText}">A waning Moon</text>
      <text x="40" y="238" class="editorial" font-size="27" fill="${theme.heroText}">sets the rhythm</text>
      <text x="40" y="269" class="ui" font-size="10.5" fill="${theme.heroSecondary}">Astronomical · Europe/Istanbul</text>
      <text x="40" y="287" class="mono" font-size="9.5" fill="${theme.heroSecondary}">Observed 09:00 TRT</text>
      ${celestialArt(338, 226, 0.66, theme, mode)}
    </g>

    <text x="20" y="340" class="editorial" font-size="24" fill="${theme.ink}">Happening now</text>
    <text x="410" y="338" text-anchor="end" class="ui" font-size="10.5" font-weight="650" fill="${theme.secondary}">3 events</text>
    ${happeningCard}

    <g aria-label="Open Calendar" filter="url(#soft-shadow)">
      <rect x="20" y="574" width="390" height="76" rx="20" fill="url(#calendar-gradient)" stroke="${theme.hairline}"/>
      <image x="27" y="580" width="62" height="62" href="${calendarDataUri(mode)}"/>
      <text x="94" y="603" class="ui" font-size="16" font-weight="750" fill="${theme.ink}">Calendar</text>
      <text x="94" y="624" class="ui" font-size="11.5" fill="${theme.secondary}">Month, week, and full timeline</text>
      <circle cx="381" cy="612" r="22" fill="${theme.surface}" fill-opacity="0.76"/>
      <path d="M377 607l5 5-5 5" fill="none" stroke="${theme.ink}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
    </g>

    <text x="20" y="686" class="editorial" font-size="24" fill="${theme.ink}">Coming up</text>
    <text x="410" y="684" text-anchor="end" class="ui" font-size="10.5" font-weight="650" fill="${theme.secondary}">NEXT 2</text>
    <g aria-label="Upcoming celestial timeline">
      <line x1="43" y1="716" x2="43" y2="817" stroke="${theme.hairline}" stroke-width="2"/>
      <rect x="20" y="702" width="46" height="48" rx="14" fill="${theme.secondarySurface}" stroke="${theme.hairline}"/>
      <text x="43" y="719" text-anchor="middle" class="label" font-size="7" fill="${theme.coralText}">AUG</text>
      <text x="43" y="740" text-anchor="middle" class="ui" font-size="17" font-weight="750" fill="${theme.ink}">15</text>
      <text x="80" y="720" class="ui" font-size="14" font-weight="700" fill="${theme.ink}">Mercury square Uranus</text>
      <text x="80" y="740" class="mono" font-size="9.6" fill="${theme.secondary}">Window · Fri 21:00 – Sat 03:00</text>
      ${badge(328, 726, "Western", theme, theme.coral, 52)}

      <rect x="20" y="768" width="46" height="48" rx="14" fill="${theme.secondarySurface}" stroke="${theme.hairline}"/>
      <text x="43" y="785" text-anchor="middle" class="label" font-size="7" fill="${theme.goldText}">SEP</text>
      <text x="43" y="806" text-anchor="middle" class="ui" font-size="17" font-weight="750" fill="${theme.ink}">22</text>
      <text x="80" y="786" class="ui" font-size="14" font-weight="700" fill="${theme.ink}">Equinox</text>
      <text x="80" y="806" class="mono" font-size="9.6" fill="${theme.secondary}">Date only · 22 September</text>
      ${badge(302, 792, "Astronomical", theme, theme.blue, 78)}
    </g>
    ${phoneTabBar(theme, mode)}
  `;

  return svgShell({
    width: 430,
    height: 932,
    title: `Humay Current Sky iPhone ${mode}`,
    description: `Review candidate, not approved. Loaded Current Sky on a current 430 by 932 point iPhone canvas in ${mode} appearance.`,
    mode,
    body
  });
}

function iPadTopNavigation(theme, mode) {
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

function iPadEventRow({ x, y, width, height, type, titleLines, summary, timing, system, accent, systemWidth }, theme, isLast) {
  const iconX = x + 34;
  const iconY = y + height / 2;
  const textX = x + 66;
  const titleY = y + 29;
  const title = titleLines.map((line, index) =>
    `<text x="${textX}" y="${titleY + index * 20}" class="ui" font-size="16" font-weight="720" fill="${theme.ink}">${escapeText(line)}</text>`
  ).join("");
  let detailY = titleY + titleLines.length * 20 + 1;
  const summaryText = summary
    ? `<text x="${textX}" y="${detailY}" class="ui" font-size="12.5" fill="${theme.secondary}">${escapeText(summary)}</text>`
    : "";
  if (summary) detailY += 21;
  return `<g>
    ${eventGlyph(type, iconX, iconY, theme, theme.surface)}
    ${title}
    ${summaryText}
    <text x="${textX}" y="${detailY}" class="mono" font-size="11" font-weight="600" fill="${theme.secondary}">${escapeText(timing)}</text>
    ${badge(x + width - systemWidth - 20, detailY - 14, system, theme, accent, systemWidth)}
    <path d="M${x + width - 24} ${iconY - 5}l5 5-5 5" fill="none" stroke="${theme.tertiary}" stroke-width="2" stroke-linecap="round"/>
    ${isLast ? "" : `<line x1="${textX}" y1="${y + height}" x2="${x + width - 20}" y2="${y + height}" stroke="${theme.hairline}"/>`}
  </g>`;
}

function iPadReference(mode) {
  const theme = themes[mode];
  const rightX = 534;
  const rightWidth = 442;
  const body = `
    <rect width="1024" height="1366" fill="${theme.ground}"/>
    ${reviewLabel(1024, theme)}
    ${statusBar(1024, theme, "pad")}
    ${iPadTopNavigation(theme, mode)}
    <g aria-label="Sky header">
      <text x="48" y="169" class="editorial" font-size="38" fill="${theme.ink}">Sky</text>
      ${profileButton(932, 128, theme, 44)}
    </g>
    ${sampleNotice(48, 185, theme, true)}

    <g aria-label="Primary Current Sky region">
      <rect x="48" y="232" width="454" height="326" rx="28" fill="url(#hero-gradient)" stroke="${mode === "light" ? "#2E3748" : theme.hairline}"/>
      <path d="M310 232c-31 76-19 219 92 326h100V232Z" fill="${theme.lavender}" opacity="0.08"/>
      <text x="78" y="272" class="label" font-size="10" fill="${theme.lavender}">ILLUSTRATIVE EDITORIAL</text>
      <text x="78" y="318" class="editorial" font-size="37" fill="${theme.heroText}">A waning Moon</text>
      <text x="78" y="356" class="editorial" font-size="37" fill="${theme.heroText}">sets the rhythm</text>
      <text x="78" y="394" class="ui" font-size="14" fill="${theme.heroSecondary}">Presentation-owned sample copy.</text>
      <text x="78" y="463" class="ui" font-size="12.5" font-weight="650" fill="${theme.heroSecondary}">ASTRONOMICAL · EUROPE/ISTANBUL</text>
      <text x="78" y="486" class="mono" font-size="12" fill="${theme.heroSecondary}">Observed 09:00 TRT</text>
      ${celestialArt(391, 435, 0.98, theme, mode)}
    </g>

    <g aria-label="Open Calendar" filter="url(#soft-shadow)">
      <rect x="48" y="586" width="454" height="118" rx="24" fill="url(#calendar-gradient)" stroke="${theme.hairline}"/>
      <image x="63" y="602" width="86" height="86" href="${calendarDataUri(mode)}"/>
      <text x="156" y="626" class="ui" font-size="18" font-weight="760" fill="${theme.ink}">Calendar</text>
      <text x="156" y="651" class="ui" font-size="13.5" fill="${theme.secondary}">Month, week, and complete timeline</text>
      <text x="156" y="675" class="ui" font-size="12" font-weight="650" fill="${theme.coralText}">OPEN CALENDAR</text>
      <circle cx="466" cy="645" r="22" fill="${theme.surface}" fill-opacity="0.76"/>
      <path d="M462 640l5 5-5 5" fill="none" stroke="${theme.ink}" stroke-width="2"/>
    </g>

    <g aria-label="Observation context">
      <rect x="48" y="730" width="454" height="118" rx="22" fill="${theme.surface}" stroke="${theme.hairline}"/>
      <circle cx="84" cy="766" r="20" fill="${theme.blue}" opacity="0.14"/>
      <circle cx="84" cy="766" r="9" fill="none" stroke="${theme.blue}" stroke-width="1.8"/>
      <path d="M75 766h18M84 757c4 5 4 13 0 18M84 757c-4 5-4 13 0 18" fill="none" stroke="${theme.blue}" stroke-width="1.2"/>
      <text x="116" y="759" class="ui" font-size="15" font-weight="720" fill="${theme.ink}">Observation context</text>
      <text x="116" y="782" class="ui" font-size="13" fill="${theme.secondary}">Times use Europe/Istanbul. Date-only events</text>
      <text x="116" y="802" class="ui" font-size="13" fill="${theme.secondary}">never receive a fabricated clock time.</text>
      <line x1="76" y1="820" x2="474" y2="820" stroke="${theme.hairline}"/>
      <text x="76" y="839" class="ui" font-size="10.5" fill="${theme.tertiary}">Context stays factual; it does not become another card wall.</text>
    </g>

    <text x="${rightX}" y="254" class="editorial" font-size="27" fill="${theme.ink}">Happening now</text>
    <text x="${rightX + rightWidth}" y="252" text-anchor="end" class="ui" font-size="11" font-weight="650" fill="${theme.secondary}">3 EVENTS</text>
    <g filter="url(#soft-shadow)">
      <rect x="${rightX}" y="272" width="${rightWidth}" height="338" rx="24" fill="${theme.surface}" stroke="${theme.hairline}"/>
      ${iPadEventRow({ x: rightX, y: 272, width: rightWidth, height: 112, type: "moon", titleLines: ["Waning gibbous Moon"], summary: "Light softens toward the next phase.", timing: "Exact · Today 18:00 TRT", system: "Astronomical", accent: theme.blue, systemWidth: 82 }, theme, false)}
      ${iPadEventRow({ x: rightX, y: 384, width: rightWidth, height: 124, type: "ingress", titleLines: ["Mars enters Gemini after an", "extended retrograde cycle"], summary: null, timing: "Date only · 14 August", system: "Western", accent: theme.coral, systemWidth: 58 }, theme, false)}
      ${iPadEventRow({ x: rightX, y: 508, width: rightWidth, height: 102, type: "aspect", titleLines: ["Jupiter trine Saturn"], summary: null, timing: "Unavailable · timing not supplied", system: "Vedic", accent: theme.lavender, systemWidth: 48 }, theme, true)}
    </g>

    <text x="${rightX}" y="658" class="editorial" font-size="27" fill="${theme.ink}">Coming up</text>
    <text x="${rightX + rightWidth}" y="656" text-anchor="end" class="ui" font-size="11" font-weight="650" fill="${theme.secondary}">NEXT 3 · THEN CALENDAR</text>
    <g aria-label="Compact celestial timeline">
      <rect x="${rightX}" y="678" width="${rightWidth}" height="246" rx="24" fill="${theme.surface}" stroke="${theme.hairline}"/>
      <line x1="${rightX + 45}" y1="714" x2="${rightX + 45}" y2="881" stroke="${theme.hairline}" stroke-width="2"/>
      <circle cx="${rightX + 45}" cy="720" r="9" fill="${theme.coralText}"/>
      <text x="${rightX + 72}" y="716" class="ui" font-size="15" font-weight="720" fill="${theme.ink}">Mercury square Uranus</text>
      <text x="${rightX + 72}" y="739" class="mono" font-size="11" fill="${theme.secondary}">Window · Fri 21:00 – Sat 03:00</text>
      ${badge(rightX + rightWidth - 82, 711, "Western", theme, theme.coral, 58)}
      <line x1="${rightX + 72}" y1="762" x2="${rightX + rightWidth - 20}" y2="762" stroke="${theme.hairline}"/>

      <circle cx="${rightX + 45}" cy="799" r="9" fill="${theme.goldText}"/>
      <text x="${rightX + 72}" y="795" class="ui" font-size="15" font-weight="720" fill="${theme.ink}">Equinox</text>
      <text x="${rightX + 72}" y="818" class="mono" font-size="11" fill="${theme.secondary}">Date only · 22 September</text>
      ${badge(rightX + rightWidth - 106, 790, "Astronomical", theme, theme.blue, 82)}
      <line x1="${rightX + 72}" y1="841" x2="${rightX + rightWidth - 20}" y2="841" stroke="${theme.hairline}"/>

      <circle cx="${rightX + 45}" cy="877" r="9" fill="${theme.lavenderText}"/>
      <text x="${rightX + 72}" y="873" class="ui" font-size="15" font-weight="720" fill="${theme.ink}">Sparse day</text>
      <text x="${rightX + 72}" y="896" class="ui" font-size="12.5" fill="${theme.secondary}">No additional event summary supplied.</text>
      <path d="M${rightX + rightWidth - 30} 872l5 5-5 5" fill="none" stroke="${theme.tertiary}" stroke-width="2"/>
    </g>
  `;

  return svgShell({
    width: 1024,
    height: 1366,
    title: `Humay Current Sky iPad ${mode}`,
    description: `Review candidate, not approved. Intentional two-region Current Sky composition on a 1024 by 1366 point iPad portrait canvas in ${mode} appearance.`,
    mode,
    body
  });
}

function standaloneArt(mode) {
  const theme = themes[mode];
  const background = mode === "light" ? "#151B28" : "#20283A";
  return svgShell({
    width: 512,
    height: 360,
    title: `Current Sky lunar meridian reference art ${mode}`,
    description: "Review candidate, not approved. Reference-only restrained lunar orbit art; not a scientific sky map and not a production asset.",
    mode,
    body: `
      <rect width="512" height="360" rx="32" fill="${background}"/>
      <circle cx="256" cy="174" r="138" fill="${theme.lavender}" opacity="0.06"/>
      ${celestialArt(256, 170, 1.65, theme, mode)}
      <text x="496" y="344" text-anchor="end" class="label" font-size="8" fill="${theme.coral}">REVIEW CANDIDATE · NOT APPROVED</text>
    `
  });
}

function stateIcon(kind, cx, cy, theme) {
  if (kind === "loading") {
    return `<circle cx="${cx}" cy="${cy}" r="19" fill="none" stroke="${theme.hairline}" stroke-width="4"/><path d="M${cx} ${cy - 19}a19 19 0 0 1 18 13" fill="none" stroke="${theme.lavender}" stroke-width="4" stroke-linecap="round"/>`;
  }
  if (kind === "offline") {
    return `<path d="M${cx - 18} ${cy - 6}c11-10 25-10 36 0M${cx - 11} ${cy + 2}c7-6 15-6 22 0M${cx - 3} ${cy + 10}c2-2 4-2 6 0M${cx - 20} ${cy - 19}l40 40" fill="none" stroke="${theme.gold}" stroke-width="3" stroke-linecap="round"/>`;
  }
  if (kind === "failed") {
    return `<path d="M${cx} ${cy - 21}l22 39h-44Z" fill="none" stroke="${theme.coral}" stroke-width="3" stroke-linejoin="round"/><path d="M${cx} ${cy - 8}v13m0 7v1" stroke="${theme.coral}" stroke-width="3" stroke-linecap="round"/>`;
  }
  if (kind === "empty") {
    return `<circle cx="${cx}" cy="${cy}" r="18" fill="${theme.gold}"/><circle cx="${cx + 9}" cy="${cy - 4}" r="19" fill="${theme.secondarySurface}"/><path d="M${cx + 21} ${cy - 18}c1 5 2 6 7 7-5 1-6 2-7 7-1-5-2-6-7-7 5-1 6-2 7-7Z" fill="${theme.coral}"/>`;
  }
  return `<circle cx="${cx}" cy="${cy}" r="20" fill="none" stroke="${theme.lavender}" stroke-width="3"/><path d="M${cx} ${cy - 9}v11m0 7v1" stroke="${theme.lavender}" stroke-width="3" stroke-linecap="round"/>`;
}

function statePanel({ x, y, width, height, mode, index, name, kind, title, detail, note, cached = false }) {
  const theme = themes[mode];
  const componentY = y + 102;
  const componentHeight = 220;
  const darkLabel = mode === "dark" ? "DARK EXAMPLE" : "LIGHT EXAMPLE";
  let component;
  if (kind === "loading") {
    component = `<rect x="${x + 24}" y="${componentY}" width="${width - 48}" height="${componentHeight}" rx="20" fill="${theme.surface}" stroke="${theme.hairline}"/>
      <rect x="${x + 46}" y="${componentY + 24}" width="${width - 140}" height="18" rx="9" fill="${theme.secondarySurface}"/>
      <rect x="${x + 46}" y="${componentY + 54}" width="${width - 196}" height="12" rx="6" fill="${theme.secondarySurface}"/>
      ${stateIcon("loading", x + width / 2, componentY + 116, theme)}
      <text x="${x + width / 2}" y="${componentY + 155}" text-anchor="middle" class="ui" font-size="15" font-weight="700" fill="${theme.ink}">Reading the current sky…</text>
      <rect x="${x + 46}" y="${componentY + 180}" width="${width - 92}" height="12" rx="6" fill="${theme.secondarySurface}"/>
      <rect x="${x + 46}" y="${componentY + 201}" width="${width - 132}" height="9" rx="4.5" fill="${theme.secondarySurface}"/>`;
  } else if (cached) {
    component = `<rect x="${x + 24}" y="${componentY}" width="${width - 48}" height="${componentHeight}" rx="20" fill="${theme.surface}" stroke="${theme.hairline}"/>
      <rect x="${x + 38}" y="${componentY + 16}" width="${width - 76}" height="58" rx="16" fill="${theme.secondarySurface}"/>
      ${stateIcon("offline", x + 67, componentY + 45, theme)}
      <text x="${x + 98}" y="${componentY + 39}" class="ui" font-size="14" font-weight="700" fill="${theme.ink}">Offline · saved sky</text>
      <text x="${x + 98}" y="${componentY + 59}" class="ui" font-size="11.5" fill="${theme.secondary}">Showing content saved at 09:00</text>
      <circle cx="${x + 60}" cy="${componentY + 113}" r="15" fill="${theme.blue}" opacity=".15"/>
      <rect x="${x + 88}" y="${componentY + 97}" width="${width - 150}" height="13" rx="6.5" fill="${theme.ink}" opacity=".82"/>
      <rect x="${x + 88}" y="${componentY + 120}" width="${width - 196}" height="9" rx="4.5" fill="${theme.secondary}" opacity=".45"/>
      <line x1="${x + 46}" y1="${componentY + 149}" x2="${x + width - 46}" y2="${componentY + 149}" stroke="${theme.hairline}"/>
      <circle cx="${x + 60}" cy="${componentY + 181}" r="15" fill="${theme.coral}" opacity=".15"/>
      <rect x="${x + 88}" y="${componentY + 166}" width="${width - 174}" height="13" rx="6.5" fill="${theme.ink}" opacity=".82"/>
      <rect x="${x + 88}" y="${componentY + 189}" width="${width - 214}" height="9" rx="4.5" fill="${theme.secondary}" opacity=".45"/>`;
  } else {
    component = `<rect x="${x + 24}" y="${componentY}" width="${width - 48}" height="${componentHeight}" rx="20" fill="${theme.surface}" stroke="${theme.hairline}"/>
      ${stateIcon(kind, x + width / 2, componentY + 61, theme)}
      <text x="${x + width / 2}" y="${componentY + 111}" text-anchor="middle" class="editorial" font-size="25" fill="${theme.ink}">${escapeText(title)}</text>
      <text x="${x + width / 2}" y="${componentY + 143}" text-anchor="middle" class="ui" font-size="12.5" fill="${theme.secondary}">${escapeText(detail[0])}</text>
      ${detail[1] ? `<text x="${x + width / 2}" y="${componentY + 162}" text-anchor="middle" class="ui" font-size="12.5" fill="${theme.secondary}">${escapeText(detail[1])}</text>` : ""}
      ${kind === "empty" ? `<rect x="${x + width / 2 - 70}" y="${componentY + 178}" width="140" height="36" rx="18" fill="${theme.secondarySurface}"/><text x="${x + width / 2}" y="${componentY + 201}" text-anchor="middle" class="ui" font-size="12.5" font-weight="700" fill="${theme.ink}">Open Calendar</text>` : ""}`;
  }

  return `<g>
    <rect x="${x}" y="${y}" width="${width}" height="${height}" rx="28" fill="${theme.ground}" stroke="#D4CCC4" stroke-opacity=".32"/>
    <text x="${x + 24}" y="${y + 31}" class="label" font-size="9" fill="${theme.coralText}">${String(index).padStart(2, "0")} · ${escapeText(name.toUpperCase())}</text>
    <text x="${x + width - 24}" y="${y + 31}" text-anchor="end" class="label" font-size="8" fill="${theme.tertiary}">${darkLabel}</text>
    <text x="${x + 24}" y="${y + 63}" class="ui" font-size="13" fill="${theme.secondary}">${escapeText(note)}</text>
    ${component}
    ${kind === "failed" ? `<text x="${x + 24}" y="${y + height - 18}" class="ui" font-size="10" fill="${theme.tertiary}">Action slot stays empty until the future pipeline exposes recovery.</text>` : ""}
  </g>`;
}

function stateBoard() {
  const boardTheme = themes.light;
  const panels = [
    { name: "Loading", kind: "loading", mode: "light", title: "", detail: [], note: "Stable hierarchy, skeleton shapes, no fake event copy." },
    { name: "Empty", kind: "empty", mode: "dark", title: "Quiet sky right now", detail: ["No notable events are available", "for this period."], note: "Legitimate empty result; Calendar remains useful." },
    { name: "Unavailable", kind: "unavailable", mode: "light", title: "Current Sky unavailable", detail: ["This methodology or source", "isn’t available yet."], note: "Deliberate limitation, not missing UI." },
    { name: "Offline + cached", kind: "offline", mode: "dark", title: "", detail: [], note: "Loaded structure remains; freshness disclosure persists.", cached: true },
    { name: "Offline + no cache", kind: "offline", mode: "light", title: "No saved sky available", detail: ["Reconnect to view current events.", "No recovery promise is invented."], note: "Distinct from a valid empty celestial day." },
    { name: "Failed / error", kind: "failed", mode: "dark", title: "Sky couldn’t load", detail: ["The request ended without", "usable Current Sky content."], note: "Failure stays distinct; recovery remains contract-led." }
  ];
  const panelMarkup = panels.map((panel, index) => statePanel({
    ...panel,
    x: 48 + (index % 3) * 464,
    y: 168 + Math.floor(index / 3) * 456,
    width: 432,
    height: 420,
    index: index + 1
  })).join("");
  return svgShell({
    width: 1440,
    height: 1120,
    title: "Humay Current Sky state board",
    description: "Review candidate, not approved. Six representative state treatments for loading, empty, unavailable, offline with and without cached content, and failure.",
    mode: "light",
    body: `<rect width="1440" height="1120" fill="#EFE9E2"/>
      <text x="48" y="63" class="label" font-size="11" fill="${boardTheme.coralText}">D3.1 · REVIEW CANDIDATE — NOT APPROVED</text>
      <text x="48" y="111" class="editorial" font-size="43" fill="${boardTheme.ink}">Current Sky state language</text>
      <text x="48" y="140" class="ui" font-size="15" fill="${boardTheme.secondary}">One quiet component family; semantics change through icon, title, copy, and freshness—not color alone.</text>
      ${panelMarkup}
      <text x="1392" y="1090" text-anchor="end" class="ui" font-size="11" fill="${boardTheme.tertiary}">Mixed Light/Dark examples · compact-width components shown</text>`
  });
}

async function writeSvgAndPng(name, svg, pngWidth) {
  const svgPath = path.join(outputDirectory, `${name}.svg`);
  const pngPath = path.join(outputDirectory, `${name}.png`);
  fs.writeFileSync(svgPath, svg);
  await sharp(Buffer.from(svg))
    .resize({ width: pngWidth, withoutEnlargement: false })
    .png({ compressionLevel: 9, adaptiveFiltering: true })
    .toFile(pngPath);
}

async function main() {
  fs.writeFileSync(path.join(elementDirectory, "current-sky-orbit-light.svg"), standaloneArt("light"));
  fs.writeFileSync(path.join(elementDirectory, "current-sky-orbit-dark.svg"), standaloneArt("dark"));

  await writeSvgAndPng("iphone-light", phoneReference("light"), 860);
  await writeSvgAndPng("iphone-dark", phoneReference("dark"), 860);
  await writeSvgAndPng("ipad-light", iPadReference("light"), 2048);
  await writeSvgAndPng("ipad-dark", iPadReference("dark"), 2048);
  await writeSvgAndPng("states", stateBoard(), 1440);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
