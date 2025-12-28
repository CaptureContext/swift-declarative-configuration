@inlinable
internal func reduce<Object>(
	_ object: Object,
	with configuration: (Configurator<Object>) -> Configurator<Object>
) -> Object {
	return Configurator(config: configuration).configured(object)
}
