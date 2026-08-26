import Foundation

/// Transport boundary for a remote AI provider (§5, §36).
///
/// The iOS app never embeds provider secrets: production routes through the
/// Humay backend/Worker, which injects credentials server-side. The client only
/// knows an endpoint and how to obtain a short-lived auth header value.
protocol AITransport: Sendable {
    func send(_ request: AIRequest) async throws -> AIResponse
}

struct AIRequest: Sendable {
    let endpoint: URL
    let payload: Data
    let contentType: String
    let authorizationHeader: String?
}

struct AIResponse: Sendable {
    let data: Data
    let modelIdentifier: String?
    let usageUnits: Int
}

/// Endpoint configuration. `authorizationHeaderProvider` is a closure so no
/// credential value is ever stored in app source or defaults.
struct RemoteForecastEndpoint: Sendable {
    let url: URL
    let authorizationHeaderProvider: @Sendable () -> String?

    init(url: URL, authorizationHeaderProvider: @escaping @Sendable () -> String? = { nil }) {
        self.url = url
        self.authorizationHeaderProvider = authorizationHeaderProvider
    }
}

/// Transport used when no remote provider is configured. Fails with a typed,
/// recoverable error — never with fake content.
struct UnavailableAITransport: AITransport {
    func send(_ request: AIRequest) async throws -> AIResponse {
        throw GenerationError.providerUnavailable
    }
}

