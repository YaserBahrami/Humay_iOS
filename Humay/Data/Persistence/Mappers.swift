import Foundation

/// Translation between stored entities and domain values.
///
/// Pure functions, so they are testable without a store. This is also the only place
/// that knows the storage encoding of `BirthTime` and `BirthPlace`, which is what keeps
/// the "no substituted midnight" rule enforceable in one readable spot.
enum BirthMapper {
    struct StoredBirth {
        var year: Int
        var month: Int
        var day: Int
        var timeKind: String
        var timeMinutes: Int?
        var timeTolerance: Int?
        var placeName: String?
        var latitude: Double?
        var longitude: Double?
        var timeZoneIdentifier: String?
    }

    static func toDomain(_ stored: StoredBirth) -> BirthDetails {
        BirthDetails(
            year: stored.year,
            month: stored.month,
            day: stored.day,
            time: time(from: stored),
            place: place(from: stored)
        )
    }

    private static func time(from stored: StoredBirth) -> BirthTime {
        // The discriminator decides, never the presence of a value. A stored zero is a
        // legitimate midnight birth; the absence of a *kind* is what means unknown.
        switch BirthTimeKind(rawValue: stored.timeKind) {
        case .exact:
            guard let minutes = stored.timeMinutes else { return .unknown }
            return .exact(minutesFromMidnight: minutes)
        case .approximate:
            guard let minutes = stored.timeMinutes else { return .unknown }
            return .approximate(
                minutesFromMidnight: minutes,
                toleranceMinutes: stored.timeTolerance ?? 0
            )
        case .unknown, nil:
            return .unknown
        }
    }

    private static func place(from stored: StoredBirth) -> BirthPlace {
        guard
            let name = stored.placeName,
            let latitude = stored.latitude,
            let longitude = stored.longitude,
            let timeZone = stored.timeZoneIdentifier
        else { return .notProvided }
        return .known(
            name: name,
            latitude: latitude,
            longitude: longitude,
            timeZoneIdentifier: timeZone
        )
    }

    static func toStored(_ birth: BirthDetails) -> StoredBirth {
        var stored = StoredBirth(
            year: birth.year,
            month: birth.month,
            day: birth.day,
            timeKind: BirthTimeKind.unknown.rawValue,
            timeMinutes: nil,
            timeTolerance: nil,
            placeName: nil,
            latitude: nil,
            longitude: nil,
            timeZoneIdentifier: nil
        )

        switch birth.time {
        case .exact(let minutes):
            stored.timeKind = BirthTimeKind.exact.rawValue
            stored.timeMinutes = minutes
        case .approximate(let minutes, let tolerance):
            stored.timeKind = BirthTimeKind.approximate.rawValue
            stored.timeMinutes = minutes
            stored.timeTolerance = tolerance
        case .unknown:
            break
        }

        if case .known(let name, let latitude, let longitude, let timeZone) = birth.place {
            stored.placeName = name
            stored.latitude = latitude
            stored.longitude = longitude
            stored.timeZoneIdentifier = timeZone
        }

        return stored
    }
}

enum UserProfileMapper {
    static func toDomain(_ entity: UserProfileEntity) -> UserProfile {
        UserProfile(
            id: entity.id,
            displayName: entity.displayName,
            birth: BirthMapper.toDomain(
                BirthMapper.StoredBirth(
                    year: entity.birthYear,
                    month: entity.birthMonth,
                    day: entity.birthDay,
                    timeKind: entity.birthTimeKind,
                    timeMinutes: entity.birthTimeMinutes,
                    timeTolerance: entity.birthTimeToleranceMinutes,
                    placeName: entity.birthPlaceName,
                    latitude: entity.birthLatitude,
                    longitude: entity.birthLongitude,
                    timeZoneIdentifier: entity.birthTimeZoneIdentifier
                )
            )
        )
    }

    static func apply(_ profile: UserProfile, to entity: UserProfileEntity) {
        let stored = BirthMapper.toStored(profile.birth)
        entity.displayName = profile.displayName
        entity.birthYear = stored.year
        entity.birthMonth = stored.month
        entity.birthDay = stored.day
        entity.birthTimeKind = stored.timeKind
        entity.birthTimeMinutes = stored.timeMinutes
        entity.birthTimeToleranceMinutes = stored.timeTolerance
        entity.birthPlaceName = stored.placeName
        entity.birthLatitude = stored.latitude
        entity.birthLongitude = stored.longitude
        entity.birthTimeZoneIdentifier = stored.timeZoneIdentifier
        entity.updatedAt = .now
    }

    static func makeEntity(_ profile: UserProfile) -> UserProfileEntity {
        let entity = UserProfileEntity(id: profile.id, displayName: profile.displayName)
        apply(profile, to: entity)
        return entity
    }
}

