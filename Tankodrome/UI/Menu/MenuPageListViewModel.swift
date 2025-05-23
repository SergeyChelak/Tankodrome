//
//  MenuPageListViewModel.swift
//  Tankodrome
//
//  Created by Sergey on 23.05.2025.
//

import Foundation

final class MenuPageListViewModel: ObservableObject {
    private let dataSource: MenuPageDataSource
    @Published
    private(set) var selectedIndex: Int?
    
    init(dataSource: MenuPageDataSource) {
        self.dataSource = dataSource
    }
    
    var title: String {
        dataSource.title
    }
    
    var elements: [MenuPageElement] {
        dataSource.elements
    }
    
    func handle(_ element: MenuPageElement) {
        dataSource.handle(action: element.action)
    }
    
    func onHover(_ index: Int, isHovered: Bool) {
        if isHovered {
            selectedIndex = index
        }
    }
    
    func isSelected(_ index: Int) -> Bool {
        index == self.selectedIndex
    }
}
