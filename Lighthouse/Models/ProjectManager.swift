//
//  ProjectManager.swift
//  Lighthouse
//
//  Created by havard.sjong@vipps.no on 04/08/2025.
//

import Foundation
import SwiftUI

class ProjectManager: ObservableObject {
    @Published var currentProject: Project?
    @Published var projectURL: URL?
    
    private let projectsFolder: URL = {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let lighthouseFolder = documentsPath.appendingPathComponent("Lighthouse Projects")
        try? FileManager.default.createDirectory(at: lighthouseFolder, withIntermediateDirectories: true)
        return lighthouseFolder
    }()
    
    func createNewProject(named name: String) {
        let projectFolder = projectsFolder.appendingPathComponent("\(name).lighthouse")
        try? FileManager.default.createDirectory(at: projectFolder, withIntermediateDirectories: true)
        
        let project = Project()
        currentProject = project
        projectURL = projectFolder
        
        saveProject()
    }
    
    func saveProject() {
        guard let project = currentProject,
              let projectURL = projectURL else { return }
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        if let data = try? encoder.encode(project) {
            let jsonURL = projectURL.appendingPathComponent("project.json")
            try? data.write(to: jsonURL)
        }
    }
    
    func loadProject(from url: URL) {
        let jsonURL = url.appendingPathComponent("project.json")
        
        if let data = try? Data(contentsOf: jsonURL) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            if let project = try? decoder.decode(Project.self, from: data) {
                currentProject = project
                projectURL = url
            }
        }
    }
    
    func addLanguage(_ languageName: String, isReference: Bool = false) {
        var language = Language()
        language.isReference = isReference
        currentProject?.languages[languageName] = language
        saveProject()
    }
}