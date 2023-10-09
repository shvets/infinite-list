import SwiftUI
//import Introspect

//class InfiniteListModel: ObservableObject {
//  @Published public var search: String = ""
//}

public struct InfiniteList<Item, Content>: View where Item: Identifiable & Hashable, Content: View {
  //@StateObject var viewModel = InfiniteListModel()

  var name: String
  var columnsCount: Int
  var dataSource: DataSource<Item>
  var content: (Item) -> Content

  public init(name: String, columnsCount: Int = 1, dataSource: DataSource<Item>,
              content: @escaping (Item) -> Content) {
    self.name = name
    self.columnsCount = columnsCount
    self.dataSource = dataSource
    self.content = content
  }

  public var body: some View {
    listItems()
      .navigationTitle(name)
      .modifier(InfiniteListStyleModifier())
  }

  private func listItems() -> some View {
    GeometryReader { geometry in
      ScrollView {
        LazyVGrid(columns: Array(repeating: .init(), count: columnsCount)) {
          ForEach(dataSource.items) { item in
            content(item)
              //.frame(maxWidth: .infinity, alignment: .leading)
              .onAppear {
                dataSource.loadNext(item)
              }
          }
//            .searchable(text: $viewModel.search)
//            .onSubmit(of: .search) {
//              Task {
//                dataSource.loadFirst()
//              }
//            }
        }
//          .introspectTableView { tableView in
//            //print(tableView)
//            tableView.separatorStyle = .singleLineEtched
//          }
          .padding(.horizontal)
          .refreshable {
            dataSource.loadFirst()
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
//        .introspectScrollView { scrollView in
//          scrollView.refreshControl = UIRefreshControl()
//        }
        .frame(width: geometry.size.width, height: geometry.size.height-20, alignment: .center)
    }
  }
}
