import Foundation
import Lexicon

extension Lexicon.Graph {
    // swiftlint:disable force_try
    static var test: Self = try! TaskPaper(
        Data(contentsOf: Bundle.module.url(forResource: "test", withExtension: "lexicon")!)
    ).decode()
}
