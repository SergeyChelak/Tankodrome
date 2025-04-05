//
//  AppViewFactory.swift
//  Tankodrome
//
//  Created by Sergey on 03.04.2025.
//

import SwiftUI

protocol AppViewFactory {
    func loadingView() -> ViewHolder
    
    func errorView(_ error: Error) -> ViewHolder
    
    func rootView(_ context: AppContext) -> ViewHolder
}
