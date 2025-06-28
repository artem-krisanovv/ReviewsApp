struct ReviewsViewModelState {
    enum LoadingState {
        case initial
        case loading
        case loaded
        case error(String)
    }

    var items = [any TableCellConfig]()
    var limit = 20
    var offset = 0
    var shouldLoad = true
    var loadingState: LoadingState = .initial
}
