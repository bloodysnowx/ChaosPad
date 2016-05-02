//
//  ViewController.swift
//  ChaosPad
//
//  Created by 岩佐　淳史 on 2016/04/28.
//
//

import UIKit
import OpenAL

class ViewController: UIViewController {
    private var device: COpaquePointer = nil
    private var context: COpaquePointer = nil
    private let samplingRate: ALsizei = 22050
    private let pi: CGFloat = 3.14159
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        touched(touches)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        touched(touches)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        touched(touches)
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches, withEvent: event)
        _ = touches.map(touched)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        initDevice()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        deinitDevice()
    }
    
    private func touched(touches: Set<UITouch>) {
        _ = touches.first.map(play)
    }

    private func initDevice() {
        device = alcOpenDevice(nil)
        context = alcCreateContext(device, nil)
        alcMakeContextCurrent(context)
    }
    
    private func deinitDevice() { }
    
    private func sine(x: ALsizei, frequency: CGFloat, amp: CGFloat) -> ALshort {
        return ALshort(sin(CGFloat(x) * pi * 2 * frequency / CGFloat(samplingRate)) * amp)
    }
    
    private func square(x: ALsizei, frequency: CGFloat, amp: CGFloat) -> ALshort {
        return ALshort(
            (ALsizei(CGFloat(x) * frequency) % samplingRate < samplingRate / 2) ? amp : -amp
        )
    }
    
    private func triangle(x: ALsizei, frequency: CGFloat, amp: CGFloat) -> ALshort {
        let y = ALsizei(CGFloat(x) * frequency) % samplingRate
        if y < samplingRate / 4 { return ALshort(CGFloat(y) / CGFloat(samplingRate / 4) * amp) }
        else if y < 3 * samplingRate / 4 { return ALshort(2 * amp - CGFloat(y) / CGFloat(samplingRate / 4) * amp) }
        else { return ALshort(CGFloat(y) / CGFloat(samplingRate / 4) * amp - 4 * amp) }
    }
    
    private func sawtooth(x: ALsizei, frequency: CGFloat, amp: CGFloat) -> ALshort {
        let y = ALsizei(CGFloat(x) * frequency) % samplingRate
        if y < samplingRate / 2 { return ALshort(CGFloat(y) / CGFloat(samplingRate / 2) * amp) }
        else { return ALshort(CGFloat(y) / CGFloat(samplingRate / 2) * amp - 2 * amp) }
    }
    
    private func hoge(x: ALsizei, frequency: CGFloat, sine: CGFloat, square: CGFloat, triangle: CGFloat, sawtooth: CGFloat) -> ALshort {
        let ret = self.sine(x, frequency: frequency, amp: sine)
        + self.square(x, frequency: square, amp: 8192)
        + self.triangle(x, frequency: triangle, amp: 8192)
        + self.sawtooth(x, frequency: sawtooth, amp: 8192)
        
        return ALshort(ret)
    }
    
    private func play(touch: UITouch) {
        guard touch.type == UITouchType.Stylus else { return }
        play(touch.locationInView(nil).y * 10,
             sine: touch.altitudeAngle / CGFloat(0.5 * pi) * 8192,
             square: touch.azimuthAngleInView(nil) / CGFloat(2 * pi) * 8192,
             triangle: touch.force / touch.maximumPossibleForce * 8192,
             sawtooth: touch.locationInView(nil).x / CGFloat(768) * 8192)
        print(String(format:"azimuth = %f" ,touch.azimuthAngleInView(nil))) // 2 * pi -> square
        print(String(format:"altitude = %f" ,touch.altitudeAngle)) // 1/2 * pi -> sine
        print(String(format:"force = %f" ,touch.force)) // 4.2 -> triangle
        print(String(format:"x = %f" ,touch.locationInView(nil).x)) // 768 -> sawtooth
        print(String(format:"y = %f" ,touch.locationInView(nil).y)) // 1024 -> freq
    }
    
    private func play(frequency: CGFloat, sine: CGFloat, square: CGFloat, triangle: CGFloat, sawtooth: CGFloat) {
        let count: ALuint = 0
        var buffers: [ALuint] = [ALuint](count: 1, repeatedValue: count)
        alGenBuffers(1, &buffers)
        var source: ALuint = 0
        
        let data: [ALshort] = (0..<samplingRate).map { hoge($0, frequency: frequency, sine: sine, square: square, triangle: triangle, sawtooth: sawtooth) }
        alBufferData(buffers[0], AL_FORMAT_MONO16, data, ALsizei(sizeof(ALshort) * data.count), samplingRate)
        alGenSources(1, &source)
        alSourcei(source, AL_BUFFER, ALint(buffers[0]))
        alSourcePlay(source)
    }
}

