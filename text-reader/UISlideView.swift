//
//  UISlideView.swift
//  test-reader
//
//  Created by kyo ago on 2018/10/11.
//  Copyright © 2018 kyo ago. All rights reserved.
//

import UIKit

class UISlideView: UIView {
    private var tap: () -> Void = {}
    private var slideUp: () -> Void = {}
    private var slideDown: () -> Void = {}
    private var initialLocation: CGPoint?

    @IBAction func dragGesture(sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            self.initialLocation = sender.location(ofTouch: 0, in: self)
        }
        if sender.state == .changed {
            let location = sender.location(ofTouch: 0, in: self)
            let y = location.y - self.initialLocation!.y
            if y < 0 {
                self.slideUp()
            } else {
                self.slideDown()
            }
        }
        if sender.state == .ended {
            self.initialLocation = nil
        }
        if sender.state == .cancelled {
            self.initialLocation = nil
        }
    }

    func setControl(_ tap: @escaping () -> (), _ slideUp: @escaping () -> (), _ slideDown: @escaping () -> ()) {
        self.tap = tap
        self.slideUp = slideUp
        self.slideDown = slideDown
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.tap()
    }
}
