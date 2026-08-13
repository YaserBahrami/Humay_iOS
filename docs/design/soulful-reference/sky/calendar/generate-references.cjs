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
    selected: "#B14A48",
    selectedText: "#FFF8F1",
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
    selected: "#F07B78",
    selectedText: "#171723",
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
    <linearGradient id="profile-gradient" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="${theme.blue}" stop-opacity="0.86"/>
      <stop offset="1" stop-color="${theme.lavender}" stop-opacity="0.94"/>
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
  return `<text x="${width / 2}" y="18" text-anchor="middle" class="label" font-size="7.5" fill="${theme.coralText}">D3.2 · APPROVED VISUAL REFERENCE</text>`;
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

function sampleNotice(x, y, theme, width = 194) {
  return `<g aria-label="Development sample, not calculated">
    <rect x="${x}" y="${y}" width="${width}" height="23" rx="11.5" fill="${theme.secondarySurface}" stroke="${theme.hairline}" stroke-width="0.7"/>
    <path d="M${x + 10} ${y + 10}l4-4 3 3-4 4m-2-1 5 5m-7-1 3-3" fill="none" stroke="${theme.tertiary}" stroke-width="1.4" stroke-linecap="round"/>
    <text x="${x + 25}" y="${y + 15.5}" class="ui" font-size="9.4" font-weight="650" fill="${theme.secondary}">Development sample · not calculated</text>
  </g>`;
}

function chevron(x, y, direction, theme, size = 5) {
  const sign = direction === "left" ? -1 : 1;
  return `<path d="M${x - sign * size} ${y - size}l${sign * size} ${size} ${-sign * size} ${size}" fill="none" stroke="${theme.ink}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>`;
}

function compactHeader(theme) {
  return `<g aria-label="Calendar navigation header">
    <rect x="12" y="43" width="88" height="44" rx="22" fill="transparent"/>
    ${chevron(27, 65, "left", theme, 4.5)}
    <text x="39" y="70" class="ui" font-size="14" font-weight="600" fill="${theme.coralText}">Sky</text>
    <text x="215" y="70" text-anchor="middle" class="ui" font-size="16" font-weight="700" fill="${theme.ink}">Calendar</text>
    <rect x="348" y="43" width="70" height="44" rx="22" fill="transparent"/>
    <text x="383" y="70" text-anchor="middle" class="ui" font-size="13" font-weight="650" fill="${theme.coralText}">Today</text>
  </g>`;
}

function segmentedControl(x, y, width, selected, theme) {
  const half = width / 2;
  const selectedX = selected === "month" ? x + 3 : x + half;
  return `<g aria-label="Calendar view, ${selected === "month" ? "Month" : "Week"} selected">
    <rect x="${x}" y="${y}" width="${width}" height="36" rx="12" fill="${theme.secondarySurface}" stroke="${theme.hairline}"/>
    <rect x="${selectedX}" y="${y + 3}" width="${half - 3}" height="30" rx="9" fill="${theme.surface}" stroke="${theme.hairline}" filter="url(#soft-shadow)"/>
    <text x="${x + half / 2}" y="${y + 23}" text-anchor="middle" class="ui" font-size="13" font-weight="${selected === "month" ? "700" : "550"}" fill="${theme.ink}">Month</text>
    <text x="${x + half + half / 2}" y="${y + 23}" text-anchor="middle" class="ui" font-size="13" font-weight="${selected === "week" ? "700" : "550"}" fill="${theme.ink}">Week</text>
  </g>`;
}

function rangeNavigation({ x, y, width, title, subtitle = null, theme, fontSize = 25 }) {
  const titleY = y + (subtitle ? 25 : 30);
  return `<g aria-label="${escapeText(title)} navigation">
    <text x="${x}" y="${titleY}" class="editorial" font-size="${fontSize}" fill="${theme.ink}">${escapeText(title)}</text>
    ${subtitle ? `<text x="${x}" y="${y + 43}" class="ui" font-size="10" fill="${theme.secondary}">${escapeText(subtitle)}</text>` : ""}
    <rect x="${x + width - 88}" y="${y}" width="44" height="44" rx="22" fill="${theme.secondarySurface}"/>
    ${chevron(x + width - 66, y + 22, "left", theme, 4.5)}
    <rect x="${x + width - 42}" y="${y}" width="44" height="44" rx="22" fill="${theme.secondarySurface}"/>
    ${chevron(x + width - 20, y + 22, "right", theme, 4.5)}
  </g>`;
}

function methodBadge(x, y, label, theme, accent, width) {
  return `<g aria-label="${escapeText(label)} methodology">
    <circle cx="${x + 4}" cy="${y + 8.5}" r="2.4" fill="${accent}"/>
    <text x="${x + 11}" y="${y + 12}" class="ui" font-size="8.2" font-weight="700" fill="${theme.secondary}">${escapeText(label)}</text>
  </g>`;
}

function eventGlyph(kind, x, y, theme) {
  const base = `<circle cx="${x}" cy="${y}" r="17" fill="${theme.secondarySurface}"/>`;
  if (kind === "moon") {
    return `${base}<circle cx="${x - 1}" cy="${y}" r="8.5" fill="${theme.goldText}"/><circle cx="${x + 4.5}" cy="${y - 2}" r="8.5" fill="${theme.secondarySurface}"/>`;
  }
  if (kind === "ingress") {
    return `${base}<circle cx="${x - 2}" cy="${y + 2}" r="6.3" fill="none" stroke="${theme.coralText}" stroke-width="2"/><path d="M${x + 3} ${y - 3}l8-8m-5 0h5v5" fill="none" stroke="${theme.coralText}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>`;
  }
  if (kind === "aspect") {
    return `${base}<circle cx="${x - 7}" cy="${y}" r="4.5" fill="none" stroke="${theme.lavenderText}" stroke-width="1.8"/><circle cx="${x + 7}" cy="${y}" r="4.5" fill="none" stroke="${theme.lavenderText}" stroke-width="1.8"/><path d="M${x - 2.5} ${y}h5" stroke="${theme.lavenderText}" stroke-width="1.8" stroke-linecap="round"/>`;
  }
  return `${base}<path d="M${x} ${y - 9}l9 9-9 9-9-9Z" fill="none" stroke="${theme.blueText}" stroke-width="1.7"/><circle cx="${x}" cy="${y}" r="2.2" fill="${theme.blueText}"/>`;
}

