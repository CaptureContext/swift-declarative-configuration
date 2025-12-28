@_exported import DeclarativeConfigurationCore

@available(
	*, deprecated,
	renamed: "ValuePath",
	message: "FunctionalKeyPath module is deprecated, use `import DeclarativeConfiguration` instead"
)
public typealias FunctionalKeyPath = ValuePath
