import Testing
@testable import Humay

@Suite("Privacy-safe logging boundary")
struct HumayLogTests {
    @Test("Application events are finite and typed")
    func applicationEventsAreFiniteAndTyped() {
        let events: [HumayApplicationLogEvent] = HumayApplicationLogEvent.allCases

        #expect(events == [.durableStorageUnavailable])
    }

    @Test("Persistence events are finite and typed")
    func persistenceEventsAreFiniteAndTyped() {
        let events: [HumayPersistenceLogEvent] = HumayPersistenceLogEvent.allCases

        #expect(events == [
            .restoreFailed,
            .saveFailed,
            .clearFailed,
            .unsupportedSchema
        ])
    }

    @Test("Typed event entry points accept only finite operational events")
    func typedEventEntryPointsAcceptFiniteEvents() {
        HumayLog.application(.durableStorageUnavailable)
        HumayLog.persistence(.restoreFailed)
        HumayLog.persistence(.saveFailed)
        HumayLog.persistence(.clearFailed)
        HumayLog.persistence(.unsupportedSchema)
    }
}
