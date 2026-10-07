//
//  RealmWrapperExtension.swift
//  SecondPlay
//
//  Created by insect on 2022/2/25.
//

import Realm
import RealmSwift

public typealias RealmWriteHandler = (Realm) -> Void
public typealias RealmCompletionHandler = (Result<Realm, Error>) -> Void

public extension RealmWrapper where Base: RealmExtensionable {
    
    static func objects() throws -> Results<Base> {
        let configuration = Self.createConfiguration()
        let realm = try Realm(configuration: configuration)
        return realm.objects(Base.self)
    }
    
    static func deleteAll(update: Realm.UpdatePolicy = .error,
                          writeQueue: DispatchQueue = DispatchQueue(label: "label"),
                          isSync: Bool = true,
                          completionQueue: DispatchQueue = DispatchQueue.main,
                          completion: RealmCompletionHandler? = nil) {
        Self.transaction(writeQueue: writeQueue,
                         isSync: isSync,
                         writeHandler: {
                             $0.deleteAll()
                         },
                         completionQueue: completionQueue,
                         completion: completion)
    }

    func add(update: Realm.UpdatePolicy = .error,
             writeQueue: DispatchQueue = DispatchQueue(label: "label"),
             isSync: Bool = true,
             completionQueue: DispatchQueue = DispatchQueue.main,
             completion: RealmCompletionHandler? = nil) {
        Self.transaction(writeQueue: writeQueue,
                         isSync: isSync,
                         writeHandler: {
                             $0.add(base, update: update)
                         },
                         completionQueue: completionQueue,
                         completion: completion)
    }

    func delete(update: Realm.UpdatePolicy = .error,
                writeQueue: DispatchQueue = DispatchQueue(label: "label"),
                isSync: Bool = true,
                completionQueue: DispatchQueue = DispatchQueue.main,
                completion: RealmCompletionHandler? = nil) {
        Self.transaction(writeQueue: writeQueue,
                         isSync: isSync,
                         writeHandler: {
                             $0.delete(base)
                         },
                         completionQueue: completionQueue,
                         completion: completion)
    }
    
    static func transaction(writeQueue: DispatchQueue = DispatchQueue(label: "label"),
                            isSync: Bool = true,
                            writeHandler: @escaping RealmWriteHandler,
                            completionQueue: DispatchQueue = DispatchQueue.main,
                            completion: RealmCompletionHandler? = nil) {
        guard isSync else {
            writeQueue.async {
                Self.perform(writeHandler: writeHandler,
                             completionQueue: completionQueue,
                             completion: completion)
            }
            return
        }

        writeQueue.sync {
            Self.perform(writeHandler: writeHandler,
                         completionQueue: completionQueue,
                         completion: completion)
        }
    }

    // MARK: - Private methods

    private static func perform(writeHandler: @escaping RealmWriteHandler,
                                completionQueue: DispatchQueue,
                                completion: RealmCompletionHandler?) {
        do {
            let configuration = Self.createConfiguration()
            let realm = try Realm(configuration: configuration)
            try realm.write {
                writeHandler(realm)
            }

            Realm.asyncOpen(configuration: configuration,
                            callbackQueue: completionQueue) {
                switch $0 {
                case let .success(realm):
                    realm.refresh()
                default:
                    break
                }
                completion?($0)
            }
        } catch {
            AppLogger.shared.error("Realm not write to database: \(error)")
            completion?(.failure(error))
        }
    }

    static func createConfiguration() -> Realm.Configuration {
        var config = Realm.Configuration()

        config.schemaVersion = Base.schemaVersion
        config.migrationBlock = Base.migrationBlock
        config.deleteRealmIfMigrationNeeded = Base.deleteRealmIfMigrationNeeded
        config.readOnly = Base.readOnly
        config.encryptionKey = Base.encryptionKey
        config.shouldCompactOnLaunch = Base.shouldCompactOnLaunch

        let file = "\(Base.fileName).realm"
        if Base.isUseInMemory {
            config.inMemoryIdentifier = "inMemory-\(file)"
        } else {
            if let appGroupIdentifier = Base.appGroupIdentifier {
                config.fileURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)?.appendingPathComponent(file)
            } else {
                config.fileURL = URL(fileURLWithPath: RLMRealmPathForFile(file))
            }
            config.objectTypes = Base.objectTypes
        }
        return config
    }
}

extension Results {
    
    var toArray: [Element] {
        return Array(self)
    }
}

extension RealmSwift.List {

    var toArray: [Element] {
        return Array(self)
    }
}
