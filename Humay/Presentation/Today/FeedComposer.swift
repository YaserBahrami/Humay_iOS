import Foundation

/// Composes the Today feed from normalized personalized data where it exists,
/// falling back to the deterministic engine feed when it does not (§28).
///
/// Expression discipline (§9): the semantic forecast never changes with
/// `PersonalityMode`. Mode only affects Humay-original expression — roast copy,
/// reveal copy, meter captions — selected locally from compact tables.
enum FeedComposer {
    static func dailyFeed(
        subject: ForecastSubject,
        document: PersonalizedForecastDocument?,
        date: Date,
        calendar: Calendar,
        mode: PersonalityMode,
        skyEvent: CosmicEventSeed?
    ) -> [FeedItem] {
        let dayOffset = calendar.dateComponents([.day], from: anchorStart(document, calendar), to: calendar.startOfDay(for: date)).day ?? 0

        if let day = document?.day(atOffset: dayOffset) {
            return personalizedFeed(
                subject: subject,
                day: day,
                document: document,
                date: date,
                calendar: calendar,
                mode: mode,
                skyEvent: skyEvent
            )
        }

        return HumayContentEngine.dailyFeed(
            profile: UserProfile(id: subject.id, displayName: subject.name, birth: subject.birth),
            date: date,
            calendar: calendar,
            mode: mode,
            skyEvent: skyEvent
        )
    }

    // MARK: - Personalized composition

    private static func personalizedFeed(
        subject: ForecastSubject,
        day: DailyMood,
        document: PersonalizedForecastDocument?,
        date: Date,
        calendar: Calendar,
        mode: PersonalityMode,
        skyEvent: CosmicEventSeed?
    ) -> [FeedItem] {
        let weekday = date.formatted(.dateTime.weekday(.wide).locale(calendar.locale ?? .current)).uppercased()
        let signName = (subject.sunSign?.displayName ?? "Everyone").uppercased()
        let kicker = "\(signName) • \(weekday)"

        var rng = HumayContentEngine.makeRNG("composer", subject.id.uuidString, String(day.dayOffset))
        var items: [FeedItem] = []

        // 1. Headline — semantic, from the day record when present.
        let headlineText = day.reading?.headline ?? fallbackHeadline(day, rng: &rng)
        items.append(FeedItem(
            id: "headline",
            kind: .headline(HeadlineContent(
                kicker: kicker,
                headline: headlineText,
                supporting: day.summary ?? subject.sunSign.map { SignFlavor.supportingLine(for: $0) }
            ))
        ))

        // 2. Meter set — scores + entertainment, captions are mode-local.
        items.append(meterItem(day, rng: &rng))

        // 3. Flags from the record, reveal as the rotating alternative.
        if let flags = day.flags {
            items.append(FeedItem(
                id: "flags",
                kind: .flagPair(FlagPairContent(redFlag: flags.red, greenFlag: flags.green))
            ))
        } else {
            let secret = HumayContentEngine.revealSecret(rng: &rng)
            items.append(FeedItem(
                id: "reveal",
                kind: .reveal(RevealContent(
                    prompt: "Today's secret reading",
                    hint: "Hold to reveal",
                    secret: secret.secret,
                    followUp: secret.followUp
                ))
            ))
        }

        // 4. Cosmic weather (fact preserved; interpretation separate).
        if let weather = cosmicWeatherItem(event: skyEvent, rng: &rng) {
            items.append(weather)
        }

        // 5. Roast — pure expression, selected by mode locally (§9).
        let roast = HumayContentEngine.roastCopy(mode: mode, rng: &rng)
        items.append(FeedItem(
            id: "roast",
            kind: .roast(RoastContent(title: roast.title, body: roast.body))
        ))

        // 6. Forecast teaser from the personalized dataset every third day.
        if day.dayOffset.isMultiple(of: 3), let document {
            items.append(teaserItem(document, from: day.dayOffset))
        }

        return items
    }

