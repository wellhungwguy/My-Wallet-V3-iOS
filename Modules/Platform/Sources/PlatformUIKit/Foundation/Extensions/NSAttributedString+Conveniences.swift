// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import ToolKit

extension NSMutableAttributedString {

    /// Makes the whole range hyperrlink
    public func makeHyperlink(to urlString: String) {
        guard let url = URL(string: urlString) else {
            Logger.shared.error("could not create URL from string: \(urlString)")
            return
        }
        let range = NSRange(location: 0, length: (string as NSString).length)
        addAttribute(NSAttributedString.Key.link, value: url, range: range)
    }

    /// Adds a given line spacing
    public func add(lineSpacing: CGFloat) {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpacing
        let range = NSRange(location: 0, length: (string as NSString).length)
        addAttribute(.paragraphStyle, value: style, range: range)
    }

    /// Adds a given alignment
    public func add(alignment: NSTextAlignment) {
        let style = NSMutableParagraphStyle()
        style.alignment = alignment
        let range = NSRange(location: 0, length: (string as NSString).length)
        addAttribute(.paragraphStyle, value: style, range: range)
    }
}

extension NSAttributedString {

    public static func lineBreak() -> NSAttributedString {
        NSAttributedString(string: "\n")
    }

    public static func space() -> NSAttributedString {
        NSAttributedString(string: " ")
    }

    public convenience init(_ labelContent: LabelContent) {
        self.init(
            labelContent.text,
            font: labelContent.font,
            color: labelContent.color
        )
    }

    public convenience init(_ text: String, font: UIFont, color: UIColor) {
        self.init(string: text, attributes: [.font: font, .foregroundColor: color])
    }

    public static func + (leading: NSAttributedString, trailing: NSAttributedString) -> NSAttributedString {
        let attributedString = NSMutableAttributedString()
        attributedString.append(leading)
        attributedString.append(trailing)
        return attributedString
    }

    public var height: CGFloat {
        heightForWidth(width: CGFloat.greatestFiniteMagnitude)
    }

    public var width: CGFloat {
        let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let rect = boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        return ceil(rect.size.width)
    }

    public func boundingRectForWidth(_ width: CGFloat) -> CGRect {
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        return boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesDeviceMetrics], context: .none)
    }

    public func fontAttribute() -> UIFont? {
        guard length > 0 else { return nil }
        guard let font = attribute(.font, at: 0, effectiveRange: nil) as? UIFont else { return nil }
        return font
    }

    public func heightForWidth(width: CGFloat) -> CGFloat {
        let size = CGSize(width: width, height: width == CGFloat.greatestFiniteMagnitude ? 0 : CGFloat.greatestFiniteMagnitude)
        let rect = boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        return ceil(rect.size.height)
    }

    public func withFont(_ font: UIFont) -> NSAttributedString {
        if fontAttribute() == .none {
            let copy = NSMutableAttributedString(attributedString: self)
            copy.addAttribute(.font, value: font, range: NSRange(location: 0, length: copy.length))
            return copy
        }
        return copy() as! NSAttributedString
    }

    public func asBulletPoint() -> NSAttributedString {
        let bullet = NSMutableAttributedString(
            string: "\u{2022} ",
            attributes: [
                .font: fontAttribute() ?? UIFont.systemFont(ofSize: 17.0)
            ]
        )
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = bullet.width
        let copy = NSMutableAttributedString(attributedString: self)
        bullet.append(copy)
        bullet.addAttributes(
            [
                .paragraphStyle: paragraphStyle,
                .font: fontAttribute() ?? UIFont.systemFont(ofSize: 17.0)
            ],
            range: NSRange(location: 0, length: bullet.length)
        )
        return bullet
    }
}

extension NSMutableAttributedString {

    /// Sets the foreground color of the substring `text` to the provided `color`
    /// if `text` is within this attributed string's range.
    ///
    /// - Parameters:
    ///   - color: the foreground color to set
    ///   - text: the text to set a foreground color to
    public func addForegroundColor(_ color: UIColor, to text: String) {
        guard let range = string.range(of: text) else {
            Logger.shared.info("Cannot add color to attributed string. Text is not in range.")
            return
        }
        addAttribute(
            NSAttributedString.Key.foregroundColor,
            value: color,
            range: NSRange(range, in: string)
        )
    }
}

extension Sequence where Element: NSAttributedString {

    public func join(withSeparator separator: NSAttributedString? = nil) -> NSAttributedString {
        let result = NSMutableAttributedString()
        for (index, string) in enumerated() {
            if index > 0 {
                if let separator {
                    result.append(separator)
                }
            }
            result.append(string)
        }
        return result
    }
}
