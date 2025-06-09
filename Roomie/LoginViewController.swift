//
//  LoginViewController.swift
//  Roomie
//
//  Created by Kira Brodsky on 6/7/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class Singleton {
    static let shared = Singleton()
    var householdID: String = ""

    private init() { }
}

class LoginViewController: UIViewController {
    
    var isPasswordHidden : Bool = true
    var eyeImage: UIImageView!
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    var householdID = ""
    
    @IBAction func login(_ sender: Any) {
        guard let email = emailField.text, !email.isEmpty, let password = passField.text, !password.isEmpty else {
            DispatchQueue.main.async {
                self.showAlert(title: "Error", message: "All login fields must be filled out.")
            }
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Login error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
                return
            }
            
            guard let result = result else {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "User not found")
                }
                return
            }
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
            
        
    
    let db = Firestore.firestore()
    
    @IBAction func signupTapped(_ sender: Any) {
        guard let email = emailField.text, let password = passField.text else { return }
            
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    print("Signup error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: error.localizedDescription)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.promptForName { name in
                            guard let name = name else {
                                self.showAlert(title: "Missing Name", message: "Please enter your name.")
                                return
                            }
                            UserDefaults.standard.set(name, forKey: "userName")
                            self.promptForHouseholdOption()
                        }
                    }
                }
            }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try Auth.auth().signOut()
            print("User signed out successfully.")
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }

        
        loginBtn.layer.cornerRadius = 10
        
        passField.isSecureTextEntry = true
        
        let eyeButton = UIButton(type: .custom)
        eyeButton.setImage(UIImage(systemName: "eye"), for: .normal)
        eyeButton.tintColor = .gray
        eyeButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        eyeButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)

        passField.rightView = eyeButton
        passField.rightViewMode = .always

        let keyboardtap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        keyboardtap.cancelsTouchesInView = false
        view.addGestureRecognizer(keyboardtap)
    }
    
    @objc func togglePasswordVisibility() {
        isPasswordHidden.toggle()

        
        let wasFirstResponder = passField.isFirstResponder
        let selectedRange = passField.selectedTextRange

        passField.isSecureTextEntry = isPasswordHidden

        
        if wasFirstResponder {
            passField.becomeFirstResponder()
            if let selectedRange = selectedRange {
                passField.selectedTextRange = selectedRange
            }
        }

        let imgName = isPasswordHidden ? "eye" : "eye.slash"
        (passField.rightView as? UIButton)?.setImage(UIImage(systemName: imgName), for: .normal)
    }

        
        
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
        return
    }
    func promptForName(completion: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: "Your Name", message: "Enter your name to continue", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Your name"
        }
        alert.addAction(UIAlertAction(title: "Continue", style: .default) { _ in
            let name = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            completion(name?.isEmpty == false ? name : nil)
        })
        present(alert, animated: true)
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
        
        self.householdID = householdID
        Singleton.shared.householdID = householdID
        print("household: \(householdID)")
        
        // Create the household document
        db.collection("households").document(householdID).setData([
            "joinCode": joinCode
        ]) { error in
            if let error = error {
                print("Failed to create household: \(error.localizedDescription)")
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }
            
            // Add current user to roomies subcollection
            if let user = Auth.auth().currentUser {
                self.db.collection("households").document(householdID)
                    .collection("memberLogin").document(user.uid).setData([
                        "email": user.email ?? "",
                        "name": UserDefaults.standard.string(forKey: "userName") ?? "",
                        "joinedAt": FieldValue.serverTimestamp()
                    ])

            }
            
            // Save householdID locally
            UserDefaults.standard.set(householdID, forKey: "householdID")
            print("Household created and user added")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.performSegue(withIdentifier: "goToHome", sender: nil)
            }
            
        }
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
        db.collection("households")
            .whereField("joinCode", isEqualTo: code)
            .getDocuments { snapshot, error in
                
                guard let doc = snapshot?.documents.first else {
                    print("Invalid join code")
                    
                    self.showAlert(title: "Error", message: "Invalid join code")
                    return
                }
                
                let householdID = doc.documentID
                if let user = Auth.auth().currentUser {
                    self.db.collection("households").document(householdID)
                        .collection("memberLogin").document(user.uid).setData([
                            "email": user.email ?? "",
                            "name": UserDefaults.standard.string(forKey: "userName") ?? "",
                            "joinedAt": FieldValue.serverTimestamp()
                        ]) { error in
                            if let error = error {
                                print("Failed to add user to household: \(error.localizedDescription)")
                                self.showAlert(title: "Error", message: error.localizedDescription)
                            } else {
                                UserDefaults.standard.set(householdID, forKey: "householdID")
                                print("Joined household")
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    self.performSegue(withIdentifier: "goToHome", sender: nil)
                                }
                            }
                        }
                }
            }
    }
    
    
    func fetchHouseholdID(completion: @escaping (Bool) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        db.collection("households").getDocuments { snapshot, error in
            var found = false
            let group = DispatchGroup()
            
            for doc in snapshot?.documents ?? [] {
                group.enter()
                let roomieDoc = doc.reference.collection("memberLogin").document(userID)
                roomieDoc.getDocument { snapshot, _ in
                    if snapshot?.exists == true {
                        UserDefaults.standard.set(doc.documentID, forKey: "householdID")
                        self.householdID = doc.documentID
                        Singleton.shared.householdID = self.householdID
                        print("Household found for user")
                        found = true
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion(found)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToHome" {
                let controller = segue.destination as? ViewController
                controller?.householdID = householdID
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

