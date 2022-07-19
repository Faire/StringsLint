//
//  StructuredPlaceholderCommentRule.swift
//  StringsLintFramework
//
//  Created by Mark Hall on 2022-07-18.
//

import Foundation

public class StructuredPlaceholderCommentRule {
    private var declaredStrings = [LocalizedString]()
    var severity: ViolationSeverity

    private let declareParser: LocalizableParser

    private var validPlaceholders = Set([
        "number",
        "date",
        "time",
        "money",
        "company_name",
        "formatting",
        "fully_translated_sentence",
        "person_name",
        "currency_code",
        "event_name",
        "email_address"
    ])

    public init(declareParser: LocalizableParser,
                usageParser: LocalizableParser,
                severity: ViolationSeverity) {
        self.declareParser = declareParser
        self.severity = severity
    }

    public required convenience init(configuration: Any) throws {
        var config = StructuredPlaceholderCommentRuleConfiguration()
        do {
            try config.apply(defaultDictionaryValue(configuration, for: StructuredPlaceholderCommentRule.self.description.identifier))
        } catch { }

        self.init(declareParser: ComposedParser(parsers: [
                    try StructuredPlaceholderCommentParser.self.init(configuration: configuration)
                    ]),
                  usageParser: ComposedParser(parsers: []),
                  severity: config.severity
        )
    }
    public required convenience init() {
        let config = StructuredPlaceholderCommentRuleConfiguration()

        self.init(declareParser: StructuredPlaceholderCommentParser(),
                  usageParser: ComposedParser(parsers: []),
                  severity: config.severity)
    }

    private func processDeclarationFile(_ file: File) -> [LocalizedString] {
        do {
            return try self.declareParser.parse(file: file)
        } catch let error {
            print("Unable to parse file \(file): \(error)")
            return []
        }
    }

    private func buildViolation(key: String, violationType: ViolationType, location: Location) -> Violation {
        return Violation(ruleDescription: StructuredPlaceholderCommentRule.description,
                         severity: self.severity,
                         location: location,
                         reason: "Comment for Localized string \"\(key)\" \(violationType.reasonDescription)")
    }
}

extension StructuredPlaceholderCommentRule: LintRule {

    public static var description = RuleDescription(
        identifier: "structured_placeholder_comment",
        name: "StructuredPlaceholderComment",
        description: "Placeholder comment is incorrect"
    )

    public func processFile(_ file: File) {
        if self.declareParser.support(file: file) {
            self.declaredStrings += self.processDeclarationFile(file)
        }
    }

    public var violations: [Violation] {
        return self.declaredStrings.compactMap { string -> (LocalizedString, ViolationType)? in

            guard let jsonData = string.comment?.data(using: String.Encoding.utf8),
                  let jsonComment = try? JSONDecoder().decode(PlaceholderComment.self, from: jsonData) else {
                return (string, ViolationType.invalidJSON)
            }

            guard let description = jsonComment.descriptionString else {
                return (string, ViolationType.missingDescription)
            }

            guard !description.isEmpty else {
                return (string, ViolationType.emptyDescription)
            }

            if let placeholders = jsonComment.placeholders {
                let invalidPlaceholders = Set(placeholders).subtracting(validPlaceholders)
                if !invalidPlaceholders.isEmpty {
                    return (string, ViolationType.containsInvalidPlaceholders(invalidPlaceholders: invalidPlaceholders))
                }
            }

            guard jsonComment.placeholders?.count ?? 0 == string.placeholders.count else {
                return (string, ViolationType.placeholderCountsDontMatch)
            }

            return nil
        }.compactMap({ input -> Violation? in
            let (string, violationType) = input
            return self.buildViolation(key: string.key,
                                       violationType: violationType,
                                       location: string.location)
        })
    }
}

extension StructuredPlaceholderCommentRule {
    enum ViolationType {
        case invalidJSON
        case missingDescription
        case emptyDescription
        case missingPlaceholders
        case containsInvalidPlaceholders(invalidPlaceholders: Set<String>)
        case placeholderCountsDontMatch

        var reasonDescription: String {
            switch self {
            case .invalidJSON:
                return "is not valid JSON"
            case .missingDescription:
                return "is missing the `description`"
            case .emptyDescription:
                return "has an empty `description`"
            case .missingPlaceholders: //TODO: (Mark Hall, July 19) might not need this one
                return "is missing `placeholders`"
            case .containsInvalidPlaceholders(let invalidPlaceholders):
                return "contains invalid placeholders: \"\(invalidPlaceholders.joined(separator: "\", \""))\""
            case .placeholderCountsDontMatch:
                return "number of placeholders don't match"

            }
        }
    }

    fileprivate struct PlaceholderComment: Decodable {
        let descriptionString: String?
        let placeholders: [String]?

        enum CodingKeys: String, CodingKey {
            case descriptionString = "description"
            case placeholders
        }
    }
}
