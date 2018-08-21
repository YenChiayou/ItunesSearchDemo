//
//  AudioPlayerController.swift
//  ItunesSearchDemo
//
//  Created by Yenchiayu on 2018/8/21.
//  Copyright © 2018 顏嘉佑(Joe). All rights reserved.
//

import UIKit
import AVFoundation
protocol PlayMusicDelegate: class {
    func closeAciton()
}
protocol Playable {
    var musicUrl: URL? { get }
    var musicDescription: String? { get }
}
class AudioPlayerController: UIViewController {
    static func factory() -> AudioPlayerController {
        let board = UIStoryboard.init(name: "Main", bundle: nil)
        let audioVC = board.instantiateViewController(withIdentifier: "AudioPlayerController") as! AudioPlayerController
        return audioVC
    }
    
   static var defaultSize: CGSize {
       return CGSize(width: UIScreen.main.bounds.width, height: 50)
    }
    
    static var share: AudioPlayerController = AudioPlayerController.factory()
    weak var delegatePlayMusic: PlayMusicDelegate?
    
    lazy var player: AVPlayer = {
        let p = AVPlayer()
        return p
    }()
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        btnClose.addTarget(self, action: #selector(closeAction(sender:)), for: .touchUpInside)
        self.view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7)
    }

    @objc func closeAction(sender: UIButton){
        stop()
        self.delegatePlayMusic?.closeAciton()
    }
    
    func play(model: Playable?) {
        guard let url = model?.musicUrl else {
            return
        }
        labelTitle.text = model?.musicDescription
        stop()
        let playItem = AVPlayerItem.init(url: url)        
        player.replaceCurrentItem(with: playItem)
        player.play()
    }
    
    func stop() {
        player.currentItem?.asset.cancelLoading()
        player.pause()
        player.replaceCurrentItem(with: nil)
    }
    
    
    
}
