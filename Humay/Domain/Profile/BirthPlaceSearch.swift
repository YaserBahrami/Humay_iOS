import Foundation
import SwiftUI

private struct BirthPlaceSearchingKey: EnvironmentKey {
    static let defaultValue: any BirthPlaceSearching = InMemoryBirthPlaceSearchService()
}

extension EnvironmentValues {
    var birthPlaceSearching: any BirthPlaceSearching {
        get { self[BirthPlaceSearchingKey.self] }
        set { self[BirthPlaceSearchingKey.self] = newValue }
    }
}

/// Normalized result of a human birthplace search. Coordinates + IANA timezone are the
/// calculation identity; displayName is cosmetic provenance.
struct BirthPlaceSearchResult: Sendable, Hashable, Identifiable {
    let id: String
    /// "Tehran, Iran" or "Tehran · Tehran Province, Iran"
    let displayName: String
    /// Secondary label for disambiguation in the row subtitle.
    let secondaryLabel: String?
    let latitude: Double
    let longitude: Double
    let timeZoneIdentifier: String

    var birthPlace: BirthPlace {
        .known(name: displayName, latitude: latitude, longitude: longitude, timeZoneIdentifier: timeZoneIdentifier)
    }
}

enum BirthPlaceSearchError: Error, Sendable, Equatable {
    case networkUnavailable
    case noResults
    case missingTimeZone
    case invalidQuery
}

/// Small abstraction so SwiftUI never touches MapKit directly and tests can inject fixtures.
protocol BirthPlaceSearching: Sendable {
    func search(query: String) async throws -> [BirthPlaceSearchResult]
    /// Resolve a single result identifier to a fully resolved place if the initial
    /// search returned a lightweight completion without coordinates.
    /// Default implementation returns the result itself when already resolved.
    func resolve(_ result: BirthPlaceSearchResult) async throws -> BirthPlaceSearchResult
}

extension BirthPlaceSearching {
    func resolve(_ result: BirthPlaceSearchResult) async throws -> BirthPlaceSearchResult { result }
}

// MARK: - In-memory fixture for tests / previews

actor InMemoryBirthPlaceSearchService: BirthPlaceSearching {
    private let fixtures: [BirthPlaceSearchResult]

    init(fixtures: [BirthPlaceSearchResult] = InMemoryBirthPlaceSearchService.defaultFixtures) {
        self.fixtures = fixtures
    }

    static var defaultFixtures: [BirthPlaceSearchResult] {
        [
            BirthPlaceSearchResult(id: "tehran-ir", displayName: "Tehran, Iran", secondaryLabel: "Tehran Province, Iran", latitude: 35.6892, longitude: 51.3890, timeZoneIdentifier: "Asia/Tehran"),
            BirthPlaceSearchResult(id: "istanbul-tr", displayName: "Istanbul, Türkiye", secondaryLabel: "Türkiye", latitude: 41.0082, longitude: 28.9784, timeZoneIdentifier: "Europe/Istanbul"),
            BirthPlaceSearchResult(id: "london-gb", displayName: "London, United Kingdom", secondaryLabel: "England, United Kingdom", latitude: 51.5072, longitude: -0.1276, timeZoneIdentifier: "Europe/London"),
            BirthPlaceSearchResult(id: "zanjan-ir", displayName: "Zanjan, Iran", secondaryLabel: "Zanjan Province, Iran", latitude: 36.6736, longitude: 48.4787, timeZoneIdentifier: "Asia/Tehran"),
            BirthPlaceSearchResult(id: "newyork-us", displayName: "New York, United States", secondaryLabel: "New York, United States", latitude: 40.7128, longitude: -74.0060, timeZoneIdentifier: "America/New_York"),
            BirthPlaceSearchResult(id: "vancouver-ca", displayName: "Vancouver, Canada", secondaryLabel: "British Columbia, Canada", latitude: 49.2827, longitude: -123.1207, timeZoneIdentifier: "America/Vancouver"),
        ]
    }

    func search(query: String) async throws -> [BirthPlaceSearchResult] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard q.count >= 2 else { throw BirthPlaceSearchError.invalidQuery }
        let filtered = fixtures.filter {
            $0.displayName.lowercased().contains(q) || ($0.secondaryLabel?.lowercased().contains(q) ?? false)
        }
        guard !filtered.isEmpty else { throw BirthPlaceSearchError.noResults }
        return filtered
    }
}

// MARK: - Failing service for error-state previews

actor FailingBirthPlaceSearchService: BirthPlaceSearching {
    func search(query: String) async throws -> [BirthPlaceSearchResult] {
        throw BirthPlaceSearchError.networkUnavailable
    }
}
