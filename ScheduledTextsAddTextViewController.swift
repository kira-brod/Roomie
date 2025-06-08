//
//  ScheduledTextsAddTextViewController.swift
//  Roomie
//
//  Created by Kira Brodsky on 5/27/25.
//

import UIKit
import FirebaseFirestore

class ScheduledTextsAddTextViewController: UIViewController, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    let db = Firestore.firestore()

//    @IBOutlet weak var Cancel: UIButton!
    @IBOutlet weak var Notes: UITextView!
    
    @IBOutlet weak var Add: UIButton!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var reminderTitle: UITextField!
    
    @IBOutlet weak var roomiePicker: UIPickerView!
    
    var date: Date?
    var textTitle: String?
    var note: String?
    var roomies: [String] = []
    
    
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

        
        
        db.collection("roomies").getDocuments { snapshot, error in
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
        note = Notes.textColor == .lightGray ? "" : Notes.text ?? ""
        textTitle = reminderTitle.text ?? ""
        date = datePicker.date
        
        let docRef = db.collection("texts").document()
        // TO DO: add roomate picker so can schedule texts for specific phone number
        let textData : [String: Any] = [
            "title" : textTitle as Any,
            "date" : Timestamp(date: date!),
            "note" : note as Any
        ]
        
        docRef.setData(textData) {
            error in
            if let error {
                print("error adding text to firestore: \(error.localizedDescription)")
            } else {
                print("Text added to firestore")
            }
        }
        
        dismiss(animated: true)
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
