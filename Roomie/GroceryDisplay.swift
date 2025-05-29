import UIKit
import Foundation

class GroceryDisplay: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var topics: [GroceryTopic] = [
        GroceryTopic(title: "Veggies", desc: "Eggplant, Onions, Garlic, Bell Pepper", questions: [], iconImageName: "pink", datePoster: "May 24, Roomie 1 Posted"),
        GroceryTopic(title: "Pasta", desc: "Ground Beef, Tomatoes, Basil", questions: [], iconImageName: "pink", datePoster: nil),
        GroceryTopic(title: "House Essentials", desc: "Paper Towels, Toilet Paper, Dishwasher Liquid, Water", questions: [], iconImageName: "blue", datePoster: "May 22, Roomie 2 Posted")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }

    @IBAction func addGroceryButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "ShowAddGrocery", sender: nil)
    }
}

extension GroceryDisplay: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }

    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroceryTopicCell", for: indexPath) as! GroceryTopicCell
        let topic = topics[indexPath.row]
        cell.titleLabel.text = topic.title
        cell.subtitleLabel.text = topic.desc
        cell.iconImageView.image = UIImage(named: topic.iconImageName)
        cell.iconImageView.layer.cornerRadius = cell.iconImageView.frame.width / 2
        cell.iconImageView.clipsToBounds = true
        cell.datePosterLabel.text = topic.datePoster
        return cell
    }

    func tableView(_ tv: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }

    func tableView(_ tv: UITableView, didSelectRowAt indexPath: IndexPath) {
        tv.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ShowGroceryDetail", sender: topics[indexPath.row])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "ShowGroceryDetail",
//           let detailVC = segue.destination as? GroceryDetail,
//           let topic = sender as? GroceryTopic {
//            detailVC.groceryItem = topic
//        }
    }
}
