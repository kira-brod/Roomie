


import UIKit

class ViewController: UIViewController, UICalendarSelectionSingleDateDelegate, UITableViewDelegate{
    
    @objc 
    

    @IBOutlet weak var Add: UIButton!
    @IBOutlet weak var tblTable: UITableView!
    //    @IBOutlet weak var textView: UITextView!
    
    var calendarView: UICalendarView!
    var selectedDate: DateComponents?
    var events: [DateComponents: [Event]] = [:]
    
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
        
        let today = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        selectedDate = today
        
        stringTableData1 = DataTable(events, selectedDate!)
        tblTable.dataSource = stringTableData1
        tblTable.delegate = self
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
    }
}

    
//    var calendarView: UICalendarView!
//    var selectedDate: DateComponents?
//    var events: [DateComponents: [Event]] = [:]
//    
//    
//    class DataTable : NSObject, UITableViewDataSource {
//        
//        var data : [DateComponents: [Event]] = [:]
//        var selectDate : DateComponents?
//
//
//        
//        var names : [String] = []
//        var detail : [String] = []
//        
//        
//        
//        
//        init(_ items : [DateComponents: [Event]], _ selectedDate : DateComponents ){
//            data = items
//            selectDate = selectedDate
//            var dateComp = selectedDate
//
//            
//            for component in items.keys {
//                if component.day == selectedDate.day {
//                    dateComp = component
//                    
//                }
//            }
//            
//            for index in 0..<items.count {
//                for i in 0..<(items[dateComp]?.count ?? 0) {
//                    names.append(items[dateComp]?[i].id ?? "No Events")
//                    detail.append(items[dateComp]?[i].note ?? "No Notes")
//                }
//            }
//           
//            
//        }
//        
//        init(_ names : [String], _ detail : [String]) {
//            self.names = names
//            self.detail = detail
//            
//            
//            
//
//        }
//        
//        
//        
////        func numberOfSections(in tableView: UITableView) -> Int {
////            return data.keys.count
////        }
////        func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
////            return (Array(data.keys))[section]
////        }
//        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//            return data[selectDate ?? Calendar.current.dateComponents([.year, .month, .day], from: Date())]?.count ?? 1
//        }
//        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//            
//        }
//        
//        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//            
//            let cell = tableView.dequeueReusableCell(withIdentifier: "StringCell")!
//            
//            cell.textLabel?.text = (names)[indexPath.row]
//            cell.detailTextLabel?.text = (detail)[indexPath.row]
//            return cell
//        }
//
//    }
//    
////    var stringTableData1 = DataTable(events, Calendar.current.dateComponents([.year, .month, .day], from: Date()))
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        createCalendar()
//        
////        textView.text = ("\(events)")
//        
//        
//
//        Add.layer.cornerRadius = Add.frame.width / 2
//        Add.layer.masksToBounds = true
//        Add.titleLabel?.font = UIFont.systemFont(ofSize: 39, weight: .bold)
//        
//        let today = Calendar.current.dateComponents([.year, .month, .day], from: Date())
//        selectedDate = today
////        updateEventsTextView(for: today)
//        
//        
//        
//        let stringTableData1 = DataTable(events, selectedDate ?? today)
//        
//        tblTable.dataSource = stringTableData1
//        tblTable.delegate = self
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
////        updateEventsTextView(for: selectedDate)
//    }
//
//    func createCalendar() {
//        calendarView = UICalendarView()
//        calendarView.translatesAutoresizingMaskIntoConstraints = false
//        calendarView.calendar = .current
//        calendarView.locale = .current
//        calendarView.fontDesign = .rounded
//        calendarView.delegate = self
//
//        let selection = UICalendarSelectionSingleDate(delegate: self)
//        calendarView.selectionBehavior = selection
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
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
////       if let navVC = segue.destination as? UINavigationController,
////        let addVC = navVC.topViewController as? AddEventViewController {
////         addVC.delegate = self
////         addVC.selectedDate = selectedDate
////     }
//        
//        if segue.identifier == "addEvent" {
//                let controller = segue.destination as? AddEventViewController
//                controller?.events = events
//        }
//    }
//    
//        @IBAction func unwindToMain(_ sender: UIStoryboardSegue) {
//    
//        }
//    
//        @IBAction func unwindToMainCancel(_ sender: UIStoryboardSegue){
//    
//        }
//    
//    
//    
//    func updateTextView(_ dateComponents: DateComponents?) {
//        
//        var dateComp = calendarView.calendar.dateComponents([.year, .month, .day], from: Date.now)
//        
//        for component in events.keys {
//            if component.day == dateComponents?.day {
//                dateComp = component
//                
//            }
//        }
//        
////        let event = Event(id: "hello", date: Date.now, note:"string")
////        textView.text = ("\(String(describing: events[dateComp]))")
////        textView.text = ("\(String(describing: events[dateComp]?[0].id))")
//
//    }
//}
//
//
////UICalendarViewDelegate
//extension ViewController: UICalendarViewDelegate {
//    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
//        if let dayEvents = events[dateComponents], !dayEvents.isEmpty {
//            return .default(color: .systemBlue, size: .medium)
//        }
//        return nil
//    }
//}
//
//// UICalendarSelectionSingleDateDelegate
//extension ViewController {
//    @objc func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
//        selectedDate = dateComponents
//        NSLog("\(String(describing: dateComponents?.day))")
//        NSLog("\(events)")
//        updateTextView(selectedDate)
//    }
//}

