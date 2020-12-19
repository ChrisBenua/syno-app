import Foundation
import UIKit

struct SnowmanUI {
    var bottomPart: UIImageView
    var midPart: UIImageView
    var headPart: UIImageView
    
    var handLeft: UIImageView
    var handRight: UIImageView
}

class CongratulationsController: UIViewController {
    private var model: ICongratulationsControllerModel
    private var topAnchor: NSLayoutConstraint!
    private var centerAnchor: NSLayoutConstraint!
    
    private var textViewsAnchors: [(top: NSLayoutConstraint, center: NSLayoutConstraint, topConstant: CGFloat, centerConstant: CGFloat)] = []
    
    private var snowman: SnowmanUI!
    
    lazy var textViews: [UIView] = {
        let views = self.model.getCongratulations().messages.map({ (gratz) -> UIView in
            let tv = UILabel()
            let translationX = CGFloat.random(in: 0..<UIScreen.main.bounds.width)
            tv.text = gratz.message
            tv.font = .systemFont(ofSize: CGFloat(gratz.fontSize))
            tv.textAlignment = .center
            tv.translatesAutoresizingMaskIntoConstraints = false
            tv.transform = .init(scaleX: 0.1, y: 0.1)
            
            return tv
        })
        
        for i in 0..<views.count {
            self.view.addSubview(views[i])
            
            var topConstraint: NSLayoutConstraint!
            var centerConstraint: NSLayoutConstraint!
            if i == 0 {
                topConstraint = views[i].topAnchor.constraint(equalTo: self.titleView.bottomAnchor, constant: UIScreen.main.bounds.height)
            } else {
                topConstraint = views[i].topAnchor.constraint(equalTo: views[i - 1].bottomAnchor, constant: UIScreen.main.bounds.height)
            }
            centerConstraint = views[i].centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: CGFloat.random(in: -2*UIScreen.main.bounds.width..<2*UIScreen.main.bounds.width))
            
            topConstraint.isActive = true
            centerConstraint.isActive = true
            
            textViewsAnchors.append((top: topConstraint, center: centerConstraint, topConstant: i == 0 ? 20 : 12, centerConstant: 0))
        }
        
        
        return views
    }()
    
    lazy var finalMessage: UIView = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28)
        label.text = "Счастливого\nНового Года!"
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var stackView: UIStackView = {
        let view = UIView()
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        let stackView = UIStackView(arrangedSubviews:  [view])
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        
        return stackView
    }()
    
    lazy var titleView: UIView = {
        let label = UILabel()
        label.text = "Дорогая Полечка!"
        label.font = .systemFont(ofSize: 32)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var gradientLayer: CAGradientLayer = {
       let gradient = CAGradientLayer()
        gradient.colors = [#colorLiteral(red: 0.846976757, green: 0.8471218944, blue: 0.9751560092, alpha: 1).cgColor, #colorLiteral(red: 0.8816462481, green: 0.8816462481, blue: 0.9089136578, alpha: 1).cgColor]
        gradient.locations = [0.0, 1.0]
        
        return gradient
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gradientLayer.frame = self.view.bounds
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.846976757, green: 0.8471218944, blue: 0.9751560092, alpha: 1)
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.barTintColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white//#colorLiteral(red: 0.846976757, green: 0.8471218944, blue: 0.9751560092, alpha: 1)
        self.navigationController?.navigationBar.isTranslucent = true
        
        //self.view.addSubview(stackView)
        //stackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, padding: .init(top: 80, left: 0, bottom: 0, right: 0))
        //self.textViews.forEach({ self.view.addSubview($0) })
        
        self.view.addSubview(titleView)
        textViews.forEach({ Logger.log("\($0.alpha)") })
        //titleView.frame.origin = CGPoint(x: view.bounds.width, y: 0)
        //titleView.frame = CGRect(x: view.bounds.width, y: 0, width: view.bounds.width, height: 40)
        //titleView.transform = .init(scaleX: 0.7, y: 0.7)
        
        topAnchor = titleView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: -70)
        centerAnchor = titleView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: view.bounds.width / 2)
        
        topAnchor.isActive = true
        centerAnchor.isActive = true
        
        self.navigationItem.title = "Для Полечки"
    }
    
    private func pointOnEllipse(angle: Int, view_: UIView) -> CGPoint {
        let a = 30.0; let b = 10.0
        let radian = Double(angle) * Double.pi / 180
        return CGPoint(x: a * cos(radian) + Double(view_.layer.frame.origin.x + view_.layer.bounds.width / 2 - 30), y: b * sin(radian) + Double(view_.layer.frame.origin.y + view_.layer.bounds.height / 2))
    }
    
    func startCircleMovingAnimation(view_: UIView) {
        let path = UIBezierPath()
          // 2
        let initialPoint = self.pointOnEllipse(angle: 0, view_: view_)
        path.move(to: initialPoint)
        
        for angle in (1...360) {
            path.addLine(to: pointOnEllipse(angle: angle, view_: view_))
        }
        
        path.close()
        
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.path = path.cgPath
        animation.repeatCount = 100
        animation.duration = 4

        view_.layer.add(animation, forKey: "animation")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.startInitialAnimations()
    }
    
    private func recursiveAnimation(index: Int) {
        let anch = self.textViewsAnchors[index]
        anch.top.constant = anch.topConstant
        anch.center.constant = anch.centerConstant
        
        UIView.animate(withDuration: 1.5, delay: TimeInterval(self.model.getCongratulations().messages[index].additionalDelayAfterAnimation), usingSpringWithDamping: 1.5, initialSpringVelocity: 3, options: .curveEaseOut) {
            self.textViews[index].transform = .identity
            self.view.layoutIfNeeded()
        } completion: { (completed) in
            if completed {
                if index + 1 < self.textViewsAnchors.count {
                    self.recursiveAnimation(index: index + 1)
                } else {
                    self.onRemoveWords()
                }
            }
        }
    }
    
    func onRemoveWords() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            if let slf = self {
                slf.recursiveAnimationOut(index: slf.textViewsAnchors.count - 1)
            }
        }
    }
    
    private func recursiveAnimationOut(index: Int) {
        UIView.animate(withDuration: 1, delay: TimeInterval(0), animations: { [weak self] in
            if let self = self {
                let rotation = index % 2 == 0 ? CGFloat.pi / 2 : -CGFloat.pi / 2
                let translationX = index % 2 == 0 ? UIScreen.main.bounds.width : -UIScreen.main.bounds.width
                self.textViews[index].transform = CGAffineTransform(translationX: translationX, y: 0).rotated(by: rotation)
            }
        }) { [weak self] (completed) in
            if completed {
                self?.textViews[index].alpha = 0
                if index > 0 {
                    self?.recursiveAnimationOut(index: index - 1)
                } else {
                    self?.buildSnowMan()
                }
            }
        }
    }
    
    func buildSnowMan() {
        let bottomPart = UIImageView(image: #imageLiteral(resourceName: "snowman_bottom")); bottomPart.translatesAutoresizingMaskIntoConstraints = false
        let midPart = UIImageView(image: #imageLiteral(resourceName: "snowman_mid")); midPart.translatesAutoresizingMaskIntoConstraints = false
        let headPart = UIImageView(image: #imageLiteral(resourceName: "snowman_top")); headPart.translatesAutoresizingMaskIntoConstraints = false
        
        let handRight = UIImageView(image: #imageLiteral(resourceName: "hand_right")); handRight.translatesAutoresizingMaskIntoConstraints = false
        let handLeft = UIImageView(image: #imageLiteral(resourceName: "hand_left")); handLeft.translatesAutoresizingMaskIntoConstraints = false
        
        self.snowman = SnowmanUI(bottomPart: bottomPart, midPart: midPart, headPart: headPart, handLeft: handLeft, handRight: handRight)
        
        self.buildSnowmanBottomPart()
    }
    
    private func buildSnowmanBottomPart() {
        let bottomPart = snowman.bottomPart
        
        bottomPart.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width / 2 + 90, y: 0).rotated(by: CGFloat.pi * 2 / 3)
        self.view.addSubview(bottomPart)
        bottomPart.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        bottomPart.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80).isActive = true
        UIView.animate(withDuration: 3.0, delay: 1.0) {
            bottomPart.transform = .identity
        } completion: { (completed) in
            self.buildSnowmanMidPart()
        }
    }
    
    private func buildSnowmanMidPart() {
        let midPart = snowman.midPart

        midPart.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width / 2, y: 0).rotated(by: CGFloat.pi - 0.1)
        self.view.addSubview(midPart)
        midPart.centerXAnchor.constraint(equalTo: snowman.bottomPart.centerXAnchor, constant: 90 + 65).isActive = true
        midPart.bottomAnchor.constraint(equalTo: snowman.bottomPart.bottomAnchor, constant: 5).isActive = true
        
        UIView.animate(withDuration: 2.5, delay: 0.5, animations: {
            midPart.transform = .identity
        }) { (completed) in
            let finalPoint = CGPoint(x: self.view.frame.width / 2, y: self.snowman.bottomPart.frame.origin.y - midPart.frame.height / 2 + 5)
            let controlPoint = CGPoint(x: self.view.frame.width / 2 + 90 + 30, y: self.snowman.bottomPart.frame.origin.y - 40)
            let firstPoint = CGPoint(x: midPart.layer.frame.origin.x + midPart.layer.frame.width / 2, y: midPart.layer.frame.origin.y + midPart.layer.frame.height / 2)
            
            let path = UIBezierPath()
            path.move(to: firstPoint)
            path.addQuadCurve(to: finalPoint, controlPoint: controlPoint)
            
            CATransaction.begin()
            
            CATransaction.setCompletionBlock {
                self.buildSnowmanHeadPart()
            }
            
            let animation = CAKeyframeAnimation(keyPath: "position")
            animation.duration = 2
            animation.path = path.cgPath
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false
            
            midPart.layer.add(animation, forKey: "animation")
            
            CATransaction.commit()
        }
    }
    
    private func buildSnowmanHeadPart() {
        let headPart = snowman.headPart

        headPart.transform = CGAffineTransform(translationX: self.view.frame.width / 2, y: 0).rotated(by: CGFloat.pi - 0.1)
        self.view.addSubview(headPart)
        headPart.centerXAnchor.constraint(equalTo: snowman.bottomPart.centerXAnchor, constant: 90 + 50).isActive = true
        headPart.bottomAnchor.constraint(equalTo: snowman.bottomPart.bottomAnchor, constant: 5).isActive = true
        
        UIView.animate(withDuration: 2.5, delay: 0.5, animations: {
            headPart.transform = .identity
        }) { (completed) in
            let finalPoint = CGPoint(x: self.view.frame.width / 2, y: self.snowman.bottomPart.frame.origin.y - self.snowman.midPart.frame.height - headPart.frame.height / 2 + 10)
            let controlPoint = CGPoint(x: self.view.frame.width / 2 + 90 + 20, y: self.snowman.bottomPart.frame.origin.y - self.snowman.midPart.frame.height * 2/3 - 40)
            let firstPoint = CGPoint(x: headPart.layer.frame.origin.x + 50, y: headPart.layer.frame.origin.y + headPart.layer.frame.height / 2)
            
            let path = UIBezierPath()
            path.move(to: firstPoint)
            path.addQuadCurve(to: finalPoint, controlPoint: controlPoint)
            
            CATransaction.begin()
            
            CATransaction.setCompletionBlock {
                self.buildSnowmanHandRight()
            }
            
            let animation = CAKeyframeAnimation(keyPath: "position")
            animation.duration = 2
            animation.path = path.cgPath
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false
            
            headPart.layer.add(animation, forKey: "animation")
            
            CATransaction.commit()
        }
    }
    
    private func buildSnowmanHandRight() {
        let hand = self.snowman.handRight
        hand.transform = CGAffineTransform.identity.translatedBy(x: UIScreen.main.bounds.width / 2, y: 0)
        self.view.addSubview(hand)
        hand.leftAnchor.constraint(equalTo: self.snowman.bottomPart.rightAnchor, constant: -28).isActive = true
        hand.bottomAnchor.constraint(equalTo: self.snowman.bottomPart.centerYAnchor, constant: -155).isActive = true
        
        UIView.animate(withDuration: 2.0, delay: 0.5, animations: {
            hand.transform = .identity
        }) { (_) in
            self.buildSnowmanHandLeft()
        }
    }
    
    private func buildSnowmanHandLeft() {
        let hand = self.snowman.handLeft
        hand.transform = CGAffineTransform.identity.translatedBy(x: -UIScreen.main.bounds.width / 2, y: 0)
        self.view.addSubview(hand)
        hand.rightAnchor.constraint(equalTo: self.snowman.bottomPart.leftAnchor, constant: 30).isActive = true
        hand.bottomAnchor.constraint(equalTo: self.snowman.bottomPart.centerYAnchor, constant: -135).isActive = true
        
        UIView.animate(withDuration: 2.0, delay: 0.5, animations: {
            hand.transform = .identity
        }) { (completed) in
            self.finalMessage.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width * 3 / 2, y: 200)
            self.view.addSubview(self.finalMessage)
            self.finalMessage.topAnchor.constraint(equalTo: self.titleView.bottomAnchor, constant: 30).isActive = true
            self.finalMessage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            
            self.view.layoutIfNeeded()
            
            UIView.animate(withDuration: 1.2) {
                self.finalMessage.transform = .identity
            }
        }
    }
    
    func startInitialAnimations() {
        self.snowfall()
                
        topAnchor.constant = 20
        centerAnchor.constant = 30
        
        UIView.animate(withDuration: 1.5, delay: 0.8) {
            self.view.layoutIfNeeded()
        } completion: { (_) in
            self.recursiveAnimation(index: 0)
            self.startCircleMovingAnimation(view_: self.titleView)
            //self.buildSnowMan()
        }
    }
    
    func snowfall() {
        let flakeEmitterCell = CAEmitterCell()
        flakeEmitterCell.contents = UIImage(named: "snowflake")?.cgImage
        flakeEmitterCell.scale = 0.012
        flakeEmitterCell.scaleRange = 0.004
        flakeEmitterCell.emissionRange = .pi / 3 * 2
        flakeEmitterCell.lifetime = 20.0
        flakeEmitterCell.birthRate = 25
        flakeEmitterCell.velocity = -15
        flakeEmitterCell.velocityRange = -6
        flakeEmitterCell.yAcceleration = 20
        flakeEmitterCell.xAcceleration = 0
        flakeEmitterCell.spin = -0.5
        flakeEmitterCell.spinRange = 0.6
        
        let snowEmitterLayer = CAEmitterLayer()
        snowEmitterLayer.emitterPosition = CGPoint(x: view.bounds.width / 2.0, y: -50)
        snowEmitterLayer.emitterSize = CGSize(width: view.bounds.width, height: 0)
        snowEmitterLayer.emitterShape = CAEmitterLayerEmitterShape.line
        snowEmitterLayer.beginTime = CACurrentMediaTime()
        snowEmitterLayer.timeOffset = 2
        snowEmitterLayer.emitterCells = [flakeEmitterCell]
        view.layer.insertSublayer(snowEmitterLayer, above: gradientLayer)
    }
    
    init(model: ICongratulationsControllerModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
