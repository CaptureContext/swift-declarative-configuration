@_exported import DeclarativeConfigurationCore

@available(
	*, deprecated,
	renamed: "ValuePath",
	message: """
	FunctionalKeyPath module is deprecated and will be removed in v2.0.0 \
	Use `import DeclarativeConfiguration` instead
	"""
)
public typealias FunctionalKeyPath = ValuePath
