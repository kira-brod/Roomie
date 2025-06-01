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
//    @IBOutlet weak var H1: UILabel!
//    @IBOutlet weak var noGroceryImageView: UIImageView!
//    @IBOutlet weak var Add: UIButton!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        H1.font = UIFont.systemFont(ofSize: 30, weight: .bold)
//        
//        Add.layer.cornerRadius = Add.frame.width/2
//        Add.layer.masksToBounds = true
//        Add.titleLabel?.font = UIFont.systemFont(ofSize: 39, weight: .bold)
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

struct GroceryTopic {
    let title: String
    let desc: String
    let questions: [String]
    let iconImageName: String
}

class GroceriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noGroceryImageView: UIImageView!
    @IBOutlet weak var Add: UIButton!
    @IBOutlet weak var H1: UILabel!
    var groceryTopics: [GroceryTopic] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        updateUI()
    }
    
    func updateUI() {
        let hasGroceries = !groceryTopics.isEmpty
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.tableView.isHidden = !hasGroceries
            self.noGroceryImageView.isHidden = hasGroceries
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groceryTopics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GroceryTopicCell", for: indexPath) as? GroceryTopicCell else {
            return UITableViewCell()
        }
        let topic = groceryTopics[indexPath.row]
        cell.titleLabel.text = topic.title
        cell.subtitleLabel.text = topic.desc
        if let imageName = topic.iconImageName.isEmpty ? nil : topic.iconImageName {
            cell.iconImageView.image = UIImage(named: imageName)
        } else {
            cell.iconImageView.image = nil
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddGroceryViewController",
           let addItemVC = segue.destination as? AddGroceryViewController {
            addItemVC.onAssignGrocery = { [weak self] eventName, ingredients in
                let newTopic = GroceryTopic(title: eventName, desc: ingredients, questions: [], iconImageName: "pink")
                self?.addGrocery(newTopic)
            }
        }
    }
    
    func addGrocery(_ grocery: GroceryTopic) {
        groceryTopics.append(grocery)
        tableView.reloadData()
        updateUI()
    }
}
