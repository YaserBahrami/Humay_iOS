import Foundation

/// Versioned, app-owned local persistence for the current user-state aggregate.
///
/// File IO is actor-isolated. The file is kept in Application Support and each save
/// uses Foundation's atomic write option. No persistence framework or UserDefaults is
/// involved.
actor FileUserStateStore: UserStateStore {
    private static let applicationDirectoryName = "Humay"
    private static let fileName = "user-state.json"
    private static let currentSchemaVersion = 2

    private let fileURL: URL

    init() throws {
        let fileManager = FileManager.default
        guard let applicationSupportURL = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            throw UserStatePersistenceError.unavailable
        }

        self.fileURL = applicationSupportURL
            .appendingPathComponent(Self.applicationDirectoryName, isDirectory: true)
            .appendingPathComponent(Self.fileName, isDirectory: false)
    }

    /// Test initializer for an isolated file location.
    init(fileURL: URL) {
        self.fileURL = fileURL
    }

    func load() async throws -> UserStateSnapshot? {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }

        let data: Data
        do {
            data = try Data(contentsOf: fileURL)
        } catch {
            throw UserStatePersistenceError.readFailed
        }

        let schemaVersion: Int
        do {
            schemaVersion = try JSONDecoder()
                .decode(SchemaVersionEnvelope.self, from: data)
                .schemaVersion
        } catch {
            throw UserStatePersistenceError.malformedPayload
        }

        switch schemaVersion {
        case Self.currentSchemaVersion:
            do {
                return try makeDecoder().decode(UserStateDocument.self, from: data).snapshot()
            } catch {
                throw UserStatePersistenceError.malformedPayload
            }

        case 1:
            // One-way migration from the Tone-era schema. Saved facts are preserved;
            // the old two-tone register maps onto the closest personality mode.
            do {
                let legacy = try makeDecoder().decode(LegacyUserStateDocument.self, from: data)
                return try legacy.migratedSnapshot()
            } catch let error as UserStatePersistenceError {
                throw error
            } catch {
                throw UserStatePersistenceError.malformedPayload
            }

        default:
            throw UserStatePersistenceError.unsupportedSchema(version: schemaVersion)
        }
    }

    func save(_ state: UserStateSnapshot) async throws {
        let document: UserStateDocument
        do {
            document = try UserStateDocument(snapshot: state)
        } catch let error as UserStatePersistenceError {
            throw error
        } catch {
            throw UserStatePersistenceError.invalidPayload
        }

        let data: Data
        do {
            data = try makeEncoder().encode(document)
        } catch {
            throw UserStatePersistenceError.writeFailed
        }

        let directoryURL = fileURL.deletingLastPathComponent()
        do {
            try FileManager.default.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true
            )
        } catch {
            throw UserStatePersistenceError.writeFailed
        }

        do {
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            throw UserStatePersistenceError.writeFailed
        }
    }

    func clear() async throws {
        let fileManager = FileManager.default
        var isDirectory = ObjCBool(false)
        guard fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDirectory) else {
            return
        }

        guard !isDirectory.boolValue else {
            throw UserStatePersistenceError.clearFailed
        }

        do {
            try fileManager.removeItem(at: fileURL)
        } catch {
            throw UserStatePersistenceError.clearFailed
        }
    }

    private func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }

    private func makeDecoder() -> JSONDecoder {
        JSONDecoder()
    }
}

/// Explicit failure store used only when the app cannot compose durable local storage.
/// It never pretends that user state is empty or durable.
actor UnavailableUserStateStore: UserStateStore {
    func load() async throws -> UserStateSnapshot? {
        throw UserStatePersistenceError.unavailable
    }

    func save(_: UserStateSnapshot) async throws {
        throw UserStatePersistenceError.unavailable
    }

    func clear() async throws {
        throw UserStatePersistenceError.unavailable
    }
}

private struct SchemaVersionEnvelope: Decodable {
    let schemaVersion: Int
}

/// Schema v2 document. Adds saved people and personality mode.
private struct UserStateDocument: Codable {
    let schemaVersion: Int
    let profile: ProfileRecord?
    let settings: SettingsRecord
    let people: [PersonRecord]

    init(snapshot: UserStateSnapshot) throws {
        schemaVersion = 2
        profile = try snapshot.profile.map(ProfileRecord.init)
        settings = try SettingsRecord(settings: snapshot.settings)
        people = try snapshot.people.map(PersonRecord.init)
    }

    func snapshot() throws -> UserStateSnapshot {
        UserStateSnapshot(
            profile: try profile.map { try $0.userProfile() },
            settings: try settings.appSettings(),
            people: try people.map { try $0.person() }
        )
    }
}

