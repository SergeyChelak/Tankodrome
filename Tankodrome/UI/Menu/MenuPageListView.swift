//
//  MenuPageListView.swift
//  Tankodrome
//
//  Created by Sergey on 05.04.2025.
//

import SwiftUI

struct MenuPageListView: View {
    let dataSource: MenuPageDataSource
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(dataSource.title)
                .font(.system(size: 17))
            Divider()
                .frame(maxWidth: 300)
            VStack(alignment: .leading, spacing: 8) {
                ForEach(dataSource.elements.indices, id: \.self) { index in
                    let element = dataSource.elements[index]
                    MenuButtonView(title: element.name) {
                        dataSource.handle(action: element.action)
                    }
                }
            }
        }
    }
}
#Preview {
    MenuPageListView(
        dataSource: LandingPageDataSource() { _ in }
    )
}
