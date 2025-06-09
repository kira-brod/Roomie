//
//  ScheduledTextsHomeViewController.swift
//  Roomie
//
//  Created by Kira Brodsky on 5/26/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import UserNotifications

class TextCell: UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
}

struct Text {
    let title: String
    let time: Date
    let note : String
    let assignedTo : String
    let notificationID : String
}

class ScheduledTextsHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var roomieColors : [String : UIColor] = [:]
    let db = Firestore.firestore()
    
    func numberOfSections(in: UITableView) -> Int {
        return texts.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return texts[dateKeys[section]]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
//     configuring the section date headers
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = .systemBackground
        
        let topLine = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 1))
                topLine.backgroundColor = .lightGray
                header.addSubview(topLine)
        
        let date = dateKeys[section]
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
           label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
           label.textColor = .black
        label.text = formatter.string(from: date)
          header.addSubview(label)
        
        NSLayoutConstraint.activate([
             label.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
             label.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -16),
             label.topAnchor.constraint(equalTo: header.topAnchor, constant: 5),
             label.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -5)
         ])
        
        return header
    }
    
    // configuring prototype cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath) as! TextCell
        // indexPath = [section: 0, row: 0]
        let textArr = texts[dateKeys[indexPath.section]]
        let textObj = textArr?[indexPath.row]
        cell.titleLabel.text = textObj?.title
        cell.noteLabel.text = textObj?.note
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        let timeStr = formatter.string(from: textObj?.time ?? Date())
        
        if let name = textObj?.assignedTo, let color = roomieColors[name] {
            cell.timeLabel.textColor = color
           
                
            cell.contentView.layer.sublayers?.removeAll(where: { $0.name == "leftBorder" })
            let leftBorder = CALayer()
        leftBorder.backgroundColor = color.cgColor
            leftBorder.frame = CGRect(x: 0, y: 0, width: 4, height: cell.contentView.frame.height)
            cell.contentView.layer.addSublayer(leftBorder)
        }
        cell.timeLabel.text = timeStr
        return cell
    }
    
    // configuring swipe to delete:
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let date = dateKeys[indexPath.section]
            let textToDelete = texts[date]![indexPath.row]
            
            // remove firebase
            deleteFromFireStore(text: textToDelete)
            
            // remove locally
            var textArr = texts[date]!
            textArr.remove(at: indexPath.row)
            if textArr.isEmpty {
                texts.removeValue(forKey: date)
            } else {
                texts[date] = textArr
            }
            dateKeys = texts.keys.sorted()
            toggleUI()
            tableView.reloadData()
        }
    }
    
    func deleteFromFireStore(text: Text) {
        db.collection("households").document(UserDefaults.standard.string(forKey: "householdID")!).collection("texts").whereField("title", isEqualTo: text.title).whereField("note", isEqualTo: text.note).getDocuments { (snapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
            }
            
            guard let documents = snapshot?.documents, let doc = documents.first else {
                print("Couldn't find text to delete")
                return
            }
            doc.reference.delete { error in
                if let error = error {
                    print("Failed to delete chore: \(error.localizedDescription)")
                } else {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [text.notificationID])
                    print("Chore deleted from Firestore.")
                }
            }
        }
    }

    @IBOutlet weak var H1: UILabel!
    @IBOutlet weak var Add: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    // key -> date,
    var texts : [Date : [Text]] = [:]
    var dateKeys : [Date] = []
    
    func toggleUI() {
        let isEmpty = texts.values.flatMap { $0
        }.isEmpty
        tableView.isHidden = isEmpty
        imageView.isHidden = !isEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // UI styling
        self.toggleUI()
        H1.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        Add.layer.cornerRadius = Add.frame.width/2
        Add.layer.masksToBounds = true
        Add.titleLabel?.font = UIFont.systemFont(ofSize: 39, weight: .bold)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = true
        tableView.allowsSelection = false
    }
    
    override func viewDidAppear(_ animated : Bool) {
        super.viewDidAppear(animated)
        fetchRoomiesAndListenForTexts()
    }
    
    func fetchRoomiesAndListenForTexts() {
        // fetching all roomies and colors
        db.collection("households").document(UserDefaults.standard.string(forKey: "householdID")!).collection("roomies").addSnapshotListener {snapshot, error in
            if let docs = snapshot?.documents {
                for doc in docs {
                    let name = doc["name"] as? String ?? ""
                    let color = doc["color"] as? String ?? ""
                    self.roomieColors[name] = self.convertColor(from: color)
                }
            }
            self.listenForTexts()
        }
    }
    
    func listenForTexts() {
        // fetching from firebase
        self.db.collection("households").document(UserDefaults.standard.string(forKey: "householdID")!).collection("texts").order(by:"date")
            .addSnapshotListener {
                snapshot, error in
                
                guard let documents = snapshot?.documents, error == nil else {
                    print("error occured when fetching texts: \(error?.localizedDescription ?? "default error")")
                    return
                    
                }
                // configuring the arrays
                var texts : [Date : [Text]] = [:]
                for doc in documents {
                    let data = doc.data()
                    guard
                        let title = data["title"] as? String,
                            let note = data["note"] as? String,
                        let date = data["date"] as? Timestamp,
                    let assignedTo = data["assignedTo"] as? String,
                        let notifID = data["notificationID"] as? String
                    else {
                        continue
                    }
                    // filtering out overdue texts
                    let dateVal = date.dateValue()
                    if dateVal < Date() {
                        let expiredText = Text(
                                    title: title,
                                    time: dateVal,
                                    note: note,
                                    assignedTo: assignedTo,
                                    notificationID: notifID
                                )
                        self.deleteFromFireStore(text: expiredText)
                        continue
                    }
                    
                    // adding to local text feild
                    let newText = Text(title: title, time: date.dateValue(), note: note, assignedTo: assignedTo, notificationID: notifID)

                    let calendar = Calendar.current
                    let componentsDate = calendar.dateComponents([.year, .month, .day], from: dateVal)
                    let dateKey = calendar.date(from: componentsDate) ?? Date()
                    
                    var sortedTexts = texts[dateKey] ?? []
    
                    sortedTexts.append(newText)
                    sortedTexts.sort{ $0.time < $1.time}
                    texts[dateKey] = sortedTexts
                }
                
                self.texts = texts
                self.dateKeys = texts.keys.sorted()
                
                DispatchQueue.main.async {
                    self.toggleUI()
                               self.tableView.reloadData()
                           }
        }
        
    }
    
    func convertColor(from name: String) -> UIColor {
        switch name.lowercased() {
        case "red" : return .systemRed
        case "blue" : return .systemBlue
        case "green" : return .systemGreen
        case "yellow" : return .systemYellow
        case "purple" : return .systemPurple
        case "gray" : return .systemGray
        default : return .gray
        }
    }
        
    @IBAction func AddAction(_ sender: Any) {
        performSegue(withIdentifier: "toScheduleDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toScheduleDetails",
           let _ = segue.destination as? ScheduledTextsAddTextViewController {
        }
    }


}
