//
//  DefaultsKeyExtension.swift
//  Motion
//
//  Created by QY on 2018/11/19.
//  Copyright © 2018年 Insect. All rights reserved.
//

import DefaultsKit

// Swift 6 兼容：DefaultsKey 是协议，(any DefaultsKey).Type 不允许访问静态成员
// 使用独立的 enum 命名空间替代
enum AppKey {
    static let buildNumberKey = Key<String>("buildNumber")
    static let isConfigDefaultColorDetail = Key<Bool>("isConfigDefaultColorDetail")
    static let isConfigDefaultSetting = Key<Bool>("isConfigDefaultSetting")
    static let traditionalDetailConfigRevision = Key<Int>("traditionalDetailConfigRevision")
    static let dataFingerprintKey = Key<String>("dataFingerprint")
}
