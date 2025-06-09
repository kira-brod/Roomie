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
    
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var joinCode: UILabel!
    
    @IBOutlet weak var Add: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
                
        tableView.dataSource = self
        tableView.delegate = self
        pageTitle.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        joinCode.font = UIFont.systemFont(ofSize: 30)
        joinCode.text = "Join Code: \(UserDefaults.standard.string(forKey: "householdID")!.prefix(6))"

        Add.layer.cornerRadius = Add.frame.width/2
        Add.layer.masksToBounds = true
        Add.titleLabel?.font = UIFont.systemFont(ofSize: 39, weight: .bold)
        tableView.allowsSelection = false
        tableView.isScrollEnabled = true
        
        db.collection("households").document(UserDefaults.standard.string(forKey: "householdID")!).collection("roomies").order(by:"name").addSnapshotListener {
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
    
    // configuring delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let roomieToDelete = roomies[indexPath.row]
            
            // remove firebase
            deleteFromFireStore(roomie: roomieToDelete)
            
            // remove locally
            roomies.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    func deleteFromFireStore(roomie: Person) {
        db.collection("households").document(UserDefaults.standard.string(forKey: "householdID")!).collection("roomies").whereField("name", isEqualTo: roomie.name).whereField("phone", isEqualTo: roomie.phoneNum).getDocuments { (snapshot, err) in
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
                    print("Chore deleted from Firestore.")
                }
            }
        }
    }
    
    @IBAction func AddAction(_ sender: Any) {
        performSegue(withIdentifier: "toHouseholdDetails", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toHouseholdDetails",
            let _ = segue.destination as? HouseholdDetailsViewController {
            
            }
        }
    
}
