


import UIKit
import SwiftUI
import FirebaseCore



class ViewController: UIViewController, UICalendarSelectionSingleDateDelegate, UITableViewDelegate{
    
    @objc 
    

    @IBOutlet weak var Add: UIButton!
    @IBOutlet weak var tblTable: UITableView!
    //    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var H2: UILabel!
    
    var calendarView: UICalendarView!
    var selectedDate: DateComponents?
    var events: [DateComponents: [Event]] = [:]
    var event : Event?
    
    var stringTableData1: DataTable!
    
    class DataTable: NSObject, UITableViewDataSource {
        var data: [Event] = []
        
        init(_ allEvents: [DateComponents: [Event]], _ selectedDate: DateComponents) {
            super.init()
            for (key, value) in allEvents {
                if let date1 = Calendar.current.date(from: key),
                   let date2 = Calendar.current.date(from: selectedDate),
                   Calendar.current.isDate(date1, inSameDayAs: date2) {
                    data = value
                    break
                }
            }
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return max(data.count, 1)
        }
        
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StringCell")!
            if data.isEmpty {
                cell.textLabel?.text = "No Events"
                cell.detailTextLabel?.text = ""
            } else {
                let event = data[indexPath.row]
                cell.textLabel?.text = event.id
                cell.detailTextLabel?.text = event.note
                
                let icon = UIImage(systemName: "staroflife.fill")?.withRenderingMode(.alwaysTemplate)
                cell.imageView?.image = icon
                
                if event.roomie == "Roomie 1" {
                    cell.imageView?.tintColor = .systemRed
                } else {
                    cell.imageView?.tintColor = .systemPurple
                }
                
            }
            
            
            
            return cell
        }
        
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createCalendar()
        
        Add.layer.cornerRadius = Add.frame.width / 2
        Add.layer.masksToBounds = true
        Add.titleLabel?.font = UIFont.systemFont(ofSize: 39, weight: .bold)
        
        H2.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        
        let today = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        selectedDate = today
        
        stringTableData1 = DataTable(events, selectedDate!)
        tblTable.dataSource = stringTableData1
        tblTable.delegate = self
    }
    
    func tableView (_ tableView : UITableView, didSelectRowAt indexPath : IndexPath) {
        
        if !stringTableData1.data.isEmpty {
                self.event = stringTableData1.data[indexPath.row]
             performSegue(withIdentifier: "event", sender: nil)

            } else {
                self.event = nil
            }
        
        tableView.deselectRow(at: indexPath, animated: true)

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
            calendarView.heightAnchor.constraint(equalToConstant: 450),
            calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addEvent" {
            let controller = segue.destination as? AddEventViewController
            controller?.events = events
        }
        
        if segue.identifier == "event" {
            let controller = segue.destination as? EventViewController
            controller?.event = event
            print("Preparing for segue - indexPick: \(String(describing: event))")

            
            
        }
    }
    
    @IBAction func unwindToMain(_ sender: UIStoryboardSegue) {
        
    }
    @IBAction func unwindToMainCancel(_ sender: UIStoryboardSegue) {
        
    }
    
    func updateTextView(_ dateComponents: DateComponents?) {
        // You can add logic here to update a text view if needed
    }
}



extension ViewController: UICalendarViewDelegate {
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        if let dayEvents = events[dateComponents], !dayEvents.isEmpty {
            return .default(color: .systemBlue, size: .medium)
        }
        return nil
    }
}

extension ViewController {
    @objc func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        guard let dateComponents = dateComponents else { return }
        selectedDate = dateComponents
        
        stringTableData1 = DataTable(events, selectedDate!)
        tblTable.dataSource = stringTableData1
        tblTable.reloadData()
        NSLog("event added: \(events)")
    }
}


    
    


    
