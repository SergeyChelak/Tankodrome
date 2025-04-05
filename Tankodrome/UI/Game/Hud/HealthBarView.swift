//
//  HealthBarView.swift
//  Tankodrome
//
//  Generated by ChatGPT on 05.04.2025.
//

import SwiftUI

struct HealthBarView: View {
    let value: CGFloat // [0...1]

    private let barHeight: CGFloat = 20.0
    private let barWidth: CGFloat = 200.0
    
    private let cornerRadius: CGFloat = 6.0
    
    private let lowThreshold: CGFloat = 0.33
    private let midThreshold: CGFloat = 0.66

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Transparent background with border
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)

                    // Only render visible part based on current zone
                    barGradient(width: geometry.size.width)
                        .frame(width: geometry.size.width * value)
                        .mask(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .frame(width: geometry.size.width * value)
                        )
                        .opacity(0.7)
                }
            }
            .frame(height: barHeight)
            
            Text("\(Int(value * 100))%")
                .font(.headline)
                .foregroundColor(.white)
                .shadow(color: .black, radius: 2)
        }
        .frame(width: barWidth)
    }

    @ViewBuilder
    private func barGradient(width: CGFloat) -> some View {
        if value <= lowThreshold {
            LinearGradient(
                gradient: Gradient(colors: [.black, .red]),
                startPoint: .leading,
                endPoint: .trailing
            )
        } else if value <= midThreshold {
            // Gradient from red to yellow (up to current health)
            LinearGradient(
                gradient: Gradient(colors: [.red, .yellow]),
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            // Gradient from red -> yellow -> green (up to current health)
            let redStop = lowThreshold / value
            let yellowStop = midThreshold / value
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: .red, location: 0.0),
                    .init(color: .yellow, location: redStop),
                    .init(color: .green, location: yellowStop)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
}


#Preview("Low") {
    HealthBarView(value: 0.2)
}

#Preview("Mid") {
    HealthBarView(value: 0.5)
}

#Preview("High") {
    HealthBarView(value: 0.9)
}
