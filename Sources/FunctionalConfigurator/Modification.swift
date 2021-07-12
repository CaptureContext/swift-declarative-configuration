/// Modifies an object.
///
/// Returns a new instance for value types
/// Returns modified reference for reference types
@available(
  *,
  deprecated,
  message:
    """
This function will be made internal in `1.0.0` release, implement `CustomConfigurable` protocol for your object and use instance method instead
"""
)
@inlinable
public func modification<Object>(
  of object: Object,
  with configuration: (Configurator<Object>) -> Configurator<Object>
) -> Object {
  return Configurator(config: configuration)
    .configured(object)
}

@inlinable
internal func _modification<Object>(
  of object: Object,
  with configuration: (Configurator<Object>) -> Configurator<Object>
) -> Object {
  return Configurator(config: configuration).configured(object)
}
