//
//  VirtualController.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

#if os(iOS)
import Foundation
import GameController

func makeVirtualController() -> GCVirtualController {
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
            // TODO: handle button taps
//            let data = DirectionData(xValue: xValue, yValue: yValue)
//            userInputController?.handle(.padDirectionChanged(data))
        }
        
        extendedGamepad.buttonA.valueChangedHandler = { _, _, isPressed in
//            let data = GamepadButtonState(button: .a, isPressed: isPressed)
//            userInputController?.handle(.gamepadButton(data))
        }
        
        extendedGamepad.buttonB.valueChangedHandler = { _, _, isPressed in
//            let data = GamepadButtonState(button: .b, isPressed: isPressed)
//            userInputController?.handle(.gamepadButton(data))
        }
        
        extendedGamepad.buttonX.valueChangedHandler = { _, _, isPressed in
//            let data = GamepadButtonState(button: .x, isPressed: isPressed)
//            userInputController?.handle(.gamepadButton(data))
        }
        
        extendedGamepad.buttonY.valueChangedHandler = { _, _, isPressed in
//            let data = GamepadButtonState(button: .y, isPressed: isPressed)
//            userInputController?.handle(.gamepadButton(data))
        }
    }
    return controller
}
#endif
