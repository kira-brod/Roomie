//
//  AnnouncementsHomeViewController.swift
//  Roomie
//
//  Created by Kira Brodsky on 6/3/25.
//

import UIKit
import FirebaseFirestore


class AnnouncementsHomeViewController: UIViewController, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource  {

    @IBOutlet weak var tblTable: UITableView!
    @IBOutlet weak var H1: UILabel!
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var Input: UITextField!
    
    @IBOutlet weak var picker: UIPickerView!
    var announcements : [String] = []
    var indexSelected = 0
    
    let db = Firestore.firestore()
    var posts : [Announcement] = []
    var roomies : [Roomie] = []
    
    var assignee : [String] = []
    
//    let roommates = ["Roomie 1", "Roomie 2", "Roomie 3", "Roomie 4", "Roomie 5"]
    var roommates : [String] = []
    let roommateColors: [String : UIColor] = ["red" : .systemRed, "blue" : .systemBlue, "green" : .systemGreen, "yellow" : .systemYellow, "purple" : .systemPurple]

//    let roommateColors: [String: UIColor] = [
//        "Roomie 1": .red,
//        "Roomie 2": .blue,
//        "Roomie 3": .green,
//        "Roomie 4": .yellow,
//        "Roomie 5": .purple
//    ]
    

    
    
    class DataTable: NSObject, UITableViewDataSource {
        var data: [String] = []
        var person : [String] = []
        var colors : [String: UIColor] = [:]
        var posts : [Announcement] = []
        var roomies : [Roomie] = []
        var i : Int = 0
        
        let db = Firestore.firestore()
        
        init(_ posts : [Announcement], _ colors : [String: UIColor], _ roomies : [Roomie]) {
            super.init()
//            data = announcements
//            self.person = person
            self.colors = colors
            self.posts = posts
            self.roomies = roomies
            
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return max(posts.count, 0)
        }
        
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StringCell")!
            if posts.isEmpty {
                cell.textLabel?.text = "No Events"
                cell.detailTextLabel?.text = ""
            } else {
                let announcement = posts[indexPath.row].notes
                cell.textLabel?.text = posts[indexPath.row].roomie
                cell.detailTextLabel?.text = announcement
                
                print("person: \(person)")
                
                let icon = UIImage(systemName: "staroflife.fill")?.withRenderingMode(.alwaysTemplate)
                cell.imageView?.image = icon
//                cell.imageView?.tintColor = colors[posts[indexPath.row].roomie]
                
                for i in 0..<roomies.count {
                    if roomies[i].name == posts[indexPath.row].roomie {
                        for j in 0..<colors.count{
                            if roomies[i].color == Array(colors.keys)[j] {
                                cell.imageView?.tintColor = colors[roomies[i].color]
                            }
                        }
                    }
                }
                
//                if event.roomie == "Roomie 1" {
//                    cell.imageView?.tintColor = .systemRed
//                } else {
//                    cell.imageView?.tintColor = .systemPurple
//                }
                
            }
            
            
            
            return cell
        }
        
        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
//                let date = sortedDates[indexPath.section]
//                var chores = choresByDate[date] ?? []
                let postToDelete = posts[indexPath.row]
                
                // Remove from Firestore
                deletePostFromFirestore(post: postToDelete)
                
                // Remove from local data
                posts.remove(at: indexPath.row)
                if posts.isEmpty {
//                    choresByDate.removeValue(forKey: date)
                } else {
                    for i in 0..<posts.count {
                        if posts[i].notes == postToDelete.notes {
                            posts.remove(at: i)
                            break
                        }
                    }
                }
//                sortedDates = choresByDate.keys.sorted()
                
