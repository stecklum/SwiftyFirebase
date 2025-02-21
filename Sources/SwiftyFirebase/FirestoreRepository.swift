//
//  FirestoreRepository.swift
//  
//
//  Created by Tom Stecklum on 21.02.25.
//

public protocol FirestoreRepository {
    associatedtype Entity: FirestoreEntity
    var manager: FirestoreManager<Entity> { get }
}

public extension FirestoreRepository {
    func add(_ object: Entity) async throws {
        try await manager.save(object)
    }
    
    func get(id: String) async throws -> Entity? {
        try await manager.get(documentId: id)
    }
    
    func get(filteredBy filter: Filter) async throws -> [Entity] {
        try await manager.getAll(filteredBy: filter)
    }
    
    func update(_ object: Entity) async throws {
        try await manager.update(object)
    }
    
    func delete(_ object: Entity) async throws {
        try await manager.delete(object)
    }
    
    func subscribe(filteredBy filter: Filter, completion: @escaping (Result<[Entity], Error>) -> Void) {
        manager.listen(filteredBy: filter, notification: completion)
    }
}
