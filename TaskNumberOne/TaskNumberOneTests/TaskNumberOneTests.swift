//
//  TaskNumberOneTests.swift
//  TaskNumberOneTests
//
//  Created by Максим Егоров on 23/04/2019.
//  Copyright © 2019 Максим Егоров. All rights reserved.
//

import XCTest
import CoreData
@testable import TaskNumberOne

class TaskNumberOneTests: XCTestCase {
    var mockCoreDataSevice: CoreDataService!

    override func setUp() {
        mockCoreDataSevice = CoreDataService.instance
    }

    override func tearDown() {
        let task = CoreDataService.instance.getTaskWithTitle(title: "edit")
        mockCoreDataSevice.managedObjectContext.delete(task)
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func test_init_coreDataManager(){
        let instance = CoreDataService.instance
        XCTAssertNotNil( instance )
    }
    
    func test_coreDataStackInitialization() {
        let coreDataStack = CoreDataService.instance.managedObjectContext
        XCTAssertNotNil( coreDataStack )
    }
    
    func test_create_task() {
        XCTAssertNotNil(mockCoreDataSevice.createTask(title: "test1", specification: "test1"))
        XCTAssertNotNil(mockCoreDataSevice.createTask(title: "test2", specification: "test2"))
    }
    
    func test_fetch_all_person() {
        let size = mockCoreDataSevice.fetchData(entityName: "Tasks", keyForSort: "date")
        guard  let sections = size.sections else { return }
        XCTAssertEqual(mockCoreDataSevice.getDataBaseSize(), sections[0].numberOfObjects)
    }
    
    func test_remove_person() {
        let task = CoreDataService.instance.getTaskWithTitle(title: "test1")
        let size = mockCoreDataSevice.getDataBaseSize()
        mockCoreDataSevice.managedObjectContext.delete(task)
        CoreDataService.instance.saveContext()
        XCTAssertEqual(mockCoreDataSevice.getDataBaseSize(), size - 1)
    }
    
    func test_edit_task() {
        let task = CoreDataService.instance.getTaskWithTitle(title: "test2")
        mockCoreDataSevice.editTask(oldTitle: task.title!, newTitle: "edit", specification: "edit")
        XCTAssertEqual("edit", task.title)
        XCTAssertEqual("edit", task.specification)
    }
}
