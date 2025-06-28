import UIKit

protocol TableCellConfig {
    var reuseId: String { get }
    func update(cell: UITableViewCell)
    func height(with size: CGSize) -> CGFloat
}

// MARK: - Internal

extension TableCellConfig {
    static var reuseId: String {
        String(describing: Self.self)
    }
    
    var reuseId: String {
        Self.reuseId
    }
}
