//
//  VideoContainerView.swift
//  AVPlayer
//
//  Created by Pratheesh on 7/6/21.
//

import UIKit
@objc(VideoContainerView)
class VideoContainerView: UIView {
  var playerLayer: CALayer?
  override func layoutSublayers(of layer: CALayer) {
    super.layoutSublayers(of: layer)
    playerLayer?.frame = self.bounds
  }
}
