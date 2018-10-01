//
//  ViewController.swift
//  ComposeMsg
//
//  Created by Yogesh Kumar on 27/09/18.
//  Copyright © 2018 Yogesh Kumar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var frame = UIScreen.main.bounds
        frame.origin = CGPoint(x: 0, y: 40)

        let textView = LWTextView(frame: frame, textContainer: nil)
        self.view.addSubview(textView)
        textView.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        textView.delegate = self
        textView.setupText(text: "I’m learning how to ____ so ____. I can trust m ____ stop____ ")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        guard let textView = textView as? LWTextView else {
            return false
        }

        if textView.isTextEditable(text, inRange: range) {

            if text.count == 0 && textView.selectedRange.length > 0 {
                if let ans = textView.ansDictionary[textView.selectedKey] {
                        textView.textWillChange(text, range: range)
                        let attText = NSMutableAttributedString(string: textView.text)
                        attText.replaceCharacters(in: textView.selectedRange, with: "")
                        textView.attributedText = attText
                        textView.textDidChanged(true)
                        return false
                }
            } else {
                textView.textWillChange(text, range: range)
            }
            
            return true
        }

        return false
    }

    func textViewDidChange(_ textView: UITextView) {
        if let textView = textView as? LWTextView  {
            textView.textDidChanged()
        }
    }
}
