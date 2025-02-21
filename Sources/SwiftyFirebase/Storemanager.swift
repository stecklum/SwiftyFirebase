//
//  Storemanager.swift
//  
//
//  Created by Tom Stecklum on 21.02.25.
//

import Foundation
import FirebaseFirestore

public protocol StoreManager {
    associatedtype Entity: FirestoreEntity
    func save(_ object: Entity) async throws -> String
    func get(documentId: String) async throws -> Entity?
    func update(_ object: Entity) async throws
    func delete(_ object: Entity) async throws
    func getAll() async throws -> [Entity]
    func getAll(filteredBy filter: Filter) async throws -> [Entity]
    func listen(notification: @escaping (Result<[Entity], Error>) -> Void)
    func listen(filteredBy filter: Filter, notification: @escaping (Result<[Entity], Error>) -> Void)
    func listen(documentId: String, notification: @escaping (Result<Entity, Error>) -> Void)
}
