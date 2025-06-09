import UIKit
import Firebase
import FirebaseFirestore

class GroceriesHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var H1: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noGroceryImageView: UIImageView!
    @IBOutlet weak var Add: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var groceryItems: [GroceryItem] = []
    var roommateColors: [String: UIColor] = [:]
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.showsVerticalScrollIndicator = true
        updateUI()
        H1.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        Add.layer.cornerRadius = Add.frame.width/2
        Add.layer.masksToBounds = true
        Add.titleLabel?.font = UIFont.systemFont(ofSize: 39, weight: .bold)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = true
        

        if UserDefaults.standard.string(forKey: "householdID") != nil {
            loadRoommateColors()
            loadGroceryItems()
        } else {
            print("No household found - showing empty state for testing")
            self.groceryItems = []
            self.roommateColors = [:]
            updateUI()
        }
    }
    
    // MARK: - Firebase Methods
    func loadRoommateColors() {
        guard let householdID = UserDefaults.standard.string(forKey: "householdID") else { return }
        
        db.collection("households").document(householdID).collection("roomies").addSnapshotListener { [weak self] snapshot, error in
            guard let documents = snapshot?.documents, error == nil else { return }
            
            var colors: [String: UIColor] = [:]
            for doc in documents {
                let data = doc.data()
                guard let name = data["name"] as? String,
                      let colorString = data["color"] as? String else { continue }
                
                colors[name] = self?.convertColor(from: colorString) ?? .gray
            }
            
            DispatchQueue.main.async {
                self?.roommateColors = colors
                self?.tableView.reloadData()
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
    
    func loadGroceryItems() {
        guard let householdID = UserDefaults.standard.string(forKey: "householdID") else {
            print("No household ID found")
            self.groceryItems = []
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.updateUI()
            }
            return
        }
        
        db.collection("households").document(householdID).collection("groceries").addSnapshotListener { [weak self] querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                self?.groceryItems = []
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.updateUI()
                }
                return
            }
            
            self?.groceryItems = documents.compactMap { document ->
                GroceryItem? in
                return GroceryItem.fromDictionary(document.data(), id: document.documentID)
            }.sorted { first, second in
                if first.isChecked == second.isChecked {
                    return false
                }
                return !first.isChecked && second.isChecked
            }
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.updateUI()
            }
        }
    }
    
    func addGroceryItem(_ item: GroceryItem) {
        guard let householdID = UserDefaults.standard.string(forKey: "householdID") else {
            print("No household ID found")
            return
        }
        db.collection("households").document(householdID).collection("groceries").addDocument(data: item.toDictionary()) { error in
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
            }
        }
    }

    func updateGroceryItem(_ item: GroceryItem) {
        guard let id = item.id,
              let householdID = UserDefaults.standard.string(forKey: "householdID") else { return }
        
        db.collection("households").document(householdID).collection("groceries").document(id).updateData(item.toDictionary()) { error in
            if let error = error {
                print("Error updating document: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteGroceryItem(_ item: GroceryItem) {
        guard let id = item.id,
              let householdID = UserDefaults.standard.string(forKey: "householdID") else { return }
        
        db.collection("households").document(householdID).collection("groceries").document(id).delete() { error in
            if let error = error {
                print("Error removing document: \(error.localizedDescription)")
            }
        }
    }

    func updateUI() {
        let hasGroceries = !groceryItems.isEmpty
        tableView.isHidden = !hasGroceries
        noGroceryImageView.isHidden = hasGroceries
    }
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groceryItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GroceryTopicCell", for: indexPath) as? GroceryTopicCell else {
            return UITableViewCell()
        }
        
        let item = groceryItems[indexPath.row]
        let text = "\(item.quantity) * \(item.name)"
        
        cell.checkBox.tag = indexPath.row
        cell.deleteButton.tag = indexPath.row
        cell.checkBox.removeTarget(nil, action: nil, for: .allEvents)
        cell.deleteButton.removeTarget(nil, action: nil, for: .allEvents)
        
        cell.checkBox.addTarget(self, action: #selector(checkBoxTapped(_:)), for: .touchUpInside)
        cell.deleteButton.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)

        if item.isChecked {
            cell.checkBox.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            cell.checkBox.tintColor = .gray
            cell.deleteButton.isHidden = true
            

            let attributedText = NSMutableAttributedString(string: text)
            attributedText.addAttribute(.strikethroughStyle,
                                      value: NSUnderlineStyle.single.rawValue,
                                      range: NSRange(location: 0, length: text.count))
            attributedText.addAttribute(.strikethroughColor,
                                      value: UIColor.gray,
                                      range: NSRange(location: 0, length: text.count))
            cell.contentLabel.attributedText = attributedText
            
        } else {

            cell.checkBox.setImage(UIImage(systemName: "circle"), for: .normal)

            let color = roommateColors[item.assignedRoomie] ?? .gray
            cell.checkBox.tintColor = color
            cell.deleteButton.isHidden = false
            

            cell.contentLabel.attributedText = nil
            cell.contentLabel.text = text
        }
        
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let checkAction = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, completionHandler) in
            var item = self?.groceryItems[indexPath.row]
            item?.isChecked.toggle()
            if let updatedItem = item {
                self?.updateGroceryItem(updatedItem)
            }
            completionHandler(true)
        }
        
        let item = groceryItems[indexPath.row]
        if item.isChecked {
            checkAction.image = UIImage(systemName: "circle")
            checkAction.title = "Uncheck"
        } else {
            checkAction.image = UIImage(systemName: "checkmark.circle.fill")
            checkAction.backgroundColor = .systemGreen
            checkAction.title = "Check"
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [checkAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
    
    @objc func checkBoxTapped(_ sender: UIButton) {
        let index = sender.tag
        var item = groceryItems[index]
        item.isChecked.toggle()
        updateGroceryItem(item)
    }

    @objc func deleteButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        let item = groceryItems[index]
        let alert = UIAlertController(title: "Delete Task",
                                      message: "Are you sure to delete this task?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deleteGroceryItem(item)
        }))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Add Button
    @IBAction func AddTapped(_ sender: UIButton) {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let addVC = storyboard.instantiateViewController(withIdentifier: "AddGroceryViewController") as? AddGroceryViewController {
            addVC.modalPresentationStyle = .formSheet
            addVC.onAssignGrocery = { [weak self] name, quantity, roomie in
                let newItem = GroceryItem(id: nil, name: name, quantity: quantity, isChecked: false, assignedRoomie: roomie)
                self?.addGroceryItem(newItem)
            }
            present(addVC, animated: true)
        }
    }
}
