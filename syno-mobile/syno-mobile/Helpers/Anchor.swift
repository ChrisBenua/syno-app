import Foundation
import UIKit

public struct AnchoredConstraints {
    
    public init() { }
    
    public var top, leading, bottom, trailing, vertical, horizontal, width, height: NSLayoutConstraint?
    
    public func activate() {
        [top, leading, bottom, trailing, vertical, horizontal, width, height].forEach({ $0?.isActive = true })
    }
    
    public func deactivate() {
        [top, leading, bottom, trailing, vertical, horizontal, width, height].forEach({ $0?.isActive = false })
    }
}

// ---------------------------------------------------------------------------------------------
// extension to facilitate autolayout usage

public extension UIView {
    
    @discardableResult
    func placeInCenter(offset: CGVector = .zero) -> AnchoredConstraints? {
        guard let superview = superview else {
            assertionFailure("View must be added to superview firstly")
            return nil
        }
        translatesAutoresizingMaskIntoConstraints = false
        var constraints = AnchoredConstraints()

        constraints.vertical = centerYAnchor.constraint(equalTo: superview.centerYAnchor)
        constraints.vertical?.priority = .defaultHigh
        constraints.vertical?.constant = offset.dy

        constraints.horizontal = centerXAnchor.constraint(equalTo: superview.centerXAnchor)
        constraints.horizontal?.priority = .defaultHigh
        constraints.horizontal?.constant = offset.dx

        constraints.top = topAnchor.constraint(greaterThanOrEqualTo: superview.topAnchor)
        constraints.top?.priority = .defaultHigh

        constraints.bottom = bottomAnchor.constraint(lessThanOrEqualTo: superview.bottomAnchor)
        constraints.bottom?.priority = .defaultHigh

        constraints.leading = leadingAnchor.constraint(greaterThanOrEqualTo: superview.leadingAnchor)
        constraints.leading?.priority = .defaultHigh

        constraints.trailing = trailingAnchor.constraint(lessThanOrEqualTo: superview.trailingAnchor)
        constraints.trailing?.priority = .defaultHigh


        constraints.activate()
        
        return constraints
    }