function eventRow({ x, y, width, height, kind, titleLines, timing, system, badgeWidth, accent, theme, last = false, large = false, stackedBadge = false }) {
  const iconX = x + (large ? 34 : 27);
  const textX = x + (large ? 66 : 55);
  const iconY = y + height / 2;
  const titleY = y + (large ? 27 : 22);
  const lineHeight = large ? 19 : 15.5;
  const titleSize = large ? 15 : 13.2;
  const timingSize = large ? 10.5 : 8.9;
  const title = titleLines.map((line, index) =>
    `<text x="${textX}" y="${titleY + index * lineHeight}" class="ui" font-size="${titleSize}" font-weight="700" fill="${theme.ink}">${escapeText(line)}</text>`
  ).join("");
  const timingY = y + height - (large ? 17 : 14);
  const badgeX = x + width - badgeWidth - (large ? 42 : 34);
  const badgeY = stackedBadge ? timingY - 40 : timingY - 13;
  return `<g aria-label="${escapeText(titleLines.join(" "))}. ${escapeText(system)}. ${escapeText(timing)}.">
    ${eventGlyph(kind, iconX, iconY, theme)}
    ${title}
    <text x="${textX}" y="${timingY}" class="mono" font-size="${timingSize}" font-weight="600" fill="${theme.secondary}">${escapeText(timing)}</text>
    ${methodBadge(badgeX, badgeY, system, theme, accent, badgeWidth)}
    ${chevron(x + width - 16, iconY, "right", theme, 4)}
    ${last ? "" : `<line x1="${textX}" y1="${y + height}" x2="${x + width - 12}" y2="${y + height}" stroke="${theme.hairline}"/>`}
  </g>`;
}

const monthCells = [
  [27, "outside", "JUL"], [28, "outside"], [29, "outside"], [30, "outside"], [31, "outside"], [1, "normal"], [2, "normal"],
  [3, "normal"], [4, "normal"], [5, "normal"], [6, "normal"], [7, "normal"], [8, "normal"], [9, "normal"],
  [10, "normal"], [11, "normal"], [12, "moon", null, 1], [13, "today"], [14, "selected", null, 3], [15, "normal"], [16, "normal"],
  [17, "normal"], [18, "normal"], [19, "normal"], [20, "normal"], [21, "normal"], [22, "normal"], [23, "normal"],
  [24, "normal"], [25, "normal"], [26, "normal"], [27, "normal"], [28, "normal"], [29, "normal"], [30, "normal"],
  [31, "normal"], [1, "outside", "SEP"], [2, "outside"], [3, "outside"], [4, "outside"], [5, "outside"], [6, "outside"]
];

function tinyMoon(cx, cy, theme, size = 4.6) {
  return `<circle cx="${cx}" cy="${cy}" r="${size}" fill="${theme.goldText}"/><circle cx="${cx + size * 0.55}" cy="${cy - size * 0.2}" r="${size}" fill="${theme.surface}"/>`;
}

function monthGrid({ x, y, width, height, theme, compact = false }) {
  const weekdays = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];
  const cellWidth = width / 7;
  const headerHeight = compact ? 28 : 34;
  const rowHeight = (height - headerHeight) / 6;
  const header = weekdays.map((day, index) =>
    `<text x="${x + cellWidth * (index + 0.5)}" y="${y + (compact ? 17 : 21)}" text-anchor="middle" class="label" font-size="${compact ? 6.7 : 8}" fill="${theme.secondary}">${day}</text>`
  ).join("");
  const lines = Array.from({ length: 7 }, (_, index) =>
    `<line x1="${x}" y1="${y + headerHeight + index * rowHeight}" x2="${x + width}" y2="${y + headerHeight + index * rowHeight}" stroke="${theme.hairline}" stroke-width="${index === 0 ? 1 : 0.75}"/>`
  ).join("");
  const cells = monthCells.map(([day, state, month, count], index) => {
    const column = index % 7;
    const row = Math.floor(index / 7);
    const cx = x + cellWidth * (column + 0.5);
    const top = y + headerHeight + row * rowHeight;
    const dateY = top + (compact ? 20 : 25);
    const markerY = top + rowHeight - (compact ? 6 : 9);
    const outside = state === "outside";
    let background = "";
    let dateFill = theme.ink;
    let dateWeight = state === "today" || state === "selected" ? "750" : "550";
    if (state === "selected") {
      const size = compact ? 28 : 34;
      background = `<rect x="${cx - size / 2}" y="${dateY - size + (compact ? 7 : 8)}" width="${size}" height="${size}" rx="${size / 2}" fill="${theme.selected}"/>`;
      dateFill = theme.selectedText;
    } else if (state === "today") {
      const size = compact ? 29 : 35;
      background = `<circle cx="${cx}" cy="${dateY - (compact ? 4.5 : 5.5)}" r="${size / 2}" fill="none" stroke="${theme.coralText}" stroke-width="1.6"/><path d="M${cx - 5} ${top + 3}h10" stroke="${theme.coralText}" stroke-width="2" stroke-linecap="round"/>`;
    }
    const monthLabel = month
      ? `<text x="${cx}" y="${top + 8}" text-anchor="middle" class="label" font-size="${compact ? 4.7 : 5.8}" fill="${theme.tertiary}">${month}</text>`
      : "";
    let marker = "";
    if (state === "moon") {
      marker = tinyMoon(cx, markerY, theme, compact ? 3.3 : 4.2);
    } else if ((state === "event" || state === "selected") && count) {
      marker = `<circle cx="${cx - (count > 1 ? 4 : 0)}" cy="${markerY - 1}" r="${compact ? 2.2 : 2.8}" fill="${theme.lavenderText}"/>${count > 1 ? `<text x="${cx + 5}" y="${markerY + 2}" text-anchor="middle" class="ui" font-size="${compact ? 6.2 : 7.5}" font-weight="750" fill="${state === "selected" ? theme.ink : theme.secondary}">${count}</text>` : ""}`;
    } else if (state === "today") {
      marker = `<text x="${cx}" y="${markerY + 1}" text-anchor="middle" class="label" font-size="${compact ? 4.5 : 5.5}" fill="${theme.coralText}">TODAY</text>`;
    }
    return `<g aria-label="${outside ? `${month || "Outside month"} ${day}, outside August` : `August ${day}${state === "today" ? ", today" : ""}${state === "selected" ? ", selected, 3 events" : count ? `, ${count} event${count > 1 ? "s" : ""}` : ""}`}">
      ${background}${monthLabel}
      <text x="${cx}" y="${dateY}" text-anchor="middle" class="ui" font-size="${outside ? compact ? 9.2 : 11 : compact ? 11.2 : 13.5}" font-weight="${dateWeight}" font-style="${outside ? "italic" : "normal"}" fill="${outside ? theme.tertiary : dateFill}" opacity="${outside ? 0.62 : 1}">${day}</text>
      ${marker}
    </g>`;
  }).join("");
  return `<g aria-label="August 2026 month grid, Monday through Sunday. Today is August 13. August 14 is selected and has 3 events.">
    ${header}${lines}${cells}
  </g>`;
}

