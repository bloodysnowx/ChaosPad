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
    let samplingRate = 22050

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
        alGenBuffers(1, &buffer)
    }
    
    @IBAction func play() {
        var buffer: ALuint = 0
        var source: ALuint = 0
        let data: [ALshort] = (0..<samplingRate).map({ ALshort(sin(Double($0) * 3.14159 * 2 * 440 / samplingRate) * 32767) })
        alBufferData(buffer, AL_FORMAT_MONO16, data, ALsizei(sizeof(ALshort) * data.count), samplingRate)
        alGenSources(1, &source)
        alSourcei(source, AL_BUFFER, ALint(buffer))
        alSourcePlay(source)
    }
}

