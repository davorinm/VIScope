//
//  AudioProvider.swift
//  ImpactWrapConsumer
//
//  Created by Davorin Mađarić on 08/05/2020.
//  Copyright © 2020 Inova. All rights reserved.
//

import Foundation

struct AudioProviderData {
    let timeStamp: Double
    let numberOfFrames: Int
    let samples: [Float]
}

protocol AudioProvider {    
    var samplesData: ObservableEvent<AudioProviderData> { get }
    
    func configureAudioOutput(audioSamples: @escaping (() -> [Float])) 
    
    func startRecording()
    func stopRecording()
}
