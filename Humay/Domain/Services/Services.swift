import Foundation

/// Something a service could not do.
enum HumayServiceError: Error, Sendable, Equatable {
    /// No content exists for this input. Distinct from a failure — a Capricorn reading
    /// that was never written is a content gap, not an outage.
    case contentUnavailable(String)
    /// The request needs birth data the profile does not have.
    case insufficientBirthData(FactUnavailability)
    /// The underlying method is not signed off.
    case methodologyPending(methodID: String)
}

// MARK: - Services
//
// Unlike repositories, these are `async`. They are network-backed later, and declaring
// that now means the loading states in the interface are real rather than retrofitted.

/// Daily readings.
protocol HoroscopeService: Sendable {
    /// The sign-wide reading. True of everyone born under that sign, and labelled so.
    func generalReading(
        sign: WesternSign,
        date: DateComponents,
        tone: Tone
    ) async throws -> HoroscopeReading

    /// The reading derived from a chart and the current sky.
    func preciseReading(
        profile: UserProfile,
        date: DateComponents,
        tone: Tone
    ) async throws -> HoroscopeReading
}

/// Charts, in each system's own terms.
protocol ChartCalculationService: Sendable {
    /// What a birth date alone supports, across all three traditions.
    func signProfile(for birth: BirthDetails) async throws -> SignProfile

    /// A full chart in one system.
    func chart(for birth: BirthDetails, system: ChartSystem) async throws -> SystemChart

    /// One placement, opened on its own.
    func placementDetail(id: String, in chart: SystemChart) async throws -> PlacementDetail
}

/// Relationship readings.
protocol CompatibilityService: Sendable {
    func generalReading(
        _ first: WesternSign,
        _ second: WesternSign,
        tone: Tone
    ) async throws -> GeneralCompatibilityReading

    func preciseReading(
        user: UserProfile,
        person: CirclePerson,
        tone: Tone
    ) async throws -> PreciseCompatibilityReading

    /// Today, for the two of them — distinct from the longer-term compatibility view.
    func todayTogether(
        user: UserProfile,
        person: CirclePerson,
        date: DateComponents,
        tone: Tone
    ) async throws -> HoroscopeReading
}

/// The sky.
protocol SkyService: Sendable {
    /// `profile` is optional because "in the sky" is answerable without one.
    func snapshot(for date: DateComponents, profile: UserProfile?) async throws -> SkySnapshot
    func events(in month: DateComponents, profile: UserProfile?) async throws -> [SkyEvent]
    func event(id: String, profile: UserProfile?) async throws -> SkyEvent
}

/// Conversational interpretation.
///
/// `answer` takes the whole conversation rather than one question, so follow-ups are a
/// first-class parameter instead of something the caller has to splice together. This
/// is the shape a real interpretation provider needs, so replacing the mock does not
/// change the signature.
protocol AstrologyAssistantService: Sendable {
    func suggestedQuestions(
        for profile: UserProfile,
        date: DateComponents
    ) async throws -> [AskSuggestion]

    func answer(
        question: String,
        in conversation: AskConversation,
        profile: UserProfile,
        tone: Tone
    ) async throws -> AskMessage
}

/// Definitions for terms that belong to one system.
protocol GlossaryService: Sendable {
    func term(id: String) async throws -> GlossaryTerm
}
