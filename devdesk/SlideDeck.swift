/*
 * /dev/desk/2017: SlideDeck.swift
 * A program to display different images based on time
 * ====================================================
 * File handles creation of slideDeck from
 * an array of Dates or the product of
 * (an array of days) x (arrays of timeslots)
 *
 * Mars Geldard attempts to make a thing:
 * Part One (last updated: 25-08-2017)
 *
 * TODO: use DateComponents
 *
 */

import UIKit
import Foundation


public class SlideDeck {

    /// type to hold each slide
    typealias Slide = (date: Date, filename: String)

    /// values the SlideDeck has/knows
    var slides: [Slide] = [] // array of all slides in deck
    var index: Int? = nil // index of current slide in array
    var displayOffset: Int = 0 // offset of manual navigation vs currentSlide
    var currentSlide: Slide { // calculated from above
        guard let index = index else {

            // TODO: write a better error
            fatalError("SlideDeck was not populated!")

        }
        return slides[index]
    }


    /// Increments current slide index to advance slide
    func advanceCurrentSlide() {
        index! += 1
        index = index! % slides.count
    }


    /// Increments displayed slide index to advance slide
    func advanceDisplayedSlide(forward: Bool) {

        // move forward or backward vs currentSlide
        switch forward {
            case true: displayOffset += 1
            case false: displayOffset -= 1
        }
    }


    /**
     Formats given Int arrays into DateFormatter-friendly Strings (day half)
     - parameter days: an array of Ints
     - throws: formatDayOutOfBounds
     - returns: [String]
     */
    func formatDays(_ days: [[Int]]) -> [String] {

        var dayStrings: [String] = []

        // convert and concatenate Strings
        for date in days {

            let day = date[0]; let month = date[1]; let year = date[2]

            // TODO: check Ints are valid for time conversion, create error

            dayStrings.append(String(describing: day) + "-" +
                String(describing: month) + "-" + String(describing: year))
        }

        return dayStrings
    }



    /**
     Formats given Ints into a DateFormatter-friendly String (time half)
     - parameter timeslots: an array of Ints
     - throws: formatTimeslotOutOfBounds
     - returns: String array
     */
    func formatTimeslots(_ timeslots: [[Int]]) -> [[String]] {

        var timesArray: [[String]] = []
        var timeslotStrings: [String] = []

        // convert and concatenate Strings
        for day in timeslots {
            
            for time in day {

                let hour = time / 100; let minutes = time % 100

                // TODO: check Int is valid for time conversion, create error

                timeslotStrings.append(String(describing: hour) + ":" + String(describing: minutes))
            }
            timesArray.append(timeslotStrings)
            timeslotStrings.removeAll()
        }

        return timesArray
    }



    /**
     Concatenates String and converts to Date for each timeslot in each day
     - parameters:
       - days: an array of Strings in "dd-MM-yyyy_" format
       - timeslots: an array of arrays of Strings in "HH:mm" format
     - returns: Date array
     */
    func formatTransitions(_ days: [[Int]], _ timeslots: [[Int]]) -> [Date] {

        var transition: String
        var transitions: [Date] = [] // give length here explicitly

        // format components to read in
        let dayStrings = formatDays(days)
        let timeslotStrings = formatTimeslots(timeslots)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy_HH:mm"

        // for each day in days array
        for index in stride(from: 0, to: days.count, by: 1)  {

            // for each times in that day's corresponding timeslot array
            for time in timeslotStrings[index] {

                // join the day + time
                transition = dayStrings[index] + "_" + time

                // put it in the array
                transitions.append(dateFormatter.date(from: transition)!)
            }
        }

        return transitions
    }
    
    
    
    /**
     Makes a Slide type for each transition in arrays
     - parameters:
       - days: an array of arrays of Ints
       - timeslots: an array of arrays of Ints
     */
    func initiateSlideDeck(forDays days: [[Int]], withTimeslots timeslots: [[Int]]) {

        // format dates to read in, send to other initialiser
        let transitions = formatTransitions(days, timeslots)
        initiateSlideDeck(fromDates: transitions)
    }



    /**
     Makes a Slide type for each date in array
     - parameter dates: an array of Dates
     */
    func initiateSlideDeck(fromDates dates: [Date]) {

        var slide: Slide
        var slideDeck: [Slide] = []

        //for each value in dates array
        for index in stride(from: 0, to: dates.count, by: 1) {

            // make a Slide type whose attributed filename is/will be *incrementing number*.png
            slide = Slide(date: dates[index],
                          filename: String(describing: index))

            // put it in the array
            slideDeck.append(slide)
        }

        // initialise values so that deck is ready to be traversed
        self.slides = slideDeck
        self.index = 0
    }
}

