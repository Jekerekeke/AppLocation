//
//  ViewModel.swift
//  TaskNumberTwo
//
//  Created by Максим Егоров on 02/05/2019.
//  Copyright © 2019 Максим Егоров. All rights reserved.
//

import RealmSwift

protocol ViewModeProtocol {
    var onTasksChanged: ((Results<Task>) -> Void)? { get set }
}

class ViewModel: ViewModeProtocol {
    var onTasksChanged: ((Results<Task>) -> Void)?
    private var tasks: Results<Task>! {
        didSet {
            onTasksChanged?(tasks)
        }
    }
    let realmService = RealmService()
    static let instance = ViewModel()
    
    private init() {}
    
    func createTask(title: String, description: String) {
        realmService.add(title: title, description: description)
        onTasksChanged?(realmService.getAll()!)
    }
    
    func editTask(oldTitle: String, title: String, description: String) {
        realmService.edit(oldTitle: oldTitle, title: title, description: description)
        onTasksChanged?(realmService.getAll()!)
    }
    
    func deleteTask(task: Task) {
        realmService.delete(task: task)
        onTasksChanged?(realmService.getAll()!)
    }
    
    func changeFlagOfDone(task: Task) {
        realmService.changeFlagOfDone(task: task)
        onTasksChanged?(realmService.getAll()!)
    }
    
    func getTask(title: String) -> Task {
       return realmService.getTask(title: title)
    }
    
}
