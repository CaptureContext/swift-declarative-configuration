extension Configurator {
	/// Appends transformation to current configuration
	@available(
		*, deprecated,
		renamed: "modify",
		message: """
		This API will be removed in v1.0.0.
		"""
	)
	@inlinable
	public func set(
		_ transform: @escaping (inout Base) -> Void
	) -> Configurator {
		modify(transform)
	}

	/// Appends transformation to current configuration
	@available(
		*, deprecated,
		renamed: "transform",
		message: """
		This API will be removed in v1.0.0.
		"""
	)
	@inlinable
	public func appendingConfiguration(_ configuration: @escaping (Base) -> Base) -> Configurator {
		modify { $0 = configuration($0) }
	}
}
