//
//  ScheduledTextsHomeViewController.swift
//  Roomie
//
//  Created by Kira Brodsky on 5/26/25.
//

import UIKit

class ScheduledTextsHomeViewController: UIViewController {

    @IBOutlet weak var H1: UILabel!
    
    @IBOutlet weak var Add: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        H1.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        
        Add.layer.cornerRadius = Add.frame.width/2
        Add.layer.masksToBounds = true
        Add.titleLabel?.font = UIFont.systemFont(ofSize: 39, weight: .bold)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func AddAction(_ sender: Any) {
        performSegue(withIdentifier: "toScheduleDetails", sender: self)
//        let vc = storyboard?.instantiateViewController(withIdentifier: "ScheduledTextsAddText") as! ScheduledTextsAddTextViewController
//        
//        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toScheduleDetails",
           let modalVC = segue.destination as? ScheduledTextsAddTextViewController {
            modalVC.onAddText = {
                [weak self] text, date, note in
                return
            }
        }
    }


}
