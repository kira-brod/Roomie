//
//  LoginViewController.swift
//  Roomie
//
//  Created by Kira Brodsky on 6/7/25.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var Login: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        Login.layer.cornerRadius = 10
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
