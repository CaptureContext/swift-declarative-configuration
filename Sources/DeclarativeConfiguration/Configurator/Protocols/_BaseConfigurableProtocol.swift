public protocol _BaseConfigurableProtocol {}

extension _BaseConfigurableProtocol {
	public typealias Config = Configurator<Self>
}
