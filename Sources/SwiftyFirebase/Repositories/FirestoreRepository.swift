//
//  FirestoreRepository.swift
//  
//
//  Created by Tom Stecklum on 21.02.25.
//

import FirebaseFirestore

/**
 A protocol defining a repository for managing Firestore entities.
 
 This protocol provides an abstraction for CRUD operations on Firestore entities
 and requires a `FirestoreManager` instance to interact with Firestore.
 */
public protocol FirestoreRepository {
    /// The type of entity managed by the repository.
    associatedtype Entity: FirestoreEntity
    
    /// The Firestore manager responsible for database operations.
    var manager: FirestoreManager<Entity> { get }
    
    /**
     Initializes the repository with a Firestore manager.
     
     - Parameter manager: The `FirestoreManager` responsible for handling Firestore operations.
     */
    init(manager: FirestoreManager<Entity>)
}

/**
 An extension providing default implementations for Firestore repository operations.
 
 This extension includes methods for adding, retrieving, updating, deleting,
 and subscribing to real-time updates of Firestore entities.
 */
public extension FirestoreRepository {
    
    /**
     Saves an entity to Firestore.
     
     - Parameter object: The entity to be saved.
     - Throws: An error if the save operation fails.
     */
    func add(_ object: Entity) async throws {
        try await manager.save(object)
    }
    
    /**
     Retrieves an entity from Firestore by its document ID.
     
     - Parameter id: The document ID of the entity to retrieve.
     - Returns: The retrieved entity or `nil` if not found.
     - Throws: An error if the retrieval operation fails.
     */
    func get(id: String) async throws -> Entity? {
        try await manager.get(documentId: id)
    }
    
    /**
     Retrieves all entities from Firestore that match the given filter.
     
     - Parameter filter: The filter criteria used for the query.
     - Returns: An array of entities that match the filter.
     - Throws: An error if the retrieval operation fails.
     */
    func get(filteredBy filter: Filter) async throws -> [Entity] {
        try await manager.getAll(filteredBy: filter)
    }
    
    /**
     Updates an existing entity in Firestore.
     
     - Parameter object: The entity with updated values.
     - Throws: An error if the update operation fails.
     */
    func update(_ object: Entity) async throws {
        try await manager.update(object)
    }
    
    /**
     Deletes an entity from Firestore.
     
     - Parameter object: The entity to delete.
     - Throws: An error if the deletion operation fails.
     */
    func delete(_ object: Entity) async throws {
        try await manager.delete(object)
    }
    
    /**
     Subscribes to real-time updates for entities that match the given filter.
     
     - Parameter filter: The filter criteria for the Firestore query.
     - Parameter completion: A closure called with the result containing updated entities or an error.
     */
    func subscribe(filteredBy filter: Filter, completion: @escaping (Result<[Entity], Error>) -> Void) {
        manager.listen(filteredBy: filter, notification: completion)
    }
}
