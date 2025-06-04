//
//  ScheduledTextsHomeViewController.swift
//  Roomie
//
//  Created by Kira Brodsky on 5/26/25.
//

import UIKit

class TextCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
}

class DateCell {
    @IBOutlet weak var dateLabel: UILabel!
}

struct Text {
    let title: String
    let note : String
}

class ScheduledTextsHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in: UITableView) -> Int {
        return texts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return texts[dateKeys[section]]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    

    @IBOutlet weak var H1: UILabel!
    @IBOutlet weak var Add: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    // key -> date,
    let texts : [String : [Text]] = [:]
    let dateKeys : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        H1.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        
        Add.layer.cornerRadius = Add.frame.width/2
        Add.layer.masksToBounds = true
        Add.titleLabel?.font = UIFont.systemFont(ofSize: 39, weight: .bold)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func AddAction(_ sender: Any) {
        performSegue(withIdentifier: "toScheduleDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toScheduleDetails",
           let modalVC = segue.destination as? ScheduledTextsAddTextViewController {
            modalVC.onAddText = {
                [weak self] text, date, note in
                let newText = Text(title: text, note: note)
                self?.tableView.reloadData()
            }
        }
    }


}
