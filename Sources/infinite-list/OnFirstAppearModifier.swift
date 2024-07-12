import SwiftUI

extension View {
  func onFirstAppear(_ action: @escaping () -> ()) -> some View {
    modifier(OnFirstAppearModifier(action: action))
  }
}

private struct OnFirstAppearModifier: ViewModifier {
  let action: () -> ()

  // Use this to only fire your block one time
  @State private var hasAppeared = false

  func body(content: Content) -> some View {
    // And then, track it here
    content.onAppear {
      guard !hasAppeared else { return }

      hasAppeared = true

      action()
    }
  }
}
