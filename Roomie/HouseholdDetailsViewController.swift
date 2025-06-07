//
//  HouseholdDetailsViewController.swift
//  Roomie
//
//  Created by Kira Brodsky on 5/27/25.
//

import UIKit
import FirebaseFirestore

class HouseholdDetailsViewController: UIViewController {
    
    let db = Firestore.firestore()

    @IBOutlet weak var Add: UIButton!
    @IBOutlet weak var H1: UITextField!
    @IBOutlet weak var phoneNum: UITextField!
    @IBOutlet var colorBtns: [UIButton]!

    
    let colors: [String] = ["red", "blue", "green", "yellow", "purple"]
    var selectedColor: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        H1.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        
        Add.layer.cornerRadius = 10
        
        H1.placeholder = "Name"
        phoneNum.keyboardType = .numberPad
        
        let img = UIImageView(image: UIImage(systemName: "phone.fill"))
        img.tintColor = .gray
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        img.frame = CGRect(x: 5, y:0, width: 20, height: 20)
        containerView.addSubview(img)
        
        phoneNum.leftView = containerView
        phoneNum.leftViewMode = .always
        phoneNum.placeholder = "(XXX)-XXX-XXX)"
        
        for btn in colorBtns {
            btn.layer.cornerRadius = btn.frame.width/2
            btn.clipsToBounds = true
        }
    }
    
    @IBAction func btnPressed(_ sender: UIButton) {
        selectedColor = colors[sender.tag]

        for btn in colorBtns {
            btn.layer.borderWidth = 0
            btn.layer.borderColor = nil
        }
        
        sender.layer.borderWidth = 2
        sender.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    @IBAction func addRoomie(_ sender: UIButton!) {
        
        guard let text = H1.text, !text.isEmpty, let phoneNum = phoneNum.text, !phoneNum.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "All Roomie fields must be filled out!!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
            return
        }
                
        let docRef = db.collection("roomies").document()
        
        let roomieData : [String: Any] = [
            "name" : text,
            "phone" : phoneNum,
            "color" : selectedColor ?? "gray"
            
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
}
