import UIKit
import FirebaseFirestore

class AddGroceryViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITextViewDelegate {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var quantityTextView: UITextView!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
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
        quantityTextView.delegate = self
        quantityTextView.keyboardType = .numberPad
        quantityTextView.layer.cornerRadius = quantityTextView.frame.width / 2
        quantityTextView.layer.borderColor = UIColor.systemGray4.cgColor
        quantityTextView.layer.borderWidth = 2.0
        quantityTextView.backgroundColor = UIColor.white
        quantityTextView.font = UIFont.systemFont(ofSize: 92, weight: .bold)
        quantityTextView.textAlignment = .center
        quantityTextView.textColor = .label
        quantityTextView.isScrollEnabled = false
        quantityTextView.showsVerticalScrollIndicator = false
        quantityTextView.showsHorizontalScrollIndicator = false
        quantityTextView.textContainerInset = UIEdgeInsets.zero
        quantityTextView.textContainer.lineFragmentPadding = 0
        quantityTextView.contentInset = UIEdgeInsets.zero
        quantityTextView.layoutIfNeeded()
        centerTextVertically()
        assigneePickerView.delegate = self
        assigneePickerView.dataSource = self
        loadRoomies()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        quantityTextView.layer.cornerRadius = quantityTextView.frame.width / 2
        centerTextVertically()
    }

    func centerTextVertically() {
        let textSize = quantityTextView.sizeThatFits(CGSize(width: quantityTextView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        let topOffset = max(0, (quantityTextView.frame.height - textSize.height) / 2)
        quantityTextView.contentInset = UIEdgeInsets(top: topOffset, left: 0, bottom: 0, right: 0)
    }


    @IBAction func minusButtonTapped(_ sender: UIButton) {
        let current = Int(quantityTextView.text ?? "1") ?? 1
        if current > 1 {
            quantityTextView.text = "\(current - 1)"
            centerTextVertically()
        }
    }

    @IBAction func plusButtonTapped(_ sender: UIButton) {
        let current = Int(quantityTextView.text ?? "1") ?? 1
        if current < 12 {
            quantityTextView.text = "\(current + 1)"
            centerTextVertically()
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        centerTextVertically()
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

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: text)
        if !allowedCharacters.isSuperset(of: characterSet) { return false }
        
        let newString = (textView.text! as NSString).replacingCharacters(in: range, with: text)
        if let value = Int(newString), value >= 1 && value <= 12 {
            return true
        }
        return newString.isEmpty
    }


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


    @IBAction func assignGroceryButtonTapped(_ sender: UIButton) {
        guard let name = nameTextField.text, !name.isEmpty,
              let quantityText = quantityTextView.text, let quantity = Int(quantityText),
              let assignee = selectedAssignee else {
            if Roomies.isEmpty {
                let alert = UIAlertController(title: "No Roommate",
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
