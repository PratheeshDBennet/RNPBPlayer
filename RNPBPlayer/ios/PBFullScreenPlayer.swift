//
//  PBFullScreenPlayer.swift
//  PBPlayer
//
//  Created by Pratheesh on 7/12/21.
//

import Foundation
import AVKit
import AVFoundation
@objc(PBFullScreenPlayer)
public class PBFullScreenPlayer: AVPlayerViewController {
  typealias DissmissBlock = () -> Void
  typealias PlayBlock = () -> Void
  typealias PauseBlock = () -> Void
  var onDismiss: DissmissBlock?
  var onPlay: PlayBlock?
  var onPause: PauseBlock?
  public override func viewDidLoad() {
    super.viewDidLoad()
    self.player?.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
  }
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    let value = UIInterfaceOrientation.landscapeLeft.rawValue
    UIDevice.current.setValue(value, forKey: "orientation")
  }
  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    if isBeingDismissed {
      onDismiss?()
    }
  }
  public override var shouldAutorotate: Bool {
      return false
  }
  public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
      return UIInterfaceOrientationMask.landscape
  }
//  public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
//    return UIInterfaceOrientation.landscapeLeft
//  }
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
      if keyPath == "rate" {
          if let playRate = self.player?.rate {
              if playRate == 0.0 {
                onPause?()
                  print("playback paused")
              } else {
                onPlay?()
                  print("playback started")
              }
          }
      }
  }
}

