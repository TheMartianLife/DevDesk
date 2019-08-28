//
//  JSONParsing.swift
//  DevDesk
//
//  Created by Mars Geldard on 21/8/19.
//  Copyright © 2019 Mars Geldard. All rights reserved.
//

import Foundation

final class DataImporter {
    
    private static var formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Hobart")
        return formatter
    }()

    static func importData() -> [Session] {
        guard  let jsonPath = Bundle.main.url(forResource: "devworld.json", withExtension: nil),
            let jsonData = try? Data(contentsOf: jsonPath),
            let jsonDict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
            let sessionsArray = jsonDict["talks"] as? [Any] else {
            fatalError("Could not import file devworld.json")
        }
        
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Hobart")
        
        var sessions: [Session] = []
        
        for session in sessionsArray {
            if let sessionObject = DataImporter.getSessionObject(session) {
                sessions.append(sessionObject)
            }
        }
        
        sessions = DataImporter.insertClosingSessions(sessions)
        
        return sessions
    }
    
    private static func getSessionObject(_ sessionData: Any?) -> Session? {
        if let sessionDict = sessionData as? [String: Any],
            let sessionType = DataImporter.getSessionType(sessionDict),
            let sessionStart = DataImporter.getDateObject(sessionDict["start_iso"]),
            let sessionEnd = DataImporter.getDateObject(sessionDict["end_iso"]) {
                return Session(
                    type: sessionType,
                    startTime: sessionStart,
                    finishTime: sessionEnd
                )
        }
        
        return nil
    }
    
    private static func getDateObject(_ dateData: Any?) -> Date? {
        if let dateString = dateData as? String {
            return DataImporter.formatter.date(from: dateString)
        }
        
        return nil
    }
    
    private static func getSessionType(_ sessionDict: [String: Any]) -> SessionType? {
        guard let type = sessionDict["type"] as? String,
            let title = sessionDict["title"] as? String else { return nil }
        
        if type == "admin" {
            
            return .break(name: title)
        }
        
        // TODO: blue "welcome" and "quiz"
        
        guard let speaker = sessionDict["speaker"] as? [String: Any],
            let name = speaker["name"] as? String else {
                if type == "special_event" && title.lowercased().contains("quiz") {
                    return .break(name: "❔ The /dev/world Quiz 🤔")
                }
                
                return nil
        }
        
        if type == "keynote" || type == "special_event" {
            return .talk(title: title, speaker: name, keynote: true)
        } else {
            return .talk(title: title, speaker: name, keynote: false)
        }
    }
    
    private static func insertClosingSessions(_ sessions: [Session]) -> [Session] {
        let calendar = Calendar.current

        var sessionsByDay = Dictionary(grouping: sessions) { (session: Session) -> Date in
            let day = calendar.component(.day, from: session.startTime)
            let month = calendar.component(.month, from: session.startTime)
            let year = calendar.component(.year, from: session.startTime)
            let dateString = "\(year)-\(month)-\(day)T00:00:00+10"
            return DataImporter.formatter.date(from: dateString)!
        }
        
        let days = sessionsByDay.keys.sorted()
        if days.count < 2 { return sessions }
        
        for (key, value) in sessionsByDay {
            sessionsByDay[key] = value.sorted { $0.finishTime < $1.finishTime }
        }

        for index in 0..<days.count - 1 {
            let day = days[index]
            if let nextDay = calendar.date(byAdding: .day, value: 1, to: day),
                let daySessions = sessionsByDay[day],
                let dayEndTime = daySessions.last?.finishTime,
                let nextDayStartTime = sessionsByDay[nextDay]?.first?.startTime {

                let closingSession = Session(
                    type: .closing,
                    startTime: dayEndTime,
                    finishTime: nextDayStartTime
                )
                
                let paddedSessions = daySessions + [closingSession]
                sessionsByDay[day] = paddedSessions
            }
        }
        
        var paddedSchedule: [Session] = []
        for day in days {
            paddedSchedule.append(contentsOf: sessionsByDay[day] ?? [])
        }
        
        return paddedSchedule
    }
}