enum CirclePersonMapper {
    static func toDomain(_ entity: CirclePersonEntity) -> CirclePerson {
        CirclePerson(
            id: entity.id,
            name: entity.name,
            role: RelationshipRole(rawValue: entity.relationshipRoleRaw) ?? .other,
            birth: BirthMapper.toDomain(
                BirthMapper.StoredBirth(
                    year: entity.birthYear,
                    month: entity.birthMonth,
                    day: entity.birthDay,
                    timeKind: entity.birthTimeKind,
                    timeMinutes: entity.birthTimeMinutes,
                    timeTolerance: entity.birthTimeToleranceMinutes,
                    placeName: entity.birthPlaceName,
                    latitude: entity.birthLatitude,
                    longitude: entity.birthLongitude,
                    timeZoneIdentifier: entity.birthTimeZoneIdentifier
                )
            )
        )
    }

    static func apply(_ person: CirclePerson, to entity: CirclePersonEntity) {
        let stored = BirthMapper.toStored(person.birth)
        entity.name = person.name
        entity.relationshipRoleRaw = person.role.rawValue
        entity.birthYear = stored.year
        entity.birthMonth = stored.month
        entity.birthDay = stored.day
        entity.birthTimeKind = stored.timeKind
        entity.birthTimeMinutes = stored.timeMinutes
        entity.birthTimeToleranceMinutes = stored.timeTolerance
        entity.birthPlaceName = stored.placeName
        entity.birthLatitude = stored.latitude
        entity.birthLongitude = stored.longitude
        entity.birthTimeZoneIdentifier = stored.timeZoneIdentifier
    }

    static func makeEntity(_ person: CirclePerson) -> CirclePersonEntity {
        let entity = CirclePersonEntity(id: person.id, name: person.name)
        apply(person, to: entity)
        return entity
    }
}

enum AppSettingsMapper {
    static func toDomain(_ entity: AppSettingsEntity) -> AppSettings {
        AppSettings(
            leadingTradition: AstrologyTradition(rawValue: entity.leadingTraditionRaw) ?? .western,
            tone: Tone(rawValue: entity.toneRaw) ?? .normal,
            onboardingCompletedAt: entity.onboardingCompletedAt,
            notifications: NotificationSettings(
                morningReading: entity.notifyMorningReading,
                todayTogether: entity.notifyTodayTogether,
                meaningfulTransit: entity.notifyMeaningfulTransit,
                lunarPhases: entity.notifyLunarPhases,
                quietHoursEnabled: entity.quietHoursEnabled,
                quietHoursStartHour: entity.quietHoursStartHour,
                quietHoursEndHour: entity.quietHoursEndHour
            )
        )
    }

    static func apply(_ settings: AppSettings, to entity: AppSettingsEntity) {
        entity.leadingTraditionRaw = settings.leadingTradition.rawValue
        entity.toneRaw = settings.tone.rawValue
        entity.onboardingCompletedAt = settings.onboardingCompletedAt
        entity.notifyMorningReading = settings.notifications.morningReading
        entity.notifyTodayTogether = settings.notifications.todayTogether
        entity.notifyMeaningfulTransit = settings.notifications.meaningfulTransit
        entity.notifyLunarPhases = settings.notifications.lunarPhases
        entity.quietHoursEnabled = settings.notifications.quietHoursEnabled
        entity.quietHoursStartHour = settings.notifications.quietHoursStartHour
        entity.quietHoursEndHour = settings.notifications.quietHoursEndHour
    }
}

enum AskMapper {
    static func toDomain(_ entity: AskConversationEntity) -> AskConversation {
        AskConversation(
            id: entity.id,
            startedAt: entity.startedAt,
            messages: (entity.messages ?? [])
                .sorted { $0.createdAt < $1.createdAt }
                .map(toDomain)
        )
    }

    static func toDomain(_ entity: AskMessageEntity) -> AskMessage {
        AskMessage(
            id: entity.id,
            role: AskRole(rawValue: entity.roleRaw) ?? .person,
            text: entity.text,
            basisLine: entity.basisLine,
            basisFactors: [],
            provenance: .mockFixture(fixtureID: entity.provenanceFixtureID ?? "ask.restored"),
            createdAt: entity.createdAt
        )
    }

    static func makeEntity(_ message: AskMessage) -> AskMessageEntity {
        let entity = AskMessageEntity(
            id: message.id,
            roleRaw: message.role.rawValue,
            text: message.text,
            createdAt: message.createdAt
        )
        entity.basisLine = message.basisLine
        if case .mockFixture(let fixtureID) = message.provenance {
            entity.provenanceFixtureID = fixtureID
        }
        return entity
    }
}
