/// Modifies copy of value and returns it as a result
///
/// - Returns:
///   - A new instance for value types
///   - Modified object for reference types
@available(*, deprecated, message: "FunctionalModification module is deprecated use `import DeclarativeConfiguration`")
@inlinable
public func reduce<Value>(
	_ value: Value,
	with transform: (inout Value) -> Void
) -> Value {
	var _value = value
	transform(&_value)
	return _value
}
