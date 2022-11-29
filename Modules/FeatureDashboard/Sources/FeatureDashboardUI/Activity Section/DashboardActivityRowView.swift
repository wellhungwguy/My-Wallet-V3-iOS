// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import Foundation
import SwiftUI
import UnifiedActivityDomain
import UnifiedActivityUI

public struct DashboardActivityRowView: View {
    let store: StoreOf<DashboardActivityRow>

    public init(store: StoreOf<DashboardActivityRow>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ActivityRow(activityEntry: viewStore.activity)
            if viewStore.isLastRow == false {
                Divider()
                    .foregroundColor(.WalletSemantic.light)
            }
        }
    }
}
