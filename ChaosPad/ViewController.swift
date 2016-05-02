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
    var device: COpaquePointer = nil
    var context: COpaquePointer = nil
    let samplingRate: ALsizei = 22050

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        initDevice()
    }

    func initDevice() {
        device = alcOpenDevice(nil)
        context = alcCreateContext(device, nil)
        alcMakeContextCurrent(context)
    }
    
    private func hoge(x: ALsizei) -> ALshort {
        return ALshort(sin(Double(x) * 3.14159 * 2 * 440 / Double(samplingRate)) * 32767)
    }
    
    @IBAction func play() {
        var buffer: ALuint = 0
        alGenBuffers(1, &buffer)
        var source: ALuint = 0
        
        let data: [ALshort] = (0..<samplingRate).map(hoge)
        alBufferData(buffer, AL_FORMAT_MONO16, data, ALsizei(sizeof(ALshort) * data.count), samplingRate)
        alGenSources(1, &source)
        alSourcei(source, AL_BUFFER, ALint(buffer))
        alSourcePlay(source)

    }
}

