//
//  Storemanager.swift
//  
//
//  Created by Tom Stecklum on 21.02.25.
//

import FirebaseFirestore

/**
 A protocol defining a Firestore store manager for handling database operations.
 
 This protocol provides methods for saving, retrieving, updating, deleting,
 and listening to Firestore documents and collections.
 */
public protocol StoreManager {
    /// The type of entity managed by the store.
    associatedtype Entity: FirestoreEntity
    
    /**
     Saves an entity to Firestore.
     
     - Parameter object: The entity to be saved.
     - Returns: The document ID of the saved entity.
     - Throws: An error if the operation fails.
     */
    func save(_ object: Entity) async throws -> String
    
    /**
     Retrieves an entity from Firestore using its document ID.
     
     - Parameter documentId: The ID of the document to retrieve.
     - Returns: The retrieved entity or `nil` if not found.
     - Throws: An error if the operation fails.
     */
    func get(documentId: String) async throws -> Entity?
    
    /**
     Updates an existing entity in Firestore.
     
     - Parameter object: The entity with updated data.
     - Throws: An error if the operation fails.
     */
    func update(_ object: Entity) async throws
    
    /**
     Deletes an entity from Firestore.
     
     - Parameter object: The entity to delete.
     - Throws: An error if the operation fails.
     */
    func delete(_ object: Entity) async throws
    
    /**
     Retrieves all entities of the specified type from Firestore.
     
     - Returns: A list of retrieved entities.
     - Throws: An error if the operation fails.
     */
    func getAll() async throws -> [Entity]
    
    /**
     Retrieves all entities from Firestore that match the given filter.
     
     - Parameter filter: The filter criteria.
     - Returns: A list of entities that match the filter.
     - Throws: An error if the operation fails.
     */
    func getAll(filteredBy filter: Filter) async throws -> [Entity]
    
    /**
     Subscribes to real-time updates for all entities and sends notifications upon changes.
     
     - Parameter notification: A closure called with the result containing updated entities or an error.
     */
    func listen(notification: @escaping (Result<[Entity], Error>) -> Void)
    
    /**
     Subscribes to real-time updates for entities that match the given filter.
     
     - Parameter filter: The filter criteria.
     - Parameter notification: A closure called with the result containing updated entities or an error.
     */
    func listen(filteredBy filter: Filter, notification: @escaping (Result<[Entity], Error>) -> Void)
    
    /**
     Subscribes to real-time updates for a specific document ID.
     
     - Parameter documentId: The ID of the document to listen for updates.
     - Parameter notification: A closure called with the result containing the updated entity or an error.
     */
    func listen(documentId: String, notification: @escaping (Result<Entity, Error>) -> Void)
}
