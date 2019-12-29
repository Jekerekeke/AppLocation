//
//  Task.swift
//  TaskNumberTwo
//
//  Created by Максим Егоров on 02/05/2019.
//  Copyright © 2019 Максим Егоров. All rights reserved.
//

import Foundation
import RealmSwift

final class Task: Object {
    @objc dynamic var title = ""
    @objc dynamic var specification: String?
    @objc dynamic var isDone = false
    @objc dynamic var date = Date()
}
