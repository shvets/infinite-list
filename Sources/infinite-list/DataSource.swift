import Combine
import SwiftUI

open class DataSource<Item: Identifiable & Hashable & Sendable>: ObservableObject {
  @Published public var items = [Item]()
  @Published public var isLoadingPage = false

  private var currentPage = 1
  private var canLoadMorePages = true

  public var onError: (Error) -> Void = { error in print("Error: \(error)")}

  public init() {}

  public func loadFirst() {
    reset()

    loadContent()
  }

  public func loadNext(_ item: Item) {
    if requiresLoad(item) {
      loadContent()
    }
  }

  open func onLoadCompleted() {}

  @MainActor
  open func process(page: Int) async throws -> [Item] {
    []
  }

  func reset() {
    items.removeAll()
    isLoadingPage = false
    canLoadMorePages = true
    currentPage = 1
  }

  func requiresLoad(_ item: Item) -> Bool {
    let thresholdIndex = items.index(items.endIndex, offsetBy: -5)

    return items.firstIndex(where: { $0.id == item.id }) == thresholdIndex
  }

  func loadContent() {
    if !isLoadingPage && canLoadMorePages {
      isLoadingPage = true

      Task { @MainActor in
        do {
          try await loadFromQueue()

          onLoadCompleted()
        }
        catch let error {
          isLoadingPage = false

          onError(error)
        }
      }
    }
  }

  func loadFromQueue() async throws {
    (try await process(page: currentPage)).publisher
      .receive(on: DispatchQueue.main)
      .collect()
      .handleEvents(receiveOutput: { items in
        self.canLoadMorePages = items.count > 0
        self.isLoadingPage = false
        self.currentPage += 1
      })
      .map { items in
        self.items + items
      }
      .catch { error -> AnyPublisher<[Item], Never> in
        self.isLoadingPage = false
        
        return Just([])
          .eraseToAnyPublisher()
      }
      .eraseToAnyPublisher()
        
      .assign(to: &$items)
  }
}
