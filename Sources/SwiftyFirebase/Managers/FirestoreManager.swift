//
//  FirestoreManager.swift
//  
//
//  Created by Tom Stecklum on 21.02.25.
//

import FirebaseFirestore

/**
 A class responsible for managing Firestore database operations for a specific entity type.
 
 This class provides methods for saving, retrieving, updating, deleting, and listening to changes in Firestore documents.
 */
public final class FirestoreManager<T: FirestoreEntity>: StoreManager {

    /// The Firestore instance used for database operations.
    private var firestore: Firestore

    /// The Firestore collection path for the specified entity.
    private var collectionPath: String

    /**
     Initializes the Firestore manager with the given collection.
     
     - Parameter collection: The Firestore collection where entities are stored.
     */
    public init(collection: FirestoreCollection) {
        firestore = Firestore.firestore()
        collectionPath = collection.rawValue
    }
    
    /**
     Saves an entity to Firestore.

     If the entity has an existing `id`, it is used as the document ID. Otherwise, a new document ID is generated.

     - Parameter object: The entity to be saved.
     - Parameter completion: A closure returning either the document ID upon success or an error if the operation fails.
     */
    private func save(_ object: T, completion: @escaping (Result<String, Error>) -> Void) {
        do {
            var documentID: String
            var documentReference: DocumentReference

            // Check if the object already has an ID, otherwise generate a new document
            if let objectID = object.id {
                documentReference = firestore.collection(collectionPath).document(objectID)
                documentID = objectID
            } else {
                documentReference = firestore.collection(collectionPath).document()
                documentID = documentReference.documentID
            }

            // Attempt to save the object to Firestore
            try documentReference.setData(from: object, merge: true) { error in
                if let error {
                    completion(.failure(error))
                } else {
                    completion(.success(documentID))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    /**
     Updates an existing entity in Firestore.

     This method attempts to update the document associated with the given entity in Firestore.
     If the entity does not have an `id`, the update is skipped.

     - Parameter object: The entity with updated values.
     - Parameter completion: A closure returning either success or an error if the operation fails.
     */
    private func update(_ object: T, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            // Ensure the object has a valid document ID before attempting an update
            guard let documentId = object.id else { return }
            
            let documentReference = firestore.collection(collectionPath).document(documentId)

            // Attempt to update the existing document
            try documentReference.setData(from: object, merge: true) { error in
                if let error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    /**
     Updates an existing entity in Firestore asynchronously.

     This method wraps the `update(_ object:completion:)` method inside a Swift concurrency continuation,
     allowing it to be used with `async/await`.

     - Parameter object: The entity with updated values.
     - Throws: An error if the update operation fails.
     */
    public func update(_ object: T) async throws {
        try await withCheckedThrowingContinuation { continuation in
            update(object) { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let failure):
                    continuation.resume(throwing: failure)
                }
            }
        }
    }
    
    /**
     Saves an entity to Firestore asynchronously.

     This method wraps the `save(_ object:completion:)` method inside a Swift concurrency continuation,
     allowing it to be used with `async/await`. If the entity does not have an `id`, Firestore generates one.

     - Parameter object: The entity to be saved.
     - Throws: An error if the save operation fails.
     - Returns: The document ID of the saved entity.
     */
    @discardableResult
    public func save(_ object: T) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            save(object) { result in
                switch result {
                case .success(let documentID):
                    continuation.resume(returning: documentID)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /**
     Retrieves an entity from Firestore by its document ID.

     This method fetches a single document from Firestore based on the provided `documentId`
     and attempts to decode it into the specified entity type.

     - Parameter documentId: The ID of the Firestore document to retrieve.
     - Parameter completion: A closure that returns either the successfully decoded entity, `nil` if the document does not exist, or an error if the operation fails.
     */
    public func get(documentId: String, completion: @escaping (Result<T?, Error>) -> Void) {
        firestore.collection(collectionPath).document(documentId).getDocument { snapshot, error in
            do {
                if let error {
                    completion(.failure(error))
                } else {
                    let document = try snapshot?.data(as: T.self)
                    completion(.success(document))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    /**
     Retrieves an entity from Firestore asynchronously by its document ID.

     This method wraps the `get(documentId:completion:)` method inside a Swift concurrency continuation,
     allowing it to be used with `async/await`.

     - Parameter documentId: The ID of the Firestore document to retrieve.
     - Throws: An error if the retrieval operation fails.
     - Returns: The retrieved entity of type `T`, or `nil` if the document does not exist.
     */
    public func get(documentId: String) async throws -> T? {
        try await withCheckedThrowingContinuation { continuation in
            get(documentId: documentId) { result in
                switch result {
                case .success(let success):
                    continuation.resume(returning: success)
                case .failure(let failure):
                    continuation.resume(throwing: failure)
                }
            }
        }
    }
    
    /**
     Retrieves all entities of type `T` from the Firestore collection.

     This method fetches all documents from the Firestore collection and attempts
     to decode them into the specified entity type.

     - Parameter completion: A closure that returns either an array of successfully decoded entities
       or an error if the operation fails.
     */
    public func getAll(completion: @escaping (Result<[T], Error>) -> Void) {
        firestore.collection(collectionPath).getDocuments { (snapshot, error) in
            if let error {
                completion(.failure(error))
                return
            }
            let objects = snapshot?.documents.compactMap { document -> T? in
                return try? document.data(as: T.self)
            }
            completion(.success(objects ?? []))
        }
    }
    
    /**
     Retrieves all entities of type `T` from the Firestore collection that match the specified filter.

     This method applies the provided `filter` to the Firestore query, fetches the matching documents,
     and attempts to decode them into the specified entity type.

     - Parameter filter: The filter criteria used to query Firestore.
     - Parameter completion: A closure that returns either an array of successfully decoded entities
       matching the filter or an error if the operation fails.
     */
    public func getAll(filteredBy filter: Filter, completion: @escaping (Result<[T], Error>) -> Void) {
        firestore.collection(collectionPath).whereFilter(filter).getDocuments { snapshot, error in
            if let error {
                completion(.failure(error))
                return
            }
            let objects = snapshot?.documents.compactMap { document -> T? in
                return try? document.data(as: T.self)
            }
            completion(.success(objects ?? []))
        }
    }
    
    /**
     Retrieves all entities of type `T` from the Firestore collection asynchronously.

     This method wraps the `getAll(completion:)` method inside a Swift concurrency continuation,
     allowing it to be used with `async/await`.

     - Throws: An error if the retrieval operation fails.
     - Returns: An array of entities of type `T` retrieved from Firestore.
     */
    public func getAll() async throws -> [T] {
        try await withCheckedThrowingContinuation { continuation in
            getAll { result in
                switch result {
                case .success(let objects):
                    continuation.resume(returning: objects)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /**
     Retrieves all entities of type `T` from the Firestore collection that match the specified filter asynchronously.

     This method wraps the `getAll(filteredBy:completion:)` method inside a Swift concurrency continuation,
     allowing it to be used with `async/await`.

     - Parameter filter: The filter criteria used to query Firestore.
     - Throws: An error if the retrieval operation fails.
     - Returns: An array of entities of type `T` that match the provided filter.
     */
    public func getAll(filteredBy filter: Filter) async throws -> [T] {
        try await withCheckedThrowingContinuation { continuation in
            getAll(filteredBy: filter) { result in
                switch result {
                case .success(let objects):
                    continuation.resume(returning: objects)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /**
     Subscribes to real-time updates for all entities in the Firestore collection.

     This method listens for any changes in the Firestore collection and provides live updates
     whenever a document is added, modified, or removed.

     - Parameter notification: A closure that returns either an updated array of entities
       or an error if the operation fails.
     */
    public func listen(notification: @escaping (Result<[T], Error>) -> Void) {
        firestore.collection(collectionPath).addSnapshotListener { snapshot, error in
            if let error {
                notification(.failure(error))
            } else {
                let objects = try? snapshot?.documents.compactMap { document -> T in
                    return try document.data(as: T.self)
                }
                notification(.success(objects ?? []))
            }
        }
    }
    
    /**
     Subscribes to real-time updates for entities in the Firestore collection that match the specified filter.

     This method listens for changes in Firestore and provides live updates whenever a document
     that matches the given `filter` is added, modified, or removed.

     - Parameter filter: The filter criteria used to query Firestore.
     - Parameter notification: A closure that returns either an updated array of filtered entities
       or an error if the operation fails.
     */
    public func listen(filteredBy filter: Filter, notification: @escaping (Result<[T], Error>) -> Void) {
        firestore.collection(collectionPath).whereFilter(filter).addSnapshotListener { snapshot, error in
            if let error {
                notification(.failure(error))
            } else {
                let objects = snapshot?.documents.compactMap { document -> T? in
                    return try? document.data(as: T.self)
                }
                notification(.success(objects ?? []))
            }
        }
    }
    
    /**
     Subscribes to real-time updates for a specific Firestore document.

     This method listens for changes to a single document in Firestore. If the document
     is updated or deleted, the listener triggers an update.

     - Parameter documentId: The ID of the Firestore document to listen for updates.
     - Parameter notification: A closure that returns either the updated entity or an error if the operation fails.
     */
    public func listen(documentId: String, notification: @escaping (Result<T, Error>) -> Void) {
        let documentReference = firestore.collection(collectionPath).document(documentId)
        documentReference.addSnapshotListener { document, error in
            if let error {
                notification(.failure(error))
            } else {
                if let document, document.exists {
                    do {
                        let object = try document.data(as: T.self)
                        notification(.success(object))
                    } catch {
                        notification(.failure(error))
                    }
                }
            }
        }
    }

    /**
     Deletes an entity from Firestore.

     This method deletes the corresponding Firestore document of the given entity if it has a valid `id`.

     - Parameter object: The entity to be deleted.
     - Parameter completion: A closure that returns either success or an error if the deletion fails.
     */
    private func delete(_ object: T, completion: @escaping (Result<Void, Error>) -> Void) {
        if let id = object.id {
            firestore.collection(collectionPath).document(id).delete { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }

    /**
     Deletes an entity from Firestore asynchronously.

     This method wraps the `delete(_ object:completion:)` method inside a Swift concurrency continuation,
     allowing it to be used with `async/await`.

     - Parameter object: The entity to be deleted.
     - Throws: An error if the deletion operation fails.
     */
    public func delete(_ object: T) async throws {
        try await withCheckedThrowingContinuation { continuation in
            delete(object) { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let failure):
                    continuation.resume(throwing: failure)
                }
            }
        }
    }
    
}
