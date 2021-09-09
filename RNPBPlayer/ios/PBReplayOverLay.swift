import UIKit

enum OverlayState: String {
  case playing
  case paused
  case finished
  case none
}
@objc(PBReplayOverLay)
class PBReplayOverLay: UIView {
  var state: OverlayState = .none {
    didSet {
      switch state {
      case .paused:
        replay.setImage(UIImage(named: "play")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
      case .finished:
        replay.setImage(UIImage(named: "replay")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
      default:
        break
      }
    }
  }
  private lazy var replay: UIButton = {
    let button = UIButton()
    button.contentHorizontalAlignment = .fill
    button.contentVerticalAlignment = .fill
    button.imageView?.contentMode = .scaleAspectFit
    button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitleColor(.black, for: .normal)
    return button
  }()
  var replayActionTapped: (() -> Void)?
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupPBPlayerReplayOverLay()
  }
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupPBPlayerReplayOverLay()
  }
  init() {
    super.init(frame: .zero)
    setupPBPlayerReplayOverLay()
  }
  convenience init(state: OverlayState) {
    self.init()
    self.state = state
  }
  private func setupPBPlayerReplayOverLay() {
    configureView()
    addSubViews()
  }
  private func configureView() {
    self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
  }
  private func addSubViews() {
    addReplayButton()
  }
  private func addReplayButton() {
    replay.addTarget(self, action: #selector(replayTapped), for: .touchUpInside)
    self.addSubview(replay)
    replay.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    replay.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    replay.widthAnchor.constraint(equalToConstant: 44).isActive = true
    replay.heightAnchor.constraint(equalToConstant: 44).isActive = true
  }
  @objc private func replayTapped() {
    UIView.animate(withDuration: 0.4) {
      self.alpha = 0
    } completion: { _ in
      self.replayActionTapped?()
      self.removeFromSuperview()
    }
  }
}
