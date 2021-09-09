//
//  PBPlayer.swift
//  RNPBPlayer
//
//  Created by Pratheesh Bennet on 20/07/21.
//

import Foundation
@objc(PBPlayer)
class PBPlayer: RCTViewManager {
  override func view() -> UIView! {
    return PBPlayerView()
  }
  override static func requiresMainQueueSetup() -> Bool {
    return true
  }
  @objc func playPauseAction(_ node: NSNumber, callback: @escaping RCTResponseSenderBlock) {
    DispatchQueue.main.async {
      guard let view = self.bridge.uiManager.view(forReactTag: node) as? PBPlayerView else { return }
      view.playPauseAction()
      callback([view.isPlaying])
    }
  }
}
