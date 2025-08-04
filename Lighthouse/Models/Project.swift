//
//  Project.swift
//  Lighthouse
//
//  Created by havard.sjong@vipps.no on 04/08/2025.
//

import Foundation

struct Project: Codable {
    var version: String = "1.0"
    var createdAt: Date = Date()
    var modifiedAt: Date = Date()
    var appContext: AppContext = AppContext()
    var languages: [String: Language] = [:]
    var settings: ProjectSettings = ProjectSettings()
}

struct AppContext: Codable {
    var name: String = ""
    var tagline: String = ""
    var category: String = "Productivity"
    var appStoreURL: String = ""
    var description: String = ""
}

struct Language: Codable {
    var isReference: Bool = false
    var screenshots: [Screenshot] = []
}

struct Screenshot: Codable {
    var id: String = UUID().uuidString
    var imagePath: String? = nil  // Optional - can be empty page
    var pageName: String = ""
    var title: String = ""
    var subtitle: String = ""
}

struct ProjectSettings: Codable {
    var device: String = "iPhone 15 Pro"
    var frameStyle: String = "stroke"
    var strokeWidth: Double = 3
    var backgroundColor: String = "#FFFFFF"
    var margin: String = "medium"
}