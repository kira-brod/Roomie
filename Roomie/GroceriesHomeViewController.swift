import UIKit
struct GroceryItem {
    var name: String
    var quantity: Int
    var isChecked: Bool
    var assignedRoomie: String
}
class GroceriesHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var H1: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noGroceryImageView: UIImageView!
    @IBOutlet weak var Add: UIButton!

    var groceryItems: [GroceryItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        H1.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        Add.layer.cornerRadius = Add.frame.width/2
        Add.layer.masksToBounds = true
        Add.titleLabel?.font = UIFont.systemFont(ofSize: 39, weight: .bold)
        tableView.delegate = self
        tableView.dataSource = self
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
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GroceryTopicCell", for: indexPath) as? GroceryTopicCell else {
            return UITableViewCell()
        }
        let item = groceryItems[indexPath.row]
        cell.contentLabel.text = "\(item.quantity) * \(item.name)"
        cell.checkBox.isSelected = item.isChecked
        cell.checkBox.tag = indexPath.row
        cell.deleteButton.tag = indexPath.row
        cell.checkBox.addTarget(self, action: #selector(checkBoxTapped(_:)), for: .touchUpInside)
        cell.deleteButton.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)

        let roommateColors: [String: UIColor] = [
            "Roomie 1": .red,
            "Roomie 2": .blue,
            "Roomie 3": .green,
            "Roomie 4": .yellow,
            "Roomie 5": .purple
        ]
        if let color = roommateColors[item.assignedRoomie] {
            cell.checkBox.tintColor = color
        } else {
            cell.checkBox.tintColor = .gray // default color
        }
        return cell
    }

    @objc func checkBoxTapped(_ sender: UIButton) {
        let index = sender.tag
        groceryItems[index].isChecked.toggle()
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }

    @objc func deleteButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        let alert = UIAlertController(title: "Delete Task",
                                      message: "Are you sure to delete this task?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.groceryItems.remove(at: index)
            self?.tableView.reloadData()
            self?.updateUI()
        }))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Add Button
    @IBAction func AddTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let addVC = storyboard.instantiateViewController(withIdentifier: "AddGroceryViewController") as? AddGroceryViewController {
            addVC.modalPresentationStyle = .formSheet
            addVC.onAssignGrocery = { [weak self] name, quantity, roomie in
                self?.groceryItems.append(GroceryItem(name: name, quantity: quantity, isChecked: false, assignedRoomie: roomie))
                self?.tableView.reloadData()
                self?.updateUI()
            }
            present(addVC, animated: true)
        }
    }
}
