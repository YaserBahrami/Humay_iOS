const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const sharp = require("sharp");

const outputDirectory = __dirname;
const fontPath = path.resolve(
  outputDirectory,
  "../../../../../Humay/Resources/Fonts/CormorantGaramond-Regular.otf"
);
const editorialFont = fs.readFileSync(fontPath).toString("base64");

const phone = { width: 430, height: 932 };
const iPad = { width: 1024, height: 1366 };

const themes = {
  light: {
    ground: "#FBF7F1",
    surface: "#FFFDFC",
    raised: "#F7F0E8",
    selected: "#FFF0EC",
    ink: "#151B28",
    secondary: "#625F62",
    tertiary: "#807B7D",
    hairline: "#E9E0D8",
    coral: "#F06F67",
    coralInk: "#A33D39",
    peach: "#F7C7B8",
    lavender: "#9A82C8",
    lavenderInk: "#62478E",
    softLavender: "#E8E0F1",
    gold: "#D5A253",
    goldInk: "#7A520C",
    blue: "#6B9FC1",
    sage: "#79A58C",
    heroStart: "#FFFDFC",
    heroEnd: "#FCF1EC",
    tab: "#FFFDFC",
    selectedTab: "#F2ECE7",
    buttonText: "#FBF7F1",
    shadow: "#594D43"
  },
  dark: {
    ground: "#101725",
    surface: "#171F30",
    raised: "#20283A",
    selected: "#2B293D",
    ink: "#F5F0EA",
    secondary: "#D6D0CC",
    tertiary: "#A59EA0",
    hairline: "#30394B",
    coral: "#F77476",
    coralInk: "#FF9998",
    peach: "#F0A79A",
    lavender: "#C17ADB",
    lavenderInk: "#D89AE9",
    softLavender: "#473653",
    gold: "#E5AA55",
    goldInk: "#F0BE73",
    blue: "#78B1D5",
    sage: "#82BDA3",
    heroStart: "#20283A",
    heroEnd: "#30283B",
    tab: "#171F30",
    selectedTab: "#3A4357",
    buttonText: "#101725",
    shadow: "#000000"
  }
};

const savedPeople = [
  { name: "Alexandria", sign: "Sagittarius", initials: "A", accent: "lavender", selected: true },
  { name: "Christopher", sign: "Capricorn", initials: "C", accent: "coral", selected: true },
  { name: "Yaser", sign: "Leo", initials: "Y", accent: "gold", selected: false },
  { name: "Salma", sign: "Gemini", initials: "S", accent: "blue", selected: false },
  { name: "Noor Aydin", sign: "Virgo", initials: "NA", accent: "sage", selected: false },
  { name: "Mateo", sign: "Aquarius", initials: "M", accent: "lavender", selected: false }
];

function validateFixture() {
  assert.equal(savedPeople.filter((person) => person.selected).length, 2);
  assert.ok(savedPeople.length > 4);
  for (const value of ["Alexandria", "Christopher", "Sagittarius", "Capricorn", "Yaser", "Salma", "Gemini"]) {
    assert.ok(savedPeople.some((person) => person.name === value || person.sign === value));
  }
}

