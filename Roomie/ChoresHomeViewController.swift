//
//  ChoresHomeViewController.swift
//  Roomie
//
//  Created by Kira Brodsky on 5/26/25.
//

import UIKit

class ChoresHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AddChoreDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var H1: UILabel!
    @IBOutlet weak var Add: UIButton!
    
    var choresByDate: [Date: [Chore]] = [:]
    var sortedDates: [Date] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()

        H1.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        
        Add.layer.cornerRadius = Add.frame.width/2
        Add.layer.masksToBounds = true
        Add.titleLabel?.font = UIFont.systemFont(ofSize: 39, weight: .bold)
        tableView.delegate = self
        tableView.dataSource = self

        //update empty state
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return sortedDates.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let date = sortedDates[section]
        return choresByDate[date]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let date = sortedDates[section]
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let date = sortedDates[indexPath.section]
        let chore = choresByDate[date]![indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "ChoreCell", for: indexPath)
        cell.textLabel?.text = chore.title
        cell.textLabel?.textColor = chore.color
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        cell.detailTextLabel?.text = chore.notes
        cell.detailTextLabel?.textColor = .gray
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
        return cell
    }

    
    func didAddChore(_ chore: Chore) {
        let date = Calendar.current.startOfDay(for: chore.date)

        if choresByDate[date] != nil {
            choresByDate[date]?.append(chore)
        } else {
            choresByDate[date] = [chore]
        }

        sortedDates = choresByDate.keys.sorted()
        tableView.reloadData()
       //empty state update
    }

    
    //empty state func


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddChore", let destination = segue.destination as? AddChoreViewController {
            destination.delegate = self
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