                tableView.reloadData()
                
                
//                updateUI()
            }
        }
        func deletePostFromFirestore(post: Announcement) {
            db.collection("announcements").document(post.id).delete { error in
                if let error = error {
                    print("Failed to delete chore: \(error.localizedDescription)")
                } else {
                    print("Chore deleted from Firestore.")
                }
            }
        }
        
    
    }
    var stringTableData1 = DataTable([Announcement(id: "hi", roomie: "hi", notes: "hi")], [:], [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        H1.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        
        

//        stringTableData1 = DataTable(posts, roommateColors)
//        tblTable.dataSource = stringTableData1
//        tblTable.delegate = self
        // Do any additional setup after loading the view.
        
        if !announcements.isEmpty {
            image.isHidden = true
        } else {
            image.isHidden = false
        }
        
        //MARK: Roomies
        db.collection("households").document("1C12762C-9083-43BC-B127-FB2FDEE942B3").collection("roomies").addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("Failed to fetch roomies: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            var roomies: [Roomie] = []
            var roommates: [String] = []

            for doc in documents {
                let data = doc.data()
                guard
                    let email = data["email"] as? String,
                    let phone = data["phone"] as? String,
                    let name = data["name"] as? String,
                    let color = data["color"] as? String,
                    let joinedAt = data["joinedAt"] as? Timestamp
                else {
                    continue
                }

                let roomie = Roomie(
                    id: doc.documentID,
                    name: name,
                    phone: phone,
                    color: color,
                    email: email,
                    joinedAt: joinedAt
                )

                roomies.append(roomie)
                roommates.append(roomie.name)
            }
            

            self.roomies = roomies
            self.roommates = roommates
            print("self: \(self.roomies)")
            print("roommates: \(self.roommates)")
            
            self.picker.delegate = self
            self.picker.dataSource = self
            
//               self.stringTableData1 = DataTable(self.posts, self.roommateColors)
//               self.tblTable.dataSource = self.stringTableData1
//               self.tblTable.delegate = self
//               self.tblTable.reloadData()
//
            
            
        }
        
        print("roomies: \(roomies)")
        
        
        
        
        //MARK: Announcements
        db.collection("announcements").addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("Failed to fetch announcements: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
          

            var posts: [Announcement] = []

            for doc in documents {
                let data = doc.data()
                guard
                    let roomie = data["roomie"] as? String,
                    let notes = data["notes"] as? String
                else {
                    continue
                }

                let post = Announcement(
                    id: doc.documentID,
                    roomie: roomie,
                    notes: notes
                )

                posts.append(post)
            }
            

            self.posts = posts
//            print("self: \(self.posts)")
//            print("posts: \(posts)")
            
            self.stringTableData1 = DataTable(self.posts, self.roommateColors, self.roomies)
               self.tblTable.dataSource = self.stringTableData1
               self.tblTable.delegate = self
               self.tblTable.reloadData()
               
            
            
        }
        
//        stringTableData1 = DataTable(posts, roommateColors)
//        tblTable.dataSource = stringTableData1
//        tblTable.delegate = self
//        
//        tblTable.reloadData()
//        
//        print("posts1: \(posts)")
    }
    
    @IBAction func Post(_ sender: Any) {
        let notes = Input.text
        let roomie = roommates[indexSelected]
        
        announcements.append(Input.text ?? "No announcement")
        assignee.append(roommates[indexSelected])
        stringTableData1 = DataTable(posts, roommateColors, roomies)
        
        tblTable.dataSource = stringTableData1
        tblTable.reloadData()
        image.isHidden = true
        
        
        let db = Firestore.firestore()
        let docRef = db.collection("announcements").document()
        
        let postData: [String: Any] = [
            "notes": notes,
            "roomie": roomie
        ]
        
        docRef.setData(postData) { error in
            if let error = error {
                print("Error adding chore: \(error.localizedDescription)")
            } else {
                print("Event added to Firestore.")
                let post = Announcement(id: "", roomie: roomie, notes: notes ?? "No Post")
                
//                if self.events[dateComp] != nil {
//                    self.events[dateComp]?.append(event)
//                } else {
//                    self.events[dateComp] = [event]
//                }
                
//                self.dismiss(animated: true)
            }
        }
        
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
