import Foundation
import Testing
@testable import Humay

@Suite("Local user-state persistence")
struct PersistenceTests {
    @Test("Missing file means no persisted state")
    func missingFileIsNotAnError() async throws {
        let fixture = try TemporaryStoreFixture()
        defer { fixture.remove() }

        let store = FileUserStateStore(fileURL: fixture.fileURL)

        let state = try await store.load()
        #expect(state == nil)
    }

    @Test("Save and load roundtrip preserves profile and settings")
    func saveLoadRoundtrip() async throws {
        let fixture = try TemporaryStoreFixture()
        defer { fixture.remove() }

        let id = UUID(uuidString: "D7E4E5C6-0D6F-4D66-9C4B-4B9C6B4F7F2A")!
        let timestamp = Date(timeIntervalSince1970: 1_754_000_123.25)
        let profile = UserProfile(
            id: id,
            displayName: "",
            birth: BirthDetails(year: 1994, month: 3, day: 14)
        )
        let settings = AppSettings(
            leadingTradition: .chinese,
            tone: .roast,
            onboardingCompletedAt: timestamp
        )
        let expected = UserStateSnapshot(profile: profile, settings: settings)
        let store = FileUserStateStore(fileURL: fixture.fileURL)

        try await store.save(expected)
        let restored = try #require(await store.load())

        #expect(restored.profile?.id == id)
        #expect(restored.profile?.birth.year == 1994)
        #expect(restored.profile?.birth.month == 3)
        #expect(restored.profile?.birth.day == 14)
        #expect(restored.profile?.birth.time == .unknown)
        #expect(restored.profile?.birth.place == .notProvided)
        #expect(restored.settings.leadingTradition == .chinese)
        #expect(restored.settings.tone == .roast)
        #expect(restored.settings.onboardingCompletedAt == timestamp)
    }

    @Test("Version 1 snapshot loads with stable enum values")
    func supportedSchemaVersionLoads() async throws {
        let fixture = try TemporaryStoreFixture()
        defer { fixture.remove() }

        try write(
            """
            {"schemaVersion":1,"profile":null,"settings":{"leadingTradition":"vedic","onboardingCompletedAt":null,"tone":"normal"}}
            """,
            to: fixture.fileURL
        )

        let store = FileUserStateStore(fileURL: fixture.fileURL)
        let restored = try #require(await store.load())

        #expect(restored.profile == nil)
        #expect(restored.settings.leadingTradition == .vedic)
        #expect(restored.settings.tone == .normal)
        #expect(restored.settings.onboardingCompletedAt == nil)
    }

    @Test("Unsupported schema version fails explicitly")
    func unsupportedSchemaVersionFails() async throws {
        let fixture = try TemporaryStoreFixture()
        defer { fixture.remove() }

        try write("{\"schemaVersion\":99}", to: fixture.fileURL)
        let store = FileUserStateStore(fileURL: fixture.fileURL)

        do {
            _ = try await store.load()
            Issue.record("Expected unsupported schema failure")
        } catch let error as UserStatePersistenceError {
            #expect(error == .unsupportedSchema(version: 99))
        } catch {
            Issue.record("Unexpected persistence error")
        }
    }

    @Test("Malformed payload fails explicitly")
    func malformedPayloadFails() async throws {
        let fixture = try TemporaryStoreFixture()
        defer { fixture.remove() }

        try write("not-json", to: fixture.fileURL)
        let store = FileUserStateStore(fileURL: fixture.fileURL)

        do {
            _ = try await store.load()
            Issue.record("Expected malformed payload failure")
        } catch let error as UserStatePersistenceError {
            #expect(error == .malformedPayload)
        } catch {
            Issue.record("Unexpected persistence error")
        }
    }

    @Test("Write failure is surfaced")
    func writeFailureIsSurfaced() async throws {
        let fixture = try TemporaryStoreFixture()
        defer { fixture.remove() }

        let blockingPath = fixture.directory.appendingPathComponent("blocked")
        try Data("not-a-directory".utf8).write(to: blockingPath)
        let store = FileUserStateStore(
            fileURL: blockingPath.appendingPathComponent("user-state.json")
        )

        do {
            try await store.save(
                UserStateSnapshot(
                    profile: nil,
                    settings: .default
                )
            )
            Issue.record("Expected directory creation failure")
        } catch let error as UserStatePersistenceError {
            #expect(error == .directoryCreationFailed)
        } catch {
            Issue.record("Unexpected persistence error")
        }
    }

