//
//  ScheduledTextsAddTextViewController.swift
//  Roomie
//
//  Created by Kira Brodsky on 5/27/25.
//

import UIKit
import FirebaseFirestore
import UserNotifications

class ScheduledTextsAddTextViewController: UIViewController, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    let db = Firestore.firestore()

//    @IBOutlet weak var Cancel: UIButton!
    @IBOutlet weak var Notes: UITextView!
    
    @IBOutlet weak var Add: UIButton!
    @IBOutlet weak var Cancel: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var reminderTitle: UITextField!
    
    @IBOutlet weak var roomiePicker: UIPickerView!
    
//    var date: Date?
//    var textTitle: String?
//    var note: String?
    var roomies: [String] = []
    let notificationCenter = UNUserNotificationCenter.current()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reminderTitle.placeholder = "Reminder Title"
        Notes!.layer.borderWidth = 1
        Notes!.layer.borderColor = UIColor.lightGray.cgColor
        Notes!.layer.cornerRadius = 5.0
        Notes.text = "Notes"
        Notes.textColor = .lightGray
        Notes.delegate = self
        roomiePicker.delegate = self
        roomiePicker.dataSource = self
        Add.layer.cornerRadius = 10
        Cancel.layer.cornerRadius = 10
        
        //configuring notifs authorization
        notificationCenter.requestAuthorization(options: [.alert, .sound]) {
            (permissionGranted, error) in
            if (!permissionGranted) {
                print("Permission Denied")
            }
        }
        
    db.collection("households").document(UserDefaults.standard.string(forKey: "householdID")!).collection("roomies").addSnapshotListener { snapshot, error in
            if let error = error { return }
            guard let documents = snapshot?.documents else {
                return
            }
            for doc in documents {
                let data = doc.data()
                let name = data["name"] as? String ?? "(No Name)"
                self.roomies.append(name)
            }
            
            DispatchQueue.main.async {
                self.roomiePicker.reloadAllComponents()
            }
        }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return roomies.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return roomies[row]
    }
    
    // formatting notes placeholder
    func textViewDidEndEditing(_ textView: UITextView) {
        if Notes.text.isEmpty {
            Notes.text = "Notes"
            Notes.textColor = .lightGray
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if Notes.textColor == .lightGray {
            Notes.textColor = .black
            Notes.text = ""
        }
    }
//    // passing data back to home VC, dismissing modal
//    var onAddText: ((String, Date, String)-> Void)?
    
    @IBAction func addText(_ sender: UIButton) {
        if roomies.isEmpty {
            let alert = UIAlertController(title: "Error", message: "Add roomies to your household.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        let noteText = Notes.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let titleText = reminderTitle.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        let date = datePicker.date
     
        if date < Date() {
            let alert = UIAlertController(title: "Error", message: "The selected date is in the past.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        let selectedRow = roomiePicker.selectedRow(inComponent: 0)
        let assignedTo = roomies[selectedRow]
        
        //configuring notification
        let notificationID = UUID().uuidString
        notificationCenter.getNotificationSettings { (settings) in
            if (settings.authorizationStatus == .authorized) {
                let content = UNMutableNotificationContent()
                content.title = titleText
                content.body = noteText
                content.sound = .default
                
                let dateComp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)
                let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
                
                self.notificationCenter.add(request) { (error) in
                    if (error != nil) {
                        print("Error adding notification: \(error.debugDescription)")
                        return
                    }
                }
                
//                DispatchQueue.main.async {
//                    let ac = UIAlertController(title: "Notification Scheduled", message: "At \(self.formattedDate(date: date))", preferredStyle: .alert)
//                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                    self.present(ac, animated: true)
//                }
                
            // user isn't authorized
            } else {
                DispatchQueue.main.async {
                    let ac = UIAlertController(title: "Enable Notofications?", message: "To use this feature you must enable notifications in settings", preferredStyle: .alert)
                    let goToSettings = UIAlertAction(title: "Settings", style: .default) {
                        (_) in
                        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }
                        
                        if (UIApplication.shared.canOpenURL(settingsURL)) {
                            UIApplication.shared.open(settingsURL)
                        }
                    }
                    
                    ac.addAction(goToSettings)
                    self.present(ac, animated: true)
                }
            }
        }
        
        
        //Making new doc in text collection
        let docRef = db.collection("households").document(UserDefaults.standard.string(forKey: "householdID")!).collection("texts").document()

        // TO DO: add roomate picker so can schedule texts for specific phone number
        let textData : [String: Any] = [
            "title" : titleText as Any,
            "date" : Timestamp(date: date),
            "note" : noteText as Any,
            "assignedTo" : assignedTo as String,
            "notificationID" : notificationID
        ]
        
        docRef.setData(textData) {
            error in
            if let error {
                print("error adding text to firestore: \(error.localizedDescription)")
            } else {
                print("Text added to firestore")
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM y HH:mm"
        return formatter.string(from: date)
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
