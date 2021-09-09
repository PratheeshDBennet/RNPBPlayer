import UIKit
import AVFoundation
import AVKit
//Test
@objc(PBPlayerView)
public class PBPlayerView: UIView {
  var playerState: OverlayState = .none
  var activityView: UIActivityIndicatorView?
  let seekDuration: Double = 5
  public typealias DissmissBlock = () -> Void
  public var onDismiss: DissmissBlock?
  @objc var onEnd: RCTDirectEventBlock!
  @objc public var url: String = "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4" {
    didSet {
      setupPBPlayer()
    }
  }
  var timeObserverToken: Any?
  lazy var videoContainerView: VideoContainerView = {
    let container = VideoContainerView()
    container.translatesAutoresizingMaskIntoConstraints = false
    container.backgroundColor =  UIColor(red: 0/255, green: 100/255, blue: 0/255, alpha: 1)
    return container
  }()
  lazy var bufferingIndicator: UIActivityIndicatorView = {
    var activityView = UIActivityIndicatorView(style: .large)
    activityView.color = .lightGray
    activityView.hidesWhenStopped = true
    return activityView
  }()
  @objc var isPlaying: Bool = false {
    didSet {
      self.togglePlayPauseTitle()
    }
  }
  @objc var shouldPlay: Bool = false  {
    didSet (newValue) {
      if newValue {
        playerPause()
      } else {
        playerPause()
      }
     }
  }
  var durationTimer: Timer?
  private lazy var playerControls: PBPlayerControlView = {
    let controlView = PBPlayerControlView()
    controlView.translatesAutoresizingMaskIntoConstraints = false
    return controlView
  }()
  private lazy var replayOverlay: PBReplayOverLay! = {
    let replayOverlay = PBReplayOverLay()
    replayOverlay.translatesAutoresizingMaskIntoConstraints = false
    return replayOverlay
  }()
  public var player: AVPlayer!
  public var playerItem: AVPlayerItem!
  public var playerLayer: AVPlayerLayer!
  public var controller = PBFullScreenPlayer()
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    setupPBPlayer()
  }
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    setupPBPlayer()
  }
  init() {
    super.init(frame: .zero)
    self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    setupPBPlayer()
  }
  convenience init(url: String) {
    self.init()
    //TODO: add url initialization
  }
  @objc
  public func setupPBPlayer() {
    addVideoContainer()
    addPlayerControls()
    setupPlayer()
    playerState = .paused
    addReplayOverLay()
    let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
    self.addGestureRecognizer(tap)
  }
  @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
     playPauseAction()
  }
  private func removeOverlay() {
    UIView.animate(withDuration: 0.4) {
      self.replayOverlay.alpha = 0
    } completion: { _ in
      self.replayOverlay.removeFromSuperview()
    }
  }
  fileprivate func createPlayerLayer() {
    playerLayer = AVPlayerLayer(player: player);
    playerLayer.videoGravity = AVLayerVideoGravity.resize;
    playerLayer.frame =  self.bounds;
    playerControls.isHidden = false
    videoContainerView.layer.addSublayer(playerLayer);
    videoContainerView.playerLayer = playerLayer;
    NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    self.setDurationLabel()
  }
  private func setupPlayer() {
    isPlaying = false
    let videoURL = URL(string: url)
    let asset = AVAsset(url: videoURL!)
    //let keys: [String] = ["playable"]
    self.playerItem = AVPlayerItem(asset: asset)
    self.player = AVPlayer(playerItem: playerItem)
    self.createPlayerLayer()
  }
  private func addPlayerItemObservers() {
    playerItem.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
    playerItem.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
    playerItem.addObserver(self, forKeyPath: "playbackBufferFull", options: .new, context: nil)
  }
  private func resetPlayer() {
    resetPlayerAttributes()
    invalidateDurationTimer()
    resetPlayerForReuse()
  }
  public func resetPlayerAttributes() {
    player?.pause()
    player?.replaceCurrentItem(with: nil)
    playerLayer?.removeFromSuperlayer()
    playerControls.isHidden = true
    playerControls.playerProgress.progress = 0
    replayOverlay?.removeFromSuperview()
    playerLayer = nil
  }
  private func addVideoContainer() {
    self.addSubview(videoContainerView)
    videoContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    videoContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    videoContainerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    videoContainerView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
  }
  private func addPlayerControls() {
    controlViewActionsObservers()
    self.addSubview(playerControls)
    playerControls.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    playerControls.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    playerControls.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    playerControls.heightAnchor.constraint(equalToConstant: 40).isActive = true
  }
  private func addPeriodicTimeObserver() {
    let interval = CMTime(seconds: 0.001,
                          preferredTimescale: CMTimeScale(NSEC_PER_SEC))
    showActivityIndicator()
    timeObserverToken =
      player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) {
        [weak self] time in
        guard let self = self,
              self.player != nil else { return }
        self.hideActivityIndicator()
        self.updatePlayerProgress()
      }
  }
  private func showActivityIndicator() {
    bufferingIndicator.center = self.center
    self.addSubview(bufferingIndicator)
    bufferingIndicator.startAnimating()
  }
  private func hideActivityIndicator() {
    if (bufferingIndicator != nil){
      bufferingIndicator.stopAnimating()
    }
  }
  public func removePeriodicObserver() {
    //player?.removeTimeObserver(timeObserverToken as Any)
    //timeObserverToken = nil
  }
  private func configureDurationTimer() {
    createTimer()
  }
  private func createTimer() {
    invalidateDurationTimer()
    durationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(setDurationLabel), userInfo: nil, repeats: true)
  }
  public func invalidateDurationTimer() {
    durationTimer?.invalidate()
    durationTimer = nil
    setDurationLabel()
  }
  @objc private func setDurationLabel() {
    if let duration = player.currentItem?.asset.duration {
      let totalDuration = CMTimeGetSeconds(duration)
      let currentTime = CMTimeGetSeconds(player.currentTime())
      print("Total Duration: \(Float(totalDuration).clean.time)", "Current: \(Float(currentTime).clean.time)")
      let currentMin = String(format: "%02d", Float(currentTime).clean.time.1)
      let currentSecond = String(format: "%02d", Float(currentTime).clean.time.2)
      let totalMin = String(format: "%02d", Float(totalDuration).clean.time.1)
      let totalSecond = String(format: "%02d", Float(totalDuration).clean.time.2)
      playerControls.timeLabel.text = "\(currentMin):\(currentSecond) / \(totalMin):\(totalSecond)"
    }
  }
  private func updatePlayerProgress() {
    if let duration = player.currentItem?.asset.duration {
      let totalDuration = CMTimeGetSeconds(duration)
      let currentTime = CMTimeGetSeconds(player.currentTime())
      self.playerControls.playerProgress.progress = Float(currentTime/totalDuration)
    }
  }
  private func updatePlayerProgress(with time: Double) {
    if let duration = player.currentItem?.asset.duration {
      let totalDuration = CMTimeGetSeconds(duration)
      self.playerControls.playerProgress.progress = Float(time/totalDuration)
    }
  }
  private func controlViewActionsObservers() {
    playPauseActionObserver()
    rewindObserver()
    forwardObserver()
    fullScreenObserver()
  }
  private func playPauseActionObserver() {
    playerControls.playPauseAction = { [weak self] in
      guard let self = self else { return  }
      self.playPauseAction()
      print("Play Pause")
    }
  }
  @objc public func playPauseAction() {
    self.isPlaying = !self.isPlaying ? true: false
    self.isPlaying ? self.player.play() : self.player.pause()
    if self.isPlaying {
      self.addPeriodicTimeObserver()
    }
    self.isPlaying ? self.createTimer(): self.invalidateDurationTimer()
    self.setDurationLabel()
    self.overLayAction()
  }
  private func togglePlayPauseTitle() {
    isPlaying ?
      self.playerControls.playPause.setImage(UIImage(named: "pause")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal) : self.playerControls.playPause.setImage(UIImage(named: "play")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
    self.playerState = isPlaying ? .playing : .paused
  }
  private func rewindObserver() {
    playerControls.rewindAction = { [weak self] in
      guard let self = self else { return  }
      self.rewindPlayer()
    }
  }
  private func forwardObserver() {
    playerControls.forwardAction = { [weak self] in
      guard let self = self else { return  }
      self.forwardPlayer()
    }
  }
  private func fullScreenObserver() {
    playerControls.fullScreenAction = { [weak self] in
      guard let self = self else { return  }
      self.makePlayerFullScreen()
    }
  }
  private func makePlayerFullScreen() {
    playerPause()
    controller.player = player
    controller.onDismiss = { [weak self] in
      guard let self = self else { return }
      self.playerPause()
      self.updatePlayerProgress()
      self.setDurationLabel()
      self.overLayAction()
      self.onDismiss?()
    }
    controller.onPlay = { [weak self] in
      guard let self = self else { return }
    }
    controller.onPause = { [weak self] in
      guard let self = self else { return }
    }
    controller.modalPresentationStyle = .currentContext
    self.findViewController()?.present(controller, animated: true) {
    }
  }
  private func overLayAction() {
    !self.isPlaying ? self.addReplayOverLay() : self.removeOverlay()
  }
  @objc func avPlayerDidDismiss(_ notification: Notification) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {[weak self] in
      guard let self = self else { return }
      self.isPlaying = false
    }
  }
  private func addReplayOverLay() {
    replayOverlay.state = playerState
    self.addSubview(replayOverlay)
    replayOverlay.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    replayOverlay.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    replayOverlay.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    replayOverlay.bottomAnchor.constraint(equalTo: self.playerControls.topAnchor).isActive = true
    replayOverlay.replayActionTapped = {
      [weak self] in
        guard let self = self else { return }
        self.playPauseAction()
    }
    replayOverlay.alpha = 0
    UIView.animate(withDuration: 0.5) {
      self.replayOverlay.alpha = 1.0
    }
  }
  private func playerPlay() {
    self.isPlaying = true
    self.player.play()
  }
  private func playerPause() {
    self.isPlaying = false
    self.player.pause()
  }
  private func forwardPlayer() {
    guard let duration  = player.currentItem?.duration else{
      return
    }
    let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
    var newTime = playerCurrentTime + seekDuration
    if newTime >= CMTimeGetSeconds(duration) {
      newTime = CMTimeGetSeconds(duration)
    }
    let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
    player.seek(to: time2) { _ in
      self.updatePlayerProgress()
      self.setDurationLabel()
    }
  }
  private func rewindPlayer() {
    let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
    var newTime = playerCurrentTime - seekDuration
    if newTime < 0 {
      newTime = 0
    }
    let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
    player.seek(to: time2) { _ in
      self.updatePlayerProgress()
      self.setDurationLabel()
    }
  }
  @objc private func playerDidFinishPlaying(note: NSNotification) {
    print("Video Finished")
    self.onEnd!(["isPlaying": self.isPlaying])
    isPlaying = false
    self.player.seek(to: CMTime.zero)
    playerState = .finished
    self.addReplayOverLay()
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.invalidateDurationTimer()
    }
  }
  deinit {
    NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
  }
  public func resetPlayerForReuse() {
    NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    self.removePeriodicObserver()
  }
}
