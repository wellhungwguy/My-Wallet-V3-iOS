// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

/// This cell represents a single instruction in `InstructionTableView`
final class InstructionTableViewCell: UITableViewCell {

    // MARK: - IBOutlets

    @IBOutlet private var indexLabel: UILabel!
    @IBOutlet private var instructionTextView: InteractableTextView!

    // MARK: - Injected

    var viewModel: InstructionCellViewModel! {
        didSet {
            guard let viewModel else { return }
            indexLabel.content = viewModel.numberViewModel
            instructionTextView.viewModel = viewModel.textViewModel
            instructionTextView.setupHeight()
        }
    }

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
    }
}
