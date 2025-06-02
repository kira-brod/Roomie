import UIKit

class AddGroceryViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var assigneePickerView: UIPickerView!
    @IBOutlet weak var assignGroceryButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    let assignees = ["Alice", "Bob", "Charlie", "Diana", "Eve"]
    var selectedAssignee: String?
    var onAssignGrocery: ((String, Int) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        quantityTextField.text = "1"
        quantityTextField.delegate = self
        quantityTextField.keyboardType = .numberPad
        assigneePickerView.delegate = self
        assigneePickerView.dataSource = self
        selectedAssignee = assignees[0]
    }

    // MARK: - Quantity Controls
    @IBAction func minusButtonTapped(_ sender: UIButton) {
        let current = Int(quantityTextField.text ?? "1") ?? 1
        if current > 1 {
            quantityTextField.text = "\(current - 1)"
        }
    }

    @IBAction func plusButtonTapped(_ sender: UIButton) {
        let current = Int(quantityTextField.text ?? "1") ?? 1
        if current < 10 {
            quantityTextField.text = "\(current + 1)"
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Only allow numbers 1-10
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        if !allowedCharacters.isSuperset(of: characterSet) { return false }
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if let value = Int(newString), value >= 1 && value <= 10 {
            return true
        }
        return newString.isEmpty // allow clearing
    }

    // MARK: - UIPickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        assignees.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        assignees[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedAssignee = assignees[row]
    }

    // MARK: - Assign & Cancel
    @IBAction func assignGroceryButtonTapped(_ sender: UIButton) {
        guard let name = nameTextField.text, !name.isEmpty,
              let quantityText = quantityTextField.text, let quantity = Int(quantityText),
              let assignee = selectedAssignee else { return }
        onAssignGrocery?(name, quantity)
        self.dismiss(animated: true)
    }

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
