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
        

        db.collection("households").document(householdID).collection("groceries")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] querySnapshot, error in
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
        cell.checkBox.removeTarget(nil, action: nil, for: .allEvents)
        cell.checkBox.addTarget(self, action: #selector(checkBoxTapped(_:)), for: .touchUpInside)
        cell.checkBox.setImage(UIImage(systemName: "basket"), for: .normal)
        let color = roommateColors[item.assignedRoomie] ?? .gray
        cell.checkBox.tintColor = color
        cell.contentLabel.attributedText = nil
        cell.contentLabel.text = text
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let purchasedAction = UIContextualAction(style: .destructive, title: "Purchased") { [weak self] (action, view, completionHandler) in
            let item = self?.groceryItems[indexPath.row]
            if let itemToPurchase = item {
                self?.deleteGroceryItem(itemToPurchase)
            }
            completionHandler(true)
        }
        
        purchasedAction.backgroundColor = .systemGreen
        let configuration = UISwipeActionsConfiguration(actions: [purchasedAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
    
    @objc func checkBoxTapped(_ sender: UIButton) {
        let index = sender.tag
        let item = groceryItems[index]
        let alert = UIAlertController(title: "Assignment Info",
                                    message: "This is assigned to \(item.assignedRoomie)",
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }

    // MARK: - Add Button
    @IBAction func AddTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let addVC = storyboard.instantiateViewController(withIdentifier: "AddGroceryViewController") as? AddGroceryViewController {
            addVC.modalPresentationStyle = .formSheet
            addVC.onAssignGrocery = { [weak self] name, quantity, roomie in
                let newItem = GroceryItem(id: nil, name: name, quantity: quantity, isChecked: false, assignedRoomie: roomie, createdAt: Date())
                self?.addGroceryItem(newItem)
            }
            present(addVC, animated: true)
        }
    }
}
