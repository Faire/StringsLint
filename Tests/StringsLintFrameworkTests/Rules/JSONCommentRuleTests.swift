//
//  File.swift
//  
//
//  Created by Mark Hall on 2022-07-19.
//

import XCTest
@testable import StringsLintFramework

class JSONCommentRuleTests: XCTestCase {

    func testStringWithValidComment() {

        let file = File(name: "Localizable.strings", content: """
            /*
              Retailer.strings
              Retailer

              Created by Raissa Nucci on 07/04/20.
              Copyright © 2020 Faire Inc. All rights reserved.
            */
            /*
            {
              "description": "A CTA to go to the New Arrivals shopping section, links the retailer to this category",
              "placeholders": ["person_name", "number"],
              "img": "https://www.google.com/"
            }
             */
            "EMPTY_STATE.VIEW_BAG_BUTTON_MULTIPLE_PLACEHOLDERS" = "View Bag %@ %@";
            """)

        let rule = JSONCommentRule()
        rule.processFile(file)

        XCTAssertEqual(rule.violations.count, 0)
    }

    func testStringWithMissingDescriptionInComment() {

        let file = File(name: "Localizable.strings", content: """
            /*
              Retailer.strings
              Retailer

              Created by Raissa Nucci on 07/04/20.
              Copyright © 2020 Faire Inc. All rights reserved.
            */
            /*
            {
              "placeholders": ["person_name", "number"]
            }
             */
            "EMPTY_STATE.VIEW_BAG_BUTTON_MULTIPLE_PLACEHOLDERS" = "View Bag %@ %@";
            """)

        let rule = JSONCommentRule()
        rule.processFile(file)

        XCTAssertEqual(rule.violations.count, 1)
        XCTAssertEqual(rule.violations.first?.severity, .warning)
    }

    func testStringWithEmptyDescriptionInComment() {

        let file = File(name: "Localizable.strings", content: """
            /*
              Retailer.strings
              Retailer

              Created by Raissa Nucci on 07/04/20.
              Copyright © 2020 Faire Inc. All rights reserved.
            */
            /*
            {
              "description": "",
              "placeholders": ["person_name", "number"]
            }
             */
            "EMPTY_STATE.VIEW_BAG_BUTTON_MULTIPLE_PLACEHOLDERS" = "View Bag %@ %@";
            """)

        let rule = JSONCommentRule()
        rule.processFile(file)

        XCTAssertEqual(rule.violations.count, 1)
        XCTAssertEqual(rule.violations.first?.severity, .warning)
    }

    func testStringWithInvalidPlaceholdersInComment() {

        let file = File(name: "Localizable.strings", content: """
            /*
              Retailer.strings
              Retailer

              Created by Raissa Nucci on 07/04/20.
              Copyright © 2020 Faire Inc. All rights reserved.
            */
            /*
            {
              "description": "A CTA to go to the New Arrivals shopping section, links the retailer to this category",
              "placeholders": ["person_name", "asdf"]
            }
             */
            "EMPTY_STATE.VIEW_BAG_BUTTON_MULTIPLE_PLACEHOLDERS" = "View Bag %@ %@";
            """)

        let rule = JSONCommentRule()
        rule.processFile(file)

        XCTAssertEqual(rule.violations.count, 1)
        XCTAssertEqual(rule.violations.first?.severity, .warning)
    }

    func testStringWithPlaceholderCountNotMatchingInComment() {

        let file = File(name: "Localizable.strings", content: """
            /*
              Retailer.strings
              Retailer

              Created by Raissa Nucci on 07/04/20.
              Copyright © 2020 Faire Inc. All rights reserved.
            */
            /*
            {
              "description": "A CTA to go to the New Arrivals shopping section, links the retailer to this category",
              "placeholders": ["person_name"]
            }
             */
            "EMPTY_STATE.VIEW_BAG_BUTTON_MULTIPLE_PLACEHOLDERS" = "View Bag %@ %@";
            """)

        let rule = JSONCommentRule()
        rule.processFile(file)

        XCTAssertEqual(rule.violations.count, 1)
        XCTAssertEqual(rule.violations.first?.severity, .warning)
    }

