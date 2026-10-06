//
//  String+Localization.swift
//  PlantColor
//
//  Created by PlantColor on 2024/01/01.
//

import Foundation

extension String {

    /// Convenience accessor for NSLocalizedString
    var localized: String {
        NSLocalizedString(self, comment: "")
    }

    /// Localized string with arguments
    func localized(_ args: CVarArg...) -> String {
        String(format: self.localized, arguments: args)
    }
}
