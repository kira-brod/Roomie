//
//  HouseholdsHomeViewController.swift
//  Roomie
//
//  Created by Kira Brodsky on 5/26/25.
//

import UIKit
import FirebaseFirestore

class TableCell: UITableViewCell {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var roomieName: UILabel!
    @IBOutlet weak var roomiePhone: UILabel!
}

class HouseholdsHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let db = Firestore.firestore()
    
    struct Person {
        let name: String
        let phoneNum: String
        let color: UIColor
    }
    
    
    var roomies : [Person] = []

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var householdName: UITextField!
    
    @IBOutlet weak var Add: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        householdName.borderStyle = .none
        
        tableView.dataSource = self
        tableView.delegate = self
        
        householdName.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        householdName.placeholder = "Household Name"

        Add.layer.cornerRadius = Add.frame.width/2
        Add.layer.masksToBounds = true
        Add.titleLabel?.font = UIFont.systemFont(ofSize: 39, weight: .bold)
        tableView.allowsSelection = false
        tableView.isScrollEnabled = true
        
        db.collection("roomies").order(by:"name").addSnapshotListener {
            snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("error occured when fetching texts: \(error?.localizedDescription ?? "default error")")
                return
            }
            
            var dbRoomies : [Person] = []
            for doc in documents {
                let data = doc.data()
                guard let name = data["name"] as? String,
                      let phoneNum = data["phone"] as? String,
                      let color = data["color"] as? String else {
                    continue
                }
                
                let newRoomie = Person(name: name, phoneNum: phoneNum, color: convertColor(from: color))
                dbRoomies.append(newRoomie)
            }
            
            self.roomies = dbRoomies
            self.tableView.reloadData()
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
    }
    
    
    
    @IBAction func changedName(_ sender: UITextField) {
        if let text = sender.text, !text.isEmpty {
            householdName.text = sender.text
        }
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        roomies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
                    tableView.dequeueReusableCell(
                        withIdentifier: "RoomieCell",
                        for: indexPath
                    ) as! TableCell
                let user = roomies[indexPath.row]
                cell.roomieName.text = user.name
        cell.icon.tintColor = user.color
        cell.icon.image = UIImage(systemName: "person.fill")
        cell.roomiePhone.text = user.phoneNum
        return cell
    }
    
    @IBAction func AddAction(_ sender: Any) {
        performSegue(withIdentifier: "toHouseholdDetails", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toHouseholdDetails",
            let _ = segue.destination as? HouseholdDetailsViewController {
            
            }
        }
    
//    modalVC.onAddRoomie = {
//        [weak self] name, phone, color in
//        let newPerson = Person(name: name, phoneNum: phone, color: color ?? .black)
//        self?.roomies.append(newPerson)
//        self?.tableView.reloadData()
//    }
    
}