    func testStringWithInvalidComment() {

        let file = File(name: "Localizable.strings", content: """
            /*
              Retailer.strings
              Retailer

              Created by Raissa Nucci on 07/04/20.
              Copyright © 2020 Faire Inc. All rights reserved.
            */
            /*
            {
              "description": "A CTA to go to the New Arrivals shopping section, links the retailer to this category",
             */
            "EMPTY_STATE.VIEW_BAG_BUTTON_MULTIPLE_PLACEHOLDERS" = "View Bag %@ %@";
            """)

        let rule = JSONCommentRule()
        rule.processFile(file)

        XCTAssertEqual(rule.violations.count, 1)
        XCTAssertEqual(rule.violations.first?.severity, .warning)
    }

  func testStringWithValidComment_NewlyAddedPlaceholderTypes() {

      let file = File(name: "Localizable.strings", content: """
          /*
            Retailer.strings
            Retailer

            Created by Raissa Nucci on 07/04/20.
            Copyright © 2020 Faire Inc. All rights reserved.
          */
          /*
          {
            "description": "A CTA to go to the New Arrivals shopping section, links the retailer to this category",
            "placeholders": ["tariff_code", "sku", "token", "tracking_code"],
            "img": "https://www.google.com/"
          }
           */
          "EMPTY_STATE.VIEW_BAG_BUTTON_MULTIPLE_PLACEHOLDERS" = "View Bag %@ %@ %@ %@";
          """)

      let rule = JSONCommentRule()
      rule.processFile(file)

      XCTAssertEqual(rule.violations.count, 0)
  }

  func testStringWithValidComment_DateRangePlaceholderTypes() {

      let file = File(name: "Localizable.strings", content: """
          /*
            Retailer.strings
            Retailer

            Created by Raissa Nucci on 07/04/20.
            Copyright © 2020 Faire Inc. All rights reserved.
          */
          /*
          {
            "description": "A CTA to go to the New Arrivals shopping section, links the retailer to this category",
            "placeholders": ["day", "month"],
            "img": "https://www.google.com/",
            "max_character_count": 20
          }
           */
          "EMPTY_STATE.VIEW_BAG_BUTTON_MULTIPLE_PLACEHOLDERS" = "View Bag %@ %@";
          """)

      let rule = JSONCommentRule()
      rule.processFile(file)

      XCTAssertEqual(rule.violations.count, 0)
  }

    func testStringWithMissingURL() {

        let file = File(name: "Localizable.strings", content: """
            /*
              Retailer.strings
              Retailer

              Created by Raissa Nucci on 07/04/20.
              Copyright © 2020 Faire Inc. All rights reserved.
            */
            /*
            {
              "description": "A CTA to go to the New Arrivals shopping section, links the retailer to this category",
              "placeholders": ["day", "month"]
            }
             */
            "EMPTY_STATE.VIEW_BAG_BUTTON_MULTIPLE_PLACEHOLDERS" = "View Bag %@ %@";
            """)

        let rule = JSONCommentRule()
        rule.processFile(file)

        XCTAssertEqual(rule.violations.count, 1)
        XCTAssertEqual(rule.violations.first?.severity, .warning)
    }

    func testStringWithInvalidURL() {

        let file = File(name: "Localizable.strings", content: """
            /*
              Retailer.strings
              Retailer

              Created by Raissa Nucci on 07/04/20.
              Copyright © 2020 Faire Inc. All rights reserved.
            */
            /*
            {
              "description": "A CTA to go to the New Arrivals shopping section, links the retailer to this category",
              "placeholders": ["day", "month"],
              "img": "Something not a URL"
            }
             */
            "EMPTY_STATE.VIEW_BAG_BUTTON_MULTIPLE_PLACEHOLDERS" = "View Bag %@ %@";
            """)

        let rule = JSONCommentRule()
        rule.processFile(file)

        XCTAssertEqual(rule.violations.count, 1)
        XCTAssertEqual(rule.violations.first?.severity, .warning)
    }

    func testStringWithInvalidComment_StringLongerThanMaxCharCount() {

        let file = File(name: "Localizable.strings", content: """
            /*
              Retailer.strings
              Retailer

              Created by Raissa Nucci on 07/04/20.
              Copyright © 2020 Faire Inc. All rights reserved.
            */
            /*
            {
              "description": "A CTA to go to the New Arrivals shopping section, links the retailer to this category",
              "placeholders": ["day", "month"],
              "img": "https://www.google.com/",
              "max_character_count": 4
            }
             */
            "EMPTY_STATE.VIEW_BAG_BUTTON_MULTIPLE_PLACEHOLDERS" = "View Bag %@ %@";
            """)

        let rule = JSONCommentRule()
        rule.processFile(file)

        XCTAssertEqual(rule.violations.count, 1)
        XCTAssertEqual(rule.violations.first?.severity, .warning)
    }

