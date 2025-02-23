//
//  VirtualController.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

#if os(iOS)
import Foundation
import GameController

func makeVirtualController(_ handler: ControlHandler?) -> GCVirtualController {
    let configuration = GCVirtualController.Configuration()
    configuration.elements = [
        GCInputDirectionPad,
        //            GCInputButtonX,
        //            GCInputButtonY,
        //            GCInputButtonA,
        GCInputButtonB
    ]
    let controller = GCVirtualController(configuration: configuration)
    if let extendedGamepad = controller.controller?.extendedGamepad {
        extendedGamepad.dpad.valueChangedHandler = { _, xValue, yValue in
            let data = ControlEvent.GamepadDirectionData(xValue: xValue, yValue: yValue)
            handler?.handle(.gamepadDirection(data))
        }
        
        extendedGamepad.buttonA.valueChangedHandler = { _, _, isPressed in
            let data = ControlEvent.GamepadButtonState(button: .a, isPressed: isPressed)
            handler?.handle(.gamepadButton(data))
        }
        
        extendedGamepad.buttonB.valueChangedHandler = { _, _, isPressed in
            let data = ControlEvent.GamepadButtonState(button: .b, isPressed: isPressed)
            handler?.handle(.gamepadButton(data))
        }
        
        extendedGamepad.buttonX.valueChangedHandler = { _, _, isPressed in
            let data = ControlEvent.GamepadButtonState(button: .x, isPressed: isPressed)
            handler?.handle(.gamepadButton(data))
        }
        
        extendedGamepad.buttonY.valueChangedHandler = { _, _, isPressed in
            let data = ControlEvent.GamepadButtonState(button: .y, isPressed: isPressed)
            handler?.handle(.gamepadButton(data))
        }
    }
    return controller
}
#endif