    @discardableResult
    func stickToSuperviewEdges(_ edges: UIRectEdge, insets: UIEdgeInsets = .zero) -> AnchoredConstraints? {
        guard let superview = superview else {
            assertionFailure("View must be added to superview firstly")
            return nil
        }
        translatesAutoresizingMaskIntoConstraints = false
        var constraints = AnchoredConstraints()
        
        if edges.contains(.top) {
            constraints.top = topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top)
        }
        if edges.contains(.bottom) {
            constraints.bottom = bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom)
        }
        if edges.contains(.left) {
            constraints.leading = leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left)
        }
        if edges.contains(.right) {
            constraints.trailing = trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -insets.right)
        }
        constraints.activate()
        
        return constraints
    }
    
    @discardableResult
    func stickToSuperviewSafeEdges(_ edges: UIRectEdge, insets: UIEdgeInsets = .zero) -> AnchoredConstraints? {
        guard let superview = superview else {
            assertionFailure("View must be added to superview firstly")
            return nil
        }
        translatesAutoresizingMaskIntoConstraints = false
        var constraints = AnchoredConstraints()
        
        if edges.contains(.top) {
            constraints.top = topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor, constant: insets.top)
        }
        if edges.contains(.bottom) {
            constraints.bottom = bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -insets.bottom)
        }
        if edges.contains(.left) {
            constraints.leading = leadingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leadingAnchor, constant: insets.left)
        }
        if edges.contains(.right) {
            constraints.trailing = trailingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.trailingAnchor, constant: -insets.right)
        }
        constraints.activate()
        
        return constraints
    }
    
    @discardableResult
    func exactSize(_ size: CGSize) -> AnchoredConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        var constraints = AnchoredConstraints()
        
        if size.width != 0 {
            constraints.width = widthAnchor.constraint(equalToConstant: size.width)
        }
        if size.height != 0 {
            constraints.height = heightAnchor.constraint(equalToConstant: size.height)
        }
    
        constraints.activate()
        
        return constraints
    }

    private func withSuperview(block: (UIView) -> NSLayoutConstraint) -> NSLayoutConstraint {
        guard let superview = superview else {
            fatalError("View must be added to superview firstly")
        }
        translatesAutoresizingMaskIntoConstraints = false
        return block(superview)
    }
    
    @discardableResult
    func centerVertically(_ constant: CGFloat = 0, to view: UIView? = nil) -> NSLayoutConstraint {
        if let view = view {
            translatesAutoresizingMaskIntoConstraints = false
            let vertical = centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant)
            vertical.priority = .defaultHigh
            vertical.isActive = true
            return vertical
        }
        return withSuperview {
            let vertical = centerYAnchor.constraint(equalTo: $0.centerYAnchor, constant: constant)
            vertical.priority = .defaultHigh
            vertical.isActive = true
            return vertical
        }
    }

    @discardableResult
    func centerHorizontally(_ constant: CGFloat = 0, to view: UIView? = nil) -> NSLayoutConstraint {
        if let view = view {
            translatesAutoresizingMaskIntoConstraints = false
            let vertical = centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: constant)
            vertical.priority = .defaultHigh
            vertical.isActive = true
            return vertical
        }
        return withSuperview {
            let vertical = centerXAnchor.constraint(equalTo: $0.centerXAnchor, constant: constant)
            vertical.priority = .defaultHigh
            vertical.isActive = true
            return vertical
        }
    }

    @discardableResult
    func trailing(_ constant: CGFloat = 0, to view: UIView? = nil) -> NSLayoutConstraint {
        if let view = view {
            translatesAutoresizingMaskIntoConstraints = false
            let c = trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: -constant)
            c.isActive = true
            return c
        }
        return withSuperview {
            let c = trailingAnchor.constraint(equalTo: $0.trailingAnchor, constant: -constant)
            c.isActive = true
            return c
        }
    }

    @discardableResult
    func leading(_ constant: CGFloat = 0, to view: UIView? = nil) -> NSLayoutConstraint {
        if let view = view {
            translatesAutoresizingMaskIntoConstraints = false
            let c = leadingAnchor.constraint(equalTo: view.trailingAnchor, constant: constant)
            c.isActive = true
            return c
        }
        return withSuperview {
            let c = leadingAnchor.constraint(equalTo: $0.leadingAnchor, constant: constant)
            c.isActive = true
            return c
        }
    }

    @discardableResult
    func top(_ constant: CGFloat = 0, to view: UIView? = nil) -> NSLayoutConstraint {
        if let view = view {
            translatesAutoresizingMaskIntoConstraints = false
            let c = topAnchor.constraint(equalTo: view.bottomAnchor, constant: constant)
            c.isActive = true
            return c
        }
        return withSuperview {
            let c = topAnchor.constraint(equalTo: $0.topAnchor, constant: constant)
            c.isActive = true
            return c
        }
    }

    @discardableResult
    func bottom(_ constant: CGFloat = 0, to view: UIView? = nil) -> NSLayoutConstraint {
        if let view = view {
            translatesAutoresizingMaskIntoConstraints = false
            let c = bottomAnchor.constraint(equalTo: view.topAnchor, constant: -constant)
            c.isActive = true
            return c
        }
        return withSuperview {
            let c = bottomAnchor.constraint(equalTo: $0.bottomAnchor, constant: -constant)
            c.isActive = true
            return c
        }
    }
    
    @discardableResult
    func safeTop(_ constant: CGFloat = 0, to view: UIView? = nil) -> NSLayoutConstraint {
        if let view = view {
            translatesAutoresizingMaskIntoConstraints = false
            let c = topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: constant)
            c.isActive = true
            return c
        }
        return withSuperview {
            let c = topAnchor.constraint(equalTo: $0.safeAreaLayoutGuide.topAnchor, constant: constant)
            c.isActive = true
            return c
        }
    }

    @discardableResult
    func safeBottom(_ constant: CGFloat = 0, to view: UIView? = nil) -> NSLayoutConstraint {
        if let view = view {
            translatesAutoresizingMaskIntoConstraints = false
            let c = bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -constant)
            c.isActive = true
            return c
        }
        return withSuperview {
            let c = bottomAnchor.constraint(equalTo: $0.safeAreaLayoutGuide.bottomAnchor, constant: -constant)
            c.isActive = true
            return c
        }
    }

    @discardableResult
    func width(_ constant: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = widthAnchor.constraint(equalToConstant: constant)
        constraint.isActive = true
        constraint.priority = UILayoutPriority(999)
        return constraint
    }

    @discardableResult
    func height(_ constant: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = heightAnchor.constraint(equalToConstant: constant)
        constraint.isActive = true
        constraint.priority = UILayoutPriority(999)
        return constraint
    }
    
    @discardableResult
    func width(to view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = widthAnchor.constraint(equalTo: view.widthAnchor, constant: constant)
        constraint.isActive = true
        constraint.priority = UILayoutPriority(999)
        return constraint
    }

    @discardableResult
    func height(to view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = heightAnchor.constraint(equalTo: view.heightAnchor, constant: constant)
        constraint.isActive = true
        constraint.priority = UILayoutPriority(999)
        return constraint
    }
}


extension UIView {
    
    /**
     Anchoring object of UIView to Top Left Bottom Right
     - Parameter top: view's topAnchor to top, Optional
     - Parameter left: view's leftAnchor to left, Optional
     - Parameter bottom: view's bottomAnchor to bottom, Optional
     - Parameter right: view's topAnchor to right, Optional
     - Parameter paddingTop: padding constant from topAnchor
     - Parameter paddingLeft: padding constant from leftAnchor
     - Parameter paddingBottom: padding constant from bottomAnchor
     - Parameter paddingRight: padding constant from rightAnchor
     - Parameter height: if one of Top or Bottom anchors isn't set, you have to set height explicitly
     - Parameter width: if one of Left or Right anchor isn't set, you have to set width explicitly
     */
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?,  paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?,  padding: UIEdgeInsets = .zero, size: CGSize = .zero) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: padding.left).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -padding.right).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
    
}


