import SwiftUI

public struct InfiniteListStyleModifier: ViewModifier {
  public init() {}

  public func body(content: Content) -> some View {
#if os(iOS)
    content.listStyle(.inset)
      .navigationBarTitleDisplayMode(.inline)
#else
    content
#endif
  }
}