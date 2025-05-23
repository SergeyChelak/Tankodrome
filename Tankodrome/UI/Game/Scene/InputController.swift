//
//  InputController.swift
//  Tankodrome
//
//  Created by Sergey on 10.05.2025.
//

import Combine
import Foundation
import GameController

final class InputController {
    private var cancellables: Set<AnyCancellable> = []
#if os(iOS)
    private let virtualController: GCVirtualController = {
        let configuration = GCVirtualController.Configuration()
        configuration.elements = [
            GCInputDirectionPad,
            //            GCInputButtonX,
            //            GCInputButtonY,
            //            GCInputButtonA,
            GCInputButtonB
        ]
        return GCVirtualController(configuration: configuration)
    }()
    private var isVirtualControllerNeeded = false
#endif
    private let eventEmitter = PassthroughSubject<ControlEvent, Never>()
    var publisher: AnyPublisher<ControlEvent, Never> {
        eventEmitter.eraseToAnyPublisher()
    }
    
    init() {
        let center = NotificationCenter.default
        center.publisher(for: .GCControllerDidBecomeCurrent)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                self?.handleControllerDidConnect(notification)
            }
            .store(in: &cancellables)

        center.publisher(for: .GCControllerDidStopBeingCurrent)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                self?.handleControllerDidDisconnect(notification)
            }
            .store(in: &cancellables)
        
        center.publisher(for: .GCKeyboardDidConnect)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                self?.handleKeyboardDidDisconnect(notification)
            }
            .store(in: &cancellables)
    }
    
    private func handleControllerDidConnect(_ notification: Notification) {
        guard let gameController = notification.object as? GCController else {
            return
        }
#if os(iOS)
        if gameController != virtualController.controller {
            disconnectVirtualController()
        }
#endif
        registerController(gameController)
    }

    private func handleControllerDidDisconnect(_ notification: Notification) {
        guard let _ = notification.object as? GCController else {
            return
        }
#if os(iOS)
        if GCController.controllers().isEmpty {
            connectVirtualController()
        }
#endif
    }
    
    private func handleKeyboardDidDisconnect(_ notification: Notification) {
        guard let keyboard = notification.object as? GCKeyboard,
              let keyboardInput = keyboard.keyboardInput else {
            return
        }
        let keys: [GCKeyCode] = [
            .escape,
            .spacebar,
            .leftArrow,
            .rightArrow,
            .upArrow,
            .downArrow,
            .keyW,
            .keyA,
            .keyS,
            .keyD
        ]
        keys.forEach { [weak self] keyCode in
            keyboardInput.button(forKeyCode: keyCode)?.valueChangedHandler = {
                (_ button: GCDeviceButtonInput, _ value: Float, _ pressed: Bool) -> Void in
                let data = ControlEvent.KeyData(isPressed: pressed, keyCode: keyCode)
                self?.eventEmitter.send(.key(data))
            }
        }
    }

#if os(iOS)
    private func connectVirtualController() {
        guard isVirtualControllerNeeded else {
            return
        }
        virtualController.connect() { [weak self] error in
            if error != nil {
                // TODO: handle error
                return
            }
            guard let self,
                  let controller = self.virtualController.controller else {
                return
            }
            self.registerController(controller)
        }
    }
    
    private func disconnectVirtualController() {
        virtualController.disconnect()
    }
#endif
    
    private func registerController(_ controller: GCController) {
        guard let extendedGamepad = controller.extendedGamepad else {
            return
        }
        
        extendedGamepad.buttonMenu.pressedChangedHandler = { [weak self] _, _, isPressed in
            let data = ControlEvent.GamepadButtonState(button: .menu, isPressed: isPressed)
            self?.eventEmitter.send(.gamepadButton(data))
        }
            
        extendedGamepad.dpad.valueChangedHandler = { [weak self] _, xValue, yValue in
            let data = ControlEvent.GamepadDirectionData(xValue: xValue, yValue: yValue)
            self?.eventEmitter.send(.gamepadDirection(data))
        }
        
        extendedGamepad.buttonA.valueChangedHandler = { [weak self] _, _, isPressed in
            let data = ControlEvent.GamepadButtonState(button: .a, isPressed: isPressed)
            self?.eventEmitter.send(.gamepadButton(data))
        }
        
        extendedGamepad.buttonB.valueChangedHandler = { [weak self] _, _, isPressed in
            let data = ControlEvent.GamepadButtonState(button: .b, isPressed: isPressed)
            self?.eventEmitter.send(.gamepadButton(data))
        }
        
        extendedGamepad.buttonX.valueChangedHandler = { [weak self] _, _, isPressed in
            let data = ControlEvent.GamepadButtonState(button: .x, isPressed: isPressed)
            self?.eventEmitter.send(.gamepadButton(data))
        }
        
        extendedGamepad.buttonY.valueChangedHandler = { [weak self] _, _, isPressed in
            let data = ControlEvent.GamepadButtonState(button: .y, isPressed: isPressed)
            self?.eventEmitter.send(.gamepadButton(data))
        }
    }

#if os(iOS)
    func setVirtualControllerNeeded(_ isNeeded: Bool) {
        isVirtualControllerNeeded = isNeeded
        guard isNeeded else {
            disconnectVirtualController()
            return
        }
        
        if nil == GCController.controllers().first {
            connectVirtualController()
        }
    }
#endif
    
    func setupController() -> Bool {
        guard let controller = GCController.controllers().first else {
            return false
        }
        registerController(controller)
        return true
    }
}
