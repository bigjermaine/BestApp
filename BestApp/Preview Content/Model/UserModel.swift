//
//  UserModel.swift
//  BestApp
//
//  Created by Daniel Jermaine on 18/06/2025.
//

import Foundation

struct UserModel: Identifiable {
    let id = UUID()
    let name: String
    let age: Int
    let imageName: String
    let question: String
    let sampleAnswer: String
    let gender:String
    var isRecorded:Bool = false
}
