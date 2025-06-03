//
//  HouseholdsHomeViewController.swift
//  Roomie
//
//  Created by Kira Brodsky on 5/26/25.
//

import UIKit

class TableCell: UITableViewCell {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var roomieName: UILabel!
}

class HouseholdsHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    struct Person {
        let name: String
        let phoneNum: String
        let color: UIColor
    }
    
    
    var roomies : [Person] = []

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var H1: UILabel!
    @IBOutlet weak var Add: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        H1.font = UIFont.systemFont(ofSize: 30, weight: .bold)

        Add.layer.cornerRadius = Add.frame.width/2
        Add.layer.masksToBounds = true
        Add.titleLabel?.font = UIFont.systemFont(ofSize: 39, weight: .bold)
        tableView.allowsSelection = false
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        roomies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
                    tableView.dequeueReusableCell(
                        withIdentifier: "QuizCell",
                        for: indexPath
                    ) as! TableCell
                let user = roomies[indexPath.row]
                cell.roomieName.text = user.name
        cell.icon.image = UIImage(systemName: "person.fill")?.withTintColor(user.color)
        return cell
    }
    
    @IBAction func AddAction(_ sender: Any) {
        performSegue(withIdentifier: "toHouseholdDetails", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toHouseholdDetails",
            let modalVC = segue.destination as? HouseholdDetailsViewController {
            modalVC.onAddRoomie = {
                [weak self] name, phone, color in
                let newPerson = Person(name: name, phoneNum: phone, color: color ?? .black)
                self?.roomies.append(newPerson)
                self?.tableView.reloadData()
            }
        }
    }
    
    
   

}
