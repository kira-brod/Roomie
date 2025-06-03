//
//  ScheduledTextsAddTextViewController.swift
//  Roomie
//
//  Created by Kira Brodsky on 5/27/25.
//

import UIKit

class ScheduledTextsAddTextViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var Cancel: UIButton!
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
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if Notes.text.isEmpty {
            Notes.text = "Notes"
            Notes.textColor = .lightGray
        }
        
        if Notes == textView {
            note = textView.text ?? ""
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if Notes.textColor == .lightGray {
            Notes.textColor = .black
            Notes.text = ""
        }
    }
    
    
    @IBAction func titleSet(_ sender: UITextField) {
        textTitle = sender.text ?? ""
    }
    
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        date = sender.date
    }
    
    var onAddText: ((String, Date, String)-> Void)?
    
    
    @IBAction func addText(_ sender: UIButton) {
        onAddText?(textTitle!, date ?? Date(), note!)
        dismiss(animated: true)

    }
    
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
