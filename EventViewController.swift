//
//  EventViewController.swift
//  Roomie
//
//  Created by Kira Brodsky on 5/30/25.
//

import UIKit

class EventViewController: UIViewController {

    @IBOutlet weak var H1: UILabel!
    var event : Event?
    
    @IBOutlet weak var H2: UILabel!
    @IBOutlet weak var date: UITextView!
    @IBOutlet weak var notes: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
        H1.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        H1.text = event?.id
        date.text = "\(event?.date)"
        notes.text = event?.note
        
        H2.font = UIFont.systemFont(ofSize: 24, weight: .bold)
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
