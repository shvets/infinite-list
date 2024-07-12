import SwiftUI

public extension View {
  func loadDataSource<Item: Identifiable & Hashable>(_ dataSource: DataSource<Item>) -> some View {
    modifier(LoadDataSourceModifier(dataSource: dataSource))
  }
}

private struct LoadDataSourceModifier<Item: Identifiable & Hashable>: ViewModifier {
  var dataSource: DataSource<Item>

  func body(content: Content) -> some View {
    content.onFirstAppear {
      dataSource.loadFirst()
    }
  }
}
