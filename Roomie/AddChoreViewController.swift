//
//  AddChoreViewController.swift
//  Roomie
//
//  Created by Mor Vered on 6/1/25.
//

import UIKit
import FirebaseFirestore


struct Chore {
    let id: String
    let title: String
    let date: Date
    let assignedTo: String
    let color: UIColor
    let notes: String?
}


class AddChoreViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {
    let db = Firestore.firestore()
    var roommates: [String] = []

    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBOutlet weak var choreName: UITextField!
    @IBOutlet weak var choreDate: UIDatePicker!
    
    let colorPalette: [UIColor] = [.red, .blue, .green, .yellow, .purple, .orange, .cyan]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        Roomie.delegate = self
        Roomie.dataSource = self
        fetchRoommatesFromFirestore()
    }

    func fetchRoommatesFromFirestore() {
        guard let householdID = UserDefaults.standard.string(forKey: "householdID") else { return }

        db.collection("households").document(householdID).collection("memberLogin").getDocuments { snapshot, error in
            if let error = error {
                print("Failed to fetch roommates: \(error)")
                return
            }

            self.roommates = snapshot?.documents.compactMap { $0.data()["name"] as? String } ?? []
            DispatchQueue.main.async {
                self.Roomie.reloadAllComponents()
            }
        }
    }
    func colorForRoommate(_ name: String) -> UIColor {
        if let index = roommates.firstIndex(of: name) {
            return colorPalette[index % colorPalette.count]
        }
        return .gray
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

    @IBOutlet weak var Roomie: UIPickerView!
    @IBOutlet weak var choreNotes: UITextField!

    
    @IBAction func add(_ sender: Any) {
        print("Add button tapped")

        let title = choreName.text ?? ""
        let date = choreDate.date
        let selectedRow = Roomie.selectedRow(inComponent: 0)
        let assignedTo = roommates[selectedRow]
        let color = colorForRoommate(assignedTo)
        let notes = choreNotes.text
        let colorHex = color.toHexString()

        guard let householdID = UserDefaults.standard.string(forKey: "householdID") else {
            print("No householdID found in UserDefaults")
            return
        }

        let docRef = db.collection("households").document(householdID).collection("chores").document()

        let choreData: [String: Any] = [
            "title": title,
            "date": Timestamp(date: date),
            "assignedTo": assignedTo,
            "color": colorHex,
            "notes": notes ?? ""
        ]

        docRef.setData(choreData) { error in
            if let error = error {
                print("Error adding chore: \(error.localizedDescription)")
            } else {
                print("Chore added under household \(householdID)")
                let chore = Chore(id: docRef.documentID, title: title, date: date, assignedTo: assignedTo, color: color, notes: notes)
                self.dismiss(animated: true)
            }
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
    func toHexString() -> String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255)
        return String(format: "#%06x", rgb)
    }
}
