//
//  LoginViewController.swift
//  Roomie
//
//  Created by Kira Brodsky on 6/7/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passField: UITextField!
    
    @IBAction func login(_ sender: Any) {
        guard let email = emailField.text, let password = passField.text else { return }
            
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
        if let error = error {
            print("Login error: \(error.localizedDescription)")
        } else {
            print("Logged in as \(email)")
            self.fetchHouseholdID { found in
                if found {
                    DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "goToHome", sender: nil)
                }
            } else {
                DispatchQueue.main.async {
                    self.promptForHouseholdOption()
                }
            }
            }
        }
        }
    }
    
    let db = Firestore.firestore()
    
    @IBAction func signupTapped(_ sender: Any) {
        guard let email = emailField.text, let password = passField.text else { return }
                Auth.auth().createUser(withEmail: email, password: password) { result, error in
                    if let error = error {
                        print("Signup error: \(error.localizedDescription)")
                    } else {
                        self.promptForHouseholdOption()
                    }
                }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func promptForHouseholdOption() {
            let alert = UIAlertController(title: "Household", message: "Create or join a household?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Create", style: .default) { _ in self.createHousehold() })
            alert.addAction(UIAlertAction(title: "Join", style: .default) { _ in self.joinHouseholdPrompt() })
            present(alert, animated: true)
        }

        func createHousehold() {
            let householdID = UUID().uuidString
            let joinCode = String(UUID().uuidString.prefix(6))

            db.collection("households").document(householdID).setData([
                "joinCode": joinCode
            ])

            if let userID = Auth.auth().currentUser?.uid {
                db.collection("households").document(householdID).collection("roomies").document(userID).setData([
                    "email": Auth.auth().currentUser?.email ?? ""
                ])
            }

            UserDefaults.standard.set(householdID, forKey: "householdID")
            print("✅ Household created")
        }

        func joinHouseholdPrompt() {
            let alert = UIAlertController(title: "Join Household", message: "Enter join code", preferredStyle: .alert)
            alert.addTextField()

            alert.addAction(UIAlertAction(title: "Join", style: .default) { _ in
                if let code = alert.textFields?.first?.text {
                    self.joinHousehold(with: code)
                }
            })

            present(alert, animated: true)
        }

        func joinHousehold(with code: String) {
            db.collection("households").whereField("joinCode", isEqualTo: code).getDocuments { snapshot, error in
                if let doc = snapshot?.documents.first {
                    let householdID = doc.documentID
                    if let userID = Auth.auth().currentUser?.uid {
                        self.db.collection("households").document(householdID).collection("roomies").document(userID).setData([
                            "email": Auth.auth().currentUser?.email ?? ""
                        ])
                    }
                    UserDefaults.standard.set(householdID, forKey: "householdID")
                    print("✅ Joined household")
                } else {
                    print("❌ Invalid join code")
                }
            }
        }

    func fetchHouseholdID(completion: @escaping (Bool) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        db.collection("households").getDocuments { snapshot, error in
            for doc in snapshot?.documents ?? [] {
                let roomieDoc = doc.reference.collection("roomies").document(userID)
                roomieDoc.getDocument { snapshot, _ in
                    if snapshot?.exists == true {
                        UserDefaults.standard.set(doc.documentID, forKey: "householdID")
                        print("✅ Household found for user")
                        completion(true)
                    }
                }
            }
            
            // If no match found
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                completion(false)
            }
        }
    }

//    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
//      // ...
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
