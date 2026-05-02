//
//  FilterSortView.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Bottom sheet for selecting sort order and category filters.
//

import SwiftUI

struct FilterSortView: View {
    let categories: [String]
    @Binding var selectedCategory: String?
    @Binding var sortOption: SortOption
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(Strings.sortBySection) {
                    ForEach(SortOption.allCases) { option in
                        selectableRow(option.displayName, isSelected: sortOption == option) {
                            sortOption = option
                        }
                    }
                }

                Section(Strings.categorySection) {
                    selectableRow(Strings.allCategories, isSelected: selectedCategory == nil) {
                        selectedCategory = nil
                    }

                    ForEach(categories, id: \.self) { category in
                        selectableRow(category.capitalized, isSelected: selectedCategory == category) {
                            selectedCategory = category
                        }
                    }
                }

                Section {
                    Button(Strings.resetFilters) {
                        selectedCategory = nil
                        sortOption = .none
                    }
                    .foregroundStyle(AppColors.destructive)
                }
            }
            .navigationTitle(Strings.filterSortTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(Strings.done) { dismiss() }
                }
            }
        }
    }

    private func selectableRow(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        HStack {
            Text(title)
            Spacer()
            if isSelected {
                Image(systemName: Strings.Icons.checkmark)
                    .foregroundStyle(AppColors.accent)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
    }
}
