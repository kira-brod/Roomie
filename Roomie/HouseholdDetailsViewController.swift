//
//  HouseholdDetailsViewController.swift
//  Roomie
//
//  Created by Kira Brodsky on 5/27/25.
//

import UIKit

class HouseholdDetailsViewController: UIViewController {

    @IBOutlet weak var Add: UIButton!
    @IBOutlet weak var H1: UITextField!
    @IBOutlet weak var phoneNum: UITextField!
    @IBOutlet var colorBtns: [UIButton]!
    var name: String = ""
    var phone: String = ""
    var color: UIColor? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        H1.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        
        Add.layer.cornerRadius = 10
        
        H1.placeholder = "Name"
        
        let img = UIImageView(image: UIImage(systemName: "phone.fill"))
        img.tintColor = .gray
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        img.frame = CGRect(x: 5, y:0, width: 20, height: 20)
        containerView.addSubview(img)
        
        phoneNum.leftView = containerView
        phoneNum.leftViewMode = .always
        phoneNum.placeholder = "Phone Number"
        
        for btn in colorBtns {
            btn.layer.cornerRadius = btn.frame.width/2
            btn.clipsToBounds = true
        }
    }
    @IBAction func changeName(_ sender: UITextField) {
        name = sender.text ?? ""
    }
    
    @IBAction func changePhone(_ sender: UITextField) {
        phone = sender.text ?? ""
    }
    
    @IBAction func btnPressed(_ sender: UIButton) {
        color = sender.backgroundColor

        for btn in colorBtns {
            btn.layer.borderWidth = 0
            btn.layer.borderColor = nil
        }
        
        sender.layer.borderWidth = 2
        sender.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    var onAddRoomie: ((String, String, UIColor?)-> Void)?
    
    @IBAction func addRoomie(_ sender: UIButton!) {
        onAddRoomie?(name, phone, color)
        dismiss(animated: true)
//        performSegue(withIdentifier: "backToHousehold", sender: self)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "backToHousehold" {
//            if let destination = segue.destination as? HouseholdsHomeViewController {
//                destination.incomingName = name
//                destination.incomingPhone = phone
//                destination.incomingColor = color
//            }
//        }
//    }
    
    

}
