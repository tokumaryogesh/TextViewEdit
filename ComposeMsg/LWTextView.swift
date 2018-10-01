//
//  LWTextView.swift
//  ComposeMsg
//
//  Created by Yogesh Kumar on 27/09/18.
//  Copyright © 2018 Yogesh Kumar. All rights reserved.
//

import UIKit

let blank = "____"

struct Answer {
    var text: String = ""
    var range: NSRange = NSRange.init(location: 0, length: 0)

    init (_ text: String, range: NSRange) {
        self.text = text
        self.range = range
    }

}

class LWTextView: UITextView {

    var ansDictionary = [Int: Answer]()
    var selectedKey: Int = 0

    func setupText(text: String) {
        self.prepareTextForDisplay(text)
        self.isSelectable = true
    }

    private func prepareTextForDisplay(_ text: String) {

        let attString = NSAttributedString(string: text)
        self.attributedText = attString

        let range = NSRange.init(location: 0, length: text.count)
        let expression = try? NSRegularExpression(pattern: blank, options: NSRegularExpression.Options.caseInsensitive)
        guard let resultArray = expression?.matches(in: text, options: NSRegularExpression.MatchingOptions.reportProgress, range: range) else {
            print("no blank found")
            return
        }

        var index = 0
        for ans in resultArray {
            let range = ans.range
            let processedResult = Answer("", range: range)
            ansDictionary[index] = processedResult
            index+=1
        }

        updateAnsBackGroundColor()
        print("result \(ansDictionary)")


    }

    func textWillChange(_ text: String, range: NSRange) {

        var currentIndex = selectedKey
        let delta = text.count - range.length

        if var result = ansDictionary[currentIndex] {
            result.text.append(text)
            result.range.length += delta
            ansDictionary[currentIndex] = result
        }

        currentIndex += 1
        updateAnsFromIndex(currentIndex, withChange: delta)
    }

    func textDidChanged(_ withBackrroundFontRedraw: Bool = false) {

        // Check if ans become Empty
        var currentIndex = selectedKey
        let delta = blank.count
        var isAnsEmpty = false


        if var ans = ansDictionary[currentIndex] {
            if ans.range.length == 0 {
                // Insert blank
                let attText = NSMutableAttributedString(string: self.text)
                let blankAttrString = NSAttributedString(string: blank)
                attText.insert(blankAttrString, at: ans.range.location)

                ans.range.length = blank.count
                ansDictionary[currentIndex] = ans

                self.attributedText = attText
                isAnsEmpty = true
                self.selectedRange = ans.range
            }
        }

        if isAnsEmpty {
            currentIndex += 1
            updateAnsFromIndex(currentIndex, withChange: delta)

            updateAttributesWithSelectedRange()
        }

        if withBackrroundFontRedraw {
            updateAttributesWithSelectedRange()

        }
        print("resukt \(ansDictionary)")
    }

    private func updateAttributesWithSelectedRange() {

        updateAnsBackGroundColor()

        if let ans = ansDictionary[selectedKey] {
            self.selectedRange = ans.range
        }
    }

    func isTextEditable(_ text:String, inRange range: NSRange) -> Bool {

        for key in ansDictionary.keys {
            if let ans = ansDictionary[key] {
                var resultRange = ans.range
                resultRange.length += 1 // Hack to include the charcter inserted at last location
                if rangeContains(resultRange, contains: range) {
                    selectedKey = key
                    return true
                }
            }
        }

        return false
    }

    func rangeContains(_ range1 :NSRange, contains range2: NSRange) -> Bool {

        if (range1.location <= range2.location && range1.location+range1.length >= range2.length+range2.location) {
            return true
        }

        return false

    }

    private func updateAnsFromIndex(_ index: Int, withChange delta: Int) {
        var currentIndex = index

        while currentIndex != INT_MAX {
            if var ans = ansDictionary[currentIndex] {
                ans.range.location += delta
                ansDictionary[currentIndex] = ans
            } else {
                break
            }
            currentIndex += 1
        }
    }

    private func updateAnsBackGroundColor(_ color: UIColor = UIColor.lightGray) {
        var ansIndex = 0
        let attString = NSMutableAttributedString(string: self.text)

        while ansIndex != INT_MAX {
            if let ans = ansDictionary[ansIndex] {
                attString.addAttribute(.backgroundColor, value: color, range: ans.range)
            } else {
                break
            }
            ansIndex += 1
        }

        self.attributedText = attString
        self.font = UIFont.systemFont(ofSize: 22, weight: .black)
    }


    // Mark - Character location pressed

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        let layoutManager = self.layoutManager

        // location of tap in myTextView coordinates and taking the inset into account
        var location = point
        location.x -= self.textContainerInset.left;
        location.y -= self.textContainerInset.top;

        // character index at tap location
        let characterIndex = layoutManager.characterIndex(for: location, in: self.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        // if index is valid then do something.
        if characterIndex < self.textStorage.length {

            // print the character index
            print("character index: \(characterIndex)")

            // print the character at the index
            let myRange = NSRange(location: characterIndex, length: 1)
            let substring = (self.attributedText.string as NSString).substring(with: myRange)
            print("character at index: \(substring)")

            // check if the touch is on Answer
            let range = NSRange.init(location: characterIndex, length: 0)
            let isEditable = self.isTextEditable("", inRange: range)
            if isEditable {
                self.becomeFirstResponder()
                if let ans = ansDictionary[selectedKey] {
                    self.selectedRange = ans.range
                }
            } else {
                self.resignFirstResponder()
            }

        } else {
            self.resignFirstResponder()
        }
        return nil
    }
}

