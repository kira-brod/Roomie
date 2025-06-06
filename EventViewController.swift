//
//  EventViewController.swift
//  Roomie
//
//  Created by Kira Brodsky on 5/30/25.
//

import UIKit
import FirebaseFirestore

class EventViewController: UIViewController {
    
    let db = Firestore.firestore()


    @IBOutlet weak var H1: UILabel!
    var event : Event?
    var events : [DateComponents: [Event]] = [:]
    
    @IBOutlet weak var H2: UILabel!
    @IBOutlet weak var date: UITextView!
    @IBOutlet weak var notes: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
        H1.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        H1.text = event?.title
        date.text = "\(event!.date)"
        notes.text = event?.note
        
        H2.font = UIFont.systemFont(ofSize: 24, weight: .bold)
    }
    
    @IBAction func Delete(_ sender: Any) {
        
        let date = Date.now
//        var index = 0
        
//        let dateComp = Calendar.current.dateComponents([.year, .month, .day], from: event?.date ?? date)
        
//        for key in events.keys {
//            if key == dateComp {
//                for i in 0..<(events[key]?.count ?? 0){
//                    if events[key]?[i].title == event?.title {
//                        events[key]?.remove(at: i)
//                    }
//                }
//            }
//        }
        
        let test = Event(id: "", title: "String", date: date, note: "String", roomie: "")
        deleteEventFromFirestore(event ?? test)
        dismiss(animated: true)
        
    }
    
    func deleteEventFromFirestore(_ event: Event) {
        db.collection("events").document(event.id).delete { error in
            if let error = error {
                print("Failed to delete event: \(error.localizedDescription)")
            } else {
                print("Event deleted from Firestore. \(event.id)")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Back" {
            let controller = segue.destination as? ViewController
            controller?.events = events
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
