//
//  RealmExtensionable.swift
//  SecondPlay
//
//  Created by insect on 2022/2/25.
//

import Realm
import RealmSwift

public typealias RealmExtensionable = Object & RealmConfigurationable

public protocol RealmConfigurationable {
    static var deleteRealmIfMigrationNeeded: Bool { get }
    static var isUseInMemory: Bool { get }
    static var readOnly: Bool { get }
    static var schemaVersion: UInt64 { get }
    static var fileName: String { get }
    static var appGroupIdentifier: String? { get }
    static var encryptionKey: Data? { get }
    static var shouldCompactOnLaunch: ((Int, Int) -> Bool)? { get }
    static var migrationBlock: MigrationBlock? { get }
    static var objectTypes: [Object.Type]? { get }
}

extension RealmConfigurationable {
    
    static var deleteRealmIfMigrationNeeded: Bool {
        false
    }

    static var isUseInMemory: Bool {
        false
    }

    static var readOnly: Bool {
        false
    }

    static var schemaVersion: UInt64 {
        1
    }

    static var fileName: String {
        "default"
    }

    static var appGroupIdentifier: String? {
        nil
    }

    static var encryptionKey: Data? {
        nil
    }

    static var shouldCompactOnLaunch: ((Int, Int) -> Bool)? {
        nil
    }

    static var migrationBlock: MigrationBlock? {
        nil
    }


    static var objectTypes: [Object.Type]? {
        nil
    }
}
