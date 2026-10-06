//
//  RealmExtension.swift
//  SecondPlay
//
//  Created by insect on 2022/2/25.
//

import Foundation
import RealmSwift

public protocol RealmCompatible {

    associatedtype T

    var re: RealmWrapper<T> { get }
}

public extension RealmCompatible {

    var re: RealmWrapper<Self> {
        return RealmWrapper(self)
    }

    static var re: RealmWrapper<Self>.Type {
        return RealmWrapper<Self>.self
    }
}

extension Object: RealmCompatible {}