    func testStringWithValidComment_ConfigurationProvided() {

        let file = File(name: "Localizable.strings", content: """
            /*
              Retailer.strings
              Retailer

              Created by Raissa Nucci on 07/04/20.
              Copyright © 2020 Faire Inc. All rights reserved.
            */
            /*
            {
              "description": "A CTA to go to the New Arrivals shopping section, links the retailer to this category",
              "placeholders": ["day", "month"],
              "img": "https://www.google.com/",
              "max_character_count": 4
            }
             */
            "EMPTY_STATE.VIEW_BAG_BUTTON_MULTIPLE_PLACEHOLDERS" = "View Bag %@ %@";
            """)

        let config = ["json_comment_rule": ["severity_map": [
            "invalidJSON": "error",
            "missingDescription": "error",
            "emptyDescription": "error",
            "containsInvalidPlaceholders": "error",
            "placeholderCountsDontMatch": "error",
            "missingScreenshotURL": "none",
            "invalidScreenshotURL": "none",
            "maxCharacterCountExceeded": "none"]]]

        var rule: JSONCommentRule?
        do {
           try rule = JSONCommentRule(configuration: config)
        } catch {}

        if let rule = rule {
            rule.processFile(file)

            XCTAssertEqual(rule.violations.count, 1)
            XCTAssertEqual(rule.violations.first?.severity, ViolationSeverity.none)
        } else {
            XCTAssertEqual(true, false)
        }
    }

  func testStringsDict_with_noViolations() {

      let file = File(name: "Localizable.stringsdict", content: """
          <?xml version="1.0" encoding="UTF-8"?>
          <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
          <plist version="1.0">
          <dict>
            <key>ORDER.ACTIONS.TRACK_SHIPMENTS</key>
            <dict>
              <key>context</key>
              <string>
                      {
                          "description": "CTA to go to package tracking from the orders list and order details pages",
                          "placeholders": ["number"],
                          "img": "https://www.google.com/"
                      }
                  </string>
              <key>NSStringLocalizedFormatKey</key>
              <string>%#@elements@</string>
              <key>elements</key>
              <dict>
                <key>NSStringFormatSpecTypeKey</key>
                <string>NSStringPluralRuleType</string>
                <key>NSStringFormatValueTypeKey</key>
                <string>d</string>
                <key>other</key>
                <string>Track Shipment · %d packages</string>
                <key>one</key>
                <string>Track Shipment · %d package</string>
              </dict>
            </dict>
          </dict>
          </plist>
          """)

      let rule = JSONCommentRule()
      rule.processFile(file)

      XCTAssertEqual(rule.violations.count, 0)
  }

  func testStringsDict_with_missingDescriptionViolation() {

      let file = File(name: "Localizable.stringsdict", content: """
          <?xml version="1.0" encoding="UTF-8"?>
          <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
          <plist version="1.0">
          <dict>
            <key>ORDER.ACTIONS.TRACK_SHIPMENTS</key>
            <dict>
              <key>context</key>
              <string>
                      {
                          "placeholders": ["number"]
                      }
                  </string>
              <key>NSStringLocalizedFormatKey</key>
              <string>%#@elements@</string>
              <key>elements</key>
              <dict>
                <key>NSStringFormatSpecTypeKey</key>
                <string>NSStringPluralRuleType</string>
                <key>NSStringFormatValueTypeKey</key>
                <string>d</string>
                <key>other</key>
                <string>Track Shipment · %d packages</string>
                <key>one</key>
                <string>Track Shipment · %d package</string>
              </dict>
            </dict>
          </dict>
          </plist>
          """)

      let rule = JSONCommentRule()
      rule.processFile(file)

      XCTAssertEqual(rule.violations.count, 1)
  }

