//
//  UIVerticalTextView.swift
//  test-reader
//
//  Created by kyo ago on 2018/10/09.
//  Copyright © 2018 kyo ago. All rights reserved.
//

import UIKit

public class UIVerticalTextView: UITextView {
    func setVerticalText(_ text: String) {
        self.text = text
        self.attributedText = self.makeMutableAttributedString()
    }

    func makeMutableAttributedString() -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(attributedString: self.attributedText)
        let allRange = NSMakeRange(0, attributedString.length)
        attributedString.removeAttribute(.foregroundColor, range: allRange)
        attributedString.addAttribute(.verticalGlyphForm, value: true, range: allRange)
        return attributedString
    }
}
