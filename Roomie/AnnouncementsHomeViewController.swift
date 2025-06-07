//
//  AnnouncementsHomeViewController.swift
//  Roomie
//
//  Created by Kira Brodsky on 6/3/25.
//

import UIKit

class AnnouncementsHomeViewController: UIViewController, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource  {

    @IBOutlet weak var tblTable: UITableView!
    @IBOutlet weak var H1: UILabel!
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var Input: UITextField!
    
    @IBOutlet weak var picker: UIPickerView!
    var announcements : [String] = []
    var indexSelected = 0
    
    var assignee : [String] = [""]
    
    let roommates = ["Roomie 1", "Roomie 2", "Roomie 3", "Roomie 4", "Roomie 5"]

    let roommateColors: [String: UIColor] = [
        "Roomie 1": .red,
        "Roomie 2": .blue,
        "Roomie 3": .green,
        "Roomie 4": .yellow,
        "Roomie 5": .purple
    ]
    

    
    
    class DataTable: NSObject, UITableViewDataSource {
        var data: [String] = []
        var person : [String] = []
        var colors : [String: UIColor] = [:]
        var i : Int = 0
        
        init(_ announcements: [String], _ person: [String], _ colors : [String: UIColor]) {
            super.init()
            data = announcements
            self.person = person
            self.colors = colors
            
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return max(data.count, 0)
        }
        
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StringCell")!
            if data.isEmpty {
                cell.textLabel?.text = "No Events"
                cell.detailTextLabel?.text = ""
            } else {
                let announcement = data[indexPath.row]
                cell.textLabel?.text = person[indexPath.row]
                cell.detailTextLabel?.text = announcement
                
                let icon = UIImage(systemName: "staroflife.fill")?.withRenderingMode(.alwaysTemplate)
                cell.imageView?.image = icon
                cell.imageView?.tintColor = colors[person[indexPath.row]]
                
//                if event.roomie == "Roomie 1" {
//                    cell.imageView?.tintColor = .systemRed
//                } else {
//                    cell.imageView?.tintColor = .systemPurple
//                }
                
            }
            
            
            
            return cell
        }
        
    
    }
    var stringTableData1 = DataTable(["announcements"], [], [:])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        H1.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        
        picker.delegate = self
        picker.dataSource = self

        stringTableData1 = DataTable(announcements, assignee, roommateColors)
        tblTable.dataSource = stringTableData1
        tblTable.delegate = self
        // Do any additional setup after loading the view.
        
        if !announcements.isEmpty {
            image.isHidden = true
        } else {
            image.isHidden = false
        }
    }
    
    @IBAction func Post(_ sender: Any) {
        announcements.append(Input.text ?? "No announcement")
        assignee.append(roommates[indexSelected])
        stringTableData1 = DataTable(announcements, assignee, roommateColors)
        
        tblTable.dataSource = stringTableData1
        tblTable.reloadData()
        image.isHidden = true
        
    }
    

    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return roommates.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return roommates[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        indexSelected = row
    }
    

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
