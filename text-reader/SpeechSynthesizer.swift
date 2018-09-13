//
//  SpeechSynthesizer.swift
//  test-reader
//
//  Created by kyo ago on 2018/10/23.
//  Copyright © 2018 kyo ago. All rights reserved.
//

import Foundation
import AVFoundation

class SpeechSynthesizer: NSObject, AVSpeechSynthesizerDelegate {
    let talker = AVSpeechSynthesizer()
    var rate: Float = 0
    var willSpeak: (NSRange) -> Void = {_ in }
    var didFinish: () -> Void = {}

    override init() {
        super.init()
        self.talker.delegate = self
    }

    func setCallback(_ willSpeak: @escaping (NSRange) -> (), _ didFinish: @escaping () -> ()) {
        self.willSpeak = willSpeak
        self.didFinish = didFinish
    }

    func pauseSpeaking(_ rate: Float) {
        self.rate = rate
        if !self.talker.isPaused {
            self.talker.pauseSpeaking(at: .immediate)
        }
    }

    func setRate(_ rate: Float) {
        if rate > 1 {
            return self.pauseSpeaking(1)
        }
        if rate.isLess(than: 0) {
            return self.pauseSpeaking(0)
        }
        self.rate = rate
        if self.talker.isPaused {
            self.talker.continueSpeaking()
        }
    }

    func utter(str:String) {
        let utterance = AVSpeechUtterance(string: str)
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        self.talker.speak(utterance)
    }

    func stop() {
        self.talker.stopSpeaking(at: .word)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        self.talker.pauseSpeaking(at: .immediate)
    }

    internal func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        utterance.rate = self.rate
        self.willSpeak(characterRange)
    }
    
    internal func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        self.didFinish()
    }
}
