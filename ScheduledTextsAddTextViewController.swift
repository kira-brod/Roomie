//
//  ScheduledTextsAddTextViewController.swift
//  Roomie
//
//  Created by Kira Brodsky on 5/27/25.
//

import UIKit

class ScheduledTextsAddTextViewController: UIViewController {

    @IBOutlet weak var Cancel: UIButton!
    @IBOutlet weak var Notes: UITextView!
    
    @IBOutlet weak var Add: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Notes!.layer.borderWidth = 1
        Notes!.layer.borderColor = UIColor.lightGray.cgColor
        Notes!.layer.cornerRadius = 5.0
        
        
        // Do any additional setup after loading the view.
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
