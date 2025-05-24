//
//  MenuPageListView.swift
//  Tankodrome
//
//  Created by Sergey on 05.04.2025.
//

import SwiftUI

struct MenuPageListView: View {
    @Environment(\.themeProvider) var themeProvider
    @ObservedObject
    var viewModel: MenuPageListViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(viewModel.title)
                .font(.system(size: 19))
                .foregroundStyle(themeProvider.menuSectionTitle)
                .italic()
            Divider()
                .frame(height: 2.0)
                .frame(maxWidth: 300)
                .background(themeProvider.menuDivider)
            VStack(alignment: .leading, spacing: 8) {
                ForEach(viewModel.elements.indices, id: \.self) { index in
                    let element = viewModel.elements[index]
                    MenuButtonView(title: element.name) {
                        viewModel.handle(index)
                    }
                    .onHover { isHovering in
                        viewModel.onHover(index, isHovered: isHovering)
                    }
                    .shadow(
                        color: themeProvider.commonShadow,
                        radius: viewModel.isSelected(index) ? 12.0 : 1.0
                    )
                }
            }
        }
        
    }
}
#Preview {
    let vm = MenuPageListViewModel(
        inputController: InputController(),
        dataSource: LandingPageDataSource() { _ in },
        settings: composeAppSettings()
    )
    return MenuPageListView(
        viewModel: vm
    )
}
