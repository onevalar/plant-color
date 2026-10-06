//
//  ErrorExtension.swift
//  PlantColor
//
//  Created by PlantColor on 2024/01/01.
//  Copyright © 2024 PlantColor. All rights reserved.
//

import Foundation
import RealmSwift

extension Error {
    
    /// 获取用户友好的错误描述
    var userFriendlyDescription: String {
        switch self {
        case let decodingError as DecodingError:
            return handleDecodingError(decodingError)
        case let realmError as Realm.Error:
            return handleRealmError(realmError)
        default:
            return localizedDescription
        }
    }
    
    private func handleDecodingError(_ error: DecodingError) -> String {
        switch error {
        case .dataCorrupted(let context):
            return "数据格式错误: \(context.debugDescription)"
        case .keyNotFound(let key, let context):
            return "缺少必要字段: \(key.stringValue)"
        case .typeMismatch(let type, let context):
            return "数据类型不匹配: 期望\(type), 位置: \(context.codingPath)"
        case .valueNotFound(let type, let context):
            return "缺少值: 期望\(type), 位置: \(context.codingPath)"
        @unknown default:
            return "数据解析错误"
        }
    }
    
    private func handleRealmError(_ error: Realm.Error) -> String {
        switch error.code {
        case .fileNotFound:
            return "数据库文件未找到"
        case .filePermissionDenied:
            return "数据库文件权限被拒绝"
        case .fileExists:
            return "数据库文件已存在"
        case .fileFormatUpgradeRequired:
            return "数据库格式需要升级"
        case .incompatibleLockFile:
            return "数据库锁定文件不兼容"
        default:
            return "数据库操作失败: \(error.localizedDescription)"
        }
    }
}

/// 自定义错误类型
enum PlantColorError: Error, LocalizedError {
    case dataFileNotFound
    case dataParseFailed(String)
    case networkError(String)
    case permissionDenied(String)
    
    var errorDescription: String? {
        switch self {
        case .dataFileNotFound:
            return "数据文件未找到"
        case .dataParseFailed(let reason):
            return "数据解析失败: \(reason)"
        case .networkError(let message):
            return "网络错误: \(message)"
        case .permissionDenied(let permission):
            return "权限被拒绝: \(permission)"
        }
    }
} 