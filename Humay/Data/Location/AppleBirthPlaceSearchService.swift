import Foundation
import MapKit

extension MKLocalSearchCompletion: @unchecked @retroactive Sendable {}

/// Production adapter over Apple's native place search stack (MapKit).
/// Uses MKLocalSearchCompleter for lightweight autocomplete, then resolves once via MKLocalSearch.
/// No location permission is requested; this is a forward search for a historical birthplace.
actor AppleBirthPlaceSearchService: BirthPlaceSearching {

    private let completerService: BirthPlaceCompleterService
    private let resolver: BirthPlaceCompletionResolver

    init(completerService: BirthPlaceCompleterService = BirthPlaceCompleterService(),
         resolver: BirthPlaceCompletionResolver = BirthPlaceCompletionResolver()) {
        self.completerService = completerService
        self.resolver = resolver
    }

    // MARK: - BirthPlaceSearching

    func suggestions(for query: String) async throws -> [BirthPlaceSuggestion] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else { throw BirthPlaceSearchError.invalidQuery }
        do {
            let comps = try await completerService.completions(for: trimmed)
            guard !comps.isEmpty else { throw BirthPlaceSearchError.noResults }
            // Map MKLocalSearchCompletion-like data to lightweight suggestions.
            // Filter to prefer locality-ish results: completer already biases to .address
            return comps.map { BirthPlaceSuggestion(id: $0.id, title: $0.title, subtitle: $0.subtitle) }
        } catch let e as BirthPlaceSearchError {
            throw e
        } catch let error as NSError where error.domain == NSURLErrorDomain {
            throw BirthPlaceSearchError.networkUnavailable
        } catch {
            if (error as NSError).domain == MKErrorDomain {
                throw BirthPlaceSearchError.networkUnavailable
            }
            throw BirthPlaceSearchError.networkUnavailable
        }
    }

    func resolve(_ suggestion: BirthPlaceSuggestion) async throws -> BirthPlaceSearchResult {
        do {
            return try await resolver.resolve(suggestion: suggestion)
        } catch let e as BirthPlaceSearchError {
            throw e
        } catch let e as BirthPlaceMapItemNormalizer.NormalizationError {
            switch e {
            case .missingTimeZone: throw BirthPlaceSearchError.missingTimeZone
            case .invalidTimeZone: throw BirthPlaceSearchError.missingTimeZone
            case .invalidCoordinates: throw BirthPlaceSearchError.resolutionFailed
            }
        } catch let error as NSError where error.domain == NSURLErrorDomain {
            throw BirthPlaceSearchError.networkUnavailable
        } catch {
            if (error as NSError).domain == MKErrorDomain {
                // Distinguish noResults vs network via code inspection
                let code = (error as NSError).code
                if code == 8 { // MKError.placemarkNotFound approx — treat as resolutionFailed
                    throw BirthPlaceSearchError.resolutionFailed
                }
                throw BirthPlaceSearchError.networkUnavailable
            }
            throw BirthPlaceSearchError.resolutionFailed
        }
    }

    // Legacy search remains available via protocol extension bridge, but provide direct resolved-search for callers that still use it.
    func search(query: String) async throws -> [BirthPlaceSearchResult] {
        let sugs = try await suggestions(for: query)
        var results: [BirthPlaceSearchResult] = []
        for s in sugs.prefix(5) {
            if let r = try? await resolve(s) {
                results.append(r)
            }
        }
        guard !results.isEmpty else { throw BirthPlaceSearchError.missingTimeZone }
        return results
    }
}

// MARK: - Completer service (MainActor delegate wrapping)

struct CompleterItem: Sendable, Hashable {
    let id: String
    let title: String
    let subtitle: String?
}

/// Registry holding the last raw completions for resolver to use Request(completion:) on MainActor.
@MainActor
final class BirthPlaceCompletionRegistry {
    static let shared = BirthPlaceCompletionRegistry()
    private var map: [String: MKLocalSearchCompletion] = [:]
    func store(results: [MKLocalSearchCompletion]) {
        map.removeAll()
        for r in results {
            let id = "\(r.title)|\(r.subtitle)"
            map[id] = r
        }
    }
    func completion(for id: String) -> MKLocalSearchCompletion? { map[id] }
}

/// Wraps MKLocalSearchCompleter with latest-query wins, cancellation-aware async bridge.
final class BirthPlaceCompleterService: NSObject, @unchecked Sendable, MKLocalSearchCompleterDelegate {
    private var completer: MKLocalSearchCompleter?
    private var pending: CheckedContinuation<[CompleterItem], Error>?
    private let lock = NSLock()

    override init() { super.init() }

