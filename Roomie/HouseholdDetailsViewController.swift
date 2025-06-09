//
//  HouseholdDetailsViewController.swift
//  Roomie
//
//  Created by Kira Brodsky on 5/27/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth


class HouseholdDetailsViewController: UIViewController, UITextFieldDelegate {
    
    let db = Firestore.firestore()

    @IBOutlet weak var Add: UIButton!
    @IBOutlet weak var H1: UITextField!
    @IBOutlet weak var phoneNum: UITextField!
    @IBOutlet var colorBtns: [UIButton]!
    @IBOutlet weak var cancel: UIButton!
    
    
    let colors: [String] = ["red", "blue", "yellow", "purple", "green"]
    var selectedColor: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        H1.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        
        Add.layer.cornerRadius = 10
        cancel.layer.cornerRadius = 10
        
        H1.placeholder = "Name"
        phoneNum.keyboardType = .numberPad
        phoneNum.delegate = self
        
        let img = UIImageView(image: UIImage(systemName: "phone.fill"))
        img.tintColor = .gray
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        img.frame = CGRect(x: 5, y:0, width: 20, height: 20)
        containerView.addSubview(img)
        
        phoneNum.leftView = containerView
        phoneNum.leftViewMode = .always
        phoneNum.placeholder = "(XXX) XXX-XXXX"
        
        for btn in colorBtns {
            btn.layer.cornerRadius = btn.frame.width/2
            btn.clipsToBounds = true
        }
    }
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let currPhone = phoneNum.text ?? ""
        let updatedText = (currPhone as NSString).replacingCharacters(in: range, with: string)
        phoneNum.text = formatPhoneNum(from : updatedText)
        
        return false
    }
    
    func formatPhoneNum(from phoneStr : String) -> String {
        let digits = phoneStr.filter {$0.isNumber}
        
        let count = digits.count
        
        switch count {
            case 0:
                return ""
            case 1...3:
                return "(\(digits)"
            case 4...6:
                let area = digits.prefix(3)
                let first = digits.dropFirst(3)
                return "(\(area)) \(first)"
            default:
                let area = digits.prefix(3)
                let first = digits.dropFirst(3).prefix(3)
                let second = digits.dropFirst(6).prefix(4)
                return "(\(area)) \(first)-\(second)"
        }
    }
    
    
    @IBAction func btnPressed(_ sender: UIButton) {
        sender.becomeFirstResponder()
        selectedColor = colors[sender.tag]

        for btn in colorBtns {
            btn.layer.borderWidth = 0
            btn.layer.borderColor = nil
        }
        
        sender.layer.borderWidth = 2
        sender.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    @IBAction func addRoomie(_ sender: UIButton!) {
        // validating non empty fields
        guard let text = H1.text, !text.isEmpty, let phoneNum = phoneNum.text, !phoneNum.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "All Roomie fields must be filled out!!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
            return
        }
        
        // validating phone Number format
        let phonePattern = #"^\(\d{3}\) \d{3}-\d{4}$"#
            let phoneRegex = try! NSRegularExpression(pattern: phonePattern)
            let range = NSRange(location: 0, length: phoneNum.utf16.count)
            
        if phoneRegex.firstMatch(in: phoneNum, options: [], range: range) == nil {
                let alert = UIAlertController(title: "Invalid Phone Number", message: "Please enter a phone number in the format (XXX) XXX-XXXX", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
        
        let docRef = db.collection("households").document(UserDefaults.standard.string(forKey: "householdID")!).collection("roomies").document()

        
        let roomieData : [String: Any] = [
            "name" : text,
            "phone" : phoneNum,
            "color" : selectedColor ?? "gray",
        ]
        
        docRef.setData(roomieData) {
            error in
            if let error {
                print("error adding text to firestore: \(error.localizedDescription)")
            } else {
                print("Text added to firestore")
            }
        }
        
        dismiss(animated: true)
    }
    
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true)
    }
}
