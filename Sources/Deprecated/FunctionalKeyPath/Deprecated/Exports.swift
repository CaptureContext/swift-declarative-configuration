@_exported import DeclarativeConfigurationCore

@available(
	*, deprecated,
	renamed: "ValuePath",
	message: """
	FunctionalKeyPath module is deprecated and will be removed in v1.0.0
	Use `import DeclarativeConfiguration` instead.
	"""
)
public typealias FunctionalKeyPath = __ValuePath_DEPRECATED
