//
//  TaskNumberTwoTests.swift
//  TaskNumberTwoTests
//
//  Created by Максим Егоров on 02/05/2019.
//  Copyright © 2019 Максим Егоров. All rights reserved.
//

import Nimble
import Quick
import RealmSwift
@testable import TaskNumberTwo

class TaskNumberTwoTests: QuickSpec {
    override func spec() {
        super.spec()
        describe("Realm test") {
            var testRealm: Realm!
            var sut: RealmService!
            context("stubbed service") {
                beforeEach {
                    testRealm = try! Realm(
                        configuration: Realm.Configuration(inMemoryIdentifier: "test")
                    )
                    sut = RealmService(realm: testRealm)
                }
                afterEach {
                    try! testRealm.write {
                        testRealm.deleteAll()
                    }
                }
                
                it("add to realm") {
                    //given
                    let task = Task()
                    task.title = "test"
                    task.specification = "test"
                    //when
                    sut.add(title: task.title, description: task.specification ?? "")
                    //then
                    expect(testRealm.objects(Task.self).count) == 1
                }
                
                it("get all from realm") {
                    //given
                    let task1 = Task()
                    let task2 = Task()
                    //when
                    sut.add(title: task1.title, description: task1.specification ?? "")
                    sut.add(title: task2.title, description: task2.specification ?? "")
                    let resultCount = sut.getAll()
                    //then
                    expect(resultCount?.count) == 2
                }

                it("delete from realm") {
                    //given
                    let task = Task()
                    task.title = "test"
                    //when
                    sut.add(title: task.title, description: task.specification ?? "")
                    let taskDel = sut.getTask(title: "test")
                    sut.delete(task: taskDel)
                    //then
                    expect(testRealm.objects(Task.self).count) == 0
                }

                it("edit realm item") {
                    //given
                    var task = Task()
                    task.title = "test"
                    task.specification = "test"
                    //when
                    sut.add(title: task.title, description: task.specification ?? "")
                    sut.edit(oldTitle: task.title, title: "editTest", description: "editTest")
                    task = sut.getTask(title: "editTest")
                    //then
                    expect(task.title) == "editTest"
                    expect(task.specification) == "editTest"
                }

                it("get task test") {
                    //given
                    let task = Task()
                    task.title = "test"
                    //when
                    sut.add(title: task.title, description: task.specification ?? "")
                    let task2 = sut.getTask(title: "test")
                    //then
                    expect(task2.title) == task.title
                }
            }
        }
    }
}