function escapeText(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

function svgShell({ width, height, mode, title, description, body }) {
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
      .label { font-family: -apple-system, BlinkMacSystemFont, "Helvetica Neue", Arial, sans-serif; font-weight: 700; letter-spacing: 1.1px; }
      text { text-rendering: optimizeLegibility; }
    </style>
    <linearGradient id="relationship-gradient" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="${theme.lavender}"/>
      <stop offset="0.52" stop-color="${theme.coral}"/>
      <stop offset="1" stop-color="${theme.gold}"/>
    </linearGradient>
    <linearGradient id="hero-gradient" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="${theme.heroStart}"/>
      <stop offset="1" stop-color="${theme.heroEnd}"/>
    </linearGradient>
    <linearGradient id="cta-gradient" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="${mode === "light" ? theme.ink : theme.coralInk}"/>
      <stop offset="1" stop-color="${mode === "light" ? theme.ink : theme.lavenderInk}"/>
    </linearGradient>
    <radialGradient id="lavender-field">
      <stop offset="0" stop-color="${theme.lavender}" stop-opacity="0.22"/>
      <stop offset="1" stop-color="${theme.lavender}" stop-opacity="0"/>
    </radialGradient>
    <radialGradient id="coral-field">
      <stop offset="0" stop-color="${theme.coral}" stop-opacity="0.20"/>
      <stop offset="1" stop-color="${theme.coral}" stop-opacity="0"/>
    </radialGradient>
    <filter id="soft-shadow" x="-25%" y="-25%" width="150%" height="170%">
      <feDropShadow dx="0" dy="5" stdDeviation="10" flood-color="${theme.shadow}" flood-opacity="${mode === "light" ? "0.10" : "0"}"/>
    </filter>
  </defs>
  ${body}
</svg>`;
}

function authorityLabel(width, theme) {
  return `<text x="${width / 2}" y="12" text-anchor="middle" class="label" font-size="6.6" fill="${theme.coralInk}">APPROVED · IMPLEMENTED · RECONCILED</text>`;
}

function statusBar(width, theme, device) {
  const isPhone = device === "phone";
  const timeX = isPhone ? 22 : 24;
  const iconX = width - (isPhone ? 78 : 92);
  const time = isPhone ? "9:41" : "9:41  ·  Thu 13 Aug";
  return `<g aria-label="System status bar">
    <text x="${timeX}" y="31" class="ui" font-size="${isPhone ? 14 : 13}" font-weight="700" fill="${theme.ink}">${time}</text>
    <g transform="translate(${iconX} 20)" fill="none" stroke="${theme.ink}" stroke-width="1.8" stroke-linecap="round">
      <path d="M0 8h2V5h2v3h2V2h2v6"/>
      <path d="M14 4c3-3 8-3 11 0M17 7c2-2 4-2 6 0"/>
      <rect x="30" y="0" width="22" height="10" rx="3"/>
      <rect x="32" y="2" width="16" height="6" rx="2" fill="${theme.ink}" stroke="none"/>
      <path d="M53 3v4"/>
    </g>
  </g>`;
}

function backButton(x, y, theme) {
  return `<g aria-label="Back">
    <circle cx="${x + 22}" cy="${y + 22}" r="22" fill="${theme.surface}" stroke="${theme.hairline}"/>
    <path d="M${x + 26} ${y + 13}l-9 9 9 9" fill="none" stroke="${theme.ink}" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round"/>
  </g>`;
}

function shareButton(x, y, theme) {
  return `<g aria-label="Share Compatibility, current toolbar control">
    <circle cx="${x + 22}" cy="${y + 22}" r="22" fill="${theme.surface}" stroke="${theme.hairline}"/>
    <rect x="${x + 14}" y="${y + 20}" width="16" height="15" rx="3" fill="none" stroke="${theme.coral}" stroke-width="2"/>
    <path d="M${x + 22} ${y + 26}V${y + 10}m-6 6 6-6 6 6" fill="none" stroke="${theme.coral}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  </g>`;
}

function phoneNavigation(theme, includeShare) {
  return `${backButton(20, 48, theme)}
    <text x="215" y="78" text-anchor="middle" class="ui" font-size="17" font-weight="700" fill="${theme.ink}">Compatibility</text>
    ${includeShare ? shareButton(366, 48, theme) : ""}`;
}

function iPadTabs(theme) {
  const labels = ["Today", "Circle", "Sky", "Chart", "Ask"];
  const centers = [334, 423, 512, 601, 690];
  return `<g aria-label="Primary navigation">
    <rect x="286" y="42" width="452" height="50" rx="25" fill="${theme.surface}" stroke="${theme.hairline}"/>
    <rect x="383" y="48" width="80" height="38" rx="19" fill="${theme.selectedTab}"/>
    ${labels.map((label, index) => `<text x="${centers[index]}" y="73" text-anchor="middle" class="ui" font-size="13" font-weight="${label === "Circle" ? "700" : "600"}" fill="${label === "Circle" ? theme.coral : theme.ink}">${label}</text>`).join("")}
  </g>`;
}

function iPadChrome(theme, includeShare) {
  return `${iPadTabs(theme)}
    ${backButton(24, 102, theme)}
    <text x="512" y="133" text-anchor="middle" class="ui" font-size="17" font-weight="700" fill="${theme.ink}">Compatibility</text>
    ${includeShare ? shareButton(956, 102, theme) : ""}`;
}

function heartIcon(x, y, size, color, filled = false) {
  const scale = size / 20;
  return `<path d="M0 7C-20-7-10-25 0-14C10-25 20-7 0 7Z" transform="translate(${x} ${y}) scale(${scale})" fill="${filled ? color : "none"}" stroke="${color}" stroke-width="${filled ? 1.6 : 2.1}" stroke-linecap="round" stroke-linejoin="round"/>`;
}

function sparkle(x, y, size, color) {
  return `<path d="M${x} ${y - size}c1 ${size * 0.62} ${size * 0.38} ${size - 1} ${size} ${size}c-${size * 0.62} 1-${size - 1} ${size * 0.38}-${size} ${size}c-1-${size * 0.62}-${size * 0.38}-${size - 1}-${size}-${size}c${size * 0.62}-1 ${size - 1}-${size * 0.38} ${size}-${size}Z" fill="none" stroke="${color}" stroke-width="1.3"/>`;
}

function medallion({ cx, cy, radius, initials, accent, theme }) {
  return `<g aria-hidden="true">
    <circle cx="${cx}" cy="${cy}" r="${radius}" fill="${theme.raised}" stroke="${accent}" stroke-width="1.5"/>
    <circle cx="${cx}" cy="${cy}" r="${radius - 1}" fill="${accent}" opacity="0.22"/>
    <circle cx="${cx}" cy="${cy + radius * 0.10}" r="${radius * 0.64}" fill="${theme.surface}" opacity="0.55"/>
    <text x="${cx}" y="${cy + radius * 0.18}" text-anchor="middle" class="ui" font-size="${radius * 0.48}" font-weight="750" fill="${theme.ink}">${escapeText(initials)}</text>
  </g>`;
}

function connector({ leftX, rightX, y, arcY, theme, heartY, large = false }) {
  const center = (leftX + rightX) / 2;
  return `<g aria-hidden="true">
    <path d="M${leftX} ${y}C${leftX + (rightX - leftX) * 0.28} ${arcY} ${rightX - (rightX - leftX) * 0.28} ${arcY} ${rightX} ${y}" fill="none" stroke="url(#relationship-gradient)" stroke-width="${large ? 3 : 2.2}" stroke-linecap="round" stroke-dasharray="${large ? "1 0" : "4 6"}"/>
    <circle cx="${leftX}" cy="${y}" r="${large ? 4 : 3}" fill="${theme.lavender}"/>
    <circle cx="${rightX}" cy="${y}" r="${large ? 4 : 3}" fill="${theme.coral}"/>
    ${heartIcon(center, heartY, large ? 16 : 13, theme.coral, false)}
  </g>`;
}

function selectionMark(x, y, theme, selected) {
  if (!selected) {
    return `<circle cx="${x}" cy="${y}" r="11" fill="none" stroke="${theme.tertiary}" stroke-width="1.6"/>`;
  }
  return `<g aria-hidden="true">
    <circle cx="${x}" cy="${y}" r="12" fill="${theme.coral}"/>
    <path d="M${x - 5} ${y}l3.5 3.5 7-8" fill="none" stroke="${theme.buttonText}" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/>
  </g>`;
}

function personRow({ x, y, width, height, person, theme, roomy = false }) {
  const accent = theme[person.accent];
  const radius = roomy ? 26 : 22;
  const centerY = y + height / 2;
  const medalX = x + (roomy ? 39 : 34);
  const textX = x + (roomy ? 78 : 68);
  const markX = x + width - (roomy ? 34 : 28);
  return `<g aria-label="${escapeText(person.name)}, ${escapeText(person.sign)}, ${person.selected ? "selected" : "not selected"}">
    <rect x="${x}" y="${y}" width="${width}" height="${height}" rx="17" fill="${person.selected ? theme.selected : theme.surface}" stroke="${person.selected ? accent : theme.hairline}" stroke-width="${person.selected ? 1.7 : 1}"/>
    ${medallion({ cx: medalX, cy: centerY, radius, initials: person.initials, accent, theme })}
    <text x="${textX}" y="${centerY - 4}" class="ui" font-size="${roomy ? 16 : 14.5}" font-weight="700" fill="${theme.ink}">${escapeText(person.name)}</text>
    <text x="${textX}" y="${centerY + 17}" class="ui" font-size="${roomy ? 12.5 : 11.5}" fill="${theme.secondary}">${escapeText(person.sign)} Sun</text>
    ${person.selected && roomy ? `<text x="${markX - 22}" y="${centerY + 4}" text-anchor="end" class="label" font-size="8" fill="${theme.coralInk}">SELECTED</text>` : ""}
    ${selectionMark(markX, centerY, theme, person.selected)}
  </g>`;
}

function pairComposer({ x, y, width, height, theme, large = false }) {
  const leftX = x + (large ? 105 : 84);
  const rightX = x + width - (large ? 105 : 84);
  const centerY = y + (large ? 150 : 91);
  const radius = large ? 48 : 32;
  const nameY = y + (large ? 224 : 145);
  const signY = y + (large ? 248 : 165);
  return `<g aria-label="Selected pair, Alexandria, Sagittarius, and Christopher, Capricorn. Two people selected.">
    <rect x="${x}" y="${y}" width="${width}" height="${height}" rx="${large ? 26 : 22}" fill="url(#hero-gradient)" stroke="${theme.hairline}" filter="url(#soft-shadow)"/>
    <circle cx="${x + 55}" cy="${y + 52}" r="${large ? 96 : 58}" fill="url(#lavender-field)"/>
    <circle cx="${x + width - 38}" cy="${y + 46}" r="${large ? 102 : 62}" fill="url(#coral-field)"/>
    <text x="${x + 18}" y="${y + 27}" class="label" font-size="${large ? 9 : 8}" fill="${theme.coralInk}">YOUR CONNECTION</text>
    <rect x="${x + width - (large ? 112 : 96)}" y="${y + 14}" width="${large ? 94 : 78}" height="24" rx="12" fill="${theme.raised}" stroke="${theme.hairline}"/>
    <text x="${x + width - (large ? 65 : 57)}" y="${y + 30}" text-anchor="middle" class="ui" font-size="${large ? 10.5 : 9.5}" font-weight="700" fill="${theme.ink}">✓ 2 selected</text>
    ${connector({ leftX: leftX + radius + 10, rightX: rightX - radius - 10, y: centerY, arcY: centerY - (large ? 48 : 32), theme, heartY: centerY - (large ? 37 : 24), large })}
    ${medallion({ cx: leftX, cy: centerY, radius, initials: "A", accent: theme.lavender, theme })}
    ${medallion({ cx: rightX, cy: centerY, radius, initials: "C", accent: theme.coral, theme })}
    <text x="${leftX}" y="${nameY}" text-anchor="middle" class="ui" font-size="${large ? 16 : 13.5}" font-weight="700" fill="${theme.ink}">Alexandria</text>
    <text x="${rightX}" y="${nameY}" text-anchor="middle" class="ui" font-size="${large ? 16 : 13.5}" font-weight="700" fill="${theme.ink}">Christopher</text>
    <text x="${leftX}" y="${signY}" text-anchor="middle" class="ui" font-size="${large ? 12.5 : 10.8}" fill="${theme.secondary}">Sagittarius</text>
    <text x="${rightX}" y="${signY}" text-anchor="middle" class="ui" font-size="${large ? 12.5 : 10.8}" fill="${theme.secondary}">Capricorn</text>
  </g>`;
}

function primaryButton({ x, y, width, theme, mode, label = "See Compatibility" }) {
  return `<g aria-label="${escapeText(label)}, button">
    <rect x="${x}" y="${y}" width="${width}" height="56" rx="18" fill="url(#cta-gradient)"/>
    ${heartIcon(x + width / 2 - 73, y + 28, 9, theme.buttonText, true)}
    <text x="${x + width / 2 + 7}" y="${y + 35}" text-anchor="middle" class="ui" font-size="16" font-weight="700" fill="${theme.buttonText}">${escapeText(label)}</text>
  </g>`;
}

function phoneTabBar(theme) {
  const items = [
    [43, "Today"],
    [129, "Circle"],
    [215, "Sky"],
    [301, "Chart"],
    [387, "Ask"]
  ];
  return `<g aria-label="Primary navigation">
    <rect x="0" y="842" width="430" height="90" fill="${theme.tab}" stroke="${theme.hairline}"/>
    <rect x="93" y="850" width="72" height="52" rx="26" fill="${theme.selectedTab}"/>
    ${items.map(([x, label], index) => {
      const selected = label === "Circle";
      const color = selected ? theme.coral : theme.ink;
      const icon = index === 0
        ? `<circle cx="${x}" cy="865" r="7" fill="none" stroke="${color}" stroke-width="1.6"/><path d="M${x} 854v-4m0 26v4m-11-15h-4m26 0h4" stroke="${color}" stroke-width="1.5"/>`
        : index === 1
          ? `<circle cx="${x - 5}" cy="862" r="4.5" fill="${color}"/><circle cx="${x + 5}" cy="862" r="4.5" fill="${color}"/><path d="M${x - 13} 875c1-7 6-10 13-10s12 3 13 10" fill="${color}"/>`
          : index === 2
            ? sparkle(x, 865, 8, color)
            : index === 3
              ? `<circle cx="${x}" cy="865" r="10" fill="none" stroke="${color}" stroke-width="1.5"/><circle cx="${x}" cy="865" r="2" fill="${color}"/><circle cx="${x - 5}" cy="861" r="1.5" fill="${color}"/><circle cx="${x + 5}" cy="869" r="1.5" fill="${color}"/>`
              : `<path d="M${x - 10} 857h20v14H${x + 2}l-6 5v-5h-6Z" fill="none" stroke="${color}" stroke-width="1.6" stroke-linejoin="round"/>`;
      return `${icon}<text x="${x}" y="899" text-anchor="middle" class="ui" font-size="10.5" font-weight="${selected ? "700" : "500"}" fill="${color}">${label}</text>`;
    }).join("")}
    <rect x="150" y="918" width="130" height="4" rx="2" fill="${theme.ink}" opacity="0.88"/>
  </g>`;
}

function phoneSelection(mode) {
  const theme = themes[mode];
  const rows = savedPeople.slice(0, 4).map((person, index) => personRow({
    x: 20,
    y: 426 + index * 74,
    width: 390,
    height: 66,
    person,
    theme
  })).join("");
  const body = `<rect width="430" height="932" fill="${theme.ground}"/>
    ${authorityLabel(430, theme)}
    ${statusBar(430, theme, "phone")}
    ${phoneNavigation(theme, false)}
    <text x="20" y="131" class="editorial" font-size="34" fill="${theme.ink}">Choose your connection</text>
    <text x="20" y="158" class="ui" font-size="14.5" fill="${theme.secondary}">Select two people to compare.</text>
    ${pairComposer({ x: 20, y: 181, width: 390, height: 190, theme })}
    <text x="20" y="407" class="ui" font-size="17" font-weight="700" fill="${theme.ink}">Saved people</text>
    <text x="410" y="407" text-anchor="end" class="ui" font-size="12" fill="${theme.secondary}">6 people</text>
    ${rows}
    <g aria-label="Safe-area action tray">
      <rect x="0" y="738" width="430" height="104" fill="${theme.ground}" opacity="0.97"/>
      <line x1="0" y1="738" x2="430" y2="738" stroke="${theme.hairline}"/>
      <text x="20" y="759" class="ui" font-size="11" font-weight="650" fill="${theme.secondary}">Alexandria + Christopher</text>
      ${primaryButton({ x: 20, y: 770, width: 390, theme, mode })}
    </g>
    ${phoneTabBar(theme)}`;
  return svgShell({
    width: phone.width,
    height: phone.height,
    mode,
    title: `Humay Compatibility selection refresh, iPhone ${mode}`,
    description: "Approved visual reference, implemented and reconciled. Full-device iPhone selection reference using a two-slot pair composer, one-column saved-person rows, long-name stress data, and a safe-area Compatibility action.",
    body
  });
}

function iPadSelection(mode) {
  const theme = themes[mode];
  const rows = savedPeople.map((person, index) => personRow({
    x: 528,
    y: 318 + index * 90,
    width: 432,
    height: 78,
    person,
    theme,
    roomy: true
  })).join("");
  const body = `<rect width="1024" height="1366" fill="${theme.ground}"/>
    ${authorityLabel(1024, theme)}
    ${statusBar(1024, theme, "ipad")}
    ${iPadChrome(theme, false)}
    <text x="64" y="208" class="editorial" font-size="46" fill="${theme.ink}">Choose your connection</text>
    <text x="64" y="239" class="ui" font-size="15" fill="${theme.secondary}">Select two people. The pair stays visible while you browse your Circle.</text>
    ${pairComposer({ x: 64, y: 274, width: 408, height: 312, theme, large: true })}
    <text x="64" y="622" class="ui" font-size="12.5" fill="${theme.secondary}">Both people are ready. Compatibility uses this exact pair.</text>
    ${primaryButton({ x: 64, y: 645, width: 408, theme, mode })}
    <rect x="64" y="725" width="408" height="96" rx="18" fill="${theme.raised}" stroke="${theme.hairline}"/>
    <circle cx="92" cy="754" r="14" fill="${theme.gold}" opacity="0.16"/>
    <path d="M92 746v10m0 5v1" stroke="${theme.goldInk}" stroke-width="2" stroke-linecap="round"/>
    <text x="118" y="751" class="ui" font-size="13" font-weight="700" fill="${theme.ink}">Simple first, precise when available</text>
    <text x="118" y="775" class="ui" font-size="12" fill="${theme.secondary}">The next screen states whether the result is Free or Precise.</text>
    <text x="118" y="795" class="ui" font-size="12" fill="${theme.secondary}">Birth details never appear in this picker.</text>
    <text x="528" y="296" class="ui" font-size="20" font-weight="700" fill="${theme.ink}">Saved people</text>
    <text x="960" y="296" text-anchor="end" class="ui" font-size="12.5" fill="${theme.secondary}">2 selected · 6 total</text>
    ${rows}`;
  return svgShell({
    width: iPad.width,
    height: iPad.height,
    mode,
    title: `Humay Compatibility selection refresh, iPad ${mode}`,
    description: "Approved visual reference, implemented and reconciled. Full-device iPad selection reference with a dedicated pair-composer region and a generous one-column saved-person list containing six people and long-name stress data.",
    body
  });
}

function basisDisclosure({ x, y, width, theme, compact = false }) {
  const iconX = x + (compact ? 18 : 20);
  const iconY = y + 19;
  return `<g aria-label="Free, Sun-sign pair. Sagittarius by Capricorn catalog, not natal synastry.">
    <circle cx="${iconX}" cy="${iconY}" r="12" fill="${theme.gold}" opacity="0.17"/>
    <circle cx="${iconX}" cy="${iconY}" r="4" fill="none" stroke="${theme.goldInk}" stroke-width="1.5"/>
    <path d="M${iconX} ${iconY - 8}v-3m0 19v3m-8-11h-3m19 0h3" stroke="${theme.goldInk}" stroke-width="1.3" stroke-linecap="round"/>
    <text x="${x + (compact ? 38 : 42)}" y="${y + 18}" class="ui" font-size="${compact ? 11 : 12.5}" font-weight="700" fill="${theme.ink}">Free · Sun-sign pair</text>
    <text x="${x + (compact ? 38 : 42)}" y="${y + 37}" class="ui" font-size="${compact ? 9.8 : 11.5}" fill="${theme.secondary}">Sagittarius × Capricorn catalog · not natal synastry</text>
    <line x1="${x}" y1="${y + 52}" x2="${x + width}" y2="${y + 52}" stroke="${theme.hairline}"/>
  </g>`;
}

function phoneRelationshipHero({ x, y, width, height, theme }) {
  const center = x + width / 2;
  const left = x + 84;
  const right = x + width - 84;
  const medalY = y + 202;
  return `<g aria-label="Alexandria and Christopher. Sagittarius Sun and Capricorn Sun. Free Sun-sign pair, not natal synastry. Compatibility score, 82 percent. Magnetic Match. You spark momentum without losing your footing.">
    <rect x="${x}" y="${y}" width="${width}" height="${height}" rx="26" fill="url(#hero-gradient)" stroke="${theme.hairline}" filter="url(#soft-shadow)"/>
    <circle cx="${x + 48}" cy="${y + 175}" r="118" fill="url(#lavender-field)"/>
    <circle cx="${x + width - 30}" cy="${y + 155}" r="124" fill="url(#coral-field)"/>
    ${sparkle(x + 31, y + 301, 5, theme.lavender)}
    ${basisDisclosure({ x: x + 17, y: y + 13, width: width - 34, theme, compact: true })}
    <text x="${center}" y="${y + 107}" text-anchor="middle" class="editorial" font-size="30" fill="${theme.ink}">Alexandria &amp; Christopher</text>
    ${connector({ leftX: left + 48, rightX: right - 48, y: medalY, arcY: medalY - 48, theme, heartY: medalY - 37 })}
    ${medallion({ cx: left, cy: medalY, radius: 42, initials: "A", accent: theme.lavender, theme })}
    ${medallion({ cx: right, cy: medalY, radius: 42, initials: "C", accent: theme.coral, theme })}
    <text x="${left}" y="${y + 261}" text-anchor="middle" class="ui" font-size="11.5" fill="${theme.secondary}">Sagittarius Sun</text>
    <text x="${right}" y="${y + 261}" text-anchor="middle" class="ui" font-size="11.5" fill="${theme.secondary}">Capricorn Sun</text>
    <text x="${center}" y="${y + 331}" text-anchor="middle" class="editorial" font-size="70" fill="url(#relationship-gradient)">82%</text>
    <text x="${center}" y="${y + 365}" text-anchor="middle" class="ui" font-size="22" font-weight="700" fill="${theme.ink}">Magnetic Match</text>
    <line x1="${x + 54}" y1="${y + 386}" x2="${x + width - 54}" y2="${y + 386}" stroke="${theme.hairline}"/>
    <text x="${center}" y="${y + 413}" text-anchor="middle" class="ui" font-size="14" fill="${theme.ink}">You spark momentum without losing your footing.</text>
    <text x="${center}" y="${y + 434}" text-anchor="middle" class="ui" font-size="12" fill="${theme.secondary}">A warm, fast-moving connection with room to grow.</text>
  </g>`;
}

function metricRow({ x, y, width, label, value, accent, theme, phone: isPhone = false }) {
  const labelX = x + (isPhone ? 32 : 38);
  const barX = x + (isPhone ? 170 : 188);
  const barWidth = width - (isPhone ? 220 : 252);
  return `<g aria-label="${escapeText(label)}, ${value} percent">
    <circle cx="${x + 13}" cy="${y - 4}" r="9" fill="${accent}" opacity="0.15"/>
    <circle cx="${x + 13}" cy="${y - 4}" r="3" fill="${accent}"/>
    <text x="${labelX}" y="${y}" class="ui" font-size="${isPhone ? 11.7 : 14}" fill="${theme.ink}">${escapeText(label)}</text>
    <rect x="${barX}" y="${y - 7}" width="${barWidth}" height="6" rx="3" fill="${theme.hairline}"/>
    <rect x="${barX}" y="${y - 7}" width="${barWidth * value / 100}" height="6" rx="3" fill="${accent}"/>
    <text x="${x + width}" y="${y}" text-anchor="end" class="ui" font-size="${isPhone ? 12 : 13.5}" font-weight="700" fill="${theme.ink}">${value}%</text>
  </g>`;
}

function phoneLowerContext(x, y, width, theme) {
  const metrics = [
    ["Chemistry", 88, theme.coral],
    ["Communication", 76, theme.gold],
    ["Emotional connection", 79, theme.lavender]
  ];
  return `<g aria-label="Existing lower Compatibility result context">
    <rect x="${x}" y="${y}" width="${width}" height="226" rx="22" fill="${theme.surface}" stroke="${theme.hairline}"/>
    <text x="${x + 20}" y="${y + 34}" class="ui" font-size="18" font-weight="700" fill="${theme.ink}">Connection strengths</text>
    ${metrics.map((metric, index) => metricRow({ x: x + 20, y: y + 76 + index * 48, width: width - 40, label: metric[0], value: metric[1], accent: metric[2], theme, phone: true })).join("")}
    <text x="${x + 20}" y="${y + 214}" class="ui" font-size="10.5" fill="${theme.tertiary}">Lower result content remains existing visual context.</text>
  </g>`;
}

function phoneResult(mode) {
  const theme = themes[mode];
  const body = `<rect width="430" height="932" fill="${theme.ground}"/>
    ${authorityLabel(430, theme)}
    ${statusBar(430, theme, "phone")}
    ${phoneNavigation(theme, true)}
    ${phoneRelationshipHero({ x: 20, y: 118, width: 390, height: 454, theme })}
    ${phoneLowerContext(20, 592, 390, theme)}
    ${phoneTabBar(theme)}`;
  return svgShell({
    width: phone.width,
    height: phone.height,
    mode,
    title: `Humay Compatibility result hero refresh, iPhone ${mode}`,
    description: "Approved visual reference, implemented and reconciled. Full-device iPhone result reference with one unified relationship field containing long pair names, signs, medallions, orbit connector, score, relationship label, summary, and Free Sun-sign basis disclosure.",
    body
  });
}

function iPadRelationshipHero({ x, y, width, height, theme }) {
  const leftCenter = x + 260;
  const rightCenter = x + 735;
  const leftMedal = x + 150;
  const rightMedal = x + 412;
  const medalY = y + 245;
  return `<g aria-label="Alexandria and Christopher. Sagittarius Sun and Capricorn Sun. Free Sun-sign pair, not natal synastry. Compatibility score, 82 percent. Magnetic Match. You spark momentum without losing your footing.">
    <rect x="${x}" y="${y}" width="${width}" height="${height}" rx="30" fill="url(#hero-gradient)" stroke="${theme.hairline}" filter="url(#soft-shadow)"/>
    <circle cx="${x + 105}" cy="${y + 245}" r="205" fill="url(#lavender-field)"/>
    <circle cx="${x + width - 90}" cy="${y + 198}" r="225" fill="url(#coral-field)"/>
    <path d="M${x + 470} ${y + 275}C${x + 555} ${y + 220} ${x + 612} ${y + 218} ${x + 680} ${y + 248}" fill="none" stroke="url(#relationship-gradient)" stroke-width="2" opacity="0.48"/>
    ${basisDisclosure({ x: x + 28, y: y + 19, width: width - 56, theme })}
    <text x="${leftCenter}" y="${y + 125}" text-anchor="middle" class="editorial" font-size="42" fill="${theme.ink}">Alexandria &amp; Christopher</text>
    ${connector({ leftX: leftMedal + 60, rightX: rightMedal - 60, y: medalY, arcY: medalY - 68, theme, heartY: medalY - 53, large: true })}
    ${medallion({ cx: leftMedal, cy: medalY, radius: 56, initials: "A", accent: theme.lavender, theme })}
    ${medallion({ cx: rightMedal, cy: medalY, radius: 56, initials: "C", accent: theme.coral, theme })}
    <text x="${leftMedal}" y="${y + 325}" text-anchor="middle" class="ui" font-size="13" fill="${theme.secondary}">Sagittarius Sun</text>
    <text x="${rightMedal}" y="${y + 325}" text-anchor="middle" class="ui" font-size="13" fill="${theme.secondary}">Capricorn Sun</text>
    <line x1="${x + 548}" y1="${y + 105}" x2="${x + 548}" y2="${y + 365}" stroke="${theme.hairline}"/>
    <text x="${rightCenter}" y="${y + 208}" text-anchor="middle" class="editorial" font-size="96" fill="url(#relationship-gradient)">82%</text>
    <text x="${rightCenter}" y="${y + 252}" text-anchor="middle" class="ui" font-size="28" font-weight="700" fill="${theme.ink}">Magnetic Match</text>
    <text x="${rightCenter}" y="${y + 296}" text-anchor="middle" class="ui" font-size="15" fill="${theme.ink}">You spark momentum without</text>
    <text x="${rightCenter}" y="${y + 320}" text-anchor="middle" class="ui" font-size="15" fill="${theme.ink}">losing your footing.</text>
    <text x="${rightCenter}" y="${y + 352}" text-anchor="middle" class="ui" font-size="12.5" fill="${theme.secondary}">Warm · fast-moving · grounded</text>
    ${sparkle(x + width - 58, y + 91, 7, theme.gold)}
    ${sparkle(x + 578, y + 350, 5, theme.lavender)}
  </g>`;
}

function iPadMetrics(x, y, width, theme) {
  const metrics = [
    ["Chemistry", 88, theme.coral],
    ["Communication", 76, theme.gold],
    ["Emotional connection", 79, theme.lavender],
    ["Adventure", 81, theme.blue]
  ];
  return `<g aria-label="Existing Connection strengths context">
    <rect x="${x}" y="${y}" width="${width}" height="284" rx="24" fill="${theme.surface}" stroke="${theme.hairline}"/>
    <text x="${x + 28}" y="${y + 46}" class="ui" font-size="22" font-weight="700" fill="${theme.ink}">Connection strengths</text>
    ${metrics.map((metric, index) => metricRow({ x: x + 28, y: y + 91 + index * 48, width: width - 56, label: metric[0], value: metric[1], accent: metric[2], theme })).join("")}
  </g>`;
}

function iPadOurTake(x, y, width, theme) {
  return `<g aria-label="Existing Our Take context">
    <rect x="${x}" y="${y}" width="${width}" height="174" rx="24" fill="${theme.raised}" stroke="${theme.hairline}"/>
    <text x="${x + 26}" y="${y + 38}" class="label" font-size="9" fill="${theme.coralInk}">OUR TAKE</text>
    <text x="${x + 26}" y="${y + 72}" class="ui" font-size="15" fill="${theme.ink}">You bring out each other's courage</text>
    <text x="${x + 26}" y="${y + 97}" class="ui" font-size="15" fill="${theme.ink}">without turning every difference</text>
    <text x="${x + 26}" y="${y + 122}" class="ui" font-size="15" fill="${theme.ink}">into a contest.</text>
    <g aria-hidden="true">
      <circle cx="${x + width - 58}" cy="${y + 110}" r="28" fill="${theme.lavender}" opacity="0.55"/>
      <ellipse cx="${x + width - 58}" cy="${y + 110}" rx="42" ry="14" fill="none" stroke="${theme.gold}" stroke-width="2" transform="rotate(-12 ${x + width - 58} ${y + 110})"/>
      ${sparkle(x + width - 30, y + 52, 5, theme.coral)}
    </g>
  </g>`;
}

function iPadResult(mode) {
  const theme = themes[mode];
  const body = `<rect width="1024" height="1366" fill="${theme.ground}"/>
    ${authorityLabel(1024, theme)}
    ${statusBar(1024, theme, "ipad")}
    ${iPadChrome(theme, true)}
    ${iPadRelationshipHero({ x: 48, y: 178, width: 928, height: 420, theme })}
    ${iPadMetrics(48, 630, 568, theme)}
    ${iPadOurTake(640, 630, 336, theme)}
    <text x="48" y="946" class="ui" font-size="11.5" fill="${theme.tertiary}">Metrics and Our Take remain existing lower-result context; this package redesigns only the relationship hero.</text>`;
  return svgShell({
    width: iPad.width,
    height: iPad.height,
    mode,
    title: `Humay Compatibility result hero refresh, iPad ${mode}`,
    description: "Approved visual reference, implemented and reconciled. Full-device iPad result reference with one wide relationship field: pair identity and orbit at left, score, relationship label, summary, and Free Sun-sign basis within the same composition at right.",
    body
  });
}

async function writeSvgAndPng(name, svg, pngWidth) {
  const svgPath = path.join(outputDirectory, `${name}.svg`);
  const pngPath = path.join(outputDirectory, `${name}.png`);
  const normalizedSvg = svg.replace(/^[\t ]+$/gm, "");
  fs.writeFileSync(svgPath, normalizedSvg);
  await sharp(Buffer.from(normalizedSvg))
    .resize({ width: pngWidth, withoutEnlargement: false })
    .png({ compressionLevel: 9, adaptiveFiltering: true })
    .toFile(pngPath);
}

async function main() {
  validateFixture();
  const references = [
    ["selection-iphone-light", phoneSelection("light"), 860],
    ["selection-iphone-dark", phoneSelection("dark"), 860],
    ["selection-ipad-light", iPadSelection("light"), 2048],
    ["selection-ipad-dark", iPadSelection("dark"), 2048],
    ["result-hero-iphone-light", phoneResult("light"), 860],
    ["result-hero-iphone-dark", phoneResult("dark"), 860],
    ["result-hero-ipad-light", iPadResult("light"), 2048],
    ["result-hero-ipad-dark", iPadResult("dark"), 2048]
  ];
  for (const [name, svg, pngWidth] of references) {
    await writeSvgAndPng(name, svg, pngWidth);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