/// Schema v1 shape kept solely for migration.
private struct LegacyUserStateDocument: Decodable {
    struct LegacySettings: Decodable {
        let leadingTradition: String
        let tone: String
        let onboardingCompletedAt: TimeInterval?
    }

    let profile: ProfileRecord?
    let settings: LegacySettings

    func migratedSnapshot() throws -> UserStateSnapshot {
        guard let tradition = AstrologyTradition(rawValue: settings.leadingTradition),
              settings.onboardingCompletedAt.map({ $0.isFinite }) ?? true else {
            throw UserStatePersistenceError.invalidPayload
        }

        let mode: PersonalityMode = switch settings.tone {
        case "roast": .roast
        case "normal": .normal
        default: .normal
        }

        return UserStateSnapshot(
            profile: try profile.map { try $0.userProfile() },
            settings: AppSettings(
                leadingTradition: tradition,
                personalityMode: mode,
                onboardingCompletedAt: settings.onboardingCompletedAt.map(Date.init(timeIntervalSince1970:))
            ),
            people: []
        )
    }
}

private struct ProfileRecord: Codable {
    let id: UUID
    let displayName: String
    let birth: BirthDetailsRecord

    init(_ profile: UserProfile) throws {
        id = profile.id
        displayName = profile.displayName
        birth = try BirthDetailsRecord(profile.birth)
    }

    func userProfile() throws -> UserProfile {
        UserProfile(
            id: id,
            displayName: displayName,
            birth: try birth.birthDetails()
        )
    }
}

private struct PersonRecord: Codable {
    let id: UUID
    let name: String
    let relationshipKind: String
    let customLabel: String?
    let birth: BirthDetailsRecord

    init(_ person: ConnectionPerson) throws {
        id = person.id
        name = person.name
        relationshipKind = person.relationshipKind.rawValue
        customLabel = person.customLabel
        birth = try BirthDetailsRecord(person.birth)
    }

    func person() throws -> ConnectionPerson {
        guard let kind = RelationshipKind(rawValue: relationshipKind) else {
            throw UserStatePersistenceError.invalidPayload
        }
        return ConnectionPerson(
            id: id,
            name: name,
            relationshipKind: kind,
            customLabel: customLabel,
            birth: try birth.birthDetails()
        )
    }
}

private struct BirthDetailsRecord: Codable {
    let year: Int
    let month: Int
    let day: Int
    let time: BirthTimeRecord
    let place: BirthPlaceRecord

    init(_ birth: BirthDetails) throws {
        guard Self.isSupportedBirthDate(year: birth.year, month: birth.month, day: birth.day) else {
            throw UserStatePersistenceError.invalidPayload
        }

        year = birth.year
        month = birth.month
        day = birth.day
        time = try BirthTimeRecord(birth.time)
        place = try BirthPlaceRecord(birth.place)
    }

    func birthDetails() throws -> BirthDetails {
        guard Self.isSupportedBirthDate(year: year, month: month, day: day) else {
            throw UserStatePersistenceError.invalidPayload
        }

        return BirthDetails(
            year: year,
            month: month,
            day: day,
            time: try time.birthTime(),
            place: try place.birthPlace()
        )
    }

    private static func isSupportedBirthDate(year: Int, month: Int, day: Int) -> Bool {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .autoupdatingCurrent

        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = calendar.timeZone
        components.year = year
        components.month = month
        components.day = day

        guard let candidate = calendar.date(from: components) else {
            return false
        }

        let resolved = calendar.dateComponents([.year, .month, .day], from: candidate)
        guard resolved.year == year,
              resolved.month == month,
              resolved.day == day,
              let earliest = calendar.date(from: DateComponents(year: 1900, month: 1, day: 1)) else {
            return false
        }

        let todayComponents = calendar.dateComponents([.year, .month, .day], from: Date.now)
        guard let today = calendar.date(from: todayComponents) else {
            return false
        }

        return candidate >= earliest && candidate <= today
    }
}

private struct BirthTimeRecord: Codable {
    enum Kind: String, Codable {
        case exact
        case approximate
        case unknown
    }

    let kind: Kind
    let minutesFromMidnight: Int?
    let toleranceMinutes: Int?

    init(_ time: BirthTime) throws {
        switch time {
        case .exact(let minutes):
            guard Self.validMinutes(minutes) else {
                throw UserStatePersistenceError.invalidPayload
            }
            kind = .exact
            minutesFromMidnight = minutes
            toleranceMinutes = nil

        case .approximate(let minutes, let tolerance):
            guard Self.validMinutes(minutes), tolerance >= 0 else {
                throw UserStatePersistenceError.invalidPayload
            }
            kind = .approximate
            minutesFromMidnight = minutes
            toleranceMinutes = tolerance

        case .unknown:
            kind = .unknown
            minutesFromMidnight = nil
            toleranceMinutes = nil
        }
    }

