//
//  DummyUserDatabaseTests.swift
//  BestApp
//
//  Created by Daniel Jermaine on 19/06/2025.
//

import XCTest
@testable import BestApp

final class DummyUserDatabaseTests: XCTestCase {

    func testUserDatabaseCount() {
        let users = DummyUserDatabase.users
        XCTAssertEqual(users.count, 15, "Expected 15 dummy users")
    }
    
    func testUsersHaveValidNames() {
        for user in DummyUserDatabase.users {
            XCTAssertFalse(user.name.isEmpty, "User name should not be empty")
        }
    }

    func testUsersHaveValidQuestionsAndAnswers() {
        for user in DummyUserDatabase.users {
            XCTAssertFalse(user.question.isEmpty, "Question should not be empty")
            XCTAssertFalse(user.sampleAnswer.isEmpty, "Sample answer should not be empty")
        }
    }
    
    func testUserGendersAreValid() {
        let validGenders = ["Male", "Female"]
        for user in DummyUserDatabase.users {
            XCTAssertTrue(validGenders.contains(user.gender), "User gender '\(user.gender)' is invalid")
        }
    }

    func testUserAgesAreRealistic() {
        for user in DummyUserDatabase.users {
            XCTAssertTrue((12...120).contains(user.age), "Age \(user.age) is not within a realistic range")
        }
    }

    func testFilterFemaleUsers() {
        let females = DummyUserDatabase.users.filter { $0.gender == "Female" }
        XCTAssertGreaterThan(females.count, 0, "Expected at least one female user")
    }
}