/// Remote AI implementation of the provider boundary.
///
/// Contract: structured output only (§12). Requests carry the versioned prompt
/// and the expected JSON shape; responses are validated through the same
/// `ForecastValidator` path as everything else before leaving this type.
///
/// With the default `UnavailableAITransport` this provider is inert — the app
/// remains fully functional on the deterministic provider (§5).
actor RemoteAIContentProvider: PersonalizedContentProviding {
    static let identifier = "remote-ai"

    private let endpoint: RemoteForecastEndpoint
    private let transport: any AITransport

    init(endpoint: RemoteForecastEndpoint, transport: any AITransport = UnavailableAITransport()) {
        self.endpoint = endpoint
        self.transport = transport
    }

    func generateYearOutline(
        subject: ForecastSubject,
        anchor: ForecastAnchor
    ) async throws -> GeneratedOutline {
        let bigThree = subject.bigThree()
        let contextJSON: String = {
            if let bt = bigThree {
                let source = bt.astrologyContextWithDegreesForAI.isEmpty ? bt.astrologyContextForAI : bt.astrologyContextWithDegreesForAI
                if let data = try? JSONSerialization.data(withJSONObject: source, options: [.sortedKeys]),
                   let s = String(data: data, encoding: .utf8) { return s }
                return "{}"
            }
            return "{\"sun\":\"\(subject.sunSign?.rawValue ?? "unavailable")\"}"
        }()
        let input = YearOutlineInput(
            startDateDescription: "\(anchor.startYear)-\(anchor.startMonth)-\(anchor.startDay)",
            sunSign: bigThree?.sunSign?.rawValue ?? subject.sunSign?.rawValue,
            moonSign: bigThree?.moonSign?.rawValue,
            risingSign: bigThree?.risingSign?.rawValue,
            astrologyContextJSON: contextJSON,
            archetypeName: HumayContentEngine.archetype(profileID: subject.id).name,
            birthTimeKnown: subject.birth.time.isKnown
        )
        let template = PromptCatalog.yearOutline

        let payload = try JSONEncoder().encode(RemoteRequestPayload(
            prompt: template.identifier.rawValue,
            request: template.build(input)
        ))
        let response = try await send(payload)

        do {
            let decoded = try JSONDecoder().decode(RemoteOutlinePayload.self, from: response.data)
            let context = try YearContext(
                yearTheme: decoded.yearTheme,
                monthlyThemes: decoded.monthlyThemes.map {
                    MonthlyTheme(monthIndex: $0.monthIndex, theme: $0.theme, tendency: $0.tendency)
                },
                notablePeriods: decoded.notablePeriods.map {
                    NotablePeriod(
                        startDayOffset: $0.startDayOffset,
                        endDayOffset: $0.endDayOffset,
                        label: $0.label,
                        kind: NotablePeriod.Kind(rawValue: $0.kind) ?? .calm
                    )
                }
            )
            return GeneratedOutline(
                context: context,
                usage: GenerationUsage(usageUnits: response.usageUnits),
                modelIdentifier: response.modelIdentifier
            )
        } catch let error as ForecastValidationError {
            throw GenerationError.validationFailed(error)
        } catch {
            throw GenerationError.malformedOutput(detail: "outline decode failed")
        }
    }

    func generateMonthChunk(
        subject: ForecastSubject,
        outline: YearContext,
        anchor: ForecastAnchor,
        monthIndex: Int
    ) async throws -> GeneratedMonth {
        let offsets = anchor.dayOffsets(inMonthIndex: monthIndex, totalDays: YearlyForecast.dayCount)
        guard let start = offsets.first, let end = offsets.last else {
            throw GenerationError.validationFailed(.invalidMonthIndex(monthIndex))
        }
        let monthTheme = outline.monthlyThemes.first { $0.monthIndex == monthIndex }

        let input = MonthChunkInput(
            monthIndex: monthIndex,
            startDayOffset: start,
            endDayOffset: end,
            dayCount: offsets.count,
            yearTheme: outline.yearTheme,
            monthTheme: monthTheme?.theme ?? "Transit season",
            monthTendency: monthTheme?.tendency ?? "Leans steady.",
            notablePeriodsSummary: outline.notablePeriods.map { "\($0.label) (days \($0.startDayOffset)–\($0.endDayOffset))" }.joined(separator: "; ")
        )
        let template = PromptCatalog.monthChunk

        let payload = try JSONEncoder().encode(RemoteRequestPayload(
            prompt: template.identifier.rawValue,
            request: template.build(input)
        ))
        let response = try await send(payload)

        do {
            let decoded = try JSONDecoder().decode(RemoteMonthPayload.self, from: response.data)
            let days = try decoded.days.map { try Self.day(from: $0) }
            return GeneratedMonth(
                days: days,
                usage: GenerationUsage(usageUnits: response.usageUnits),
                modelIdentifier: response.modelIdentifier
            )
        } catch let error as GenerationError {
            throw error
        } catch let error as ForecastValidationError {
            throw GenerationError.validationFailed(error)
        } catch {
            throw GenerationError.malformedOutput(detail: "month chunk decode failed")
        }
    }

    func regenerateDay(
        subject: ForecastSubject,
        outline: YearContext,
        anchor: ForecastAnchor,
        dayOffset: Int
    ) async throws -> DailyMood {
        let monthIndex = anchorMonthIndex(forDayOffset: dayOffset, anchor: anchor)
        let monthTheme = outline.monthlyThemes.first { $0.monthIndex == monthIndex }

        let input = MonthChunkInput(
            monthIndex: monthIndex,
            startDayOffset: dayOffset,
            endDayOffset: dayOffset,
            dayCount: 1,
            yearTheme: outline.yearTheme,
            monthTheme: monthTheme?.theme ?? "Transit season",
            monthTendency: monthTheme?.tendency ?? "Leans steady.",
            notablePeriodsSummary: "n/a"
        )
        let template = PromptCatalog.dayRegeneration

        let payload = try JSONEncoder().encode(RemoteRequestPayload(
            prompt: template.identifier.rawValue,
            request: template.build(input)
        ))
        let response = try await send(payload)

        do {
            let decoded = try JSONDecoder().decode(RemoteMonthPayload.self, from: response.data)
            guard let raw = decoded.days.first else {
                throw GenerationError.malformedOutput(detail: "day regeneration returned no day")
            }
            return try Self.day(from: raw, dayOffset: dayOffset)
        } catch let error as GenerationError {
            throw error
        } catch let error as ForecastValidationError {
            throw GenerationError.validationFailed(error)
        } catch {
            throw GenerationError.malformedOutput(detail: "day decode failed")
        }
    }

    // MARK: - Wire shapes

    private struct RemoteRequestPayload: Encodable {
        let prompt: String
        let request: String
    }

    struct RemoteOutlinePayload: Decodable {
        let yearTheme: String
        let monthlyThemes: [RemoteMonthlyTheme]
        let notablePeriods: [RemoteNotablePeriod]
    }

    struct RemoteMonthlyTheme: Decodable {
        let monthIndex: Int
        let theme: String
        let tendency: String
    }

    struct RemoteNotablePeriod: Decodable {
        let startDayOffset: Int
        let endDayOffset: Int
        let label: String
        let kind: String
    }

    struct RemoteMonthPayload: Decodable {
        let days: [RemoteDay]
    }

    struct RemoteDay: Decodable {
        let dayOffset: Int
        let scores: [String: Int]
        let entertainment: RemoteEntertainment
        let reading: RemoteReading
        let flags: RemoteFlags
        let summary: String?
        let note: String?
    }

    struct RemoteEntertainment: Decodable {
        let delusion: Int
        let mainCharacterEnergy: Int
        let dontTextThem: Int
    }

    struct RemoteReading: Decodable {
        let headline: String
        let personal: String
        let love: String
        let career: String
        let social: String
    }

    struct RemoteFlags: Decodable {
        let green: String
        let red: String
    }

    /// Raw wire value → validated domain day. The single gate every remote day
    /// passes through (§11, §12).
    static func day(from raw: RemoteDay, dayOffset expected: Int? = nil) throws -> DailyMood {
        if let expected, raw.dayOffset != expected {
            throw GenerationError.malformedOutput(detail: "unexpected day offset \(raw.dayOffset), expected \(expected)")
        }

        var scoreValues: [MoodDimension: Int] = [:]
        for dimension in MoodDimension.allCases {
            scoreValues[dimension] = raw.scores[dimension.rawValue]
        }
        let scores = try MoodScores(validating: scoreValues)

        let entertainment = try EntertainmentMetrics(
            delusion: raw.entertainment.delusion,
            mainCharacterEnergy: raw.entertainment.mainCharacterEnergy,
            dontTextThem: raw.entertainment.dontTextThem
        )

        let reading = try DayReading(
            headline: raw.reading.headline,
            sections: [
                DayReadingSection(category: .personal, text: raw.reading.personal),
                DayReadingSection(category: .love, text: raw.reading.love),
                DayReadingSection(category: .career, text: raw.reading.career),
                DayReadingSection(category: .social, text: raw.reading.social)
            ]
        )

        let flags = try DayFlags(green: raw.flags.green, red: raw.flags.red)

        return DailyMood(
            dayOffset: raw.dayOffset,
            scores: scores,
            note: raw.note,
            reading: reading,
            entertainment: entertainment,
            flags: flags,
            summary: raw.summary
        )
    }

    private func anchorMonthIndex(forDayOffset offset: Int, anchor: ForecastAnchor) -> Int {
        for index in 0..<12 {
            let offsets = anchor.dayOffsets(inMonthIndex: index, totalDays: YearlyForecast.dayCount)
            if let first = offsets.first, let last = offsets.last, offset >= first, offset <= last {
                return index
            }
        }
        return 0
    }

    private func send(_ payload: Data) async throws -> AIResponse {
        let request = AIRequest(
            endpoint: endpoint.url,
            payload: payload,
            contentType: "application/json",
            authorizationHeader: endpoint.authorizationHeaderProvider()
        )
        do {
            return try await transport.send(request)
        } catch let error as GenerationError {
            throw error
        } catch is CancellationError {
            throw GenerationError.cancelled
        } catch let error as URLError
        where error.code == .notConnectedToInternet || error.code == .timedOut || error.code == .networkConnectionLost {
            throw GenerationError.networkUnavailable
        } catch {
            throw GenerationError.serverError(status: 0)
        }
    }
}
