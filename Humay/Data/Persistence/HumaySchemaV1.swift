import Foundation
import SwiftData

/// Version 1 of the Humay store.
///
/// The schema is versioned from the first release even though nothing has migrated
/// yet. A later revision becomes `HumaySchemaV2` with a stage in `HumayMigrationPlan`;
/// `V1` is never edited retroactively, because the moment a shipped build has written
/// data in this shape, this file is a description of what is on disk rather than a
/// description of what we would like.
///
/// Entities here are deliberately dumb: primitives and `String` raw values only. No
/// enums with associated values, no `Codable` composites. SwiftData can persist those,
/// but they are the most migration-fragile part of the framework, and keeping the
/// storage shape flat means `BirthTime.unknown` cannot be confused with a stored zero.
enum HumaySchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }

    static var models: [any PersistentModel.Type] {
        [
            UserProfileEntity.self,
            AppSettingsEntity.self,
            CirclePersonEntity.self,
            AskConversationEntity.self,
            AskMessageEntity.self,
        ]
    }

    @Model
    final class UserProfileEntity {
        var id: UUID = UUID()
        var displayName: String = ""

        var birthYear: Int = 1970
        var birthMonth: Int = 1
        var birthDay: Int = 1

        /// `BirthTime` case name. Never inferred from whether the minutes are zero.
        var birthTimeKind: String = BirthTimeKind.unknown.rawValue
        var birthTimeMinutes: Int?
        var birthTimeToleranceMinutes: Int?

        var birthPlaceName: String?
        var birthLatitude: Double?
        var birthLongitude: Double?
        var birthTimeZoneIdentifier: String?

        var createdAt: Date = Date.now
        var updatedAt: Date = Date.now

        init(id: UUID, displayName: String) {
            self.id = id
            self.displayName = displayName
        }
    }

    @Model
    final class AppSettingsEntity {
        var leadingTraditionRaw: String = AstrologyTradition.western.rawValue
        var toneRaw: String = Tone.normal.rawValue
        var onboardingCompletedAt: Date?

        var notifyMorningReading: Bool = true
        var notifyTodayTogether: Bool = true
        var notifyMeaningfulTransit: Bool = true
        var notifyLunarPhases: Bool = false
        var quietHoursEnabled: Bool = true
        var quietHoursStartHour: Int = 22
        var quietHoursEndHour: Int = 7

        init() {}
    }

    @Model
    final class CirclePersonEntity {
        var id: UUID = UUID()
        var name: String = ""
        var relationshipRoleRaw: String = RelationshipRole.other.rawValue

        var birthYear: Int = 1970
        var birthMonth: Int = 1
        var birthDay: Int = 1

        var birthTimeKind: String = BirthTimeKind.unknown.rawValue
        var birthTimeMinutes: Int?
        var birthTimeToleranceMinutes: Int?

        var birthPlaceName: String?
        var birthLatitude: Double?
        var birthLongitude: Double?
        var birthTimeZoneIdentifier: String?

        var createdAt: Date = Date.now

        init(id: UUID, name: String) {
            self.id = id
            self.name = name
        }
    }

    @Model
    final class AskConversationEntity {
        var id: UUID = UUID()
        var startedAt: Date = Date.now

        @Relationship(deleteRule: .cascade, inverse: \AskMessageEntity.conversation)
        var messages: [AskMessageEntity]? = []

        init(id: UUID, startedAt: Date) {
            self.id = id
            self.startedAt = startedAt
        }
    }

    @Model
    final class AskMessageEntity {
        var id: UUID = UUID()
        var roleRaw: String = AskRole.person.rawValue
        var text: String = ""
        var basisLine: String?
        var createdAt: Date = Date.now
        /// Recorded so that a stored answer still declares where it came from.
        var provenanceFixtureID: String?

        var conversation: AskConversationEntity?

        init(id: UUID, roleRaw: String, text: String, createdAt: Date) {
            self.id = id
            self.roleRaw = roleRaw
            self.text = text
            self.createdAt = createdAt
        }
    }
}

/// The stored discriminator for `BirthTime`.
///
/// Lives beside the schema rather than on the domain type, because it describes the
/// storage format and must not drift when the domain enum is refactored.
enum BirthTimeKind: String, Sendable {
    case exact
    case approximate
    case unknown
}

/// Migration plan.
///
/// Empty of stages today. It exists now so that adding `HumaySchemaV2` is a matter of
/// appending a schema and a stage, rather than introducing versioning to a store that
/// has already shipped without it.
enum HumayMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [HumaySchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}

// Aliases for the current version, so call sites are not littered with the version
// name. When V2 lands, these point at V2 and the mappers are updated in one place.
typealias UserProfileEntity = HumaySchemaV1.UserProfileEntity
typealias AppSettingsEntity = HumaySchemaV1.AppSettingsEntity
typealias CirclePersonEntity = HumaySchemaV1.CirclePersonEntity
typealias AskConversationEntity = HumaySchemaV1.AskConversationEntity
typealias AskMessageEntity = HumaySchemaV1.AskMessageEntity
