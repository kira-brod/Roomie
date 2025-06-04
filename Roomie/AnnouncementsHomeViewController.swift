//
//  AnnouncementsHomeViewController.swift
//  Roomie
//
//  Created by Kira Brodsky on 6/3/25.
//

import UIKit

class AnnouncementsHomeViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tblTable: UITableView!
    @IBOutlet weak var H1: UILabel!
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var Input: UITextField!
    
    var announcements : [String] = []
    
    class DataTable: NSObject, UITableViewDataSource {
        var data: [String] = []
        
        init(_ announcements: [String]) {
            super.init()
            data = announcements
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
                cell.textLabel?.text = "name"
                cell.detailTextLabel?.text = announcement
                
                let icon = UIImage(systemName: "staroflife.fill")?.withRenderingMode(.alwaysTemplate)
                cell.imageView?.image = icon
                
//                if event.roomie == "Roomie 1" {
//                    cell.imageView?.tintColor = .systemRed
//                } else {
//                    cell.imageView?.tintColor = .systemPurple
//                }
                
            }
            
            
            
            return cell
        }
        
    
    }
    
    var stringTableData1 = DataTable(["announcements"])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        H1.font = UIFont.systemFont(ofSize: 30, weight: .bold)

        stringTableData1 = DataTable(announcements)
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
        stringTableData1 = DataTable(announcements)
        
        tblTable.dataSource = stringTableData1
        tblTable.reloadData()
        image.isHidden = true
        
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
