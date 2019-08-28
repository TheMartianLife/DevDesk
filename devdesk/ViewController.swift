//
//  ViewController.swift
//  DevDesk
//
//  Created by Mars Geldard on 19/8/19.
//  Copyright © 2019 Mars Geldard. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let sessionsDidChangeOver =  Notification.Name("sessionsDidChangeOver")
}

class SessionView: UIView {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "H:mma"
        return formatter
    }()
    
    func setFontSize(_ size: CGFloat) {
        timeLabel.font = timeLabel.font.withSize(size)
        titleLabel.font = titleLabel.font.withSize(size * 1.2)
        subtitleLabel.font = subtitleLabel.font.withSize(size)
    }
    
    func setSession(_ session: Session) {
        backgroundColor = session.backgroundColor
        timeLabel.text = session.timeslot(with: formatter)
        titleLabel.text = session.title
        subtitleLabel.text = session.subtitle
        
        print("View set session to: \(session)")
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var nowLabel: UILabel!
    @IBOutlet weak var upNextLabel: UILabel!
    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var bottomContainerView: UIView!
    
    private var topSessionView: SessionView? = nil
    private var bottomSessionView: SessionView? = nil
    private lazy var year: Int = {
        let calendar = Calendar.current
        return calendar.component(.year, from: Date())
    }()
    
    private var fontSize: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        return screenHeight / 28.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveNotification(_:)),
            name: .sessionsDidChangeOver,
            object: nil
        )
        
        setFontSize()
        setLogoSize()
        
        refresh()
    }
    
    @objc func didReceiveNotification(_ notification: Notification) {
        if notification.name == Notification.Name.sessionsDidChangeOver {
            refresh()
        }
    }
    
    private func refresh() {
        guard let sessions = SessionManager.nextSessions() else { return }
        
        topSessionView?.setSession(sessions.first)
        bottomSessionView?.setSession(sessions.second)
        
        logoLabel.text = "/dev/world/\(year)"
    }
    
    private func setFontSize() {
        topSessionView?.setFontSize(fontSize)
        bottomSessionView?.setFontSize(fontSize)
        logoLabel.font = logoLabel.font.withSize(fontSize)
        nowLabel.font = nowLabel.font.withSize(fontSize)
        upNextLabel.font = upNextLabel.font.withSize(fontSize)
    }
    
    private func setLogoSize() {
        let oldSize = logoImage.frame.size.width
        let newSize = fontSize * 2.0
        let difference = (oldSize - newSize)
        let oldOrigin = logoImage.frame.origin
        
        logoImage.frame = CGRect(
            x: oldOrigin.x + difference,
            y: oldOrigin.y + difference  / 2.0,
            width: newSize,
            height: newSize
        )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "topContainerEmbed" {
            topSessionView = segue.destination.view as? SessionView
        }
        
        if segue.identifier == "bottomContainerEmbed" {
            bottomSessionView = segue.destination.view as? SessionView
        }
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        setFontSize()
        setLogoSize()
    }
}

