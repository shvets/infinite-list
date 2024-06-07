import SwiftUI

public struct InfiniteList<Item, Content>: View where Item: Identifiable & Hashable, Content: View {
  var name: String
  var columnsCount: Int
  var dataSource: DataSource<Item>
  var itemContent: (Item) -> Content

  public init(name: String, columnsCount: Int = 1, dataSource: DataSource<Item>, itemContent: @escaping (Item) -> Content) {
    self.name = name
    self.columnsCount = columnsCount
    self.dataSource = dataSource
    self.itemContent = itemContent
  }

  public var body: some View {
    listItems()
      .navigationTitle(name)
  }

  private func listItems() -> some View {
      ScrollView {
        LazyVGrid(columns: Array(repeating: .init(), count: columnsCount)) {
          ForEach(dataSource.items) { item in
            itemContent(item)
              .onAppear {
                dataSource.loadNext(item)
              }
          }
        }
          .padding(.horizontal)
          .refreshable {
            dataSource.loadFirst()
          }
      }
        .overlay {
          if dataSource.isLoadingPage {
            VStack {
              ProgressView()
                .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
                .scaleEffect(1.5, anchor: .center)
            }
          }
    }
  }
}
