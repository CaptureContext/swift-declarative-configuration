@available(*, deprecated, message: """
Will be removed in future versions of swift-declarative-configuration
""")
@inlinable
public func assign<Root: AnyObject, T0>(
  to root: Root,
  _ keyPath: ReferenceWritableKeyPath<Root, T0>
) -> (T0) -> Void {
  { [weak root] result in root?[keyPath: keyPath] = result }
}

@available(*, deprecated, message: """
Will be removed in future versions of swift-declarative-configuration
""")
@inlinable
public func assignFirst<Root: AnyObject, T0, T1>(
  to root: Root,
  _ keyPath: ReferenceWritableKeyPath<Root, T0>
) -> (T0, T1) -> Void {
  { [weak root] result, _ in root?[keyPath: keyPath] = result }
}

@available(*, deprecated, message: """
Will be removed in future versions of swift-declarative-configuration
""")
@inlinable
public func assignFirst<Root: AnyObject, T0, T1, T2>(
  to root: Root,
  _ keyPath: ReferenceWritableKeyPath<Root, T0>
) -> (T0, T1, T2) -> Void {
  { [weak root] result, _, _ in root?[keyPath: keyPath] = result }
}

@available(*, deprecated, message: """
Will be removed in future versions of swift-declarative-configuration
""")
@inlinable
public func assignFirst<Root: AnyObject, T0, T1, T2, T3>(
  to root: Root,
  _ keyPath: ReferenceWritableKeyPath<Root, T0>
) -> (T0, T1, T2, T3) -> Void {
  { [weak root] result, _, _, _ in root?[keyPath: keyPath] = result }
}

@available(*, deprecated, message: """
Will be removed in future versions of swift-declarative-configuration
""")
@inlinable
public func assignFirst<Root: AnyObject, T0, T1, T2, T3, T4>(
  to root: Root,
  _ keyPath: ReferenceWritableKeyPath<Root, T0>
) -> (T0, T1, T2, T3, T4) -> Void {
  { [weak root] result, _, _, _, _ in root?[keyPath: keyPath] = result }
}

@available(*, deprecated, message: """
Will be removed in future versions of swift-declarative-configuration
""")
@inlinable
public func assignSecond<Root: AnyObject, T0, T1>(
  to root: Root,
  _ keyPath: ReferenceWritableKeyPath<Root, T1>
) -> (T0, T1) -> Void {
  { [weak root] _, result in root?[keyPath: keyPath] = result }
}

@available(*, deprecated, message: """
Will be removed in future versions of swift-declarative-configuration
""")
@inlinable
public func assignSecond<Root: AnyObject, T0, T1, T2>(
  to root: Root,
  _ keyPath: ReferenceWritableKeyPath<Root, T1>
) -> (T0, T1, T2) -> Void {
  { [weak root] _, result, _ in root?[keyPath: keyPath] = result }
}

@available(*, deprecated, message: """
Will be removed in future versions of swift-declarative-configuration
""")
@inlinable
public func assignSecond<Root: AnyObject, T0, T1, T2, T3>(
  to root: Root,
  _ keyPath: ReferenceWritableKeyPath<Root, T1>
) -> (T0, T1, T2, T3) -> Void {
  { [weak root] _, result, _, _ in root?[keyPath: keyPath] = result }
}

@available(*, deprecated, message: """
Will be removed in future versions of swift-declarative-configuration
""")
@inlinable
public func assignSecond<Root: AnyObject, T0, T1, T2, T3, T4>(
  to root: Root,
  _ keyPath: ReferenceWritableKeyPath<Root, T1>
) -> (T0, T1, T2, T3, T4) -> Void {
  { [weak root] _, result, _, _, _ in root?[keyPath: keyPath] = result }
}

@available(*, deprecated, message: """
Will be removed in future versions of swift-declarative-configuration
""")
@inlinable
public func assignThird<Root: AnyObject, T0, T1, T2>(
  to root: Root,
  _ keyPath: ReferenceWritableKeyPath<Root, T2>
) -> (T0, T1, T2) -> Void {
  { [weak root] _, _, result in root?[keyPath: keyPath] = result }
}

