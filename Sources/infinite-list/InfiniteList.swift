import SwiftUI

public struct InfiniteList<Item, Content>: View where Item: Identifiable & Hashable & Sendable, Content: View {
  @Binding var name: String
  var columnsCount: Int
  @ObservedObject var dataSource: DataSource<Item>
  var axes: Axis.Set
  var itemContent: (Item) -> Content

  public init(name: Binding<String>, columnsCount: Int = 1, @ObservedObject dataSource: DataSource<Item>,
              axes: Axis.Set = [.horizontal, .vertical], itemContent: @escaping (Item) -> Content) {
    self._name = name
    self.columnsCount = columnsCount
    self.dataSource = dataSource
    self.axes = axes
    self.itemContent = itemContent
  }

  public var body: some View {
    listItems()
      .navigationTitle(name)
  }

  private func listItems() -> some View {
    VStack {
      ScrollView {
        ZStack {
          Spacer().containerRelativeFrame(axes)

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
      }
        .scrollBounceBehavior(.basedOnSize)
    }
      .overlay(loadingOverlay)
  }

  @ViewBuilder private var loadingOverlay: some View {
    if dataSource.isLoadingPage {
      ZStack {
        Spacer().containerRelativeFrame(axes)

        ProgressView()
          .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
          .scaleEffect(1.5, anchor: .center)
      }
    }
  }
}
