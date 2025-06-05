//
//  ChoresHomeViewController.swift
//  Roomie
//
//  Created by Kira Brodsky on 5/26/25.
//

import UIKit
import FirebaseFirestore


class ChoresHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let db = Firestore.firestore()

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var H1: UILabel!
    @IBOutlet weak var Add: UIButton!
    
    var choresByDate: [Date: [Chore]] = [:]
    var sortedDates: [Date] = []
    func updateUI() {
        let hasChores = !choresByDate.values.flatMap { $0 }.isEmpty
        tableView.isHidden = !hasChores
        imageView.isHidden = hasChores
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.bringSubviewToFront(imageView)

        H1.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        
        Add.layer.cornerRadius = Add.frame.width/2
        Add.layer.masksToBounds = true
        Add.titleLabel?.font = UIFont.systemFont(ofSize: 39, weight: .bold)
        tableView.delegate = self
        tableView.dataSource = self

        //update empty state
        db.collection("chores").order(by: "date").addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("❌ Failed to fetch chores: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            var choresByDate: [Date: [Chore]] = [:]

            for doc in documents {
                let data = doc.data()
                guard
                    let title = data["title"] as? String,
                    let timestamp = data["date"] as? Timestamp,
                    let assignedTo = data["assignedTo"] as? String,
                    let colorHex = data["color"] as? String,
                    let notes = data["notes"] as? String
                else {
                    continue
                }

                let chore = Chore(
                    id: doc.documentID,
                    title: title,
                    date: timestamp.dateValue(),
                    assignedTo: assignedTo,
                    color: UIColor(hex: colorHex),
                    notes: notes
                )

                let day = Calendar.current.startOfDay(for: chore.date)
                choresByDate[day, default: []].append(chore)
            }

            self.choresByDate = choresByDate
            self.sortedDates = choresByDate.keys.sorted()
            self.tableView.reloadData()
            self.updateUI()
        }

    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let date = sortedDates[indexPath.section]
            var chores = choresByDate[date] ?? []
            let choreToDelete = chores[indexPath.row]
            
            // Remove from Firestore
            deleteChoreFromFirestore(chore: choreToDelete)
            
            // Remove from local data
            chores.remove(at: indexPath.row)
            if chores.isEmpty {
                choresByDate.removeValue(forKey: date)
            } else {
                choresByDate[date] = chores
            }
            sortedDates = choresByDate.keys.sorted()
            
            tableView.reloadData()
            updateUI()
        }
    }
    func deleteChoreFromFirestore(chore: Chore) {
        db.collection("chores").document(chore.id).delete { error in
            if let error = error {
                print("Failed to delete chore: \(error.localizedDescription)")
            } else {
                print("Chore deleted from Firestore.")
            }
        }
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        return sortedDates.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let date = sortedDates[section]
        return choresByDate[date]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let date = sortedDates[section]
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let date = sortedDates[indexPath.section]
        let chore = choresByDate[date]![indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "ChoreCell", for: indexPath)
        cell.textLabel?.text = chore.title
        cell.textLabel?.textColor = chore.color
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        cell.detailTextLabel?.text = chore.notes
        cell.detailTextLabel?.textColor = .gray
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
        return cell
    }



    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddChore", let destination = segue.destination as? AddChoreViewController {
        }
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
extension UIColor {
    convenience init(hex: String) {
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hex = hex.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)

        let r = CGFloat((rgb >> 16) & 0xff) / 255
        let g = CGFloat((rgb >> 8) & 0xff) / 255
        let b = CGFloat(rgb & 0xff) / 255

        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}

