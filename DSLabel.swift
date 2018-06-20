//
//  DSLabel.swift
//  sedal
//
//  Created by David Soler on 19/6/18.
//  Copyright © 2018 Bemobile. All rights reserved.
//

import UIKit

class DSLabel: UILabel {

    override public var text: String? {
        didSet {
            layoutIfNeeded()
            configure()
        }
    }
    var linkFont: UIFont? {
        set (value) {
            _linkFont = value
            configure()
        }
        get { return _linkFont }
    }
    var linkColor: UIColor? {
        set (value) {
            _linkColor = value
            configure()
        }
        get { return _linkColor }
    }
    var linkBgColor: UIColor? {
        set (value) {
            _linkBgColor = value
            configure()
        }
        get { return _linkBgColor }
    }
    var lineSpacing: CGFloat {
        set (value) {
            _lineSpacing = value
            configure()
        }
        get { return _lineSpacing }
    }

    private var _linkFont: UIFont?
    private var _linkColor: UIColor?
    private var _linkBgColor: UIColor?
    private var _lineSpacing: CGFloat = 0
    private var links: [String] = []
    private var positions: [Int] = []
    private var completion: ((String, NSRange) -> Void)?

    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - Private

    private func setup() {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
    }
    
    private func configure() {
        let text = (self.text)!
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        let attrString = NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.font : self.font, NSAttributedStringKey.foregroundColor : self.textColor, NSAttributedStringKey.backgroundColor : self.backgroundColor ?? UIColor.clear, NSAttributedStringKey.paragraphStyle : paragraphStyle])

        for i in 0..<links.count {
            let position = positions[i]
            let ranges = self.ranges(of: links[i], from: text)
            for j in 0..<ranges.count {
                if position == -1 || position == j {
                    if let linkFont = linkFont {
                        attrString.addAttribute(.font, value: linkFont, range: NSRange(ranges[j], in: text))
                    }
                    if let linkColor = linkColor {
                        attrString.addAttribute(.foregroundColor, value: linkColor, range: NSRange(ranges[j], in: text))
                    }
                    if let linkBgColor = linkBgColor {
                        attrString.addAttribute(.backgroundColor, value: linkBgColor, range: NSRange(ranges[j], in: text))
                    }
                }
            }
        }
        self.attributedText = attrString
    }
    
    private func indices(of occurrence: String, from string: String) -> [Int] {
        var indices = [Int]()
        var position = string.startIndex
        while let range = string.range(of: occurrence, range: position..<string.endIndex) {
            let i = string.distance(from: string.startIndex,
                                    to: range.lowerBound)
            indices.append(i)
            let offset = occurrence.distance(from: occurrence.startIndex,
                                             to: occurrence.endIndex) - 1
            guard let after = string.index(range.lowerBound,
                                           offsetBy: offset,
                                           limitedBy: string.endIndex) else {
                                            break
            }
            position = string.index(after: after)
        }
        return indices
    }
    
    private func ranges(of searchString: String, from string: String) -> [Range<String.Index>] {
        let _indices = indices(of: searchString, from: string)
        let count = searchString.count
        return _indices.map({ string.index(string.startIndex, offsetBy: $0)..<string.index(string.startIndex, offsetBy: $0+count) })
    }

    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        let text = (self.text)!
        for i in 0..<links.count {
            let position = positions[i]
            let ranges = self.ranges(of: links[i], from: text)
            for j in 0..<ranges.count {
                if position == -1 || position == j {
                    if isTappedInRange(NSRange(ranges[j], in: text), gesture: sender) {
                        if let completion = self.completion {
                            completion(links[i], NSRange(ranges[j], in: text))
                        }
                    }
                }
            }
        }
    }

    private func isTappedInRange(_ range: NSRange, gesture: UITapGestureRecognizer) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: self.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = self.lineBreakMode
        textContainer.maximumNumberOfLines = self.numberOfLines
        let labelSize = self.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = gesture.location(in: self)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, range)
    }

    // MARK: - Public
    
    public func addLink(text: String, which: Int = -1) {
        links.append(text)
        positions.append(which)
        configure()
    }
    
    public func handleLink(completion: @escaping (String, NSRange) -> Void) {
        self.completion = completion
    }
}