    func birthTime() throws -> BirthTime {
        switch kind {
        case .exact:
            guard let minutesFromMidnight,
                  Self.validMinutes(minutesFromMidnight),
                  toleranceMinutes == nil else {
                throw UserStatePersistenceError.invalidPayload
            }
            return .exact(minutesFromMidnight: minutesFromMidnight)

        case .approximate:
            guard let minutesFromMidnight,
                  let toleranceMinutes,
                  Self.validMinutes(minutesFromMidnight),
                  toleranceMinutes >= 0 else {
                throw UserStatePersistenceError.invalidPayload
            }
            return .approximate(
                minutesFromMidnight: minutesFromMidnight,
                toleranceMinutes: toleranceMinutes
            )

        case .unknown:
            guard minutesFromMidnight == nil, toleranceMinutes == nil else {
                throw UserStatePersistenceError.invalidPayload
            }
            return .unknown
        }
    }

    private static func validMinutes(_ minutes: Int) -> Bool {
        (0...1_439).contains(minutes)
    }
}

private struct BirthPlaceRecord: Codable {
    enum Kind: String, Codable {
        case notProvided
        case known
    }

    let kind: Kind
    let name: String?
    let latitude: Double?
    let longitude: Double?
    let timeZoneIdentifier: String?

    init(_ place: BirthPlace) throws {
        switch place {
        case .notProvided:
            kind = .notProvided
            name = nil
            latitude = nil
            longitude = nil
            timeZoneIdentifier = nil

        case .known(let nameValue, let latitudeValue, let longitudeValue, let timeZone):
            guard Self.isValidKnownPlace(
                name: nameValue,
                latitude: latitudeValue,
                longitude: longitudeValue,
                timeZoneIdentifier: timeZone
            ) else {
                throw UserStatePersistenceError.invalidPayload
            }
            kind = .known
            name = nameValue
            latitude = latitudeValue
            longitude = longitudeValue
            timeZoneIdentifier = timeZone
        }
    }

    func birthPlace() throws -> BirthPlace {
        switch kind {
        case .notProvided:
            guard name == nil,
                  latitude == nil,
                  longitude == nil,
                  timeZoneIdentifier == nil else {
                throw UserStatePersistenceError.invalidPayload
            }
            return .notProvided

        case .known:
            guard let name,
                  let latitude,
                  let longitude,
                  let timeZoneIdentifier,
                  Self.isValidKnownPlace(
                    name: name,
                    latitude: latitude,
                    longitude: longitude,
                    timeZoneIdentifier: timeZoneIdentifier
                  ) else {
                throw UserStatePersistenceError.invalidPayload
            }
            return .known(
                name: name,
                latitude: latitude,
                longitude: longitude,
                timeZoneIdentifier: timeZoneIdentifier
            )
        }
    }

    private static func isValidKnownPlace(
        name: String,
        latitude: Double,
        longitude: Double,
        timeZoneIdentifier: String
    ) -> Bool {
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !normalizedName.isEmpty
            && latitude.isFinite
            && longitude.isFinite
            && (-90...90).contains(latitude)
            && (-180...180).contains(longitude)
            && TimeZone(identifier: timeZoneIdentifier) != nil
    }
}

private struct SettingsRecord: Codable {
    let leadingTradition: String
    let personalityMode: String
    let onboardingCompletedAt: TimeInterval?

    init(settings: AppSettings) throws {
        leadingTradition = settings.leadingTradition.rawValue
        personalityMode = settings.personalityMode.rawValue
        if let date = settings.onboardingCompletedAt {
            guard date.timeIntervalSince1970.isFinite else {
                throw UserStatePersistenceError.invalidPayload
            }
            onboardingCompletedAt = date.timeIntervalSince1970
        } else {
            onboardingCompletedAt = nil
        }
    }

    func appSettings() throws -> AppSettings {
        guard let leadingTradition = AstrologyTradition(rawValue: leadingTradition),
              let personalityMode = PersonalityMode(rawValue: personalityMode),
              onboardingCompletedAt.map({ $0.isFinite }) ?? true else {
            throw UserStatePersistenceError.invalidPayload
        }

        return AppSettings(
            leadingTradition: leadingTradition,
            personalityMode: personalityMode,
            onboardingCompletedAt: onboardingCompletedAt.map(Date.init(timeIntervalSince1970:))
        )
    }
}
