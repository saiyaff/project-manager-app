//
//  AddProjectViewController.swift
//  project-manager-app
//
//  Created by Saiyaff Farouk on 5/23/19.
//  Copyright © 2019 Saiyaff Farouk. All rights reserved.
//

import UIKit
import CoreData
import EventKit

class AddProjectViewController: UIViewController {
    
    var parentProject: Projects!
    var popOverType: String!

    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var notesTextView: UITextView!
    @IBOutlet var dueDatePicker: UIDatePicker!
    @IBOutlet var prioritySegmentControl: UISegmentedControl!
    @IBOutlet var addToCalendarSwitch: UISwitch!
    
    var projectPriority = [1, 2, 3]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if popOverType == "edit" {
            nameTextField.text = parentProject.projectName
            notesTextView.text = parentProject.projectNotes
            dueDatePicker.date = parentProject.projectDueDate! as Date
            prioritySegmentControl.selectedSegmentIndex = Int(parentProject.projectPriority)
            addToCalendarSwitch.isOn = parentProject.projectAddedToCalendar
        }
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func addProject(_ sender: Any) {
 
        if (self.nameTextField.text != "") {
            if (validateDate(self.dueDatePicker.date)) {
                if (addToCalendarSwitch.isOn) {
                    addProjectToCalendar(projectName: self.nameTextField.text!, dueDate: self.dueDatePicker.date, notes: self.notesTextView.text, createdDate: Date())
                }
                self.saveProject()
            } else {
                self.present(UtilityService.showErrorMessage("Due date should be a future date"), animated: true, completion: nil)
            }
        } else {
            self.present(UtilityService.showErrorMessage("Project name can't be empty"), animated: true, completion: nil)
        }
        
        dismiss(animated: true)
        
    }
    
    // Reusable functions goes below

    func validateDate(_ date: Date) -> Bool {
        let currentDate = Date()
        if date < currentDate {
            return false
        } else {
            return true
        }
    }
    
    func addProjectToCalendar(projectName: String, dueDate: Date, notes: String, createdDate: Date) {
        let eventStore: EKEventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event) {(granted, error) in
            
            if (granted) && (error == nil) {
                
                let event:EKEvent = EKEvent(eventStore: eventStore)
                event.title = projectName
                event.startDate = createdDate
                event.endDate = dueDate
                event.notes = notes
                event.calendar = eventStore.defaultCalendarForNewEvents
                
                do {
                    try eventStore.save(event, span: .thisEvent)
                }catch let error as NSError{
                    print("error saving event \(error)")
                }
                
            }
            
        }
    }
    
    
    func saveProject() {
        if(popOverType == "new") {
            let project = Projects(context: PersistenceService.context)
            project.projectName = nameTextField.text
            project.projectNotes = notesTextView.text
            project.projectDueDate = dueDatePicker.date as NSDate
            project.projectPriority = Int16( projectPriority[prioritySegmentControl.selectedSegmentIndex])
            project.projectAddedToCalendar = addToCalendarSwitch.isOn
            project.projectId = UUID().uuidString
            
            PersistenceService.saveContext()
        }else {
            let managedContext = PersistenceService.context
            let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Projects")
            fetchRequest.predicate = NSPredicate(format: "projectId = %@", parentProject.projectId!)
            
            do{
                let project = try managedContext.fetch(fetchRequest) as! [Projects]
                let prjUpdate = project[0] as! Projects

                prjUpdate.projectName = nameTextField.text
                prjUpdate.projectNotes = notesTextView.text
                prjUpdate.projectDueDate = dueDatePicker.date as NSDate
                prjUpdate.projectPriority = Int16(projectPriority[prioritySegmentControl.selectedSegmentIndex])
                prjUpdate.projectAddedToCalendar = addToCalendarSwitch.isOn

                do {
                    try managedContext.save()
                }catch{
                    print(error)
                }
                
                NotificationCenter.default.post(name: NSNotification.Name("loadTasks"), object: nil)

            }catch {
                print(error)
            }
            
        }
       
    }
    

}
