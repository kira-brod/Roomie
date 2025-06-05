//
//  ScheduledTextsAddTextViewController.swift
//  Roomie
//
//  Created by Kira Brodsky on 5/27/25.
//

import UIKit

class ScheduledTextsAddTextViewController: UIViewController, UITextViewDelegate {

//    @IBOutlet weak var Cancel: UIButton!
    @IBOutlet weak var Notes: UITextView!
    
    @IBOutlet weak var Add: UIButton!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var reminderTitle: UITextField!
    
    var date: Date?
    var textTitle: String?
    var note: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reminderTitle.placeholder = "Reminder Title"
        Notes!.layer.borderWidth = 1
        Notes!.layer.borderColor = UIColor.lightGray.cgColor
        Notes!.layer.cornerRadius = 5.0
        Notes.text = "Notes"
        Notes.textColor = .lightGray
        Notes.delegate = self
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

    // passing data back to home VC, dismissing modal
    var onAddText: ((String, Date, String)-> Void)?
    
    @IBAction func addText(_ sender: UIButton) {
        note = Notes.textColor == .lightGray ? "" : Notes.text ?? ""
        textTitle = reminderTitle.text ?? ""
        date = datePicker.date
        
        onAddText?(textTitle!, date ?? Date(), note!)
        dismiss(animated: true)
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
