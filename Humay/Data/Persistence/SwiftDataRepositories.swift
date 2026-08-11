import Foundation
import SwiftData

/// SwiftData-backed repositories.
///
/// All of these run on the main actor against `container.mainContext`. The `@Model`
/// objects therefore never cross an isolation boundary, which is why their lack of
/// `Sendable` conformance is not a problem here and why no `@ModelActor` is needed. The
/// entire dataset is a few kilobytes on the same device.
@MainActor
final class SwiftDataUserProfileRepository: UserProfileRepository {
    /// The container is held, not just its context.
    ///
    /// `ModelContext` does not keep its container alive on its own, so a repository
    /// that stored only `container.mainContext` would work for as long as something
    /// else happened to hold the container and then trap inside SwiftData once that
    /// reference went away. The composition root builds the container in a local, so
    /// this is the only thing keeping it alive.
    private let container: ModelContainer
    private var context: ModelContext { container.mainContext }

    init(container: ModelContainer) {
        self.container = container
    }

    func load() throws -> UserProfile? {
        try context.fetch(FetchDescriptor<UserProfileEntity>())
            .first
            .map(UserProfileMapper.toDomain)
    }

    func save(_ profile: UserProfile) throws {
        let existing = try context.fetch(FetchDescriptor<UserProfileEntity>()).first
        if let existing {
            UserProfileMapper.apply(profile, to: existing)
        } else {
            context.insert(UserProfileMapper.makeEntity(profile))
        }
        try context.save()
    }

    func delete() throws {
        for entity in try context.fetch(FetchDescriptor<UserProfileEntity>()) {
            context.delete(entity)
        }
        try context.save()
    }
}

@MainActor
final class SwiftDataAppSettingsRepository: AppSettingsRepository {
    private let container: ModelContainer
    private var context: ModelContext { container.mainContext }

    init(container: ModelContainer) {
        self.container = container
    }

    func load() throws -> AppSettings {
        guard let entity = try context.fetch(FetchDescriptor<AppSettingsEntity>()).first else {
            return .default
        }
        return AppSettingsMapper.toDomain(entity)
    }

    func save(_ settings: AppSettings) throws {
        let entity = try context.fetch(FetchDescriptor<AppSettingsEntity>()).first ?? {
            let created = AppSettingsEntity()
            context.insert(created)
            return created
        }()
        AppSettingsMapper.apply(settings, to: entity)
        try context.save()
    }
}

@MainActor
final class SwiftDataCirclePersonRepository: CirclePersonRepository {
    private let container: ModelContainer
    private var context: ModelContext { container.mainContext }

    init(container: ModelContainer) {
        self.container = container
    }

    func loadAll() throws -> [CirclePerson] {
        let descriptor = FetchDescriptor<CirclePersonEntity>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        return try context.fetch(descriptor).map(CirclePersonMapper.toDomain)
    }

    func save(_ person: CirclePerson) throws {
        let identifier = person.id
        let descriptor = FetchDescriptor<CirclePersonEntity>(
            predicate: #Predicate { $0.id == identifier }
        )
        if let existing = try context.fetch(descriptor).first {
            CirclePersonMapper.apply(person, to: existing)
        } else {
            context.insert(CirclePersonMapper.makeEntity(person))
        }
        try context.save()
    }

    func delete(id: UUID) throws {
        let descriptor = FetchDescriptor<CirclePersonEntity>(
            predicate: #Predicate { $0.id == id }
        )
        for entity in try context.fetch(descriptor) {
            context.delete(entity)
        }
        try context.save()
    }

    func deleteAll() throws {
        for entity in try context.fetch(FetchDescriptor<CirclePersonEntity>()) {
            context.delete(entity)
        }
        try context.save()
    }
}

@MainActor
final class SwiftDataAskConversationRepository: AskConversationRepository {
    private let container: ModelContainer
    private var context: ModelContext { container.mainContext }

    init(container: ModelContainer) {
        self.container = container
    }

    func loadAll() throws -> [AskConversation] {
        let descriptor = FetchDescriptor<AskConversationEntity>(
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        return try context.fetch(descriptor).map(AskMapper.toDomain)
    }

    func save(_ conversation: AskConversation) throws {
        let identifier = conversation.id
        let descriptor = FetchDescriptor<AskConversationEntity>(
            predicate: #Predicate { $0.id == identifier }
        )
        let entity = try context.fetch(descriptor).first ?? {
            let created = AskConversationEntity(id: conversation.id, startedAt: conversation.startedAt)
            context.insert(created)
            return created
        }()

        // Messages are append-only in practice, so only the new tail is inserted.
        let storedIDs = Set((entity.messages ?? []).map(\.id))
        for message in conversation.messages where !storedIDs.contains(message.id) {
            let messageEntity = AskMapper.makeEntity(message)
            messageEntity.conversation = entity
            context.insert(messageEntity)
        }
        try context.save()
    }

    func delete(id: UUID) throws {
        let descriptor = FetchDescriptor<AskConversationEntity>(
            predicate: #Predicate { $0.id == id }
        )
        for entity in try context.fetch(descriptor) {
            context.delete(entity)
        }
        try context.save()
    }

    func deleteAll() throws {
        for entity in try context.fetch(FetchDescriptor<AskConversationEntity>()) {
            context.delete(entity)
        }
        try context.save()
    }
}
