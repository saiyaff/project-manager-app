//
//  AddTaskViewController.swift
//  project-manager-app
//
//  Created by Saiyaff Farouk on 5/25/19.
//  Copyright © 2019 Saiyaff Farouk. All rights reserved.
//

import UIKit
import CoreData

class AddTaskViewController: UIViewController {
    
    var parentProject: Projects!
    var popOverType: String!
    var currentTask: Tasks!
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var notesTextView: UITextView!
    @IBOutlet var startDatePicker: UIDatePicker!
    @IBOutlet var endDatePicker: UIDatePicker!
    @IBOutlet var eventReminderSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if (popOverType == "edit") {
            nameTextField.text = currentTask.taskName
            notesTextView.text = currentTask.taskNotes
            startDatePicker.date = currentTask.taskStartDate! as Date
            endDatePicker.date = currentTask.taskDueDate! as Date
            eventReminderSwitch.isOn = currentTask.taskReminderFlag
        }
    }
    
    @IBAction func addTask(_ sender: Any) {
        
        if (self.nameTextField.text != "") {
            if (validateDueDate(self.endDatePicker.date)) {
                self.saveTask()
            } else {
                self.present(UtilityService.showErrorMessage("Due date should be a future date"), animated: true, completion: nil)
            }
        } else {
            self.present(UtilityService.showErrorMessage("Task name can't be empty"), animated: true, completion: nil)
        }
        NotificationCenter.default.post(name: NSNotification.Name("loadTasks"), object: nil)
        self.dismiss(animated: true)
        
    }
    
    // Reusable methods goes here
    
    func validateDueDate(_ dueDate: Date) -> Bool {
        let currentDate = Date()
        
        if dueDate > currentDate {
            return true
        } else {
            return false
        }
    }
    
    func saveTask() {
        
        if (popOverType == "new") {
            let task = Tasks(context: PersistenceService.context)
            task.taskName = nameTextField.text
            task.taskNotes = notesTextView.text
            task.taskStartDate = startDatePicker.date
            task.taskDueDate = endDatePicker.date
            task.taskReminderFlag = eventReminderSwitch.isOn
            task.taskId = UUID().uuidString
            
            if (self.parentProject != nil) {
                task.parentProject = self.parentProject
                self.parentProject.addToHasTasks(task)
            }
            
            PersistenceService.saveContext()
        } else {
            
            let managedContext = PersistenceService.context
            let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Tasks")
            fetchRequest.predicate = NSPredicate(format: "taskId = %@", currentTask.taskId!)
            
            do{
                let task = try managedContext.fetch(fetchRequest) as! [Tasks]
                let taskUpdate = task[0] as! Tasks
                
                taskUpdate.taskName = nameTextField.text
                taskUpdate.taskNotes = notesTextView.text
                taskUpdate.taskStartDate = startDatePicker.date
                taskUpdate.taskDueDate = endDatePicker.date as Date
                taskUpdate.taskReminderFlag = eventReminderSwitch.isOn
                
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
