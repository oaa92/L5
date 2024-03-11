import SwiftUI

struct ContentView: View {
    let colors = [Color.white, .pink, .yellow, .black]
    let squareSize = CGSize(width: 100, height: 100)

    @State private var frames: [Color: CGRect] = [:]

    @GestureState private var startLocation: CGPoint? = nil
    @State private var squareLocation: CGPoint = CGPoint(x: 100, y: 200)

    @State private var intersections: [Color: CGRect] = [:]

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                ForEach(colors, id: \.self) { color in
                    GeometryReader { proxy in
                        color
                            .onAppear {
                                frames[color] = proxy.frame(in: .global)
                            }
                    }
                }
            }
            squareView
        }
        .ignoresSafeArea()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                calculateIntersections()
            }
        }
    }

    private var squareView: some View {
        VStack(spacing: 0) {
            ForEach(colors, id: \.self) { color in
                if let intersection = intersections[color], !intersection.isEmpty {
                    Rectangle()
                        .foregroundStyle(color == .white || color == .yellow ? Color.black : Color.white)
                        .frame(width: intersection.width, height: intersection.height)
                }
            }
        }
        .cornerRadius(20)
        .position(squareLocation)
        .gesture(simpleDrag)
    }

    private var simpleDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                var newLocation = startLocation ?? squareLocation
                newLocation.x += value.translation.width
                newLocation.y += value.translation.height
                self.squareLocation = newLocation
                self.calculateIntersections()
            }
            .updating($startLocation) { (value, startLocation, _) in
                startLocation = startLocation ?? squareLocation
            }
    }

    private func calculateIntersections() {
        let squareFrame = CGRect(
            origin: CGPoint(
                x: squareLocation.x - squareSize.width / 2,
                y: squareLocation.y - squareSize.height / 2
            ),
            size: squareSize
        )
        for (color, frame) in frames {
            intersections[color] = frame.intersection(squareFrame)
        }
    }
}

#Preview {
    ContentView()
}

