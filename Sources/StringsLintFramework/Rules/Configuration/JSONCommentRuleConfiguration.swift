//
//  JSONCommentRuleConfiguration.swift
//  StringsLintFramework
//
//  Created by Mark Hall on 2022-07-18.
//

import Foundation

public struct JSONCommentRuleConfiguration: RuleConfiguration {
    public var description: String {
        return "Default Severity: \(self.defaultSeverity)"
    }

    //TODO: (Mark Hall, July 18) once we have all the existing strings converted to the new comment format, make this an error severity
    public var defaultSeverity: ViolationSeverity = .warning
    public var severityMap: [String:String] = [:]
    public var validPlaceholders: [String] = []

    public mutating func apply(_ configuration: Any) throws {

        guard let configuration = configuration as? [String: Any] else {
            throw ConfigurationError.unknownConfiguration
        }

        self.severityMap = configuration["severity_map"] as! [String:String]
        self.validPlaceholders = defaultStringArray(configuration["valid_placeholders"])
    }

}
