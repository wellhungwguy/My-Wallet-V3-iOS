import PlatformUIKit
import RxCocoa
import RxSwift

final class RadioSelectionHandler: RadioSelectionHandling {

    let selectionAction = PublishRelay<RadioSelectionAction>()

    let selectionState: Observable<[AnyHashable: Bool]>

    init() {
        self.selectionState = selectionAction
            .distinctUntilChanged()
            .scan(into: [String: Bool](), accumulator: { state, action in
                switch action {
                case .initialValues(let values):
                    state = Dictionary(uniqueKeysWithValues: values.map { ($0, false) })
                case .select(let id):
                    for key in state.keys where id != key {
                        state[key] = false
                    }
                    state[id] = true
                case .deselect(let id):
                    state[id] = false
                case .deselectAll:
                    for key in state.keys {
                        state[key] = false
                    }
                }
            })
            .share(replay: 1, scope: .whileConnected)
    }
}
