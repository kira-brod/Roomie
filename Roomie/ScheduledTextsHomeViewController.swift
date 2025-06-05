//
//  ScheduledTextsHomeViewController.swift
//  Roomie
//
//  Created by Kira Brodsky on 5/26/25.
//

import UIKit

class TextCell: UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
}

//class DateCell: UITableViewCell {
//    @IBOutlet weak var dateLabel: UILabel!
//}

struct Text {
    let title: String
    let time: Date
    let note : String
}

class ScheduledTextsHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
        // Do any additional setup after loading the view.
    }
    
    @IBAction func AddAction(_ sender: Any) {
        performSegue(withIdentifier: "toScheduleDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toScheduleDetails",
           let modalVC = segue.destination as? ScheduledTextsAddTextViewController {
            modalVC.onAddText = {
                [weak self] text, date, note in
                // extracting the date
                let calendar = Calendar.current
                let componentsDate = calendar.dateComponents([.year, .month, .day], from: date)
                let dateKey = calendar.date(from: componentsDate) ?? Date()
                
                // extracting the time
//                let componentsTime = calendar.dateComponents([.hour, .minute], from: date)
//                let today = calendar.startOfDay(for: Date())
//                let timeOnly = calendar.date(byAdding: componentsTime, to: today)
                
                let newText = Text(title: text, time: date, note: note)
                NSLog(note)
                
                // adding and sort
                var sortedTexts = self?.texts[dateKey] ?? []
                sortedTexts.append(newText)
                sortedTexts.sort{ $0.time < $1.time}
                self?.texts[dateKey] = sortedTexts
                
                self?.dateKeys = (self?.texts.keys.sorted())!
                self?.tableView.reloadData()
            }
        }
    }


}
