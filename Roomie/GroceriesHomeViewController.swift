////
////  GroceriesViewController.swift
////  Roomie
////
////  Created by Kira Brodsky on 5/26/25.
////
//
//import UIKit
//
//class GroceriesViewController: UIViewController {
//
//    
//
//    @IBOutlet weak var noGroceryImageView: UIImageView!
//    @IBOutlet weak var Add: UIButton!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        

//
//        // Do any additional setup after loading the view.
//    }
//    
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
import UIKit

struct GroceryItem {
    var name: String
    var quantity: Int
    var isChecked: Bool
}

class GroceriesHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var H1: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noGroceryImageView: UIImageView!
    @IBOutlet weak var Add: UIButton!

    var groceryItems: [GroceryItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        H1.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        Add.layer.cornerRadius = Add.frame.width/2
        Add.layer.masksToBounds = true
        Add.titleLabel?.font = UIFont.systemFont(ofSize: 39, weight: .bold)
        tableView.dataSource = self
        tableView.delegate = self
        updateUI()
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
        return cell
    }

    @objc func checkBoxTapped(_ sender: UIButton) {
        let index = sender.tag
        groceryItems[index].isChecked.toggle()
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }

    @objc func deleteButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        groceryItems.remove(at: index)
        tableView.reloadData()
        updateUI()
    }

    // MARK: - Add Button
    @IBAction func AddTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let addVC = storyboard.instantiateViewController(withIdentifier: "AddGroceryViewController") as? AddGroceryViewController {
            addVC.modalPresentationStyle = .formSheet
            addVC.onAssignGrocery = { [weak self] name, quantity in
                self?.groceryItems.append(GroceryItem(name: name, quantity: quantity, isChecked: false))
                self?.tableView.reloadData()
                self?.updateUI()
            }
            present(addVC, animated: true)
        }
    }
}
