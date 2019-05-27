//
//  DetailViewController.swift
//  project-manager-app
//
//  Created by Saiyaff Farouk on 5/23/19.
//  Copyright © 2019 Saiyaff Farouk. All rights reserved.
//

import UIKit
import MultiSlider
import CoreData

class DetailViewController: UIViewController, UIPopoverPresentationControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    
    var detailViewController: DetailViewController? = nil
    var project: Projects!
    var progressBarValue: CGFloat = 0
    
    private var tasks: [Tasks] = [];

    @IBOutlet var editProjectBtn: UIBarButtonItem!
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet var projectNotesLabel: UITextView!
    @IBOutlet var dueDateLabel: UILabel!
    @IBOutlet var numOfDaysLeftLabel: UILabel!
    
    @IBOutlet var addTaskBarbtnItem: UIBarButtonItem!
    
    @IBOutlet var progressBar: ProgressBar!
    
    @IBOutlet var tasksTableView: UITableView!
    
    var detailItem: Projects? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
        
//        configureSlider()
        
        tasksTableView.dataSource = self
        tasksTableView.delegate = self
        self.getTasks()
        
        // refresh tasks on add
        NotificationCenter.default.addObserver(self, selector: #selector(afterNewTaskCreation), name: NSNotification.Name("loadTasks"), object: nil)
        
        // progress bar value
        DispatchQueue.main.async {
            self.progressBar.progress = min(0.01 * self.progressBarValue, 1)
        }
        
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                self.project = detail
                label.text = detail.projectName!.description
                self.projectNotesLabel.text = detail.projectNotes
                self.dueDateLabel.text = UtilityService.convertDateToString(detail.projectDueDate! as Date)
                let currentDate = Date()
                let numOfDaysLeftString = self.getDaysLeftString(currentDate, self.project!.projectDueDate! as Date)
                self.numOfDaysLeftLabel.text = numOfDaysLeftString

            }
        }

    }
    
    func getDaysLeftString(_ older: Date,_ newer: Date) -> (String?)  {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        
        let componentsLeftTime = Calendar.current.dateComponents([.minute , .hour , .day,.month, .weekOfMonth,.year], from: older, to: newer)
        
        let year = componentsLeftTime.year ?? 0
        if  year > 0 {
            formatter.allowedUnits = [.year]
            return formatter.string(from: older, to: newer)
        }
        
        
        let month = componentsLeftTime.month ?? 0
        if  month > 0 {
            formatter.allowedUnits = [.month]
            return formatter.string(from: older, to: newer)
        }
        
        let weekOfMonth = componentsLeftTime.weekOfMonth ?? 0
        if  weekOfMonth > 0 {
            formatter.allowedUnits = [.weekOfMonth]
            return formatter.string(from: older, to: newer)
        }
        
        let day = componentsLeftTime.day ?? 0
        if  day > 0 {
            formatter.allowedUnits = [.day]
            return formatter.string(from: older, to: newer)
        }
        
        let hour = componentsLeftTime.hour ?? 0
        if  hour > 0 {
            formatter.allowedUnits = [.hour]
            return formatter.string(from: older, to: newer)
        }
        
        let minute = componentsLeftTime.minute ?? 0
        if  minute > 0 {
            formatter.allowedUnits = [.minute]
            return formatter.string(from: older, to: newer) ?? ""
        }
        
        return nil
    }
    
    @objc
    func sliderChanged(slider: MultiSlider) {
        print("\(slider.value)") // e.g., [1.0, 4.5, 5.0]
    }
    
    @objc
    func afterNewTaskCreation() {
        self.getTasks()
        tasksTableView.reloadData()
    }
    
    func projectDatanewFetch(id: String){
        print("fetchUpdateProject")
        if (self.detailItem != nil) {
            let managedContext = PersistenceService.context
            let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Projects")
            fetchRequest.predicate = NSPredicate(format: "projectId = %@", (id))
        
            do {
                let prj = try managedContext.fetch(fetchRequest) as! [Projects]
                print(prj[0])
                project = prj[0]
                configureView()
            } catch {
                print(error)
            }
            
        }
    }
    
    func getTasks(){
        if (self.project != nil) {
            if let allTasks = self.project.hasTasks?.allObjects as? [Tasks] {
                self.tasks = allTasks
                self.setProjectProgress()
            }
            self.projectDatanewFetch(id: self.project.projectId!)
        }
        tasksTableView.reloadData()
    }
    
    func setProjectProgress() {
        var totalPercentage: Float = 0.0
        for i in self.tasks {
            totalPercentage = totalPercentage + Float(i.taskPercentage)
        }
        var projectPercentage: Float = 0.0;
        projectPercentage = totalPercentage / Float(self.tasks.count)
        if (!projectPercentage.isNaN) {
            self.progressBarValue = CGFloat(Int(projectPercentage))
        }
    }
    
    // custom table view related fns
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellIdentifier") as! CustomTableViewCell
        let task = tasks[indexPath.row]
        cell.configureSlider(sliderValue: CGFloat(task.taskPercentage))
        cell.selectedTask = task
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = self.deleteAction(at: indexPath)
        let edit = self.editAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
    
    func editAction(at indexPath: IndexPath) -> UIContextualAction {
        let task = tasks[indexPath.row]
        let action = UIContextualAction.init(style: .normal, title: "edit") {(action , view, completion) in
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "AddTask") as! AddTaskViewController
            self.preparePopover(contentController: viewController, sender: self.addTaskBarbtnItem, delegate: self)
            viewController.parentProject = self.detailItem
            viewController.currentTask = task
            viewController.popOverType = "edit"
            self.present(viewController, animated: true, completion: nil)
            completion(true)
        }
        
        action.image = UIGraphicsImageRenderer(size: CGSize(width: 30, height: 30)).image { _ in
            UIImage(named: "icons8-edit-30")?.draw(in: CGRect(x: 0, y: 0, width: 30, height: 30))
            action.backgroundColor = UIColor.blue
        
        }
        return action
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let task = tasks[indexPath.row]
        let action = UIContextualAction.init(style: .normal, title: "delete") {(action , view, completion) in
            let deleteAlert = UIAlertController(title: "Confirm", message: "Delete task \(task.taskName!) ? ", preferredStyle: UIAlertController.Style.alert)
            deleteAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                let context = PersistenceService.context
                context.delete(self.tasks[indexPath.row])
                self.tasks.remove(at: indexPath.row)
                self.tasksTableView.deleteRows(at: [indexPath], with: .fade)
                PersistenceService.saveContext()
                //                self.reloadOnDismiss()
                
            }))
            
            deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel , handler: { (action: UIAlertAction!) in
                print("Handle Cancel Logic here")
            }))
            
            self.present(deleteAlert, animated: true, completion: nil)
            
            print(task)
            completion(true)
        }
        
        action.image = UIGraphicsImageRenderer(size: CGSize(width: 30, height: 30)).image { _ in
            UIImage(named: "icons8-close-window-30")?.draw(in: CGRect(x: 0, y: 0, width: 30, height: 30))
            
            
            action.backgroundColor = UIColor.red

        }
        
        return action
    }
    
    //  Events goes here
    @IBAction func onAddTask(_ sender: Any) {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "AddTask") as! AddTaskViewController
        self.preparePopover(contentController: viewController, sender: self.addTaskBarbtnItem, delegate: self)
        viewController.parentProject = self.project
        viewController.popOverType = "new"
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func onEditProject(_ sender: Any) {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "AddProject") as! AddProjectViewController
        self.preparePopover(contentController: viewController, sender: self.editProjectBtn, delegate: self)
        viewController.parentProject = self.project
        viewController.popOverType = "edit"
        present(viewController, animated: true, completion: nil)
    }
    
    
    func preparePopover(contentController: UIViewController,
                        sender: UIBarButtonItem,
                        delegate: UIPopoverPresentationControllerDelegate?) {
        
        let bounds = UIScreen.main.bounds
        let widgetWidth = bounds.size.width - 22
        let widgetHeight = bounds.size.height - 150
        
        contentController.preferredContentSize = CGSize(width: widgetWidth, height: widgetHeight)
        contentController.modalPresentationStyle = .popover
        contentController.popoverPresentationController?.barButtonItem = sender
        contentController.popoverPresentationController!.delegate = delegate
    }
    

}

extension Date {
    func convertDateToString(date : String ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = date
        return dateFormatter.string(from: self)
    }
}
