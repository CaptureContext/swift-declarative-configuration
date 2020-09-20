/// Modifies an object.
///
/// Returns a new instance for value types
/// Returns modified reference for reference types
@inlinable
public func modification<Object>(
    of object: Object,
    with transform: (inout Object) -> Void
) -> Object {
    var _object = object
    transform(&_object)
    return _object
}
