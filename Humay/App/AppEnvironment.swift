import Foundation
import Observation

/// Where the application's content comes from.
///
/// Only `.mock` has an implementation today. The case is explicit so that anything
/// reading it has to acknowledge the distinction rather than assume.
enum ContentMode: Sendable {
    /// Illustrative fixture content. Nothing is calculated. See `DEVIATIONS.md` DEV-001.
    case mock
    /// Humay-owned catalog and calculation services.
    case live
}

/// The composition root.
///
/// Every dependency is held as a protocol existential, so no view names a concrete
/// repository or service. `AppEnvironment+Live` is the only file that knows which
/// implementations are in use; swapping the mocks for real services is a change to that
/// one file.
@Observable
@MainActor
final class AppEnvironment {
    let contentMode: ContentMode

    let profileRepository: any UserProfileRepository
    let settingsRepository: any AppSettingsRepository
    let personRepository: any CirclePersonRepository
    let askRepository: any AskConversationRepository

    let horoscopeService: any HoroscopeService
    let chartService: any ChartCalculationService
    let compatibilityService: any CompatibilityService
    let skyService: any SkyService
    let assistantService: any AstrologyAssistantService
    let glossaryService: any GlossaryService

    /// The live application state that more than one screen needs to agree about.
    private(set) var profile: UserProfile?
    private(set) var settings: AppSettings
    private(set) var people: [CirclePerson] = []

    init(
        contentMode: ContentMode,
        profileRepository: any UserProfileRepository,
        settingsRepository: any AppSettingsRepository,
        personRepository: any CirclePersonRepository,
        askRepository: any AskConversationRepository,
        horoscopeService: any HoroscopeService,
        chartService: any ChartCalculationService,
        compatibilityService: any CompatibilityService,
        skyService: any SkyService,
        assistantService: any AstrologyAssistantService,
        glossaryService: any GlossaryService
    ) {
        self.contentMode = contentMode
        self.profileRepository = profileRepository
        self.settingsRepository = settingsRepository
        self.personRepository = personRepository
        self.askRepository = askRepository
        self.horoscopeService = horoscopeService
        self.chartService = chartService
        self.compatibilityService = compatibilityService
        self.skyService = skyService
        self.assistantService = assistantService
        self.glossaryService = glossaryService

        settings = (try? settingsRepository.load()) ?? .default
        profile = try? profileRepository.load()
        people = (try? personRepository.loadAll()) ?? []
    }

    // MARK: - Derived state

    var hasCompletedOnboarding: Bool { settings.hasCompletedOnboarding && profile != nil }

    /// The Sun sign the general content is keyed on.
    ///
    /// Nil until there is a birth date, so a screen cannot render a reading for someone
    /// who has not told us when they were born.
    var sunSign: WesternSign? {
        profile.map { MockAstrology.sunSign(for: $0.birth) }
    }

    var supportsPrecision: Bool {
        profile?.birth.supportsPrecision ?? false
    }

    // MARK: - Mutations
    //
    // Every write goes through here so the in-memory copy and the store cannot drift.

    func updateProfile(_ profile: UserProfile) {
        self.profile = profile
        persist { try profileRepository.save(profile) }
    }

    func updateSettings(_ settings: AppSettings) {
        self.settings = settings
        persist { try settingsRepository.save(settings) }
    }

    func completeOnboarding(profile: UserProfile, tradition: AstrologyTradition) {
        var updated = settings
        updated.leadingTradition = tradition
        updated.onboardingCompletedAt = .now
        updateProfile(profile)
        updateSettings(updated)
        seedCircleIfEmpty()
    }

    func savePerson(_ person: CirclePerson) {
        if let index = people.firstIndex(where: { $0.id == person.id }) {
            people[index] = person
        } else {
            people.append(person)
        }
        persist { try personRepository.save(person) }
    }

    func deletePerson(id: UUID) {
        people.removeAll { $0.id == id }
        persist { try personRepository.delete(id: id) }
    }

    /// Removes birth data and readings, keeping preferences.
    func deleteAstrologyData() {
        profile = nil
        people = []
        persist {
            try profileRepository.delete()
            try personRepository.deleteAll()
            try askRepository.deleteAll()
        }
    }

    /// Removes everything, returning the app to a first-launch state.
    func deleteAllData() {
        profile = nil
        people = []
        settings = .default
        persist {
            try profileRepository.delete()
            try personRepository.deleteAll()
            try askRepository.deleteAll()
            try settingsRepository.save(.default)
        }
    }

    private func seedCircleIfEmpty() {
        guard people.isEmpty else { return }
        for person in SeedCircleFixtures.people {
            savePerson(person)
        }
    }

    /// Persistence failures are logged and swallowed.
    ///
    /// Losing a write to a local store is worth knowing about, but it is not worth
    /// interrupting someone mid-flow with an alert they cannot act on. The in-memory
    /// state remains correct for the session either way.
    private func persist(_ work: () throws -> Void) {
        do {
            try work()
        } catch {
            HumayLog.persistenceFailure("Write failed: \(error)")
        }
    }
}
