//
//  RealmService.swift
//  TaskNumberTwo
//
//  Created by Максим Егоров on 02/05/2019.
//  Copyright © 2019 Максим Егоров. All rights reserved.
//

import Foundation
import RealmSwift

final class RealmService {
    private let realm: Realm?
    
    public init(realm: Realm?) {
        self.realm = realm
    }
    
    public convenience init() {
        do {
            let realm = try Realm()
            self.init(realm: realm)
        } catch {
            fatalError("\(error)")
        }
    }
    
    func getAll() -> Results<Task>? {
        guard let realm = realm else { return nil }
        return realm.objects(Task.self).sorted(byKeyPath: "date", ascending: false).sorted(byKeyPath: "isDone")
    }
    
    func add(title: String, description: String) {
        let task = Task()
        task.title = title
        task.specification = description
        try? realm?.write {
            realm?.add(task)
        }
    }
    
    func edit(oldTitle: String, title: String, description: String) {
        let task = getTask(title: oldTitle)
        try? realm?.write {
            task.title = title
            task.specification = description
        }
    }
    
    func getTask(title: String) -> Task{
        let tasks = realm?.objects(Task.self).filter("title = '\(title)'")
        guard let task = tasks?.first else {
            return Task()
        }
        return task
    }
    
    func delete(task: Task) {
        try? realm?.write {
            realm?.delete(task)
        }
    }
    
    func changeFlagOfDone(task: Task) {
        try? realm?.write {
            task.isDone = !task.isDone
        }
    }
}
