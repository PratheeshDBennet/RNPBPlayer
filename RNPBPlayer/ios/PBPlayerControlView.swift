import UIKit
extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}
@objc(PBPlayerControlView)
class PBPlayerControlView: UIView {
  private lazy var controlContainer: UIVisualEffectView =  {
    let effect = UIBlurEffect(style: .dark)
    let view = UIVisualEffectView(effect: effect)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .clear
    return view
  }()
  lazy var bufferingIndicator: UIActivityIndicatorView = {
    var activityView = UIActivityIndicatorView(style: .medium)
    activityView.color = .lightGray
    activityView.hidesWhenStopped = true
    return activityView
  }()
  private lazy var hStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .horizontal
    stackView.distribution = .fill
    stackView.spacing = 10
    return stackView
  }()
  lazy var playerProgress: UIProgressView = {
    let progressView = UIProgressView(progressViewStyle: .default)
    progressView.translatesAutoresizingMaskIntoConstraints = false
    progressView.progressTintColor = .red
    progressView.trackTintColor = .lightGray
    progressView.progress = 0
    return progressView
  }()
  lazy var playPause: UIButton = {
    let button = UIButton()
    button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Play", for: .normal)
    //button.setImage(UIImage(named: "play")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
    button.imageView?.contentMode = .scaleAspectFit
    button.imageEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
    button.setTitleColor(.white, for: .normal)
    return button
  }()
  private lazy var fullScreen: UIButton = {
    let button = UIButton()
    button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Full", for: .normal)
    //button.setImage(UIImage(named: "fullscreen")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
    button.imageView?.contentMode = .scaleAspectFit
    button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    button.setTitleColor(.white, for: .normal)
    return button
  }()
  lazy var timeLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 14)
    label.text = "Test"
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .white
    return label
  }()
  lazy var forward: UIButton = {
    let button = UIButton()
    button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle(">>", for: .normal)
    //button.setImage(UIImage(named: "forward")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
    button.imageView?.contentMode = .scaleAspectFit
    button.imageEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
    button.setTitleColor(.white, for: .normal)
    return button
  }()
  lazy var rewind: UIButton = {
    let button = UIButton()
    button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("<<", for: .normal)
    //button.setImage(UIImage(named: "rewind")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
    button.imageView?.contentMode = .scaleAspectFit
    button.imageEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
    button.setTitleColor(.white, for: .normal)
    return button
  }()
  var playPauseAction:(() -> Void)?
  var fullScreenAction:(() -> Void)?
  var rewindAction:(() -> Void)?
  var forwardAction:(() -> Void)?
  required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
    setupPBPlayerControls()
  }
  override init(frame: CGRect) {
      super.init(frame: frame)
    setupPBPlayerControls()
  }
  init() {
    super.init(frame: .zero)
    setupPBPlayerControls()
  }
  private func setupPBPlayerControls() {
    addSubViews()
  }
  private func addSubViews() {
    addControlContainer()
    addHStackView()
    addPlayPause()
    //addBufferingIndicator()
    addTime()
    addRewind()
    addForward()
    addFullScreen()
    addPlayerProgress()
  }
  private func addControlContainer() {
    self.addSubview(controlContainer)
    controlContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    controlContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    controlContainer.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    controlContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
  }
  private func addHStackView() {
    controlContainer.contentView.addSubview(hStackView)
    hStackView.leadingAnchor.constraint(equalTo: controlContainer.leadingAnchor).isActive = true
    hStackView.trailingAnchor.constraint(equalTo: controlContainer.trailingAnchor).isActive = true
    hStackView.topAnchor.constraint(equalTo: controlContainer.topAnchor).isActive = true
    hStackView.bottomAnchor.constraint(equalTo: controlContainer.bottomAnchor).isActive = true
  }
  private func addPlayPause() {
    playPause.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
    playPause.widthAnchor.constraint(equalToConstant: 40).isActive = true
    hStackView.addArrangedSubview(playPause)
  }
  private func addBufferingIndicator() {
    //self.addSubview(timeLabel)
    bufferingIndicator.widthAnchor.constraint(equalToConstant: 10).isActive = true
    
    bufferingIndicator.heightAnchor.constraint(equalToConstant: 10).isActive = true
    hStackView.addArrangedSubview(bufferingIndicator)
  }
  private func addTime() {
    //self.addSubview(timeLabel)
    timeLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
    hStackView.addArrangedSubview(timeLabel)
  }
  private func addRewind() {
    rewind.addTarget(self, action: #selector(rewindTapped), for: .touchUpInside)
    rewind.widthAnchor.constraint(equalToConstant: 40).isActive = true
    hStackView.addArrangedSubview(rewind)
  }
  private func addForward() {
    forward.addTarget(self, action: #selector(forwardTapped), for: .touchUpInside)
    forward.widthAnchor.constraint(equalToConstant: 40).isActive = true
    hStackView.addArrangedSubview(forward)
  }
  private func addFullScreen() {
    fullScreen.addTarget(self, action: #selector(fullScreenTapped), for: .touchUpInside)
    fullScreen.widthAnchor.constraint(equalToConstant: 40).isActive = true
    hStackView.addArrangedSubview(fullScreen)
  }
  private func addPlayerProgress() {
    controlContainer.contentView.addSubview(playerProgress)
    playerProgress.leadingAnchor.constraint(equalTo: self.controlContainer.leadingAnchor, constant: .zero).isActive = true
    playerProgress.trailingAnchor.constraint(equalTo: self.controlContainer.trailingAnchor).isActive = true
    playerProgress.topAnchor.constraint(equalTo: self.controlContainer.topAnchor).isActive = true
    playerProgress.heightAnchor.constraint(equalToConstant: 2.5).isActive = true
  }
  @objc private func playPauseTapped(){
      self.playPauseAction?()
  }
  @objc private func fullScreenTapped(){
      self.fullScreenAction?()
  }
  @objc private func rewindTapped(){
      self.rewindAction?()
  }
  @objc private func forwardTapped(){
      self.forwardAction?()
  }
}
