//
//  SessionManager.swift
//  DevDesk
//
//  Created by Mars Geldard on 20/8/19.
//  Copyright © 2019 Mars Geldard. All rights reserved.
//

import Foundation

final class SessionManager {
    private static let shared = SessionManager()
    private var sessions: [Session] = []
    private var timers: [Timer] = []
    
    private init() {
        self.sessions = DataImporter.importData()
        
        setTimer(for: sessions.first!.finishTime)
//        for session in sessions {
//            setTimer(for: session.finishTime)
//        }
    }
    
    private func setTimer(for date: Date) {
//        let timer = Timer(fire: date, interval: 0, repeats: false) { _ in
//            NotificationCenter.default.post(name: .sessionsDidChangeOver, object: nil)
//        }
        let timer = Timer(fire: Date() + 5, interval: 5, repeats: true) { _ in
            NotificationCenter.default.post(name: .sessionsDidChangeOver, object: nil)
        }

        RunLoop.main.add(timer, forMode: .common)
        self.timers.append(timer)
    }
    
    static func nextSessions() -> (first: Session, second: Session)? {
        let sessions = SessionManager.shared.sessions
//
//        let now = Date()
//        var futureSessions = sessions.filter { $0.finishTime > now }
//        futureSessions.sort { $0.startTime < $1.startTime }
//
//        if futureSessions.count < 2 { return nil }
//
        let theseSessions = (sessions[0], sessions[1])
        SessionManager.shared.sessions.removeFirst()
        return theseSessions
        
//        return (futureSessions[0], futureSessions[1])
    }
}
