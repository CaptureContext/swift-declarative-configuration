@_exported import DeclarativeConfiguration

@available(
	*, deprecated,
	message: """
	FunctionalBuilder module is deprecated and will be removed in v2.0.0 \
	Use `import DeclarativeConfiguration` instead
	"""
)
public typealias Builder<Base> = DeclarativeConfiguration.Builder<Base>

@available(
	*, deprecated,
	message: """
	FunctionalBuilder module is deprecated and will be removed in v2.0.0 \
	Use `import DeclarativeConfiguration` instead
	"""
)
public typealias BuilderProvider = DeclarativeConfiguration.BuilderProvider
