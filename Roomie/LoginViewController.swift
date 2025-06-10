//
//  LoginViewController.swift
//  Roomie
//
//  Created by Kira Brodsky on 6/7/25.
//

import UIKit
import FirebaseFirestore

class Singleton {
    static let shared = Singleton()
    var householdID: String = ""
    private init() { }
}

class LoginViewController: UIViewController, UITextFieldDelegate {

    let db = Firestore.firestore()
    
    @IBOutlet weak var codeField: UITextField!
    
    @IBOutlet weak var household: UIButton!
    
    @IBOutlet weak var newHouse: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        household.layer.cornerRadius = 10
        newHouse.layer.cornerRadius = 10

        codeField.delegate = self

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func createHouseholdTapped(_ sender: Any) {
        let householdID = UUID().uuidString
        let joinCode = String(UUID().uuidString.prefix(6)).uppercased()

        db.collection("households").document(householdID).setData([
            "joinCode": joinCode
        ]) { error in
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }

            UserDefaults.standard.set(householdID, forKey: "householdID")
            Singleton.shared.householdID = householdID
            print("Created household with ID: \(householdID)")

            self.performSegue(withIdentifier: "goToHome", sender: nil)
        }
    }

    @IBAction func joinHouseholdTapped(_ sender: Any) {
        guard let code = codeField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !code.isEmpty else {
            showAlert(title: "Missing Code", message: "Please enter a join code.")
            return
        }

        db.collection("households")
            .whereField("joinCode", isEqualTo: code.uppercased())
            .getDocuments { snapshot, error in
                if let error = error {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                    return
                }

                guard let document = snapshot?.documents.first else {
                    self.showAlert(title: "Invalid Code", message: "No household found for that code.")
                    return
                }

                let householdID = document.documentID
                UserDefaults.standard.set(householdID, forKey: "householdID")
                Singleton.shared.householdID = householdID
                print("Joined household with ID: \(householdID)")

                self.performSegue(withIdentifier: "goToHome", sender: nil)
            }
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToHome" {
            let controller = segue.destination as? ViewController
            controller?.householdID = Singleton.shared.householdID
        }
    }
}