@available(*, deprecated, message: """
Will be removed in future versions of swift-declarative-configuration
""")
@inlinable
public func assignThird<Root: AnyObject, T0, T1, T2, T3>(
  to root: Root,
  _ keyPath: ReferenceWritableKeyPath<Root, T2>
) -> (T0, T1, T2, T3) -> Void {
  { [weak root] _, _, result, _ in root?[keyPath: keyPath] = result }
}

@available(*, deprecated, message: """
Will be removed in future versions of swift-declarative-configuration
""")
@inlinable
public func assignThird<Root: AnyObject, T0, T1, T2, T3, T4>(
  to root: Root,
  _ keyPath: ReferenceWritableKeyPath<Root, T2>
) -> (T0, T1, T2, T3, T4) -> Void {
  { [weak root] _, _, result, _, _ in root?[keyPath: keyPath] = result }
}

@available(*, deprecated, message: """
Will be removed in future versions of swift-declarative-configuration
""")
@inlinable
public func assignFourth<Root: AnyObject, T0, T1, T2, T3>(
  to root: Root,
  _ keyPath: ReferenceWritableKeyPath<Root, T3>
) -> (T0, T1, T2, T3) -> Void {
  { [weak root] _, _, _, result in root?[keyPath: keyPath] = result }
}

@available(*, deprecated, message: """
Will be removed in future versions of swift-declarative-configuration
""")
@inlinable
public func assignFourth<Root: AnyObject, T0, T1, T2, T3, T4>(
  to root: Root,
  _ keyPath: ReferenceWritableKeyPath<Root, T3>
) -> (T0, T1, T2, T3, T4) -> Void {
  { [weak root] _, _, _, result, _ in root?[keyPath: keyPath] = result }
}

@available(*, deprecated, message: """
Will be removed in future versions of swift-declarative-configuration
""")
@inlinable
public func assignFifth<Root: AnyObject, T0, T1, T2, T3, T4>(
  to root: Root,
  _ keyPath: ReferenceWritableKeyPath<Root, T4>
) -> (T0, T1, T2, T3, T4) -> Void {
  { [weak root] _, _, _, _, result in root?[keyPath: keyPath] = result }
}

@available(*, deprecated, message: """
Will be removed in future versions of swift-declarative-configuration
""")
@inlinable
public func assign<Root: AnyObject, T0>(
	to root: Root,
	_ keyPath: ReferenceWritableKeyPath<Root, T0?>
) -> (T0) -> Void {
	{ [weak root] result in root?[keyPath: keyPath] = result }
}

@available(*, deprecated, message: """
Will be removed in future versions of swift-declarative-configuration
""")
@inlinable
public func assignFirst<Root: AnyObject, T0, T1>(
  to root: Root,
  _ keyPath: ReferenceWritableKeyPath<Root, T0?>
) -> (T0, T1) -> Void {
  { [weak root] result, _ in root?[keyPath: keyPath] = result }
}

@available(*, deprecated, message: """
Will be removed in future versions of swift-declarative-configuration
""")
@inlinable
public func assignFirst<Root: AnyObject, T0, T1, T2>(
  to root: Root,
  _ keyPath: ReferenceWritableKeyPath<Root, T0?>
) -> (T0, T1, T2) -> Void {
  { [weak root] result, _, _ in root?[keyPath: keyPath] = result }
}

@available(*, deprecated, message: """
Will be removed in future versions of swift-declarative-configuration
""")
@inlinable
public func assignFirst<Root: AnyObject, T0, T1, T2, T3>(
  to root: Root,
  _ keyPath: ReferenceWritableKeyPath<Root, T0?>
) -> (T0, T1, T2, T3) -> Void {
  { [weak root] result, _, _, _ in root?[keyPath: keyPath] = result }
}

@available(*, deprecated, message: """
Will be removed in future versions of swift-declarative-configuration
""")
@inlinable
public func assignFirst<Root: AnyObject, T0, T1, T2, T3, T4>(
  to root: Root,
  _ keyPath: ReferenceWritableKeyPath<Root, T0?>
) -> (T0, T1, T2, T3, T4) -> Void {
  { [weak root] result, _, _, _, _ in root?[keyPath: keyPath] = result }
}

