//
//  CustomTableViewCell.swift
//  project-manager-app
//
//  Created by Saiyaff Farouk on 5/25/19.
//  Copyright © 2019 Saiyaff Farouk. All rights reserved.
//

import UIKit
import CoreData

class CustomTableViewCell: UITableViewCell {

    @IBOutlet var taskNameLabel: UILabel!
    @IBOutlet var taskNotesTextview: UITextView!
    
    @IBOutlet var taskDueLabel: UILabel!
    @IBOutlet var progressSlider: MultiSliderApp!
    var selectedTask: Tasks!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        setCustomTaskCell(task: selectedTask)
        // Configure the view for the selected state
    }
    
    func setCustomTaskCell(task: Tasks) {
        taskNameLabel.text = task.taskName
        taskNotesTextview.text = task.taskNotes
        taskDueLabel.text = task.taskDueDate?.convertToString(date: "yyyy-MM-dd")
    }
    
    func configureSlider(sliderValue: CGFloat){
        self.progressSlider.orientation = .horizontal
        self.progressSlider.minimumValue = 0
        self.progressSlider.maximumValue = 100
        self.progressSlider.outerTrackColor = .gray
        self.progressSlider.value = [0, sliderValue]
        self.progressSlider.disabledThumbIndices = [0]
        self.progressSlider.valueLabelPosition = .top
        self.progressSlider.tintColor = .purple
        self.progressSlider.trackWidth = 15
        self.progressSlider.valueLabelFormatter.maximumFractionDigits = 0
        self.progressSlider.showsThumbImageShadow = false
        self.progressSlider.addTarget(self, action: #selector(sliderDragEnded), for: . touchUpInside) // sent when drag ends
    }
    
    @objc
    func sliderDragEnded() {
        let fetchRequest: NSFetchRequest<Tasks> = Tasks.fetchRequest()
        let filterPredicate = NSPredicate(format: "taskId =[c] %@", selectedTask.taskId!)
        fetchRequest.predicate = filterPredicate
        
        do {
            let tasks = try PersistenceService.context.fetch(fetchRequest)
            if tasks.count == 1 {
                tasks[0].taskPercentage = Int16(self.progressSlider.value[1])
                PersistenceService.saveContext()
                self.selectedTask = tasks[0]
            }
            NotificationCenter.default.post(name: NSNotification.Name("updateTaskStatus"), object: nil)
        } catch {
            print(error)
        }
    }

}

extension Date {
    func convertToString(date : String ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = date
        return dateFormatter.string(from: self)
    }
}
