//
//  ViewController.swift
//  /dev/desk
//
//  Created by Mars on 24/8/17.
//  Copyright © 2017 Mars. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    // dates/ timeslots of the three days
    let days = [[28, 08, 2017], [29, 08, 2017], [30, 08, 2017]]
    let mondayTimes = [1000, 1300, 1345, 1700, 1830]
    let tuesdayTimes = [0900, 1020, 1055, 1130, 1210, 1245, 1345, 1430, 1500, 1530, 1615, 1700, 1830]
    let wednesdayTimes = [1000, 1120, 1155, 1225, 1325, 1430, 1500, 1530, 1615]

    // values made when view loads
    var slideDeck: SlideDeck?
    var transition: Timer?



    /// Current slide marker advances when transition time is matched
    func timerExpired() {

        // move through deck, update image
        slideDeck!.advanceCurrentSlide()
        currentSlide() // this would have to come out in manual control
        view.backgroundColor = .black

        // set timer for next transition
        transition = Timer.init(fire: slideDeck!.currentSlide.date, interval: 0, repeats: false, block: { (timer) in self.timerExpired() })
        RunLoop.main.add(transition!, forMode: .defaultRunLoopMode)
    }



    /// Refreshes to display current slide
    func currentSlide() {
        let filename = slideDeck!.currentSlide.filename
        imageView.image = UIImage(named: filename)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        var currentDate = Date()

        // deck of slides
        let timeslots = [mondayTimes, tuesdayTimes, wednesdayTimes]
        slideDeck = SlideDeck()
        slideDeck!.initiateSlideDeck(forDays: days, withTimeslots: timeslots)

        // advance until next slide's date is after current Date()
        while currentDate.compare(slideDeck!.currentSlide.date) == .orderedDescending {
            slideDeck!.advanceCurrentSlide()
            currentDate = Date()
        }

        // display view
        currentSlide()
        view.backgroundColor = .black

        // set timer for first transition
        transition = Timer.init(fire: slideDeck!.currentSlide.date, interval: 0, repeats: false, block: { (timer) in self.timerExpired() })
        RunLoop.main.add(transition!, forMode: .defaultRunLoopMode)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // TODO: Dispose of any resources that can be recreated.
    }


}

