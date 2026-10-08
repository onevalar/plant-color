//
//  Feedback.swift
//  Mobilephone
//
//  Created by Mobilephone on 2021/8/4.
//

import UIKit

struct Feedback {
    
    static func prepare() {
        guard HomePreferences.shared.hapticsEnabled else { return }
        let feedback = UIImpactFeedbackGenerator(style: .medium)
        feedback.prepare()
        feedback.impactOccurred()
    }
    
    static func lightPrepare() {
        guard HomePreferences.shared.hapticsEnabled else { return }
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.prepare()
        feedback.impactOccurred()
    }
}