@available(*, deprecated, message: """
Will be removed in future versions of swift-declarative-configuration
""")
@inlinable
public func assignSecond<Root: AnyObject, T0, T1>(
  to root: Root,
  _ keyPath: ReferenceWritableKeyPath<Root, T1?>
) -> (T0, T1) -> Void {
  { [weak root] _, result in root?[keyPath: keyPath] = result }
}

@available(*, deprecated, message: """
Will be removed in future versions of swift-declarative-configuration
""")
@inlinable
public func assignSecond<Root: AnyObject, T0, T1, T2>(
  to root: Root,
  _ keyPath: ReferenceWritableKeyPath<Root, T1?>
) -> (T0, T1, T2) -> Void {
  { [weak root] _, result, _ in root?[keyPath: keyPath] = result }
}

@available(*, deprecated, message: """
Will be removed in future versions of swift-declarative-configuration
""")
@inlinable
public func assignSecond<Root: AnyObject, T0, T1, T2, T3>(
  to root: Root,
  _ keyPath: ReferenceWritableKeyPath<Root, T1?>
) -> (T0, T1, T2, T3) -> Void {
  { [weak root] _, result, _, _ in root?[keyPath: keyPath] = result }
}

@available(*, deprecated, message: """
Will be removed in future versions of swift-declarative-configuration
""")
@inlinable
public func assignSecond<Root: AnyObject, T0, T1, T2, T3, T4>(
  to root: Root,
  _ keyPath: ReferenceWritableKeyPath<Root, T1?>
) -> (T0, T1, T2, T3, T4) -> Void {
  { [weak root] _, result, _, _, _ in root?[keyPath: keyPath] = result }
}

@available(*, deprecated, message: """
Will be removed in future versions of swift-declarative-configuration
""")
@inlinable
public func assignThird<Root: AnyObject, T0, T1, T2>(
  to root: Root,
  _ keyPath: ReferenceWritableKeyPath<Root, T2?>
) -> (T0, T1, T2) -> Void {
  { [weak root] _, _, result in root?[keyPath: keyPath] = result }
}

@available(*, deprecated, message: """
Will be removed in future versions of swift-declarative-configuration
""")
@inlinable
public func assignThird<Root: AnyObject, T0, T1, T2, T3>(
  to root: Root,
  _ keyPath: ReferenceWritableKeyPath<Root, T2?>
) -> (T0, T1, T2, T3) -> Void {
  { [weak root] _, _, result, _ in root?[keyPath: keyPath] = result }
}

@available(*, deprecated, message: """
Will be removed in future versions of swift-declarative-configuration
""")
@inlinable
public func assignThird<Root: AnyObject, T0, T1, T2, T3, T4>(
  to root: Root,
  _ keyPath: ReferenceWritableKeyPath<Root, T2?>
) -> (T0, T1, T2, T3, T4) -> Void {
  { [weak root] _, _, result, _, _ in root?[keyPath: keyPath] = result }
}

@available(*, deprecated, message: """
Will be removed in future versions of swift-declarative-configuration
""")
@inlinable
public func assignFourth<Root: AnyObject, T0, T1, T2, T3>(
  to root: Root,
  _ keyPath: ReferenceWritableKeyPath<Root, T3?>
) -> (T0, T1, T2, T3) -> Void {
  { [weak root] _, _, _, result in root?[keyPath: keyPath] = result }
}

@available(*, deprecated, message: """
Will be removed in future versions of swift-declarative-configuration
""")
@inlinable
public func assignFourth<Root: AnyObject, T0, T1, T2, T3, T4>(
  to root: Root,
  _ keyPath: ReferenceWritableKeyPath<Root, T3?>
) -> (T0, T1, T2, T3, T4) -> Void {
  { [weak root] _, _, _, result, _ in root?[keyPath: keyPath] = result }
}

@available(*, deprecated, message: """
Will be removed in future versions of swift-declarative-configuration, \
probably will move to `capturecontext/swift-prelude` when
""")
@inlinable
public func assignFifth<Root: AnyObject, T0, T1, T2, T3, T4>(
  to root: Root,
  _ keyPath: ReferenceWritableKeyPath<Root, T4?>
) -> (T0, T1, T2, T3, T4) -> Void {
  { [weak root] _, _, _, _, result in root?[keyPath: keyPath] = result }
}
