//
//  ViewController.swift
//  video-transitions
//
//  Created by Rafi Martirosyan on 20.06.21.
//

import UIKit
import AVKit

class ViewController: UIViewController {
    
    private let firstTrackId: CMPersistentTrackID = 1
    private let secondTrackId: CMPersistentTrackID = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async { [weak self] in
            self?.play()
        }
    }
    
    private func play() {
        let composition = getComposition()
        let playerItem = AVPlayerItem(asset: composition)
        playerItem.videoComposition = getVideoComposition(composition: composition)
        
        let controller = AVPlayerViewController()
        let player = AVPlayer(playerItem: playerItem)
        controller.player = player
        
        player.play()
        present(controller, animated: true)
    }
    
    private func getComposition() -> AVMutableComposition {
        let composition = AVMutableComposition()
        
        let firstTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: firstTrackId)!
        let secondTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: secondTrackId)!
        
        let firstVideo = getAsset(name: "first")
        let secondVideo = getAsset(name: "second")
        let thirdVideo = getAsset(name: "third")
        
        try! firstTrack.insertTimeRange(CMTimeRange(start: .zero, duration: firstVideo.duration), of: firstVideo.tracks(withMediaType: .video).first!, at: .zero)
        try! firstTrack.insertTimeRange(CMTimeRange(start: .zero, duration: secondVideo.duration), of: secondVideo.tracks(withMediaType: .video).first!, at: firstVideo.duration)
        
        try! secondTrack.insertTimeRange(CMTimeRange(start: .zero, duration: CMTime(seconds: 3, preferredTimescale: 600)), of: thirdVideo.tracks(withMediaType: .video).first!, at: CMTime(seconds: 3, preferredTimescale: 600))
        
        return composition
    }
    
    private func getAsset(name: String) -> AVAsset {
        return AVAsset(url: Bundle.main.url(forResource: name, withExtension: "mp4")!)
    }
    
    private func getVideoComposition(composition: AVMutableComposition) -> AVMutableVideoComposition {
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSize(width: 1280, height: 720)
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        videoComposition.renderScale = 1
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: composition.duration)
        
        let firstTrack = composition.track(withTrackID: firstTrackId)!
        let firstInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: firstTrack)
        
        let secondTrack = composition.track(withTrackID: secondTrackId)!
        let secondInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: secondTrack)
        
        let transform = CGAffineTransform(translationX: 200, y: 200).concatenating(CGAffineTransform(scaleX: 0.3, y: 0.3))
        secondInstruction.setTransform(transform, at: .zero)
        secondInstruction.setOpacity(0, at: secondTrack.timeRange.end)
        
        let moveTransform = CGAffineTransform(translationX: 100, y: 100).concatenating(CGAffineTransform(scaleX: 0.8, y: 0.8))
        secondInstruction.setTransformRamp(fromStart: transform, toEnd: moveTransform, timeRange: CMTimeRange(start: CMTime(seconds: 3, preferredTimescale: 600), duration: CMTime(seconds: 1, preferredTimescale: 600)))
        
        secondInstruction.setCropRectangleRamp(fromStartCropRectangle: CGRect(x: 0, y: 0, width: 1920, height: 720), toEndCropRectangle: CGRect(x: 200, y: 200, width: 1920 / 3, height: 720 / 3), timeRange: CMTimeRange(start: CMTime(seconds: 4, preferredTimescale: 600), duration: CMTime(seconds: 1, preferredTimescale: 600)))
        
        secondInstruction.setOpacityRamp(fromStartOpacity: 1, toEndOpacity: 0, timeRange: CMTimeRange(start: CMTime(seconds: 5, preferredTimescale: 600), duration: CMTime(seconds: 1, preferredTimescale: 600)))
        
        
        instruction.layerInstructions = [secondInstruction, firstInstruction]
        videoComposition.instructions = [instruction]
        
        return videoComposition
    }
}

