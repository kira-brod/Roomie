//
//  AddEventViewController.swift
//  Roomie
//
//  Created by Kira Brodsky on 5/28/25.
//

//import UIKit
//
//class AddEventViewController: UIViewController {
//    
//    protocol EventCreationDelegate: AnyObject {
//        func didCreateEvent(_ event: Event)
//    }
//    
//    weak var delegate: EventCreationDelegate?
//
//    @IBOutlet weak var datePicker: UIDatePicker!
//    
//    @IBOutlet weak var titleTextField: UITextField!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//    }
//    
//    @IBAction func AddEvent(_ sender: Any) {
//        let newEvent = Event( id: titleTextField.text ?? "", date: datePicker.date, note: "test")
//            delegate?.didCreateEvent(newEvent)
//            navigationController?.popViewController(animated: true)
//    }
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

protocol EventCreationDelegate: AnyObject {
    func didCreateEvent(_ event: Event)
}

class AddEventViewController: UIViewController {

    weak var delegate: EventCreationDelegate?

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var events: [DateComponents: [Event]] = [:]


    var selectedDate: DateComponents?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Pre-select date if passed from Calendar VC
        if let selectedDate = selectedDate,
           let date = Calendar.current.date(from: selectedDate) {
            datePicker.date = date
        }
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let title = titleTextField.text, !title.isEmpty else { return }

        let date = datePicker.date
        let event = Event(id: title, date: date, note:"string")

        delegate?.didCreateEvent(event)
//        navigationController?.popViewController(animated: true)
        
        let dateComp = Calendar.current.dateComponents([.year, .month, .day], from: date)
        
        events[dateComp] = [event]
        
        NSLog("event added: \(events)")
        
    }
    
    //save is not unwinded - currently testing because event took longer to add and would only appear in events dict after segue happened
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CancelBack" || segue.identifier == "CancelUnwind" {
                let controller = segue.destination as? ViewController
                controller?.events = events
            }
    }
}