    @Test("Clear removes durable state")
    func clearRemovesDurableState() async throws {
        let fixture = try TemporaryStoreFixture()
        defer { fixture.remove() }

        let store = FileUserStateStore(fileURL: fixture.fileURL)
        try await store.save(
            UserStateSnapshot(
                profile: nil,
                settings: .default
            )
        )
        #expect(FileManager.default.fileExists(atPath: fixture.fileURL.path))

        try await store.clear()

        #expect(!FileManager.default.fileExists(atPath: fixture.fileURL.path))
        #expect(try await store.load() == nil)
    }

    @Test("Save failure does not create volatile completion")
    @MainActor
    func saveFailureDoesNotCreateVolatileCompletion() async throws {
        let store = InMemoryUserStateStore()
        let environment = AppEnvironment(store: store)
        await environment.restore()
        await store.setFailure(.writeFailed)

        let profile = UserProfile(
            displayName: "",
            birth: BirthDetails(year: 1994, month: 3, day: 14)
        )

        do {
            try await environment.completeOnboarding(
                profile: profile,
                tradition: .western
            )
            Issue.record("Expected save failure")
        } catch let error as UserStatePersistenceError {
            #expect(error == .writeFailed)
        } catch {
            Issue.record("Unexpected completion error")
        }

        #expect(environment.profile == nil)
        #expect(!environment.hasCompletedOnboarding)
        #expect(environment.restorationState == .ready)
    }

    @Test("Restore failure is distinct from fresh onboarding")
    @MainActor
    func restoreFailureIsDistinctFromFreshOnboarding() async {
        let store = InMemoryUserStateStore()
        await store.setFailure(.readFailed)
        let environment = AppEnvironment(store: store)

        await environment.restore()

        let navigation = AppNavigationState(environment: environment)
        #expect(environment.restorationState == .failed)
        #expect(navigation.root == .persistenceFailure)
    }

    @Test("Valid incomplete state restores exactly and stays in onboarding")
    @MainActor
    func incompleteStateRestoresExactly() async throws {
        let store = InMemoryUserStateStore()
        let expectedSettings = AppSettings(
            leadingTradition: .vedic,
            tone: .roast,
            onboardingCompletedAt: nil
        )
        try await store.save(
            UserStateSnapshot(
                profile: nil,
                settings: expectedSettings
            )
        )

        let environment = AppEnvironment(store: store)
        await environment.restore()
        let navigation = AppNavigationState(environment: environment)

        #expect(environment.profile == nil)
        #expect(environment.settings == expectedSettings)
        #expect(navigation.root == .onboarding)
    }

    @Test("Development reset clears state used by a subsequent restore")
    @MainActor
    func developmentResetClearsStateForSubsequentRestore() async throws {
        let store = InMemoryUserStateStore()
        let environment = AppEnvironment(store: store)
        await environment.restore()

        let profile = UserProfile(
            displayName: "",
            birth: BirthDetails(year: 1994, month: 3, day: 14)
        )
        try await environment.completeOnboarding(
            profile: profile,
            tradition: .western
        )
        #expect(environment.hasCompletedOnboarding)

        try await environment.resetForDevelopment()

        let restoredEnvironment = AppEnvironment(store: store)
        await restoredEnvironment.restore()
        let navigation = AppNavigationState(environment: restoredEnvironment)

        #expect(restoredEnvironment.profile == nil)
        #expect(!restoredEnvironment.settings.hasCompletedOnboarding)
        #expect(navigation.root == .onboarding)
    }

    private func write(_ string: String, to url: URL) throws {
        try Data(string.utf8).write(to: url, options: [.atomic])
    }
}

private struct TemporaryStoreFixture {
    let directory: URL
    let fileURL: URL

    init() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("HumayPersistenceTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
        self.directory = directory
        self.fileURL = directory.appendingPathComponent("user-state.json")
    }

    func remove() {
        try? FileManager.default.removeItem(at: directory)
    }
}
