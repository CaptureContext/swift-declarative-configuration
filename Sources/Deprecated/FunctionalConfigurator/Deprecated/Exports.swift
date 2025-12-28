@_exported import DeclarativeConfiguration

@available(
	*, deprecated,
	message: """
	FunctionalConfigurator module is deprecated and will be removed in v1.0.0
	Use `import DeclarativeConfiguration` instead
	"""
)
public typealias Configurator<Base> = DeclarativeConfiguration.Configurator<Base>
