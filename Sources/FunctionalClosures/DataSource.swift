/// A wrapper for clusure-based interaction between objects
///
/// Provides a public API to set internal closure-based datasource with a functional API
@propertyWrapper
public class DataSource<Input, Output> {
  public struct Container {
    @usableFromInline
    internal var action: (Input) -> Output

    public init(action: @escaping (Input) -> Output) {
      self.action = action
    }

    @inlinable
    public mutating func callAsFunction(perform action: @escaping (Input) -> Output) {
      self.action = action
    }
  }

  public init(wrappedValue: Container) {
    self.wrappedValue = wrappedValue
  }

  public var wrappedValue: Container

  @inlinable
  public var projectedValue: (Input) -> Output {
    get { wrappedValue.action }
    set { wrappedValue.action = newValue }
  }

  @inlinable
  public func callAsFunction(_ input: Input) -> Output? {
    projectedValue(input)
  }

  @inlinable
  public func callAsFunction() -> Output where Input == Void {
    projectedValue(())
  }
}

/// A wrapper for clusure-based interaction between objects
///
/// Provides a public API to set internal closure-based datasource with a functional API
@propertyWrapper
public class OptionalDataSource<Input, Output> {
  public struct Container {
    @usableFromInline
    internal var action: ((Input) -> Output)?

    internal init() {}

    public init(action: ((Input) -> Output)?) {
      self.action = action
    }

    @inlinable
    public mutating func callAsFunction(perform action: ((Input) -> Output)?) {
      self.action = action
    }
  }

  public init() {}

  public init(wrappedValue: Container) {
    self.wrappedValue = wrappedValue
  }

  public var wrappedValue: Container = .init()

  @inlinable
  public var projectedValue: ((Input) -> Output)? {
    get { wrappedValue.action }
    set { wrappedValue.action = newValue }
  }

  @inlinable
  public func callAsFunction(_ input: Input) -> Output? {
    projectedValue?(input)
  }

  @inlinable
  public func callAsFunction() -> Output? where Input == Void {
    projectedValue?(())
  }
}
