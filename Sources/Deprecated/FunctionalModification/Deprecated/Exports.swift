/// Modifies copy of value and returns it as a result
///
/// - Returns:
///   - A new instance for value types
///   - Modified object for reference types
@available(
	*, deprecated,
	message: """
	FunctionalModification module is deprecated and will be removed in v1.0.0
	Use `import DeclarativeConfiguration` instead
	"""
)
@inlinable
public func reduce<Value>(
	_ value: Value,
	with transform: (inout Value) -> Void
) -> Value {
	var _value = value
	transform(&_value)
	return _value
}
