//
//  RealmWrapper.swift
//  SecondPlay
//
//  Created by insect on 2022/2/25.
//

import RealmSwift

public struct RealmWrapper<Base> {

    let base: Base

    init(_ base: Base) {
        
        self.base = base
    }
}
