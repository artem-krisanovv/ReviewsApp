import UIKit

extension NSAttributedString {
    func boundingRect(width: CGFloat, height: CGFloat = .greatestFiniteMagnitude) -> CGRect {
        boundingRect(
            with: CGSize(width: width, height: height),
            options: .usesLineFragmentOrigin,
            context: nil
        )
    }
    
    func isEmpty(trimmingCharactersIn set: CharacterSet = .whitespacesAndNewlines) -> Bool {
        string.trimmingCharacters(in: set).isEmpty
    }
    
    func font(at location: Int = .zero) -> UIFont? {
        attributes(at: location, effectiveRange: nil)[.font] as? UIFont
    }
}
