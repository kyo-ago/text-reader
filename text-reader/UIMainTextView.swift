//
//  UIMainTextView.swift
//  test-reader
//
//  Created by kyo ago on 2018/10/03.
//  Copyright © 2018 kyo ago. All rights reserved.
//

import UIKit

class UIMomentumScrollingView: UIVerticalTextView, UITextViewDelegate {
    fileprivate var slideView: UISlideView?
    fileprivate let speechSynthesizer: SpeechSynthesizer = SpeechSynthesizer()

    private let interval:TimeInterval = 0.1
    private let incrementVelocityValue:CGFloat = 0.1

    private var timer: Timer?
    private var velocity: CGPoint?

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        targetContentOffset.pointee = scrollView.contentOffset
        if velocity.x == 0 && velocity.y == 0 {
            stopInterval()
            return
        }
        self.setVelocity(velocity)
        if (self.timer != nil) {
            return
        }
        startInterval()
    }

    func onWillSpeak(_ characterRange: NSRange) {
        let mutableAttributedString = self.makeMutableAttributedString()
        mutableAttributedString.addAttribute(.foregroundColor, value: UIColor.red, range: characterRange)
        self.attributedText = mutableAttributedString
    }

    func onDidFinish() {
        self.stopInterval()
    }

    func startInterval() {
        self.timer = Timer.scheduledTimer(timeInterval: interval,
                                          target:self,
                                          selector: #selector(self.intervalScrolling),
                                          userInfo:nil,
                                          repeats:true)
        self.slideView?.isHidden = false;
    }

    func stopInterval() {
        self.timer?.invalidate()
        self.timer = nil
        self.velocity = nil
        self.slideView?.isHidden = true;
        self.speechSynthesizer.stop()
    }

    func incrementVelocity() {
        guard let velocity = self.velocity else {
            return
        }
        self.setVelocity(CGPoint.init(x: velocity.x, y: velocity.y + self.incrementVelocityValue))
    }

    func decrementVelocity() {
        guard let velocity = self.velocity else {
            return
        }
        self.setVelocity(CGPoint.init(x: velocity.x, y: velocity.y - self.incrementVelocityValue))
    }

    private func setVelocity(_ velocity: CGPoint) {
        self.velocity = velocity
        self.speechSynthesizer.setRate(Float(velocity.y) / 5)
    }

    @objc func intervalScrolling() {
        guard let velocity = self.velocity else {
            return
        }
        let offset = CGPoint.init(x: self.contentOffset.x + (velocity.x * 100), y: self.contentOffset.y + (velocity.y * 100))
        if self.contentSize.width < offset.x {
            stopInterval()
            return
        }
        if self.contentSize.height < offset.y {
            stopInterval()
            return
        }
        self.setContentOffset(offset, animated: true)
        if offset.x < 0 || offset.y < 0 {
            stopInterval()
            return
        }
    }
}

class UISyncScrollView: UIMomentumScrollingView {
    fileprivate var beforeText: UIVerticalTextView?
    fileprivate var afterText: UIVerticalTextView?
    
    private var visibleRange: NSRange? {
        guard let startCharacterRange = characterRange(at: bounds.origin) else {
            return nil
        }
        
        let startPosition = startCharacterRange.start
        let endPoint = CGPoint(x: bounds.maxX,
                               y: bounds.maxY)
        guard let endCharacterRange = characterRange(at: endPoint) else {
            return nil
        }
        
        let endPosition = endCharacterRange.end
        
        let startIndex = offset(from: beginningOfDocument, to: startPosition)
        let endIndex = offset(from: startPosition, to: endPosition)
        return NSRange(location: startIndex, length: endIndex)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        beforeText!.setContentOffset(self.contentOffset, animated: false)
//        afterText!.setContentOffset(self.contentOffset, animated: false)

            guard let range = self.visibleRange else {
                return
            }

            UIView.setAnimationsEnabled(false)
            self.beforeText!.scrollRangeToVisible(range)
            self.afterText!.scrollRangeToVisible(range)
            UIView.setAnimationsEnabled(true)

            self.beforeText!.contentOffset.y -= UIScreen.main.bounds.height
            self.afterText!.contentOffset.y += UIScreen.main.bounds.height
    }

    fileprivate func setText(_ text: String) {
        self.setVerticalText(text)
        self.beforeText!.setVerticalText(text)
        self.afterText!.setVerticalText(text)

        self.textContainer.lineFragmentPadding = (self.frame.size.width - self.font!.pointSize) / 2
        
        self.beforeText!.contentOffset.y -= UIScreen.main.bounds.height
        self.afterText!.contentOffset.y += UIScreen.main.bounds.height
        //        self.speechSynthesisVoice(mainText.text)
    }
}

class UIMainTextView: UISyncScrollView {
    let request: Request = Request()

    public func setSideView(_ beforeText: UIVerticalTextView, _ afterText: UIVerticalTextView, _ slideView: UISlideView) {

        self.beforeText = beforeText
        self.afterText = afterText
        self.slideView = slideView

        self.slideView?.setControl(
            {[weak self] in
                self?.stopInterval()
            }, {[weak self] in
                self?.incrementVelocity()
            }, {[weak self] in
                self?.decrementVelocity()
            }
        )

        self.speechSynthesizer.setCallback({ [weak self] (characterRange: NSRange) in
            self?.onWillSpeak(characterRange)
        }) { [weak self] in
            self?.onDidFinish()
        }
    }

    public func loadContent(_ url: String) {
        self.delegate = self

        request.get(url: URL(string: url)!, completionHandler: { data, response, error in
            guard let data = data else {
                return
            }
            let text = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
            DispatchQueue.main.async {
                self.setText(text)
                self.speechSynthesizer.utter(str: text)
            }
        })
    }
}