  func testStringsDict_with_noPlaceholderInString_noViolations() {

      let file = File(name: "Localizable.stringsdict", content: """
          <?xml version="1.0" encoding="UTF-8"?>
          <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
          <plist version="1.0">
          <dict>
            <key>ORDER.ACTIONS.TRACK_SHIPMENTS</key>
            <dict>
              <key>context</key>
              <string>
                      {
                          "description": "CTA to go to package tracking from the orders list and order details pages",
                          "img": "https://www.google.com/"
                      }
                  </string>
              <key>NSStringLocalizedFormatKey</key>
              <string>%#@elements@</string>
              <key>elements</key>
              <dict>
                <key>NSStringFormatSpecTypeKey</key>
                <string>NSStringPluralRuleType</string>
                <key>NSStringFormatValueTypeKey</key>
                <string>d</string>
                <key>other</key>
                <string>Track packages</string>
                <key>one</key>
                <string>Track package</string>
              </dict>
            </dict>
          </dict>
          </plist>
          """)

      let rule = JSONCommentRule()
      rule.processFile(file)

      XCTAssertEqual(rule.violations.count, 0)
  }

  func testStringsDict_with_placeholderInString_missingPlaceholdersInComment_oneViolations() {

      let file = File(name: "Localizable.stringsdict", content: """
          <?xml version="1.0" encoding="UTF-8"?>
          <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
          <plist version="1.0">
          <dict>
            <key>ORDER.ACTIONS.TRACK_SHIPMENTS</key>
            <dict>
              <key>context</key>
              <string>
                      {
                          "description": "CTA to go to package tracking from the orders list and order details pages"
                      }
                  </string>
              <key>NSStringLocalizedFormatKey</key>
              <string>%#@elements@</string>
              <key>elements</key>
              <dict>
                <key>NSStringFormatSpecTypeKey</key>
                <string>NSStringPluralRuleType</string>
                <key>NSStringFormatValueTypeKey</key>
                <string>d</string>
                <key>other</key>
                <string>Track Shipment · %d packages</string>
                <key>one</key>
                <string>Track Shipment · %d package</string>
              </dict>
            </dict>
          </dict>
          </plist>
          """)

      let rule = JSONCommentRule()
      rule.processFile(file)

      XCTAssertEqual(rule.violations.count, 1)
  }

    func testStringsDict_with_noPlaceholderInString_missingURL() {

        let file = File(name: "Localizable.stringsdict", content: """
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
            <dict>
              <key>ORDER.ACTIONS.TRACK_SHIPMENTS</key>
              <dict>
                <key>context</key>
                <string>
                        {
                            "description": "CTA to go to package tracking from the orders list and order details pages"
                        }
                    </string>
                <key>NSStringLocalizedFormatKey</key>
                <string>%#@elements@</string>
                <key>elements</key>
                <dict>
                  <key>NSStringFormatSpecTypeKey</key>
                  <string>NSStringPluralRuleType</string>
                  <key>NSStringFormatValueTypeKey</key>
                  <string>d</string>
                  <key>other</key>
                  <string>Track packages</string>
                  <key>one</key>
                  <string>Track package</string>
                </dict>
              </dict>
            </dict>
            </plist>
            """)

        let rule = JSONCommentRule()
        rule.processFile(file)

        XCTAssertEqual(rule.violations.count, 1)
    }

    func testStringsDict_with_noPlaceholderInString_invalidURL() {

        let file = File(name: "Localizable.stringsdict", content: """
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
            <dict>
              <key>ORDER.ACTIONS.TRACK_SHIPMENTS</key>
              <dict>
                <key>context</key>
                <string>
                        {
                            "description": "CTA to go to package tracking from the orders list and order details pages",
                            "img": "Something not a URL"
                        }
                    </string>
                <key>NSStringLocalizedFormatKey</key>
                <string>%#@elements@</string>
                <key>elements</key>
                <dict>
                  <key>NSStringFormatSpecTypeKey</key>
                  <string>NSStringPluralRuleType</string>
                  <key>NSStringFormatValueTypeKey</key>
                  <string>d</string>
                  <key>other</key>
                  <string>Track packages</string>
                  <key>one</key>
                  <string>Track package</string>
                </dict>
              </dict>
            </dict>
            </plist>
            """)

        let rule = JSONCommentRule()
        rule.processFile(file)

        XCTAssertEqual(rule.violations.count, 1)
    }

}
