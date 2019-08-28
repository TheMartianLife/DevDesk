//
//  Session.swift
//  DevDesk
//
//  Created by Mars Geldard on 20/8/19.
//  Copyright © 2019 Mars Geldard. All rights reserved.
//

import UIKit

extension UIColor {
    static let lightGreen = UIColor(red: 0.66, green: 0.84, blue: 0.66, alpha: 1.00)
    static let lightBlue  = UIColor(red: 0.53, green: 0.83, blue: 0.98, alpha: 1.00)
}

enum SessionType: Equatable {
    case talk(title: String, speaker: String, keynote: Bool)
    case `break`(name: String)
    case closing
}

struct Session: CustomStringConvertible {
    private static let lunchDescription = "🍔 Lunch 🥗"
    private static let afternoonBreakDescription = "☕️ Afternoon Break 🍩"
    private static let registrationDescription = "👋 Registration 📋"
    private static let closingDescription = "👋 Closed for the day 😴"
    
    let type: SessionType
    let startTime: Date
    let finishTime: Date
    
    var title: String {
        switch self.type {
            case .talk(let title, let speaker, let keynote):
                return keynote ? "Keynote by\n\(speaker)" : title
            
            case .break(let name):
                switch name {
                    case "Registration": return Session.registrationDescription
                    case "Lunch": return Session.lunchDescription
                    case "Afternoon Tea": return Session.afternoonBreakDescription
                    default: return name
                }
            
            case .closing: return Session.closingDescription
        }
    }
    
    var subtitle: String? {
        switch self.type {
            case .talk(_, let speaker, let keynote):
                return keynote ? nil : speaker
            
            default: return nil
        }
    }
    
    var backgroundColor: UIColor {
        switch self.type {
            case .talk(_, _, let keynote):
                return keynote ? .lightBlue : .white
            
            case .closing: return .lightGray
            default: return .lightGreen
        }
    }
    
    var description: String {
        return "\(self.title): \(self.startTime) - \(self.finishTime)"
    }
    
    func timeslot(with formatter: DateFormatter) -> String {
        let start = formatter.string(from: startTime).lowercased()
        let finish = formatter.string(from: finishTime).lowercased()
        return self.type == .closing ? "\(start)" : "\(start) - \(finish)"
    }
}
