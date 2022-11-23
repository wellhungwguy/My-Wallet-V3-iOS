// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Foundation
import Localization
import SwiftUI
import UIComponentsKit

public struct CountryPickerView: View {

    private typealias LocalizedStrings = LocalizationConstants.Authentication.CountryAndStatePickers

    static let restrictedCountryIdentifiers: Set<String> = ["CU", "IR", "KP", "SY"]

    public static let countries: [SearchableItem<String>] = Locale.isoRegionCodes
        .filter { !restrictedCountryIdentifiers.contains($0) }
        .compactMap { code -> SearchableItem? in
            guard let countryName = Locale.current.localizedString(forRegionCode: code) else {
                return nil
            }
            return SearchableItem(
                id: code,
                title: countryName
            )
        }
        .sorted {
            $0.title.localizedCompare($1.title) == .orderedAscending
        }

    @Binding private var selectedItem: SearchableItem<String>?
    @Binding private var items: [SearchableItem<String>]

    private var sections: [SearchableItemPicker<String>.SearchableSection] {
        var sections: [SearchableItemPicker<String>.SearchableSection] = []

        if let currentRegionCode = Locale.current.regionCode,
           let country = items.first(where: { $0.id == currentRegionCode })
        {
            sections.append(
                .init(
                    title: LocalizedStrings.suggestedSelectionTitle,
                    items: [SearchableItem(id: currentRegionCode, title: country.title)]
                )
            )
        }

        sections.append(
            .init(
                title: LocalizedStrings.countriesSectionTitle,
                items: items
            )
        )

        return sections
    }

    public init(
        selectedItem: Binding<SearchableItem<String>?>,
        items: Binding<[SearchableItem<String>]> = .constant(CountryPickerView.countries)
    ) {
        _selectedItem = selectedItem
        _items = items
    }

    public var body: some View {
        SearchableItemPicker(
            sections: sections,
            selectedItem: $selectedItem,
            cancelButtonTitle: LocalizationConstants.searchCancelButtonTitle,
            searchPlaceholder: LocalizationConstants.searchPlaceholder
        )
    }
}
