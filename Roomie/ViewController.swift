////
////  ViewController.swift
////  Roomie
////
////  Created by Kira Brodsky on 5/26/25.
////
//
//import UIKit
//
//
//class ViewController: UIViewController {
//    
//    var events: [Event] = []
//
//
//    @IBOutlet weak var Add: UIButton!
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//        createCalendar()
//        Add.layer.cornerRadius = Add.frame.width/2
//        Add.layer.masksToBounds = true
//        Add.titleLabel?.font = UIFont.systemFont(ofSize: 39, weight: .bold)
//    }
//    
//    
//    
//    @IBAction func unwindToMain(_ sender: UIStoryboardSegue) {
//        
//    }
//    
//    @IBAction func unwindToMainCancel(_ sender: UIStoryboardSegue){
//        
//    }
//    
//    func createCalendar() {
//        let calendarView = UICalendarView()
//        calendarView.translatesAutoresizingMaskIntoConstraints = false
//        calendarView.calendar = .current
//        calendarView.locale = .current
//        calendarView.fontDesign = .rounded
//        calendarView.delegate = self
//        
//        view.addSubview(calendarView)
//        
//        NSLayoutConstraint.activate([
//            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
//            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
//            calendarView.heightAnchor.constraint(equalToConstant: 500),
//            calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
//        ])
//    }
//
//
//}
//
//extension ViewController : UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
//    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
//        NSLog("\(selection)")
//    }
//    
//    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
//        return nil
//    }
//}
//


import UIKit

class ViewController: UIViewController, UICalendarSelectionSingleDateDelegate{
    
    @objc 
    

    @IBOutlet weak var Add: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    var calendarView: UICalendarView!
    var selectedDate: DateComponents?
    var events: [DateComponents: [Event]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        createCalendar()
        
        textView.text = ("\(events)")

        Add.layer.cornerRadius = Add.frame.width / 2
        Add.layer.masksToBounds = true
        Add.titleLabel?.font = UIFont.systemFont(ofSize: 39, weight: .bold)
    }

    func createCalendar() {
        calendarView = UICalendarView()
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.calendar = .current
        calendarView.locale = .current
        calendarView.fontDesign = .rounded
        calendarView.delegate = self

        let selection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = selection

        view.addSubview(calendarView)

        NSLayoutConstraint.activate([
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            calendarView.heightAnchor.constraint(equalToConstant: 500),
            calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let destinationVC = segue.destination as? AddEventViewController {
//            destinationVC.delegate = self
//            destinationVC.selectedDate = selectedDate
//        }
    }
    
        @IBAction func unwindToMain(_ sender: UIStoryboardSegue) {
    
        }
    
        @IBAction func unwindToMainCancel(_ sender: UIStoryboardSegue){
    
        }
}

// MARK: - EventCreationDelegate
extension ViewController: EventCreationDelegate {
    func didCreateEvent(_ event: Event) {
        let components = calendarView.calendar.dateComponents([.year, .month, .day], from: event.date)

        if events[components] != nil {
            events[components]?.append(event)
        } else {
            events[components] = [event]
        }

        calendarView.reloadDecorations(forDateComponents: [components], animated: true)
    }
}

// MARK: - UICalendarViewDelegate
extension ViewController: UICalendarViewDelegate {
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        if let dayEvents = events[dateComponents], !dayEvents.isEmpty {
            return .default(color: .systemBlue, size: .medium)
        }
        return nil
    }
}

// MARK: - UICalendarSelectionSingleDateDelegate
extension ViewController {
    @objc func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        selectedDate = dateComponents
    }
}

