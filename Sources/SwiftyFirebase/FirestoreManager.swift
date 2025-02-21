//
//  FirestoreManager.swift
//  
//
//  Created by Tom Stecklum on 21.02.25.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

public class FirestoreManager<T: FirestoreEntity>: StoreManager {

    private var firestore
    private var collectionPath: String

    init(collection: FirestoreCollection) {
        firestore = Firestore.firestore()
        self.collectionPath = collection.rawValue
    }
    
    private func save(_ object: T, completion: @escaping (Result<String, Error>) -> Void) {
        do {
            var documentID: String
            var documentReference: DocumentReference
            if let objectID = object.id {
                documentReference = firestore.collection(collectionPath).document(objectID)
                documentID = objectID
            } else {
                documentReference = firestore.collection(collectionPath).document()
                documentID = documentReference.documentID
            }
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
    
    private func update(_ object: T, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            guard let documentId = object.id else { return }
            let documentReference = firestore.collection(collectionPath).document(documentId)
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
    
    func update(_ object: T) async throws {
        try await withCheckedThrowingContinuation { continuation in
            update(object) { result in
                switch result {
                case .success(_):
                    continuation.resume()
                case .failure(let failure):
                    continuation.resume(throwing: failure)
                }
            }
        }
    }
    
    @discardableResult
    func save(_ object: T) async throws -> String {
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
    
    func get(documentId: String, completion: @escaping (Result<T?, Error>) -> Void) {
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
    
    func get(documentId: String) async throws -> T? {
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
    
    func getAll(completion: @escaping (Result<[T], Error>) -> Void) {
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
    
    func getAll(filteredBy filter: Filter, completion: @escaping (Result<[T], Error>) -> Void) {
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
    
    func getAll() async throws -> [T] {
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
    
    func getAll(filteredBy filter: Filter) async throws -> [T] {
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
    
    func listen(notification: @escaping (Result<[T], Error>) -> Void) {
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
    
    func listen(filteredBy filter: Filter, notification: @escaping (Result<[T], Error>) -> Void) {
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
    
    func listen(documentId: String, notification: @escaping (Result<T, Error>) -> Void) {
        let documentReference = firestore.collection(collectionPath).document(documentId)
        documentReference.addSnapshotListener { document, error in
            if let error {
                notification(.failure(error))
            } else {
                if let document,
                   document.exists {
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
    
    func delete(_ object: T) async throws {
        try await withCheckedThrowingContinuation { continuation in
            delete(object) { result in
                switch result {
                case .success(_):
                    continuation.resume()
                case .failure(let failure):
                    continuation.resume(throwing: failure)
                }
            }
        }
    }
    
}
