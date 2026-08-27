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

/// Lightweight suggestion shown while typing — no coordinates, just display titles.
struct BirthPlaceSuggestion: Sendable, Hashable, Identifiable {
    let id: String
    let title: String
    let subtitle: String?

    init(id: String, title: String, subtitle: String? = nil) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
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
    case resolutionFailed
}

/// Explicit two-stage contract for birthplace search.
protocol BirthPlaceSearching: Sendable {
    /// Lightweight autocomplete suggestions while typing — no geocoding.
    func suggestions(for query: String) async throws -> [BirthPlaceSuggestion]
    /// Resolve a single selected suggestion to a fully canonized result with coordinates + IANA tz.
    func resolve(_ suggestion: BirthPlaceSuggestion) async throws -> BirthPlaceSearchResult

    /// Legacy single-stage search — kept for backward compatibility where providers already return resolved results.
    /// Default implementation bridges via suggestions→resolve where possible.
    func search(query: String) async throws -> [BirthPlaceSearchResult]
}

extension BirthPlaceSearching {
    func search(query: String) async throws -> [BirthPlaceSearchResult] {
        let sugs = try await suggestions(for: query)
        var results: [BirthPlaceSearchResult] = []
        for sug in sugs {
            if let r = try? await resolve(sug) {
                results.append(r)
            }
        }
        guard !results.isEmpty else { throw BirthPlaceSearchError.noResults }
        return results
    }
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

    func suggestions(for query: String) async throws -> [BirthPlaceSuggestion] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard q.count >= 2 else { throw BirthPlaceSearchError.invalidQuery }
        let filtered = fixtures.filter {
            $0.displayName.lowercased().contains(q) || ($0.secondaryLabel?.lowercased().contains(q) ?? false)
        }
        guard !filtered.isEmpty else { throw BirthPlaceSearchError.noResults }
        return filtered.map { BirthPlaceSuggestion(id: $0.id, title: $0.displayName, subtitle: $0.secondaryLabel) }
    }

    func resolve(_ suggestion: BirthPlaceSuggestion) async throws -> BirthPlaceSearchResult {
        guard let match = fixtures.first(where: { $0.id == suggestion.id }) else {
            throw BirthPlaceSearchError.resolutionFailed
        }
        return match
    }

    // Fast legacy search path for two-stage compat
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
    func suggestions(for query: String) async throws -> [BirthPlaceSuggestion] {
        throw BirthPlaceSearchError.networkUnavailable
    }
    func resolve(_ suggestion: BirthPlaceSuggestion) async throws -> BirthPlaceSearchResult {
        throw BirthPlaceSearchError.networkUnavailable
    }
    func search(query: String) async throws -> [BirthPlaceSearchResult] {
        throw BirthPlaceSearchError.networkUnavailable
    }
}

// MARK: - Pure normalizer: MapKit-agnostic conversion (testable)

struct BirthPlaceMapItemNormalizer {
    struct Input: Sendable, Hashable {
        let name: String?
        let locality: String?
        let administrativeArea: String?
        let country: String?
        let title: String?
        let coordinateLatitude: Double
        let coordinateLongitude: Double
        let timeZoneIdentifier: String?
    }

    enum NormalizationError: Error, Equatable, Sendable {
        case missingTimeZone
        case invalidTimeZone(String)
        case invalidCoordinates
    }

    static func normalize(input: Input) throws -> BirthPlaceSearchResult {
        guard input.coordinateLatitude.isFinite, input.coordinateLongitude.isFinite,
              (-90...90).contains(input.coordinateLatitude),
              (-180...180).contains(input.coordinateLongitude) else {
            throw NormalizationError.invalidCoordinates
        }
        guard let tzID = input.timeZoneIdentifier, !tzID.isEmpty else {
            throw NormalizationError.missingTimeZone
        }
        guard TimeZone(identifier: tzID) != nil else {
            throw NormalizationError.invalidTimeZone(tzID)
        }
        let displayName = formattedDisplayName(locality: input.locality, administrativeArea: input.administrativeArea, country: input.country, name: input.name, title: input.title)
        let secondary = secondaryLabel(administrativeArea: input.administrativeArea, country: input.country)
        let id = "\(input.coordinateLatitude),\(input.coordinateLongitude)|\(tzID)|\(displayName)"
        return BirthPlaceSearchResult(id: id, displayName: displayName, secondaryLabel: secondary, latitude: input.coordinateLatitude, longitude: input.coordinateLongitude, timeZoneIdentifier: tzID)
    }

    private static func formattedDisplayName(locality: String?, administrativeArea: String?, country: String?, name: String?, title: String?) -> String {
        if let locality, let country {
            if let admin = administrativeArea, admin != locality, admin != country {
                return "\(locality), \(admin), \(country)"
            }
            return "\(locality), \(country)"
        }
        if let name, let country, name != country {
            return "\(name), \(country)"
        }
        return title ?? name ?? "Unknown place"
    }

    private static func secondaryLabel(administrativeArea: String?, country: String?) -> String? {
        switch (administrativeArea, country) {
        case let (a?, c?) where a != c: return "\(a), \(c)"
        case let (_, c?): return c
        case let (a?, _): return a
        default: return nil
        }
    }
}
