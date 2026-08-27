import Foundation
import MapKit

/// Production adapter over Apple's native place search stack (MapKit).
/// No location permission is requested; this is a forward search for a historical birthplace.
/// No third-party SDK.
actor AppleBirthPlaceSearchService: BirthPlaceSearching {
    func search(query: String) async throws -> [BirthPlaceSearchResult] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else { throw BirthPlaceSearchError.invalidQuery }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = trimmed
        // Bias toward administrative areas and localities; don't require current location.
        request.resultTypes = [.address, .pointOfInterest]
        // Don't use region from user location — historical birthplace is unrelated.
        let search = MKLocalSearch(request: request)
        let response: MKLocalSearch.Response
        do {
            response = try await search.start()
        } catch let error as NSError where error.domain == NSURLErrorDomain {
            throw BirthPlaceSearchError.networkUnavailable
        } catch {
            // MapKit errors when offline often surface as MKError or generic NSError.
            // Surface as networkUnavailable rather than corrupting existing place.
            if (error as NSError).code == 2 || (error as NSError).domain == MKErrorDomain {
                throw BirthPlaceSearchError.networkUnavailable
            }
            throw BirthPlaceSearchError.networkUnavailable
        }

        let items = response.mapItems
        guard !items.isEmpty else { throw BirthPlaceSearchError.noResults }

        var results: [BirthPlaceSearchResult] = []
        results.reserveCapacity(items.count)
        for item in items.prefix(10) {
            let placemark = item.placemark
            let coordinate = placemark.coordinate
            guard coordinate.latitude.isFinite, coordinate.longitude.isFinite else { continue }
            // IANA timezone — required for astrology historical DST (§18). Do not silently accept missing.
            guard let tz = placemark.timeZone, let identifier = tz.identifier as String?, TimeZone(identifier: identifier) != nil else {
                continue
            }
            // Build human-readable display name: "City, Country" with region disambiguation.
            let displayName = formattedDisplayName(for: placemark, fallback: item.name)
            let secondary = secondaryLabel(for: placemark)
            // Use placemark title/name as fallback but prefer displayName.
            // Coordinates round-tripped via BirthPlaceSearchResult; timezone is IANA.
            let id = "\(coordinate.latitude),\(coordinate.longitude)|\(identifier)|\(displayName)"
            results.append(BirthPlaceSearchResult(
                id: id,
                displayName: displayName,
                secondaryLabel: secondary,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                timeZoneIdentifier: identifier
            ))
        }
        guard !results.isEmpty else {
            // All items lacked timezone — surface as missingTimeZone rather than silent guess.
            throw BirthPlaceSearchError.missingTimeZone
        }
        return results
    }

    private nonisolated func formattedDisplayName(for placemark: MKPlacemark, fallback: String?) -> String {
        // Prefer locality + country, with administrativeArea for disambiguation when relevant.
        let locality = placemark.locality
        let admin = placemark.administrativeArea
        let country = placemark.country
        if let locality, let country {
            // Avoid duplicate when locality == country or admin duplicates
            if let admin, admin != locality, admin != country {
                // Include province/region for duplicate city names (e.g., Springfield)
                return "\(locality), \(admin), \(country)"
            }
            return "\(locality), \(country)"
        }
        if let name = placemark.name, let country, name != country {
            return "\(name), \(country)"
        }
        return fallback ?? placemark.title ?? "Unknown place"
    }

    private nonisolated func secondaryLabel(for placemark: MKPlacemark) -> String? {
        let admin = placemark.administrativeArea
        let country = placemark.country
        switch (admin, country) {
        case let (a?, c?) where a != c: return "\(a), \(c)"
        case let (_, c?): return c
        case let (a?, _): return a
        default: return nil
        }
    }
}
