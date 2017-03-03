//
//  TabmanBar.swift
//  Tabman
//
//  Created by Merrick Sapsford on 17/02/2017.
//  Copyright © 2017 Merrick Sapsford. All rights reserved.
//

import UIKit
import PureLayout
import Pageboy

public protocol TabmanBarDataSource {
    
    /// The items to display in the tab bar.
    ///
    /// - Parameter tabBar: The tab bar.
    /// - Returns: Items to display in the tab bar.
    func items(forTabBar tabBar: TabmanBar) -> [TabmanBarItem]?
}

public protocol TabmanBarDelegate {
    
    /// The tab bar did select a tab at an index.
    ///
    /// - Parameters:
    ///   - tabBar: The tab bar.
    ///   - index: The selected index.
    func tabBar(_ tabBar: TabmanBar, didSelectTabAtIndex index: Int)
}

public protocol TabmanBarLifecycle: TabmanAppearanceUpdateable {
    
    /// Construct the contents of the tab bar for the current style and given items.
    ///
    /// - Parameter items: The items to display.
    func constructTabBar(items: [TabmanBarItem])
    
    /// Update the tab bar for a positional update.
    ///
    /// - Parameters:
    ///   - position: The new position.
    ///   - direction: The direction of travel.
    ///   - minimumIndex: The minimum possible index.
    ///   - maximumIndex: The maximum possible index.
    func update(forPosition position: CGFloat,
                direction: PageboyViewController.NavigationDirection,
                minimumIndex: Int,
                maximumIndex: Int)
}

open class TabmanBar: UIView, TabmanBarLifecycle {
    
    //
    // MARK: Types
    //
    
    internal typealias Appearance = TabmanBar.AppearanceConfig
    
    //
    // MARK: Properties
    //
    
    // Private
    
    internal var items: [TabmanBarItem]?
    internal var containerView = UIView(forAutoLayout: ())
    internal private(set) var currentPosition: CGFloat = 0.0
    internal var fadeGradientLayer: CAGradientLayer?
    
    internal var indicatorLeftMargin: NSLayoutConstraint?
    internal var indicatorWidth: NSLayoutConstraint?
    internal var indicatorIsProgressive: Bool = TabmanBar.AppearanceConfig.defaultAppearance.indicator.isProgressive ?? false
    internal var indicatorBounces: Bool = TabmanBar.AppearanceConfig.defaultAppearance.indicator.bounces ?? false
    
    // Public
    
    /// The object that acts as a data source to the bar.
    public var dataSource: TabmanBarDataSource? {
        didSet {
            self.reloadData()
        }
    }
    
    /// The object that acts as a delegate to the bar.
    public var delegate: TabmanBarDelegate?
    
    /// Appearance configuration for the bar.
    public var appearance: AppearanceConfig = .defaultAppearance {
        didSet {
            self.update(forAppearance: appearance)
        }
    }
    
    /// Background view of the bar.
    public private(set) var backgroundView: TabmanBarBackgroundView = TabmanBarBackgroundView(forAutoLayout: ())
    
    /// Indicator for the bar.
    public var indicator: TabmanIndicator?
    
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: 0.0, height: 44.0)
    }
    
    //
    // MARK: Init
    //
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initTabBar()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initTabBar()
    }
    
    private func initTabBar() {
        self.addSubview(backgroundView)
        backgroundView.autoPinEdgesToSuperviewEdges()
        
        self.addSubview(containerView)
        containerView.autoPinEdgesToSuperviewEdges()
        
        if let indicatorType = self.indicatorStyle().rawType {
            self.indicator = indicatorType.init()
        }
    }
    
    //
    // MARK: Lifecycle
    //
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.fadeGradientLayer?.frame = self.bounds
    }
    
    open func indicatorStyle() -> TabmanIndicator.Style {
        print("indicatorStyle() returning default. This should be overridden in subclass")
        return .none
    }
    
    //
    // MARK: Data
    //
    
    /// Reload and reconstruct the contents of the bar.
    public func reloadData() {
        self.items = self.dataSource?.items(forTabBar: self)
        self.clearAndConstructBar()
    }
    
    /// Reconstruct the bar for a new style or data set.
    private func clearAndConstructBar() {
        self.clearBar()

        guard let items = self.items else { return } // no items yet
        
        self.constructTabBar(items: items)
        self.update(forAppearance: self.appearance)
    }
    
    //
    // MARK: TabBar content
    //
    
    /// Remove all components and subviews from the bar.
    internal func clearBar() {
        self.containerView.removeAllSubviews()
    }
    
    internal func updatePosition(_ position: CGFloat,
                                 direction: PageboyViewController.NavigationDirection) {
        guard let items = self.items else {
            return
        }
        
        self.layoutIfNeeded()
        self.currentPosition = position
        self.update(forPosition: position,
                    direction: direction,
                    minimumIndex: 0, maximumIndex: items.count - 1)
    }
    
    //
    // MARK: TabmanBarLifecycle
    //
    
    open func constructTabBar(items: [TabmanBarItem]) {
        // Override in subclass
    }
    
    open func update(forPosition position: CGFloat,
                         direction: PageboyViewController.NavigationDirection,
                         minimumIndex: Int,
                         maximumIndex: Int) {
        // Override in subclass
    }
    
    open func update(forAppearance appearance: AppearanceConfig) {
        
        if let backgroundStyle = appearance.backgroundStyle {
            self.backgroundView.backgroundStyle = backgroundStyle
        }
        
        if let indicatorIsProgressive = appearance.indicator.isProgressive {
            self.indicatorIsProgressive = indicatorIsProgressive
        }
        
        if let indicatorBounces = appearance.indicator.bounces {
            self.indicatorBounces = indicatorBounces
        }
        
        self.updateEdgeFade(visible: appearance.showEdgeFade ?? false)
    }
}

// MARK: - Bar appearance configuration
internal extension TabmanBar {
    
    func updateEdgeFade(visible: Bool) {
        if visible {
            
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = self.bounds
            gradientLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            gradientLayer.locations = [0.02, 0.05, 0.95, 0.98]
            self.containerView.layer.mask = gradientLayer
            self.fadeGradientLayer = gradientLayer
            
        } else {
            self.containerView.layer.mask = nil
            self.fadeGradientLayer = nil
        }
    }
}

internal extension TabmanIndicator.Style {
    
    var rawType: TabmanIndicator.Type? {
        switch self {
        case .line:
            return TabmanLineIndicator.self
        case .custom(let type):
            return type
        default:
            return nil
        }
    }
}
