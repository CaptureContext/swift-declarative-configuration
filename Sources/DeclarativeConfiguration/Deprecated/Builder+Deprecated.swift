extension Builder {
	@available(
		*, deprecated,
		message: """
		Use `.combined(with: builder.configurator)` instead.
		This API will be removed in v1.0.0.
		"""
	)
	@inlinable
	public func combined(
		with builder: Builder
	) -> Builder {
		combined(with: builder.configurator)
	}

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
	) -> Builder {
		modify(transform)
	}

	/// Applies modification to a new builder, created with a built object, also passes leading parameters to transform function.
	@available(
		*, deprecated,
		message: """
		Use `modify` and capture arguments explicitly instead.
		This API is likely to be removed in v1.0.0
		"""
	)
	@inlinable
	public func reinforce<each Arg>(
		_ args: repeat each Arg,
		transform: @escaping (inout Base, repeat each Arg) -> Void
	) -> Builder {
		commit().modify { transform(&$0, repeat each args) }
	}
}
