//
//  VirtualController.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

#if os(iOS)
import Foundation
import GameController

class VirtualController {
    private lazy var controller: GCVirtualController = {
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
    
    func connect(to handler: ControlHandler) {
        controller.connect { [weak self] error in
            if error == nil {
                self?.setupHandler(handler)
            }
        }
    }
    
    private func setupHandler(_ handler: ControlHandler) {
        guard let extendedGamepad = controller.controller?.extendedGamepad else {
            return
        }
        extendedGamepad.dpad.valueChangedHandler = { _, xValue, yValue in
            let data = ControlEvent.GamepadDirectionData(xValue: xValue, yValue: yValue)
            handler.handleControlEvent(.gamepadDirection(data))
        }
        
        extendedGamepad.buttonA.valueChangedHandler = { _, _, isPressed in
            let data = ControlEvent.GamepadButtonState(button: .a, isPressed: isPressed)
            handler.handleControlEvent(.gamepadButton(data))
        }
        
        extendedGamepad.buttonB.valueChangedHandler = { _, _, isPressed in
            let data = ControlEvent.GamepadButtonState(button: .b, isPressed: isPressed)
            handler.handleControlEvent(.gamepadButton(data))
        }
        
        extendedGamepad.buttonX.valueChangedHandler = { _, _, isPressed in
            let data = ControlEvent.GamepadButtonState(button: .x, isPressed: isPressed)
            handler.handleControlEvent(.gamepadButton(data))
        }
        
        extendedGamepad.buttonY.valueChangedHandler = { _, _, isPressed in
            let data = ControlEvent.GamepadButtonState(button: .y, isPressed: isPressed)
            handler.handleControlEvent(.gamepadButton(data))
        }
    }
    
    func disconnect() {
        assert(Thread.isMainThread)
        controller.disconnect()
    }
}
#endif