function weekRail({ x, y, width, height, theme, selectedDay, compact = false }) {
  const days = [
    ["MON", "10", 0], ["TUE", "11", 0], ["WED", "12", 1, "moon"], ["THU", "13", 0, "today"],
    ["FRI", "14", 3], ["SAT", "15", 0], ["SUN", "16", 0]
  ];
  const cellWidth = width / 7;
  return `<g aria-label="Seven-day navigator, 10 through 16 August 2026">${days.map(([weekday, date, count, special], index) => {
    const cellX = x + index * cellWidth;
    const cx = cellX + cellWidth / 2;
    const selected = Number(date) === selectedDay;
    const today = date === "13";
    const pad = compact ? 3 : 5;
    const selectedRect = selected
      ? `<rect x="${cellX + pad}" y="${y + pad}" width="${cellWidth - pad * 2}" height="${height - pad * 2}" rx="${compact ? 17 : 20}" fill="${theme.selected}"/>`
      : today
        ? `<rect x="${cellX + pad}" y="${y + pad}" width="${cellWidth - pad * 2}" height="${height - pad * 2}" rx="${compact ? 17 : 20}" fill="none" stroke="${theme.coralText}" stroke-width="1.5"/><path d="M${cx - 7} ${y + pad + 5}h14" stroke="${theme.coralText}" stroke-width="2" stroke-linecap="round"/>`
        : "";
    const fg = selected ? theme.selectedText : theme.ink;
    const secondary = selected ? theme.selectedText : theme.secondary;
    let marker = "";
    if (special === "moon") {
      const mask = selected ? theme.selected : theme.surface;
      marker = `<circle cx="${cx}" cy="${y + height - (compact ? 13 : 17)}" r="${compact ? 4 : 5}" fill="${selected ? theme.goldWash : theme.goldText}"/><circle cx="${cx + 3}" cy="${y + height - (compact ? 14 : 18)}" r="${compact ? 4 : 5}" fill="${mask}"/>`;
    } else if (count) {
      marker = `<circle cx="${cx - (count > 1 ? 5 : 0)}" cy="${y + height - (compact ? 13 : 17)}" r="${compact ? 2.3 : 3}" fill="${selected ? theme.selectedText : theme.lavenderText}"/>${count > 1 ? `<text x="${cx + 5}" y="${y + height - (compact ? 10 : 13)}" class="ui" font-size="${compact ? 6.5 : 8}" font-weight="750" fill="${secondary}">${count}</text>` : ""}`;
    } else if (today) {
      marker = `<text x="${cx}" y="${y + height - (compact ? 10 : 13)}" text-anchor="middle" class="label" font-size="${compact ? 4.7 : 5.8}" fill="${theme.coralText}">TODAY</text>`;
    }
    return `<g aria-label="${weekday}, August ${date}${today ? ", today" : ""}${selected ? ", selected" : ""}${count ? `, ${count} event${count > 1 ? "s" : ""}` : ", no events"}">
      ${selectedRect}
      <text x="${cx}" y="${y + (compact ? 20 : 25)}" text-anchor="middle" class="label" font-size="${compact ? 6.2 : 7.5}" fill="${secondary}">${weekday}</text>
      <text x="${cx}" y="${y + (compact ? 45 : 57)}" text-anchor="middle" class="ui" font-size="${compact ? 16 : 20}" font-weight="750" fill="${fg}">${date}</text>
      ${marker}
    </g>`;
  }).join("")}</g>`;
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

function phoneMonth(mode) {
  const theme = themes[mode];
  return svgShell({
    width: 430,
    height: 932,
    title: `Humay Calendar Month iPhone ${mode}`,
    description: `D3.2 approved visual reference. Month view on a 430 by 932 point iPhone canvas in ${mode} appearance.`,
    mode,
    body: `<rect width="430" height="932" fill="${theme.ground}"/>
      ${reviewLabel(430, theme)}${statusBar(430, theme, "phone")}${compactHeader(theme)}
      ${sampleNotice(20, 90, theme)}
      ${segmentedControl(230, 89, 180, "month", theme)}
      ${rangeNavigation({ x: 20, y: 137, width: 390, title: "August 2026", theme })}
      <g filter="url(#soft-shadow)"><rect x="20" y="188" width="390" height="316" rx="20" fill="${theme.surface}" stroke="${theme.hairline}"/></g>
      ${monthGrid({ x: 30, y: 197, width: 370, height: 296, theme, compact: true })}
      <text x="20" y="543" class="editorial" font-size="22" fill="${theme.ink}">Friday · 14 August</text>
      <text x="410" y="541" text-anchor="end" class="label" font-size="7.4" fill="${theme.secondary}">3 EVENTS</text>
      <g aria-label="Selected-day agenda">
        <line x1="20" y1="558" x2="410" y2="558" stroke="${theme.hairline}"/>
        ${eventRow({ x: 20, y: 558, width: 390, height: 88, kind: "ingress", titleLines: ["Mars enters Gemini after an", "extended retrograde cycle"], timing: "Date only · 14 August", system: "Western", badgeWidth: 52, accent: theme.coral, theme })}
        ${eventRow({ x: 20, y: 646, width: 390, height: 76, kind: "aspect", titleLines: ["Mercury square Uranus"], timing: "Fri 21:00 – Sat 03:00", system: "Western", badgeWidth: 52, accent: theme.lavender, theme })}
        ${eventRow({ x: 20, y: 722, width: 390, height: 88, kind: "method", titleLines: ["Jupiter trine Saturn"], timing: "Timing unavailable", system: "Vedic", badgeWidth: 44, accent: theme.blue, theme, last: true })}
        <line x1="20" y1="810" x2="410" y2="810" stroke="${theme.hairline}"/>
      </g>
      ${phoneTabBar(theme)}`
  });
}

function laterThisWeek(theme) {
  return `<g aria-label="Later this week">
    <text x="20" y="489" class="editorial" font-size="22" fill="${theme.ink}">Later this week</text>
    <line x1="55" y1="517" x2="55" y2="650" stroke="${theme.hairline}" stroke-width="2"/>
    <circle cx="55" cy="535" r="5" fill="${theme.coralText}"/>
    <text x="76" y="525" class="label" font-size="6.7" fill="${theme.coralText}">FRI · 14 AUG</text>
    <text x="76" y="548" class="ui" font-size="14" font-weight="700" fill="${theme.ink}">Three celestial events</text>
    <text x="76" y="568" class="ui" font-size="10.5" fill="${theme.secondary}">Ingress · aspect · Vedic</text>
    <text x="76" y="586" class="ui" font-size="10" fill="${theme.secondary}">One event continues into Saturday</text>
    ${chevron(397, 551, "right", theme, 4)}
    <circle cx="55" cy="625" r="5" fill="${theme.sage}"/>
    <text x="76" y="615" class="label" font-size="6.7" fill="${theme.sage}">SUN · 16 AUG</text>
    <text x="76" y="638" class="ui" font-size="14" font-weight="700" fill="${theme.ink}">Quiet sky this day</text>
    <text x="76" y="658" class="ui" font-size="10.5" fill="${theme.secondary}">No supplied celestial events</text>
    ${chevron(397, 635, "right", theme, 4)}
    <text x="20" y="698" class="ui" font-size="10" fill="${theme.secondary}">Europe/Istanbul · civil week begins Monday</text>
  </g>`;
}

function phoneWeek(mode) {
  const theme = themes[mode];
  return svgShell({
    width: 430,
    height: 932,
    title: `Humay Calendar Week iPhone ${mode}`,
    description: `D3.2 approved visual reference. Seven-day celestial week navigator on a 430 by 932 point iPhone canvas in ${mode} appearance.`,
    mode,
    body: `<rect width="430" height="932" fill="${theme.ground}"/>
      ${reviewLabel(430, theme)}${statusBar(430, theme, "phone")}${compactHeader(theme)}
      ${sampleNotice(20, 90, theme)}
      ${segmentedControl(230, 89, 180, "week", theme)}
      ${rangeNavigation({ x: 20, y: 137, width: 390, title: "10–16 August", subtitle: "Week begins Monday", theme, fontSize: 24 })}
      <g filter="url(#soft-shadow)"><rect x="20" y="190" width="390" height="90" rx="20" fill="${theme.surface}" stroke="${theme.hairline}"/></g>
      ${weekRail({ x: 25, y: 195, width: 380, height: 80, theme, selectedDay: 12, compact: true })}
      <text x="20" y="319" class="editorial" font-size="22" fill="${theme.ink}">Wednesday · 12 August</text>
      <text x="410" y="317" text-anchor="end" class="label" font-size="7.4" fill="${theme.secondary}">1 EVENT</text>
      <g aria-label="Selected-day agenda">
        <line x1="20" y1="334" x2="410" y2="334" stroke="${theme.hairline}"/>
        ${eventRow({ x: 20, y: 334, width: 390, height: 116, kind: "moon", titleLines: ["Waning gibbous Moon"], timing: "Exact · 18:00 TRT", system: "Astronomical", badgeWidth: 76, accent: theme.blue, theme, last: true })}
        <line x1="20" y1="450" x2="410" y2="450" stroke="${theme.hairline}"/>
      </g>
      ${laterThisWeek(theme)}
      ${phoneTabBar(theme)}`
  });
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

function wideHeader(theme, selected) {
  return `<g aria-label="Calendar nested-screen header">
    <rect x="36" y="122" width="90" height="44" rx="22" fill="transparent"/>
    ${chevron(52, 144, "left", theme, 5)}
    <text x="66" y="149" class="ui" font-size="15" font-weight="650" fill="${theme.coralText}">Sky</text>
    <text x="142" y="151" class="editorial" font-size="34" fill="${theme.ink}">Calendar</text>
    ${segmentedControl(382, 125, 260, selected, theme)}
    <rect x="892" y="122" width="84" height="44" rx="22" fill="${theme.secondarySurface}"/>
    <text x="934" y="149" text-anchor="middle" class="ui" font-size="13" font-weight="700" fill="${theme.coralText}">Today</text>
  </g>`;
}

function observationFooter(x, y, theme, text = "Europe/Istanbul · civil dates · sample not calculated") {
  return `<g aria-label="Observation context"><line x1="${x}" y1="${y}" x2="${x + 280}" y2="${y}" stroke="${theme.hairline}"/><text x="${x}" y="${y + 25}" class="ui" font-size="10.5" fill="${theme.secondary}">${escapeText(text)}</text></g>`;
}

function iPadMonth(mode) {
  const theme = themes[mode];
  const agendaX = 660;
  const agendaWidth = 316;
  return svgShell({
    width: 1024,
    height: 1366,
    title: `Humay Calendar Month iPad ${mode}`,
    description: `D3.2 approved visual reference. Month master-detail composition on a 1024 by 1366 point iPad canvas in ${mode} appearance.`,
    mode,
    body: `<rect width="1024" height="1366" fill="${theme.ground}"/>
      ${reviewLabel(1024, theme)}${statusBar(1024, theme, "pad")}${iPadTopNavigation(theme)}${wideHeader(theme, "month")}
      ${sampleNotice(48, 179, theme, 204)}
      ${rangeNavigation({ x: 48, y: 216, width: 580, title: "August 2026", theme, fontSize: 31 })}
      <g filter="url(#soft-shadow)"><rect x="48" y="274" width="580" height="626" rx="26" fill="${theme.surface}" stroke="${theme.hairline}"/></g>
      ${monthGrid({ x: 64, y: 293, width: 548, height: 584, theme })}
      ${observationFooter(48, 930, theme)}

      <g aria-label="Selected date agenda">
        <text x="${agendaX}" y="245" class="label" font-size="8.5" fill="${theme.coralText}">SELECTED DATE</text>
        <text x="${agendaX}" y="285" class="editorial" font-size="31" fill="${theme.ink}">Friday · 14 August</text>
        <text x="${agendaX}" y="310" class="ui" font-size="12" fill="${theme.secondary}">3 celestial events</text>
        <g filter="url(#soft-shadow)">
          <rect x="${agendaX}" y="333" width="${agendaWidth}" height="360" rx="24" fill="${theme.surface}" stroke="${theme.hairline}"/>
          ${eventRow({ x: agendaX, y: 333, width: agendaWidth, height: 132, kind: "ingress", titleLines: ["Mars enters Gemini after", "an extended retrograde cycle"], timing: "Date only · 14 August", system: "Western", badgeWidth: 52, accent: theme.coral, theme, large: true })}
          ${eventRow({ x: agendaX, y: 465, width: agendaWidth, height: 105, kind: "aspect", titleLines: ["Mercury square Uranus"], timing: "Fri 21:00 – Sat 03:00", system: "Western", badgeWidth: 52, accent: theme.lavender, theme, large: true })}
          ${eventRow({ x: agendaX, y: 570, width: agendaWidth, height: 123, kind: "method", titleLines: ["Jupiter trine Saturn"], timing: "Timing unavailable", system: "Vedic", badgeWidth: 44, accent: theme.blue, theme, large: true, last: true })}
        </g>
        <g aria-label="Timing context">
          <line x1="${agendaX}" y1="723" x2="${agendaX + agendaWidth}" y2="723" stroke="${theme.hairline}"/>
          <circle cx="${agendaX + 14}" cy="750" r="9" fill="none" stroke="${theme.goldText}" stroke-width="1.5"/>
          <path d="M${agendaX + 14} 745v6l4 2" fill="none" stroke="${theme.goldText}" stroke-width="1.5" stroke-linecap="round"/>
          <text x="${agendaX + 34}" y="755" class="ui" font-size="13" font-weight="700" fill="${theme.ink}">One interval continues into Saturday.</text>
          <text x="${agendaX + 34}" y="777" class="ui" font-size="10.5" fill="${theme.secondary}">All clock times shown in TRT.</text>
        </g>
      </g>`
  });
}

function acrossWeek(theme) {
  return `<g aria-label="Across the visible week">
    <text x="660" y="591" class="editorial" font-size="28" fill="${theme.ink}">Across the week</text>
    <line x1="684" y1="624" x2="684" y2="849" stroke="${theme.hairline}" stroke-width="2"/>
    ${eventGlyph("moon", 684, 651, theme)}
    <text x="714" y="631" class="label" font-size="7.5" fill="${theme.goldText}">WED · 12 AUG</text>
    <text x="714" y="655" class="ui" font-size="14" font-weight="700" fill="${theme.ink}">Waning gibbous Moon</text>
    <text x="714" y="675" class="mono" font-size="9.5" fill="${theme.secondary}">Exact · 18:00 TRT</text>
    <circle cx="684" cy="750" r="6" fill="${theme.lavenderText}"/>
    <text x="714" y="728" class="label" font-size="7.5" fill="${theme.coralText}">FRI · 14 AUG</text>
    <text x="714" y="754" class="ui" font-size="13.5" font-weight="700" fill="${theme.ink}">3 celestial events</text>
    <circle cx="684" cy="832" r="6" fill="${theme.ground}" stroke="${theme.sage}" stroke-width="2"/>
    <text x="714" y="811" class="label" font-size="7.5" fill="${theme.sage}">SUN · 16 AUG</text>
    <text x="714" y="836" class="ui" font-size="13.5" font-weight="700" fill="${theme.ink}">Quiet sky this day</text>
    <text x="714" y="855" class="ui" font-size="10.5" fill="${theme.secondary}">Navigation remains available.</text>
  </g>`;
}

function iPadWeek(mode) {
  const theme = themes[mode];
  return svgShell({
    width: 1024,
    height: 1366,
    title: `Humay Calendar Week iPad ${mode}`,
    description: `D3.2 approved visual reference. Seven-day celestial rail and bounded agenda on a 1024 by 1366 point iPad canvas in ${mode} appearance.`,
    mode,
    body: `<rect width="1024" height="1366" fill="${theme.ground}"/>
      ${reviewLabel(1024, theme)}${statusBar(1024, theme, "pad")}${iPadTopNavigation(theme)}${wideHeader(theme, "week")}
      ${sampleNotice(48, 179, theme, 204)}
      ${rangeNavigation({ x: 48, y: 216, width: 928, title: "10–16 August 2026", subtitle: "Week begins Monday", theme, fontSize: 31 })}
      <g filter="url(#soft-shadow)"><rect x="48" y="278" width="928" height="150" rx="26" fill="${theme.surface}" stroke="${theme.hairline}"/></g>
      ${weekRail({ x: 58, y: 288, width: 908, height: 130, theme, selectedDay: 14 })}

      <g aria-label="Selected date agenda">
        <text x="48" y="483" class="label" font-size="8.5" fill="${theme.coralText}">SELECTED DATE</text>
        <text x="48" y="526" class="editorial" font-size="31" fill="${theme.ink}">Friday · 14 August</text>
        <text x="48" y="552" class="ui" font-size="12" fill="${theme.secondary}">3 celestial events</text>
        <g filter="url(#soft-shadow)">
          <rect x="48" y="575" width="580" height="360" rx="24" fill="${theme.surface}" stroke="${theme.hairline}"/>
          ${eventRow({ x: 48, y: 575, width: 580, height: 122, kind: "ingress", titleLines: ["Mars enters Gemini after an", "extended retrograde cycle"], timing: "Date only · 14 August", system: "Western", badgeWidth: 52, accent: theme.coral, theme, large: true })}
          ${eventRow({ x: 48, y: 697, width: 580, height: 111, kind: "aspect", titleLines: ["Mercury square Uranus"], timing: "Fri 21:00 – Sat 03:00", system: "Western", badgeWidth: 52, accent: theme.lavender, theme, large: true })}
          ${eventRow({ x: 48, y: 808, width: 580, height: 127, kind: "method", titleLines: ["Jupiter trine Saturn"], timing: "Timing unavailable", system: "Vedic", badgeWidth: 44, accent: theme.blue, theme, large: true, last: true })}
        </g>
        ${observationFooter(48, 966, theme)}
      </g>
      ${acrossWeek(theme)}`
  });
}

function stateIcon(kind, cx, cy, theme) {
  if (kind === "loading") {
    return `<circle cx="${cx}" cy="${cy}" r="19" fill="none" stroke="${theme.hairline}" stroke-width="4"/><path d="M${cx} ${cy - 19}a19 19 0 0 1 16 9" fill="none" stroke="${theme.lavender}" stroke-width="4" stroke-linecap="round"/>`;
  }
  if (kind === "offline") {
    return `<path d="M${cx - 20} ${cy - 7}c12-10 28-10 40 0m-32 8c7-6 17-6 24 0m-16 9c2-2 6-2 8 0M${cx - 18} ${cy - 22}l36 40" fill="none" stroke="${theme.gold}" stroke-width="3" stroke-linecap="round"/>`;
  }
  if (kind === "failed") {
    return `<path d="M${cx} ${cy - 22}l22 40h-44Z" fill="none" stroke="${theme.coral}" stroke-width="3" stroke-linejoin="round"/><path d="M${cx} ${cy - 8}v13m0 7v1" stroke="${theme.coral}" stroke-width="3" stroke-linecap="round"/>`;
  }
  if (kind === "quiet") {
    return `<circle cx="${cx}" cy="${cy}" r="15" fill="none" stroke="${theme.sage}" stroke-width="2"/><ellipse cx="${cx}" cy="${cy}" rx="24" ry="9" fill="none" stroke="${theme.gold}" stroke-width="1.5" transform="rotate(-14 ${cx} ${cy})"/><path d="M${cx + 22} ${cy - 18}c1 5 2 6 7 7-5 1-6 2-7 7-1-5-2-6-7-7 5-1 6-2 7-7Z" fill="${theme.coral}"/>`;
  }
  return `<circle cx="${cx}" cy="${cy}" r="20" fill="none" stroke="${theme.lavender}" stroke-width="3"/><path d="M${cx} ${cy - 9}v11m0 7v1" stroke="${theme.lavender}" stroke-width="3" stroke-linecap="round"/>`;
}

function miniGrid(x, y, width, theme, { markers = true, selected = false, loading = false } = {}) {
  const columns = 7;
  const rows = 4;
  const cw = width / columns;
  const rh = 27;
  let cells = "";
  for (let row = 0; row < rows; row += 1) {
    for (let column = 0; column < columns; column += 1) {
      const cx = x + cw * (column + 0.5);
      const cy = y + row * rh + 12;
      if (loading) {
        cells += `<circle cx="${cx}" cy="${cy}" r="4" fill="${theme.secondarySurface}"/>`;
      } else {
        const day = row * 7 + column + 1;
        const isSelected = selected && day === 14;
        cells += `${isSelected ? `<circle cx="${cx}" cy="${cy - 2}" r="11" fill="${theme.selected}"/>` : ""}<text x="${cx}" y="${cy + 2}" text-anchor="middle" class="ui" font-size="8" font-weight="${isSelected ? "750" : "550"}" fill="${isSelected ? theme.selectedText : theme.ink}">${day}</text>`;
        if (markers && [12, 14].includes(day)) cells += `<circle cx="${cx}" cy="${cy + 9}" r="1.7" fill="${theme.lavenderText}"/>`;
      }
    }
  }
  return `<g>${Array.from({ length: rows + 1 }, (_, index) => `<line x1="${x}" y1="${y - 4 + index * rh}" x2="${x + width}" y2="${y - 4 + index * rh}" stroke="${theme.hairline}"/>`).join("")}${cells}</g>`;
}

function statePanel({ x, y, width, height, mode, index, name, note, kind }) {
  const theme = themes[mode];
  const contentX = x + 22;
  const contentY = y + 92;
  const contentWidth = width - 44;
  let component = "";
  if (kind === "loading") {
    component = `<rect x="${contentX}" y="${contentY}" width="${contentWidth}" height="218" rx="20" fill="${theme.surface}" stroke="${theme.hairline}"/>
      <rect x="${contentX + 18}" y="${contentY + 20}" width="154" height="13" rx="6.5" fill="${theme.secondarySurface}"/>
      ${miniGrid(contentX + 18, contentY + 58, contentWidth - 36, theme, { loading: true })}
      ${stateIcon("loading", x + width / 2, contentY + 181, theme)}
      <text x="${x + width / 2}" y="${contentY + 211}" text-anchor="middle" class="ui" font-size="12" font-weight="700" fill="${theme.ink}">Loading Calendar…</text>`;
  } else if (kind === "empty-month") {
    component = `<rect x="${contentX}" y="${contentY}" width="${contentWidth}" height="218" rx="20" fill="${theme.surface}" stroke="${theme.hairline}"/>
      <text x="${contentX + 18}" y="${contentY + 27}" class="ui" font-size="12" font-weight="700" fill="${theme.ink}">August 2026</text>
      ${miniGrid(contentX + 18, contentY + 48, contentWidth - 36, theme, { markers: false })}
      <text x="${x + width / 2}" y="${contentY + 196}" text-anchor="middle" class="ui" font-size="12" font-weight="700" fill="${theme.ink}">No notable events this month</text>
      <text x="${x + width / 2}" y="${contentY + 213}" text-anchor="middle" class="ui" font-size="9.5" fill="${theme.secondary}">Civil navigation remains available.</text>`;
  } else if (kind === "quiet") {
    component = `<rect x="${contentX}" y="${contentY}" width="${contentWidth}" height="218" rx="20" fill="${theme.surface}" stroke="${theme.hairline}"/>
      <text x="${contentX + 18}" y="${contentY + 28}" class="ui" font-size="12" font-weight="700" fill="${theme.ink}">Sunday · 16 August</text>
      <line x1="${contentX + 18}" y1="${contentY + 42}" x2="${contentX + contentWidth - 18}" y2="${contentY + 42}" stroke="${theme.hairline}"/>
      ${stateIcon("quiet", x + width / 2, contentY + 94, theme)}
      <text x="${x + width / 2}" y="${contentY + 139}" text-anchor="middle" class="editorial" font-size="23" fill="${theme.ink}">Quiet sky this day</text>
      <text x="${x + width / 2}" y="${contentY + 166}" text-anchor="middle" class="ui" font-size="10.5" fill="${theme.secondary}">No notable events are supplied.</text>`;
  } else if (kind === "cached") {
    component = `<rect x="${contentX}" y="${contentY}" width="${contentWidth}" height="218" rx="20" fill="${theme.surface}" stroke="${theme.hairline}"/>
      <rect x="${contentX + 12}" y="${contentY + 12}" width="${contentWidth - 24}" height="52" rx="15" fill="${theme.secondarySurface}"/>
      ${stateIcon("offline", contentX + 38, contentY + 38, theme)}
      <text x="${contentX + 68}" y="${contentY + 34}" class="ui" font-size="12" font-weight="700" fill="${theme.ink}">Offline · saved Calendar</text>
      <text x="${contentX + 68}" y="${contentY + 51}" class="ui" font-size="9.5" fill="${theme.secondary}">Showing content saved at 09:00</text>
      ${miniGrid(contentX + 18, contentY + 88, contentWidth - 36, theme, { selected: true })}`;
  } else if (kind === "date-key") {
    const startX = contentX + 36;
    const labels = ["TODAY", "SELECTED", "2 EVENTS", "OUTSIDE"];
    component = `<rect x="${contentX}" y="${contentY}" width="${contentWidth}" height="218" rx="20" fill="${theme.surface}" stroke="${theme.hairline}"/>
      ${labels.map((label, idx) => {
        const cx = startX + idx * 72;
        if (idx === 0) return `<circle cx="${cx}" cy="${contentY + 66}" r="18" fill="none" stroke="${theme.coralText}" stroke-width="1.6"/><path d="M${cx - 6} ${contentY + 44}h12" stroke="${theme.coralText}" stroke-width="2"/><text x="${cx}" y="${contentY + 71}" text-anchor="middle" class="ui" font-size="11" font-weight="750" fill="${theme.ink}">13</text>`;
        if (idx === 1) return `<circle cx="${cx}" cy="${contentY + 66}" r="18" fill="${theme.selected}"/><text x="${cx}" y="${contentY + 71}" text-anchor="middle" class="ui" font-size="11" font-weight="750" fill="${theme.selectedText}">14</text>`;
        if (idx === 2) return `<text x="${cx}" y="${contentY + 64}" text-anchor="middle" class="ui" font-size="11" font-weight="600" fill="${theme.ink}">27</text><circle cx="${cx - 4}" cy="${contentY + 78}" r="2.5" fill="${theme.lavenderText}"/><text x="${cx + 5}" y="${contentY + 81}" class="ui" font-size="7" font-weight="750" fill="${theme.secondary}">2</text>`;
        return `<text x="${cx}" y="${contentY + 48}" text-anchor="middle" class="label" font-size="5.5" fill="${theme.tertiary}">SEP</text><text x="${cx}" y="${contentY + 71}" text-anchor="middle" class="ui" font-size="10" font-style="italic" fill="${theme.tertiary}" opacity=".62">1</text>`;
      }).join("")}
      ${labels.map((label, idx) => `<text x="${startX + idx * 72}" y="${contentY + 111}" text-anchor="middle" class="label" font-size="5.8" fill="${theme.secondary}">${label}</text>`).join("")}
      <text x="${x + width / 2}" y="${contentY + 151}" text-anchor="middle" class="ui" font-size="10.5" fill="${theme.secondary}">Shape, text, weight, and count</text>
      <text x="${x + width / 2}" y="${contentY + 169}" text-anchor="middle" class="ui" font-size="10.5" fill="${theme.secondary}">reinforce color.</text>`;
  } else {
    const failed = kind === "failed";
    const offline = kind === "offline";
    const title = failed ? "Calendar couldn’t load" : offline ? "No saved Calendar" : "Calendar unavailable";
    const detail = failed ? "The source could not be loaded." : offline ? "Reconnect to load these dates." : "This source isn’t available yet.";
    component = `<rect x="${contentX}" y="${contentY}" width="${contentWidth}" height="218" rx="20" fill="${theme.surface}" stroke="${theme.hairline}"/>
      ${stateIcon(failed ? "failed" : offline ? "offline" : "unavailable", x + width / 2, contentY + 64, theme)}
      <text x="${x + width / 2}" y="${contentY + 119}" text-anchor="middle" class="editorial" font-size="23" fill="${theme.ink}">${title}</text>
      <text x="${x + width / 2}" y="${contentY + 150}" text-anchor="middle" class="ui" font-size="10.5" fill="${theme.secondary}">${detail}</text>`;
  }
  return `<g>
    <rect x="${x}" y="${y}" width="${width}" height="${height}" rx="28" fill="${theme.ground}" stroke="#D4CCC4" stroke-opacity=".32"/>
    <text x="${x + 22}" y="${y + 29}" class="label" font-size="8.5" fill="${theme.coralText}">${String(index).padStart(2, "0")} · ${escapeText(name.toUpperCase())}</text>
    <text x="${x + width - 22}" y="${y + 29}" text-anchor="end" class="label" font-size="7" fill="${theme.tertiary}">${mode.toUpperCase()}</text>
    <text x="${x + 22}" y="${y + 59}" class="ui" font-size="12" fill="${theme.secondary}">${escapeText(note)}</text>
    ${component}
  </g>`;
}

function stateBoard() {
  const panels = [
    { name: "Loading", kind: "loading", mode: "light", note: "Stable grid skeleton; no fake events." },
    { name: "Empty month", kind: "empty-month", mode: "dark", note: "No event-bearing days is a valid result." },
    { name: "Quiet selected day", kind: "quiet", mode: "light", note: "A normal day, not an application error." },
    { name: "Unavailable", kind: "unavailable", mode: "dark", note: "Source limitation remains explicit." },
    { name: "Offline + cached", kind: "cached", mode: "dark", note: "Saved structure stays with freshness." },
    { name: "Offline + no cache", kind: "offline", mode: "light", note: "Distinct from empty or quiet." },
    { name: "Failed / error", kind: "failed", mode: "dark", note: "Failure is not unavailable data." },
    { name: "Date semantics", kind: "date-key", mode: "light", note: "Meaning never relies only on color." }
  ];
  const panelMarkup = panels.map((panel, index) => statePanel({
    ...panel,
    x: 40 + (index % 4) * 390,
    y: 158 + Math.floor(index / 4) * 454,
    width: 370,
    height: 416,
    index: index + 1
  })).join("");
  return svgShell({
    width: 1600,
    height: 1080,
    title: "Humay Calendar state board",
    description: "D3.2 approved visual reference. Seven Calendar state treatments plus the date-state key.",
    mode: "light",
    body: `<rect width="1600" height="1080" fill="#EFE9E2"/>
      <text x="40" y="53" class="label" font-size="10.5" fill="${themes.light.coralText}">D3.2 · APPROVED VISUAL REFERENCE</text>
      <text x="40" y="99" class="editorial" font-size="42" fill="${themes.light.ink}">Calendar state language</text>
      <text x="40" y="128" class="ui" font-size="14.5" fill="${themes.light.secondary}">Empty Calendar data, a quiet selected day, unavailable data, and failure remain separate meanings.</text>
      ${panelMarkup}
      <text x="40" y="1050" class="ui" font-size="10.5" fill="${themes.light.tertiary}">Reference annotation: no recovery action is shown because current contracts expose none.</text>
      <text x="1560" y="1050" text-anchor="end" class="ui" font-size="10.5" fill="${themes.light.tertiary}">Mixed Light/Dark examples · compact-width components shown</text>`
  });
}

function stressMiniMonth({ x, y, width, theme, title, leading, days, previousDays, rows }) {
  const weekdays = ["M", "T", "W", "T", "F", "S", "S"];
  const cellWidth = width / 7;
  const rowHeight = 33;
  const cells = Array.from({ length: rows * 7 }, (_, index) => {
    const day = index - leading + 1;
    const inside = day >= 1 && day <= days;
    const shown = inside ? day : day < 1 ? previousDays + day : day - days;
    return `<text x="${x + cellWidth * (index % 7 + 0.5)}" y="${y + 68 + Math.floor(index / 7) * rowHeight}" text-anchor="middle" class="ui" font-size="9.5" font-style="${inside ? "normal" : "italic"}" fill="${inside ? theme.ink : theme.tertiary}" opacity="${inside ? 1 : 0.55}">${shown}</text>`;
  }).join("");
  return `<g aria-label="${escapeText(title)} stress month">
    <text x="${x}" y="${y + 20}" class="editorial" font-size="25" fill="${theme.ink}">${escapeText(title)}</text>
    ${weekdays.map((day, index) => `<text x="${x + cellWidth * (index + 0.5)}" y="${y + 43}" text-anchor="middle" class="label" font-size="6" fill="${theme.secondary}">${day}</text>`).join("")}
    <line x1="${x}" y1="${y + 50}" x2="${x + width}" y2="${y + 50}" stroke="${theme.hairline}"/>
    ${cells}
  </g>`;
}

function stressPanel({ x, mode, label, note, body }) {
  const theme = themes[mode];
  return `<g>
    <rect x="${x}" y="150" width="370" height="500" rx="28" fill="${theme.ground}" stroke="#D4CCC4" stroke-opacity=".32"/>
    <text x="${x + 22}" y="181" class="label" font-size="8.5" fill="${theme.coralText}">${escapeText(label)}</text>
    <text x="${x + 348}" y="181" text-anchor="end" class="label" font-size="7" fill="${theme.tertiary}">${mode.toUpperCase()}</text>
    <text x="${x + 22}" y="211" class="ui" font-size="11.5" fill="${theme.secondary}">${escapeText(note)}</text>
    <rect x="${x + 22}" y="235" width="326" height="382" rx="20" fill="${theme.surface}" stroke="${theme.hairline}"/>
    ${body(theme, x + 44, 258)}
  </g>`;
}

function stressBoard() {
  const panels = [
    stressPanel({
      x: 40,
      mode: "light",
      label: "01 · LONG LOCALIZED MONTH",
      note: "Heading wraps before controls or targets shrink.",
      body: (theme, x, y) => `${stressMiniMonth({ x, y, width: 282, theme, title: "septiembre de 2026", leading: 1, days: 30, previousDays: 31, rows: 5 })}
        <text x="${x}" y="${y + 254}" class="ui" font-size="10.5" fill="${theme.secondary}">Five rows retain the standard row rhythm.</text>`
    }),
    stressPanel({
      x: 430,
      mode: "dark",
      label: "02 · SIX-ROW NOVEMBER",
      note: "Late start and outside dates stay legible.",
      body: (theme, x, y) => `${stressMiniMonth({ x, y, width: 282, theme, title: "November 2026", leading: 6, days: 30, previousDays: 31, rows: 6 })}
        <text x="${x}" y="${y + 287}" class="ui" font-size="10.5" fill="${theme.secondary}">Outside-month dates remain secondary.</text>`
    }),
    stressPanel({
      x: 820,
      mode: "light",
      label: "03 · LONG AGENDA CONTENT",
      note: "Titles wrap; timing and methodology survive.",
      body: (theme, x, y) => `<text x="${x}" y="${y + 20}" class="editorial" font-size="23" fill="${theme.ink}">Friday · 27 November</text>
        <text x="${x}" y="${y + 48}" class="ui" font-size="14" font-weight="700" fill="${theme.ink}">Mars enters Sagittarius after an</text>
        <text x="${x}" y="${y + 68}" class="ui" font-size="14" font-weight="700" fill="${theme.ink}">extended retrograde cycle</text>
        <text x="${x}" y="${y + 96}" class="mono" font-size="10" fill="${theme.secondary}">Date only · 27 November</text>
        ${methodBadge(x + 206, y + 82, "Western", theme, theme.coral, 52)}
        <line x1="${x}" y1="${y + 120}" x2="${x + 282}" y2="${y + 120}" stroke="${theme.hairline}"/>
        <text x="${x}" y="${y + 149}" class="ui" font-size="14" font-weight="700" fill="${theme.ink}">Mercury square Uranus</text>
        <text x="${x}" y="${y + 176}" class="mono" font-size="10" fill="${theme.secondary}">Fri 21:00 – Sat 03:00</text>
        ${methodBadge(x + 206, y + 162, "Western", theme, theme.lavender, 52)}
        <line x1="${x}" y1="${y + 201}" x2="${x + 282}" y2="${y + 201}" stroke="${theme.hairline}"/>
        <text x="${x}" y="${y + 230}" class="ui" font-size="14" font-weight="700" fill="${theme.ink}">Jupiter trine Saturn</text>
        <text x="${x}" y="${y + 257}" class="mono" font-size="10" fill="${theme.secondary}">Timing unavailable</text>
        ${methodBadge(x + 220, y + 243, "Vedic", theme, theme.blue, 44)}`
    }),
    stressPanel({
      x: 1210,
      mode: "dark",
      label: "04 · ACCESSIBILITY PRESSURE",
      note: "Width and text pressure trigger one column.",
      body: (theme, x, y) => `<text x="${x}" y="${y + 24}" class="editorial" font-size="30" fill="${theme.ink}">Selected date</text>
        <text x="${x}" y="${y + 62}" class="ui" font-size="20" font-weight="700" fill="${theme.ink}">Friday · 27 November</text>
        <line x1="${x}" y1="${y + 86}" x2="${x + 282}" y2="${y + 86}" stroke="${theme.hairline}"/>
        <text x="${x}" y="${y + 121}" class="ui" font-size="18" font-weight="700" fill="${theme.ink}">Long event title wraps</text>
        <text x="${x}" y="${y + 146}" class="ui" font-size="18" font-weight="700" fill="${theme.ink}">without truncation</text>
        <text x="${x}" y="${y + 181}" class="mono" font-size="14" fill="${theme.secondary}">Timing unavailable</text>
        <text x="${x}" y="${y + 229}" class="ui" font-size="12" fill="${theme.secondary}">Agenda drops below the grid.</text>
        <text x="${x}" y="${y + 251}" class="ui" font-size="12" fill="${theme.secondary}">44 pt targets remain intact.</text>
        <text x="${x}" y="${y + 273}" class="ui" font-size="12" fill="${theme.secondary}">Decorative markers disappear first.</text>`
    })
  ].join("");
  return svgShell({
    width: 1600,
    height: 720,
    title: "Humay Calendar stress board",
    description: "D3.2 approved visual reference. Calendar stress evidence for long month names, five- and six-row months, long agenda content, and accessibility pressure.",
    mode: "light",
    body: `<rect width="1600" height="720" fill="#EFE9E2"/>
      <text x="40" y="53" class="label" font-size="10.5" fill="${themes.light.coralText}">D3.2 · APPROVED VISUAL REFERENCE</text>
      <text x="40" y="99" class="editorial" font-size="42" fill="${themes.light.ink}">Calendar stress evidence</text>
      <text x="40" y="128" class="ui" font-size="14.5" fill="${themes.light.secondary}">September, November, long content, mixed timing, Sagittarius, and accessibility pressure are exercised without extra device screenshots.</text>
      ${panels}`
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
  await writeSvgAndPng("month-iphone-light", phoneMonth("light"), 860);
  await writeSvgAndPng("month-iphone-dark", phoneMonth("dark"), 860);
  await writeSvgAndPng("month-ipad-light", iPadMonth("light"), 2048);
  await writeSvgAndPng("month-ipad-dark", iPadMonth("dark"), 2048);
  await writeSvgAndPng("week-iphone-light", phoneWeek("light"), 860);
  await writeSvgAndPng("week-iphone-dark", phoneWeek("dark"), 860);
  await writeSvgAndPng("week-ipad-light", iPadWeek("light"), 2048);
  await writeSvgAndPng("week-ipad-dark", iPadWeek("dark"), 2048);
  await writeSvgAndPng("states", stateBoard(), 1600);
  await writeSvgAndPng("stress", stressBoard(), 1600);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
