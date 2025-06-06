//
//  ScheduledTextsHomeViewController.swift
//  Roomie
//
//  Created by Kira Brodsky on 5/26/25.
//

import UIKit
import FirebaseFirestore

class TextCell: UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
}

struct Text {
    let title: String
    let time: Date
    let note : String
}

class ScheduledTextsHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
        cell.timeLabel.text = timeStr
        
        return cell
    }
    

    @IBOutlet weak var H1: UILabel!
    @IBOutlet weak var Add: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    // key -> date,
    var texts : [Date : [Text]] = [:]
    var dateKeys : [Date] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        H1.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        
        Add.layer.cornerRadius = Add.frame.width/2
        Add.layer.masksToBounds = true
        Add.titleLabel?.font = UIFont.systemFont(ofSize: 39, weight: .bold)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        // fetching from firebase
        db.collection("texts").order(by:"date")
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
                        let date = data["date"] as? Timestamp else {
                        continue
                    }
                    
                    let newText = Text(title: title, time: date.dateValue(), note: note)
                    
                    let calendar = Calendar.current
                    let componentsDate = calendar.dateComponents([.year, .month, .day], from: date.dateValue())
                    let dateKey = calendar.date(from: componentsDate) ?? Date()
                    
                    var sortedTexts = texts[dateKey] ?? []
    
                    sortedTexts.append(newText)
                    sortedTexts.sort{ $0.time < $1.time}
                    texts[dateKey] = sortedTexts
                }
                
                self.texts = texts
                self.dateKeys = texts.keys.sorted()
                self.tableView.reloadData()
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
