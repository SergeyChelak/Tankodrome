//
//  MenuPageListViewModel.swift
//  Tankodrome
//
//  Created by Sergey on 23.05.2025.
//

import Combine
import Foundation

final class MenuPageListViewModel: ObservableObject {
    private let dataSource: MenuPageDataSource
    private let inputController: InputController
    private let settings: AppSettings
    private var cancellables: Set<AnyCancellable> = []
    @Published
    private(set) var selectedIndex: Int = 0
    
    init(
        inputController: InputController,
        dataSource: MenuPageDataSource,
        settings: AppSettings
    ) {
        self.inputController = inputController
        self.dataSource = dataSource
        self.settings = settings
        
        setupObservables()
    }
    
    var title: String {
        dataSource.title
    }
    
    var elements: [MenuPageElement] {
        dataSource.elements
    }
    
    func handle(_ index: Int) {
        dataSource.handle(action: elements[index].action)
    }
    
    func onHover(_ index: Int, isHovered: Bool) {
        if isHovered {
            selectedIndex = index
        }
    }
    
    func isSelected(_ index: Int) -> Bool {
        index == self.selectedIndex
    }
    
    func handleInputEvent(_ event: ControlEvent) {
        guard let menuEvent = reduce(event) else {
            return
        }
        let count = dataSource.elements.count
        switch menuEvent {
        case .up:
            selectedIndex = (selectedIndex + count - 1) % count
        case .down:
            selectedIndex = (selectedIndex + 1) % count
        case .select:
            handle(selectedIndex)
        }
        if case(.empty) = elements[selectedIndex].action {
            handleInputEvent(event)
        }
    }
    
    private func setupObservables() {
#if os(iOS)
        inputController.setVirtualControllerNeeded(false)
#endif
        inputController.publisher
            .sink { [weak self] in self?.handleInputEvent($0) }
            .store(in: &cancellables)
        
        settings.publisher
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
}

fileprivate enum MenuInput {
    case up, down, select
}

fileprivate func reduce(_ event: ControlEvent) -> MenuInput? {
    switch event {
    case .key(let keyData):
        return reduce(keyData)
    case .gamepadDirection(let data):
        return reduce(data)
    case .gamepadButton(let state) where state.isPressed:
        return state.button == .b ? .select : nil
    default:
        return nil
    }
}

fileprivate func reduce(_ data: ControlEvent.KeyData) -> MenuInput? {
    if data.isPressed(.upArrow) || data.isPressed(.keyW) {
        return .up
    }
    if data.isPressed(.downArrow) || data.isPressed(.keyS) {
        return .down
    }
    if data.isPressed(.spacebar) {
        return .select
    }
    return nil
}

fileprivate func reduce(_ data: ControlEvent.GamepadDirectionData) -> MenuInput? {
    if data.yValue > 0.9 {
        return .up
    }
    
    if data.yValue < -0.9 {
        return .down
    }
    return nil
}
