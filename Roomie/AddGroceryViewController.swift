import UIKit
import FirebaseFirestore

class AddGroceryViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var assigneePickerView: UIPickerView!
    @IBOutlet weak var assignGroceryButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    let db = Firestore.firestore()

    struct Roomie {
        let name: String
        let phoneNum: String
        let color: UIColor
    }
    
    var Roomies: [Roomie] = []
    var selectedAssignee: String?
    var onAssignGrocery: ((String, Int, String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        quantityTextField.text = "1"
        quantityTextField.delegate = self
        quantityTextField.keyboardType = .numberPad
        assigneePickerView.delegate = self
        assigneePickerView.dataSource = self

        loadRoomies()
    }
    
    func loadRoomies() {
        guard let householdID = UserDefaults.standard.string(forKey: "householdID") else {
            print("No household ID found")
            return
        }
        
        db.collection("households").document(householdID).collection("roomies").order(by: "name").addSnapshotListener { [weak self] snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("Error fetching Roomies: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            var loadedRoomies: [Roomie] = []
            for doc in documents {
                let data = doc.data()
                guard let name = data["name"] as? String,
                      let phoneNum = data["phone"] as? String,
                      let colorString = data["color"] as? String else {
                    continue
                }
                
                let color = self?.convertColor(from: colorString) ?? .gray
                let Roomie = Roomie(name: name, phoneNum: phoneNum, color: color)
                loadedRoomies.append(Roomie)
            }
            
            DispatchQueue.main.async {
                self?.Roomies = loadedRoomies
                self?.assigneePickerView.reloadAllComponents()
                
                // Set default selection
                if !loadedRoomies.isEmpty {
                    self?.selectedAssignee = loadedRoomies[0].name
                }
            }
        }
    }
    
    func convertColor(from name: String) -> UIColor {
        switch name.lowercased() {
        case "red": return .systemRed
        case "blue": return .systemBlue
        case "green": return .systemGreen
        case "yellow": return .systemYellow
        case "purple": return .systemPurple
        case "gray": return .systemGray
        default: return .gray
        }
    }

    // MARK: - Quantity Controls (KEEP THESE UNCHANGED)
    @IBAction func minusButtonTapped(_ sender: UIButton) {
        let current = Int(quantityTextField.text ?? "1") ?? 1
        if current > 1 {
            quantityTextField.text = "\(current - 1)"
        }
    }

    @IBAction func plusButtonTapped(_ sender: UIButton) {
        let current = Int(quantityTextField.text ?? "1") ?? 1
        if current < 12 {
            quantityTextField.text = "\(current + 1)"
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        if !allowedCharacters.isSuperset(of: characterSet) { return false }
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if let value = Int(newString), value >= 1 && value <= 10 {
            return true
        }
        return newString.isEmpty
    }

    // MARK: - UIPickerView (UPDATE THESE METHODS)
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Roomies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Roomies[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedAssignee = Roomies[row].name
    }

    // MARK: - Assign & Cancel (ADD ERROR HANDLING)
    @IBAction func assignGroceryButtonTapped(_ sender: UIButton) {
        guard let name = nameTextField.text, !name.isEmpty,
              let quantityText = quantityTextField.text, let quantity = Int(quantityText),
              let assignee = selectedAssignee else {
            if Roomies.isEmpty {
                let alert = UIAlertController(title: "No Roommates",
                                            message: "Please add roommates first in the Households section.",
                                            preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true)
                return
            }
            return
        }
        
        onAssignGrocery?(name, quantity, assignee)
        self.dismiss(animated: true)
    }

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
