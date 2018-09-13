//
//  ViewController.swift
//  test-reader
//
//  Created by kyo ago on 2018/09/13.
//  Copyright © 2018 kyo ago. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet weak var beforeText: UIVerticalTextView!
    @IBOutlet weak var afterText: UIVerticalTextView!
    @IBOutlet weak var mainText: UIMainTextView!
    @IBOutlet weak var slideView: UISlideView!
    @IBOutlet weak var panGesture: UISlideView!

    override func viewDidLoad() {
        super.viewDidLoad()

        mainText.setSideView(beforeText, afterText, slideView)
        mainText.loadContent("https://ncode.syosetu.com/txtdownload/dlstart/ncode/369633/?no=1&hankaku=0&code=utf-8&kaigyo=crlf")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func speechSynthesisVoice(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.rate = 0.5
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
}