    private static func meterItem(_ day: DailyMood, rng: inout SeededGenerator) -> FeedItem {
        let core: [FunMeter] = [
            FunMeter(
                metric: .confidence,
                value: day.scores[.confidence],
                caption: HumayContentEngine.meterCaption(for: .confidence, value: day.scores[.confidence])
            ),
            FunMeter(
                metric: .patience,
                value: day.scores[.patience],
                caption: HumayContentEngine.meterCaption(for: .patience, value: day.scores[.patience])
            ),
            FunMeter(
                metric: .chaos,
                value: day.scores[.chaos],
                caption: HumayContentEngine.meterCaption(for: .chaos, value: day.scores[.chaos])
            )
        ]

        var rotating: [FunMeter] = []
        if let entertainment = day.entertainment {
            rotating = [
                FunMeter(metric: .delusion, value: entertainment.delusion),
                FunMeter(metric: .mainCharacterEnergy, value: entertainment.mainCharacterEnergy),
                FunMeter(metric: .dontTextThem, value: entertainment.dontTextThem)
            ]
        } else {
            rotating = [
                FunMeter(metric: .socialBattery, value: day.scores[.social]),
                FunMeter(metric: .flirtingPotential, value: day.scores[.romance]),
                FunMeter(metric: .overthinking, value: 100 - day.scores[.patience])
            ]
        }

        let picked = Array(rotating.shuffled(using: &rng).prefix(2))
        let meters = (core + picked.map { meter in
            FunMeter(metric: meter.metric, value: meter.value, caption: HumayContentEngine.meterCaption(for: meter.metric, value: meter.value))
        }).shuffled(using: &rng)

        return FeedItem(
            id: "meters-\(day.dayOffset)",
            kind: .meterSet(MeterSetContent(title: "Today's energy", meters: Array(meters)))
        )
    }

    private static func teaserItem(_ document: PersonalizedForecastDocument, from offset: Int) -> FeedItem {
        let window = document.days.filter { $0.dayOffset >= offset && $0.dayOffset < offset + 30 }
        let anchor = document.anchor

        var entries: [ForecastTeaserContent.Entry] = []

        if let bestRomance = window.max(by: { $0.scores[.romance] < $1.scores[.romance] }) {
            entries.append(.init(
                dayOffset: bestRomance.dayOffset,
                label: "Best romance day",
                detail: anchor.date(forDayOffset: bestRomance.dayOffset)?.formatted(.dateTime.day().month(.wide)) ?? ""
            ))
        }
        if let peakChaos = window.max(by: { $0.scores[.chaos] < $1.scores[.chaos] }) {
            entries.append(.init(
                dayOffset: peakChaos.dayOffset,
                label: "Maximum chaos",
                detail: anchor.date(forDayOffset: peakChaos.dayOffset)?.formatted(.dateTime.day().month(.wide)) ?? ""
            ))
        }
        if let peakConfidence = window.max(by: { $0.scores[.confidence] < $1.scores[.confidence] }) {
            entries.append(.init(
                dayOffset: peakConfidence.dayOffset,
                label: "Strongest confidence",
                detail: anchor.date(forDayOffset: peakConfidence.dayOffset)?.formatted(.dateTime.day().month(.wide)) ?? ""
            ))
        }

        return FeedItem(
            id: "teaser",
            kind: .forecastTeaser(ForecastTeaserContent(title: "Next 30 days", entries: entries))
        )
    }

    private static func fallbackHeadline(_ day: DailyMood, rng: inout SeededGenerator) -> String {
        let shape = DeterministicContentProvider.DayShape(scores: day.scores)
        return shape.headlines.pick(using: &rng)!
    }

    private static func cosmicWeatherItem(
        event: CosmicEventSeed?,
        rng: inout SeededGenerator
    ) -> FeedItem? {
        if let event {
            return FeedItem(
                id: "weather-\(event.id)",
                kind: .cosmicWeather(CosmicWeatherContent(
                    headline: event.humanHeadline,
                    factLine: event.factLine,
                    skyEventID: event.id
                ))
            )
        }
        guard let line = GenericSkyLines.all.pick(using: &rng) else { return nil }
        return FeedItem(
            id: "weather-generic",
            kind: .cosmicWeather(CosmicWeatherContent(headline: line.0, factLine: line.1, skyEventID: nil))
        )
    }

    /// Day offset of `date` relative to the document anchor; without a document
    /// the offset is relative to today (engine path handles its own day keys).
    private static func anchorStart(_ document: PersonalizedForecastDocument?, _ calendar: Calendar) -> Date {
        guard let document else {
            return calendar.startOfDay(for: .now)
        }
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = calendar.timeZone
        return gregorian.date(from: DateComponents(
            year: document.anchor.startYear,
            month: document.anchor.startMonth,
            day: document.anchor.startDay
        )) ?? calendar.startOfDay(for: .now)
    }
}
