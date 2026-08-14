import Foundation
@testable import Humay

actor InMemoryUserStateStore: UserStateStore {
    private var state: UserStateSnapshot?
    private var failure: UserStatePersistenceError?

    init(state: UserStateSnapshot? = nil) {
        self.state = state
    }

    func load() async throws -> UserStateSnapshot? {
        if let failure {
            throw failure
        }
        return state
    }

    func save(_ state: UserStateSnapshot) async throws {
        if let failure {
            throw failure
        }
        self.state = state
    }

    func clear() async throws {
        if let failure {
            throw failure
        }
        state = nil
    }

    func setFailure(_ failure: UserStatePersistenceError?) {
        self.failure = failure
    }
}
