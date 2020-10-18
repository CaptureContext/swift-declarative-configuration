/// Modifies an object.
///
/// Returns a new instance for value types
/// Returns modified reference for reference types
@inlinable
public func modification<Object>(
    of object: Object,
    with configuration: (Configurator<Object>) -> Configurator<Object>
) -> Object {
    return Configurator(config: configuration)
        .configured(object)
}
