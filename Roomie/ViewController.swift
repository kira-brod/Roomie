


import UIKit
import SwiftUI
import FirebaseCore
import FirebaseFirestore

struct Roomie {
    var id : String
    var name : String
    var phone : String
    var color : String
//    var email: String
//    var joinedAt: Timestamp
}



class ViewController: UIViewController, UICalendarSelectionSingleDateDelegate, UITableViewDelegate{
    
    @objc
    let db = Firestore.firestore()
    let colors: [String : UIColor] = ["red" : .systemRed, "blue" : .systemBlue, "green" : .systemGreen, "yellow" : .systemYellow, "purple" : .systemPurple]

    

    @IBOutlet weak var Add: UIButton!
    @IBOutlet weak var tblTable: UITableView!
    //    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var H2: UILabel!
    
    var calendarView: UICalendarView!
    var selectedDate: DateComponents?
    var events: [DateComponents: [Event]] = [:]
    var test: [DateComponents: [Event]] = [:]
    var event : Event?
    var roomies : [Roomie] = []
    var roommates : [String] = []
    var householdID = ""
    
    var stringTableData1: DataTable!
    
    class DataTable: NSObject, UITableViewDataSource {
        var data: [Event] = []
        var roomies: [Roomie] = []
        var colors: [String:UIColor] = [:]
        
        init(_ allEvents: [DateComponents: [Event]], _ selectedDate: DateComponents, _ roomies: [Roomie], _ colors: [String:UIColor]) {
            super.init()
            for (key, value) in allEvents {
                if let date1 = Calendar.current.date(from: key),
                   let date2 = Calendar.current.date(from: selectedDate),
                   Calendar.current.isDate(date1, inSameDayAs: date2) {
                    data = value
                    break
                }
            }
            self.roomies = roomies
            self.colors = colors
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
                cell.textLabel?.text = event.title
                cell.detailTextLabel?.text = event.note
                
                let icon = UIImage(systemName: "staroflife.fill")?.withRenderingMode(.alwaysTemplate)
                cell.imageView?.image = icon
                
                for i in 0..<roomies.count {
                    if roomies[i].name == event.roomie {
                        for j in 0..<colors.count{
                            if roomies[i].color == Array(colors.keys)[j] {
                                cell.imageView?.tintColor = colors[roomies[i].color]
                            }
                        }
                    }
                }
//                
//                if event.roomie == "Roomie 1" {
//                    cell.imageView?.tintColor = .systemRed
//                } else {
//                    cell.imageView?.tintColor = .systemPurple
//                }
                
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
        
        print("household: \(Singleton.shared.householdID)")
        
        
        //MARK: Roomies
        db.collection("households").document(Singleton.shared.householdID).collection("roomies").addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("Failed to fetch roomies: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
          

            var roomies: [Roomie] = []
            var roommates: [String] = []

            for doc in documents {
                let data = doc.data()
                guard
//                    let email = data["email"] as? String,
                    let phone = data["phone"] as? String,
                    let name = data["name"] as? String,
                    let color = data["color"] as? String
//                    let joinedAt = data["joinedAt"] as? Timestamp
                else {
                    continue
                }

                let roomie = Roomie(
                    id: doc.documentID,
                    name: name,
                    phone: phone,
                    color: color
//                    email: email,
//                    joinedAt: joinedAt
                )

                roomies.append(roomie)
                roommates.append(roomie.name)
            }
            

            self.roomies = roomies
            self.roommates = roommates
            print("self: \(self.roomies)")
//            print("posts: \(posts)")
            
//               self.stringTableData1 = DataTable(self.posts, self.roommateColors)
//               self.tblTable.dataSource = self.stringTableData1
//               self.tblTable.delegate = self
//               self.tblTable.reloadData()
            
            
//
            
            
        }
        
        print("roomies: \(roomies)")
        
        
        
        
        
        
        //MARK: Events
        db.collection("events").order(by: "date").addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("Failed to fetch events: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
//            print("documents: \(documents)")

            var eventsByDate: [DateComponents: [Event]] = [:]
            
            

            for doc in documents {
                let data = doc.data()
                guard
                    let title = data["title"] as? String,
                    let date = data["date"] as? Timestamp,
                    let note = data["note"] as? String,
                    let roomie = data["roomie"] as? String
                else {
//                    print("continue")
                    continue
                }

                let event = Event(
                    id: doc.documentID,
                    title: title,
                    date: date.dateValue(),
                    note: note,
                    roomie: roomie
                )
                

                let day = Calendar.current.dateComponents([.year, .month, .day], from: Calendar.current.startOfDay(for: event.date))
                eventsByDate[day, default: []].append(event)
            }
            
            self.events = eventsByDate
            
//            for (key, value) in eventsByDate {
////                self.test[Calendar.current.dateComponents([.year, .month, .day], from: key)] = value
//                if self.test[Calendar.current.dateComponents([.year, .month, .day], from: key)] != nil {
//                    self.test[Calendar.current.dateComponents([.year, .month, .day], from: key)]?.append(contentsOf: value)
//                } else {
//                    self.test[Calendar.current.dateComponents([.year, .month, .day], from: key)] = value
//                }
//            }
            
//            print("test: \(self.test)")
//            print("events by date: \(eventsByDate)")
//            print(count)
//            print("testing reload")
            
            
            
        }
        
        stringTableData1 = DataTable(events, selectedDate!, roomies, colors)
        tblTable.dataSource = stringTableData1
        tblTable.delegate = self
        
        tblTable.reloadData()
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
            controller?.roommates = roommates
        }
        
        if segue.identifier == "event" {
            let controller = segue.destination as? EventViewController
            controller?.event = event
            controller?.events = events
            print("Preparing for segue - indexPick: \(String(describing: event))")

            
            
        }
    }
    
    @IBAction func unwindToMain(_ sender: UIStoryboardSegue) {
        
    }
    @IBAction func unwindToMainCancel(_ sender: UIStoryboardSegue) {
        
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
        
        stringTableData1 = DataTable(events, selectedDate!, roomies, colors)
//        NSLog("event view b4 reload: \(test)")
        tblTable.dataSource = stringTableData1
        tblTable.reloadData()
        NSLog("roomies again: \(roomies)")
    }
}


    
    


    