    func completions(for query: String) async throws -> [CompleterItem] {
        try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                self.startCompleter(query: query, continuation: continuation)
            }
        }
    }

    @MainActor
    private func startCompleter(query: String, continuation: CheckedContinuation<[CompleterItem], Error>) {
        if let prev = pending { prev.resume(throwing: CancellationError()) }
        pending = continuation
        if completer == nil {
            let c = MKLocalSearchCompleter()
            c.delegate = self
            c.resultTypes = [.address]
            c.regionPriority = .default
            completer = c
        }
        completer?.queryFragment = query
    }

    @MainActor
    private func completePending(with items: [CompleterItem]) {
        guard let cont = pending else { return }
        pending = nil
        cont.resume(returning: items)
    }

    @MainActor
    private func failPending(error: Error) {
        guard let cont = pending else { return }
        pending = nil
        cont.resume(throwing: error)
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let rawResults = completer.results
        // Registry store assumes main thread (MapKit delivers on main)
        MainActor.assumeIsolated {
            BirthPlaceCompletionRegistry.shared.store(results: rawResults)
        }
        let items: [CompleterItem] = rawResults.map { r in
            CompleterItem(id: "\(r.title)|\(r.subtitle)", title: r.title, subtitle: r.subtitle.isEmpty ? nil : r.subtitle)
        }
        var seen = Set<String>()
        var deduped: [CompleterItem] = []
        for it in items {
            let k = "\(it.title)|\(it.subtitle ?? "")"
            if seen.insert(k).inserted { deduped.append(it) }
            if deduped.count >= 8 { break }
        }
        Task { @MainActor in self.completePending(with: deduped) }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        Task { @MainActor in
            let ns = error as NSError
            if ns.domain == NSURLErrorDomain || ns.domain == MKErrorDomain {
                self.failPending(error: BirthPlaceSearchError.networkUnavailable)
            } else {
                self.failPending(error: BirthPlaceSearchError.networkUnavailable)
            }
        }
    }
}

// MARK: - Resolver: MKLocalSearch.Request(completion:) -> BirthPlaceSearchResult

final class BirthPlaceCompletionResolver: Sendable {
    func resolve(suggestion: BirthPlaceSuggestion) async throws -> BirthPlaceSearchResult {
        try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                self.resolveOnMain(suggestion: suggestion, continuation: continuation)
            }
        }
    }

    @MainActor
    private func resolveOnMain(suggestion: BirthPlaceSuggestion, continuation: CheckedContinuation<BirthPlaceSearchResult, Error>) {
        // Prefer the original MKLocalSearchCompletion when available for exact resolution.
        if let completion = BirthPlaceCompletionRegistry.shared.completion(for: suggestion.id) {
            let request = MKLocalSearch.Request(completion: completion)
            let search = MKLocalSearch(request: request)
            Task {
                do {
                    let response = try await search.start()
                    guard let item = response.mapItems.first else {
                        continuation.resume(throwing: BirthPlaceSearchError.resolutionFailed)
                        return
                    }
                    let tz = item.timeZone ?? item.placemark.timeZone
                    let tzID = tz?.identifier
                    let input = BirthPlaceMapItemNormalizer.Input(
                        name: item.name,
                        locality: item.placemark.locality,
                        administrativeArea: item.placemark.administrativeArea,
                        country: item.placemark.country,
                        title: item.placemark.title,
                        coordinateLatitude: item.placemark.coordinate.latitude,
                        coordinateLongitude: item.placemark.coordinate.longitude,
                        timeZoneIdentifier: tzID
                    )
                    do {
                        let result = try BirthPlaceMapItemNormalizer.normalize(input: input)
                        continuation.resume(returning: result)
                    } catch let ne as BirthPlaceMapItemNormalizer.NormalizationError {
                        switch ne {
                        case .missingTimeZone, .invalidTimeZone: continuation.resume(throwing: BirthPlaceSearchError.missingTimeZone)
                        case .invalidCoordinates: continuation.resume(throwing: BirthPlaceSearchError.resolutionFailed)
                        }
                    }
                } catch let ns as NSError where ns.domain == NSURLErrorDomain || ns.domain == MKErrorDomain {
                    continuation.resume(throwing: BirthPlaceSearchError.networkUnavailable)
                } catch {
                    continuation.resume(throwing: BirthPlaceSearchError.resolutionFailed)
                }
            }
            return
        }
        // Fallback: natural language query seeded from suggestion when original completion expired.
        let query: String
        if let sub = suggestion.subtitle, !sub.isEmpty {
            query = "\(suggestion.title), \(sub)"
        } else {
            query = suggestion.title
        }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = [.address, .pointOfInterest]
        let search = MKLocalSearch(request: request)
        Task {
            do {
                let response = try await search.start()
                guard let item = response.mapItems.first else {
                    continuation.resume(throwing: BirthPlaceSearchError.resolutionFailed)
                    return
                }
                // Prefer MKMapItem.timeZone, then placemark.timeZone as secondary.
                let tz = item.timeZone ?? item.placemark.timeZone
                let tzID = tz?.identifier
                let name = item.name
                let placemark = item.placemark
                let input = BirthPlaceMapItemNormalizer.Input(
                    name: name,
                    locality: placemark.locality,
                    administrativeArea: placemark.administrativeArea,
                    country: placemark.country,
                    title: placemark.title,
                    coordinateLatitude: placemark.coordinate.latitude,
                    coordinateLongitude: placemark.coordinate.longitude,
                    timeZoneIdentifier: tzID
                )
                do {
                    let result = try BirthPlaceMapItemNormalizer.normalize(input: input)
                    continuation.resume(returning: result)
                } catch let ne as BirthPlaceMapItemNormalizer.NormalizationError {
                    switch ne {
                    case .missingTimeZone, .invalidTimeZone: continuation.resume(throwing: BirthPlaceSearchError.missingTimeZone)
                    case .invalidCoordinates: continuation.resume(throwing: BirthPlaceSearchError.resolutionFailed)
                    }
                }
            } catch let ns as NSError where ns.domain == NSURLErrorDomain || ns.domain == MKErrorDomain {
                continuation.resume(throwing: BirthPlaceSearchError.networkUnavailable)
            } catch {
                continuation.resume(throwing: BirthPlaceSearchError.resolutionFailed)
            }
        }
    }
}
