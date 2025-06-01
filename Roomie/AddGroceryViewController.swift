import UIKit
//
//struct GroceryTopic {
//    let title: String         // Event name
//    let desc: String          // Ingredients (comma-separated)
//    let questions: [String]   // (Can be unused or used for future features)
//    let iconImageName: String // Leave blank for now
//    let datePoster: String?   // Leave blank for now
//}

class AddGroceryViewController: UIViewController {


    
    
    
    
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var itemsStackView: UIStackView!

    var items: [String] = []
    var onAssignGrocery: ((String, String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        quantityTextField.keyboardType = .numberPad
        quantityTextField.text = "1"
        popupView.isHidden = true
    }

    @IBAction func submitButtonTapped(_ sender: UIButton) {
        guard let name = nameTextField.text, !name.isEmpty,
              let quantityText = quantityTextField.text, let quantity = Int(quantityText), quantity > 0 else {
            return
        }
        let itemString = "\(quantity) * \(name)"
        items.append(itemString)
        let newItemLabel = UILabel()
        newItemLabel.text = itemString
        itemsStackView.addArrangedSubview(newItemLabel)
        popupView.isHidden = true
        nameTextField.text = ""
        quantityTextField.text = ""
    }

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        popupView.isHidden = true
        nameTextField.text = ""
        quantityTextField.text = ""
    }

    @IBAction func minusButtonTapped(_ sender: UIButton) {
        let current = Int(quantityTextField.text ?? "1") ?? 1
        if current > 1 {
            quantityTextField.text = "\(current - 1)"
        }
    }

    @IBAction func plusButtonTapped(_ sender: UIButton) {
        let current = Int(quantityTextField.text ?? "1") ?? 1
        quantityTextField.text = "\(current + 1)"
    }

    @IBAction func showPopupButtonTapped(_ sender: UIButton) {
        popupView.isHidden = false
    }


    
    
    
    
    
    @IBAction func assignGroceryButtonTapped(_ sender: UIButton) {
        guard let eventName = eventNameTextField.text, !eventName.isEmpty else { return }
        let ingredients = items.joined(separator: ", ")
        onAssignGrocery?(eventName, ingredients)
        items.removeAll()
        for view in itemsStackView.arrangedSubviews {
            itemsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        self.dismiss(animated: true)
    }
}
