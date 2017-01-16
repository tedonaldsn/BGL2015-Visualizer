//
//  StrengthText.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 10/9/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import BASimulationFoundation

// StrengthText
//
// Note: Does not use string convenience methods to draw text. Rather, uses
//      the underlying NSTextStorage, NSLayoutManager, and NSTextContainer
//      classes directly, as recommended by Apple for text that is frequently
//      re-drawn.
//
open class StrengthText: CustomStringConvertible, CustomDebugStringConvertible {

    open static let defaultFontName = "Helvetica"
    open static let defaultFontSize: CGFloat = 9.0
    open static let defaultFont = NSFont(name: defaultFontName, size: defaultFontSize)!
    
    open static let defaultSuperscriptFontSize: CGFloat = defaultFontSize * 0.75
    open static let defaultSuperscriptFont = NSFont(name: defaultFontName, size: defaultSuperscriptFontSize)!
    open static let defaultSuperscriptBaselineOffset = NSNumber(value: Double(defaultFontSize) * 0.75 as Double)
    
    open static let defaultSubscriptFontSize: CGFloat = defaultFontSize * 0.75
    open static let defaultSubscriptFont = NSFont(name: defaultFontName, size: defaultSubscriptFontSize)!
    open static let defaultSubscriptBaselineOffset = NSNumber(value: Double(defaultFontSize) * -0.33 as Double)
    
    open static let defaultForegroundColorAtWeakest: CGColor = NSColor.gray.cgColor
    open static let defaultForegroundColorAtStrongest: CGColor = NSColor.black.cgColor
    
    
    
    // MARK: Data
    
    open var length: Int { return priv_textStorage.length }
    open var isEmpty: Bool { return priv_textStorage.length == 0 }
    
    open var text: NSAttributedString { return NSAttributedString(attributedString: priv_textStorage)}
    open var asString: String { return priv_textStorage.string }
    
    open var foregroundColor =
        StrengthColor(colorAtWeakest: StrengthText.defaultForegroundColorAtWeakest,
                      colorAtStrongest: StrengthText.defaultForegroundColorAtStrongest)
    
    // CustomStringConvertible
    open var description: String {
        return asString
    }
    
    // CustomDebugStringConvertible
    open var debugDescription: String {
        return asString
    }
    
    // MARK: Initialization
    
    public init(attributedString: NSAttributedString? = nil) {
        
        priv_textStorage = NSTextStorage()
        priv_layoutManager = NSLayoutManager()
        
        priv_textContainer = NSTextContainer()
        priv_textContainer.lineFragmentPadding = 0.0
        
        priv_layoutManager.addTextContainer(priv_textContainer)
        priv_textStorage.addLayoutManager(priv_layoutManager)
        
        if let attributedString = attributedString {
            priv_textStorage.append(attributedString)
        }
    }
    
    
    
    public convenience init(string: String,
                            font: NSFont? = StrengthText.defaultFont) {
        let initialText =
            NSAttributedString(string: string, attributes: [NSFontAttributeName: font!])
        self.init(attributedString: initialText)
    }
    
    // Return isMutable copy
    //
    public convenience init(strengthTextToCopy: StrengthText) {
        self.init(attributedString: strengthTextToCopy.priv_textStorage)
        self.foregroundColor = strengthTextToCopy.foregroundColor
    }
    
    
    // MARK: Build
    
    
    open func appendString(_ string: String) -> StrengthText {
        return appendText(NSAttributedString(string: string))
    }
    open func appendText(_ text: NSAttributedString) -> StrengthText {
        priv_textStorage.append(text)
        return self
    }
    
    
    open func appendSuperscript(_ string: String) -> StrengthText {
        return appendSuperscript(NSAttributedString(string: string))
    }
    open func appendSuperscript(_ text: NSAttributedString) -> StrengthText {
        let location = priv_textStorage.length
        let length = text.length
        
        if length > 0 {
            let _ = appendText(text)
            let range = NSMakeRange(location, length)
            priv_textStorage.addAttribute(NSFontAttributeName,
                                   value: StrengthText.defaultSuperscriptFont,
                                   range: range)
            priv_textStorage.addAttribute(NSBaselineOffsetAttributeName,
                                   value: StrengthText.defaultSuperscriptBaselineOffset,
                                   range: range)
        }
        return self

    } // end appendSuperscript
    
    
    open func appendSubscript(_ string: String) -> StrengthText {
        return appendSubscript(NSAttributedString(string: string))
    }
    open func appendSubscript(_ text: NSAttributedString) -> StrengthText {
        let location = priv_textStorage.length
        let length = text.length
        
        if length > 0 {
            let _ = appendText(text)
            let range = NSMakeRange(location, length)
            priv_textStorage.addAttribute(NSFontAttributeName,
                                   value: StrengthText.defaultSubscriptFont,
                                   range: range)
            priv_textStorage.addAttribute(NSBaselineOffsetAttributeName,
                                   value: StrengthText.defaultSubscriptBaselineOffset,
                                   range: range)
        }
        return self
        
    } // end appendSubscript
    
    
    

    
    // MARK: Sizing
    
    
    open var glyphSize: CGSize {
        return priv_layoutManager.usedRect(for: priv_textContainer).size
    }
    open var glyphRange: NSRange {
        return priv_layoutManager.glyphRange(for: priv_textContainer)
    }
    
    
    
    open func scale(_ scalingFactor: CGFloat) -> Void {
        guard scalingFactor != 1.0 else { return }
        priv_textStorage.scaleFonts(scalingFactor)
    }
    
    
    // MARK: Draw
    

    open func setAttributes(atStrength: CGFloat) -> Void {
        
        let attributeRange = NSRange(location: 0, length: priv_textStorage.length)
        
        priv_textStorage.removeAttribute(NSForegroundColorAttributeName,
                                         range: attributeRange)
        
        let color = foregroundColor.color(atStrength)
        
        priv_textStorage.addAttribute(NSForegroundColorAttributeName,
                                      value: NSColor(cgColor: color)!,
                                      range: attributeRange)
    }
    
    open func draw(inRect: CGRect, atStrength: CGFloat) -> Void {
        
        setAttributes(atStrength: atStrength)
        
        let range: NSRange = glyphRange
        let size: CGSize = glyphSize
        
        let glyphOrigin: CGPoint =
            CGPoint(
                x: inRect.origin.x
                    + ((inRect.size.width - size.width) / 2.0),
                
                y: inRect.origin.y
                    + ((inRect.size.height - size.height) / 2.0)
        )
        
        // According to Apple's documentation for NSLayoutManager drawGlyphs,
        // "This method expects the coordinate system of the view to be flipped."
        // Same is true of the neural net layout classes, so all is good.
        //
        // If you try to use the drawGlyphs in an unflipped NSView, the
        // positioning will be high by about half the glyphSize.
        //
        priv_layoutManager.drawGlyphs(forGlyphRange: range, at: glyphOrigin)
        
    } // end draw
    
    
    
    // MARK: Copying

    public convenience init(strengthText: StrengthText) {
        self.init(attributedString: strengthText.priv_textStorage)
        self.foregroundColor = strengthText.foregroundColor
    }

    open func clone() -> StrengthText {
        return StrengthText(strengthText: self)
    }
    
    
    // MARK: *Private*
    
    // Use NSTextStorage instead of NSMutableAttributedString to allow us
    // to use NSLayoutManager for more efficient drawing of text.
    //
    fileprivate var priv_textStorage: NSTextStorage
    fileprivate var priv_layoutManager: NSLayoutManager
    fileprivate var priv_textContainer: NSTextContainer
    
} // end class StrengthText

