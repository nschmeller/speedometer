@MainActor
protocol SpeedSource: AnyObject {
    var onReading: ((SpeedReading) -> Void)? { get set }
    func start()
}
