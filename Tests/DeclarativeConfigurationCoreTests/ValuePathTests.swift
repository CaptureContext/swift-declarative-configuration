import Testing
@testable import DeclarativeConfigurationCore

@Suite("ValuePathTests")
struct ValuePathTests {
	@propertyWrapper
	struct Entry<Value: Equatable>: Equatable {
		private(set) var wrappedValue: Value

		var projectedValue: Value {
			get { wrappedValue }
			set { wrappedValue = newValue }
		}

		init(wrappedValue: Value) {
			self.wrappedValue = wrappedValue
		}
	}

	struct ValSubject: Equatable {
		@Entry
		var int: Int = 0

		@Entry
		var string: String = ""

		@Entry
		var array: [Int] = [0, 0, 0]

		@Entry
		var dictionary: [Int: Int] = [0: 0, 1: 1, 2: 2]

		@Entry
		var optionalInt: Int? = nil
	}

	class RefSubject {
		@Entry
		var value: ValSubject = .init()
	}

	@Suite("Init")
	struct Init {
		@Test
		func writableKeyPath() async throws {
			let valPath: ValuePath<RefSubject, ValSubject> = .init(\.$value)
			let intPath: ValuePath<RefSubject, Int> = .init(\.$value.$int)
			let valIntPath: ValuePath<ValSubject, Int> = .init(\.$int)

			let subject = RefSubject()

			func validateExtraction(
				_ sourceLocation: SourceLocation = #_sourceLocation
			) {
				#expect(
					valPath.extract(from: subject) == subject.value,
					sourceLocation: sourceLocation
				)
				#expect(
					intPath.extract(from: subject) == subject.value.int,
					sourceLocation: sourceLocation
				)
				#expect(
					valIntPath.extract(from: subject.value) == subject.value.int,
					sourceLocation: sourceLocation
				)
			}

			validateExtraction()

			do { // modify
				subject.$value.$int = 1
				validateExtraction()
			}

			do { // embedding
				// writing by reference
				valPath.embed(.init(), in: subject)
				#expect(subject.value == .init())
				validateExtraction()

				let localResult = valIntPath.embed(1, in: subject.$value)
				#expect(localResult.int == 1)
				#expect(subject.value.int == 0) // no mutation
				validateExtraction()

				intPath.embed(2, in: subject)
				#expect(subject.value.int == 2)
				validateExtraction()

				valIntPath.embed(3, in: &subject.$value)
				#expect(subject.value.int == 3)
				validateExtraction()
			}
		}
	}

	@Suite("StaticMethods")
	struct StaticMethods {
		@Test
		func getonly() async throws {
			let valPath: ValuePath<RefSubject, ValSubject> = .getonly(\.value)
			let intPath: ValuePath<RefSubject, Int> = .getonly(\.value.int)
			let intPathThroughWritable: ValuePath<RefSubject, Int> = .getonly(\.$value.int)
			let valIntPath: ValuePath<ValSubject, Int> = .getonly(\.int)

			let subject = RefSubject()

			func validateExtraction(
				_ sourceLocation: SourceLocation = #_sourceLocation
			) {
				#expect(
					valPath.extract(from: subject) == .init(), // always initial value
					sourceLocation: sourceLocation
				)
				#expect(
					intPath.extract(from: subject) == 0, // always initial value
					sourceLocation: sourceLocation
				)
				#expect(
					intPathThroughWritable.extract(from: subject) == 0, // always initial value
					sourceLocation: sourceLocation
				)
				#expect(
					valIntPath.extract(from: subject.value) == 0, // always initial value
					sourceLocation: sourceLocation
				)
			}

			validateExtraction()

			do { // embedding is always ignored for getonly ValuePaths
				valPath.embed(.init(), in: subject)
				validateExtraction()

				let localResult = valIntPath.embed(1, in: subject.$value)
				#expect(localResult.int == 0)
				validateExtraction()

				intPath.embed(2, in: subject)
				validateExtraction()

				valIntPath.embed(3, in: &subject.$value)
				validateExtraction()
			}
		}

		@Test
		func optional() async throws {
			let optionalPath: ValuePath<ValSubject?, Int?> = ValuePath.optional(unwrapWithRoot: false, \.$int)

			do { // none
				let optionalSubject: ValSubject? = nil
				#expect(optionalPath.extract(from: optionalSubject) == nil)

				do { // embed
					var localResult = optionalPath.embed(nil, in: optionalSubject)
					#expect(localResult == nil)

					#expect(optionalPath.embed(0, in: optionalSubject) == nil)

					optionalPath.embed(0, in: &localResult)
					#expect(localResult == nil)
				}
			}

			do { // some
				var optionalSubject: ValSubject? = ValSubject()

				#expect(optionalPath.extract(from: optionalSubject) == 0)

				do { // mutate
					optionalSubject?.$int = 1
					#expect(optionalPath.extract(from: optionalSubject) == 1)
				}

				do { // embed
					#expect(optionalPath.embed(nil, in: optionalSubject) == nil)
				}
			}
		}

		@Test
		func optional_unwrapWithRoot() async throws {
			let optionalPath: ValuePath<ValSubject?, Int?> = ValuePath.optional(unwrapWithRoot: true, \.$int)

			do { // none
				let optionalSubject: ValSubject? = nil
				#expect(optionalPath.extract(from: optionalSubject) == nil)

				do { // embed
					var localResult = optionalPath.embed(nil, in: optionalSubject)
					#expect(localResult == nil)

					#expect(optionalPath.embed(0, in: optionalSubject) == nil)

					optionalPath.embed(0, in: &localResult)
					#expect(localResult == nil)
				}
			}

			do { // some
				var optionalSubject: ValSubject? = ValSubject()

				#expect(optionalPath.extract(from: optionalSubject) == 0)

				do { // mutate
					optionalSubject?.$int = 1
					#expect(optionalPath.extract(from: optionalSubject) == 1)
				}

				do { // embed
					var localResult = optionalPath.embed(nil, in: optionalSubject)
					#expect(localResult?.int == 1)

					#expect(optionalPath.embed(0, in: localResult)?.int == 0)
					#expect(localResult?.int == 1) // no mutation

					optionalPath.embed(0, in: &localResult)
					#expect(localResult?.int == 0)
				}
			}
		}

		@Test
		func key() async throws {
			let zeroKeyPath: ValuePath<[Int: Int], Int?> = .key(0)
			#expect(zeroKeyPath.extract(from: [0: 1]) == 1)
			#expect(zeroKeyPath.extract(from: [1: 2]) == nil)
			#expect(zeroKeyPath.extract(from: [0: 1, 1: 2]) == 1)

			do { // embed
				// Note: keep single element, to avoid inconsistent sorting
				var localResult = zeroKeyPath.embed(1, in: [0: 0])
				#expect(localResult == [0: 1])

				zeroKeyPath.embed(0, in: &localResult)
				#expect(localResult == [0: 0])
			}
		}

		@Test
		func index() async throws {
			let firstElementPath: ValuePath<[Int], Int> = .index(0)
			#expect(firstElementPath.extract(from: [0]) == 0)
			#expect(firstElementPath.extract(from: [0, 1]) == 0)
			#expect(firstElementPath.extract(from: [1, 2]) == 1)

			do { // embed
				var localResult = firstElementPath.embed(1, in: [0])
				#expect(localResult == [1])

				firstElementPath.embed(0, in: &localResult)
				#expect(localResult == [0])
			}
		}

		@Test
		func index_getonly() async throws {
			do { // Array<Int>
				let firstElementPath: ValuePath<[Int], Int> = .index(getonly: 0)
				#expect(firstElementPath.extract(from: [0]) == 0)
				#expect(firstElementPath.extract(from: [0, 1]) == 0)
				#expect(firstElementPath.extract(from: [1, 2]) == 1)

				do { // embed is ignored for getonly ValuePaths
					var localResult = firstElementPath.embed(1, in: [0])
					#expect(localResult == [0])

					firstElementPath.embed(1, in: &localResult)
					#expect(localResult == [0])
				}
			}

			do { // String
				let firstElementPath: ValuePath<String, Character> = .index(getonly: "".startIndex)
				#expect(firstElementPath.extract(from: "a") == "a".first!)
				#expect(firstElementPath.extract(from: "ab") == "a".first!)
				
				do { 
					var localResult = firstElementPath.embed("b", in: "ab")
					#expect(localResult == "ab")

					firstElementPath.embed("b", in: &localResult)
					#expect(localResult == "ab")
				}
			}
		}

		@Test
		func index_safe() async throws {
			let secondElementPath: ValuePath<[Int], Int?> = .index(safe: 1)
			#expect(secondElementPath.extract(from: [0]) == nil)
			#expect(secondElementPath.extract(from: [0, 1]) == 1)
			#expect(secondElementPath.extract(from: [1, 2]) == 2)

			do { // embed
				var localResult = secondElementPath.embed(1, in: [0, 0])
				#expect(localResult == [0, 1])

				secondElementPath.embed(0, in: &localResult)
				#expect(localResult == [0, 0])
			}
		}
	}

	@Suite("InstanceMethods")
	struct InstanceMethods {
		@Test
		func optional() async throws {
			let optionalPath: ValuePath<ValSubject?, Int?> = ValuePath(\.$int).optional(unwrapWithRoot: false)

			do { // none
				let optionalSubject: ValSubject? = nil
				#expect(optionalPath.extract(from: optionalSubject) == nil)

				do { // embed
					var localResult = optionalPath.embed(nil, in: optionalSubject)
					#expect(localResult == nil)

					#expect(optionalPath.embed(0, in: optionalSubject) == nil)

					optionalPath.embed(0, in: &localResult)
					#expect(localResult == nil)
				}
			}

			do { // some
				var optionalSubject: ValSubject? = ValSubject()

				#expect(optionalPath.extract(from: optionalSubject) == 0)

				do { // mutate
					optionalSubject?.$int = 1
					#expect(optionalPath.extract(from: optionalSubject) == 1)
				}

				do { // embed
					#expect(optionalPath.embed(nil, in: optionalSubject) == nil)
				}
			}
		}

		@Test
		func optional_unwrapWithRoot() async throws {
			let optionalPath: ValuePath<ValSubject?, Int?> = ValuePath(\.$int).optional(unwrapWithRoot: true)

			do { // none
				let optionalSubject: ValSubject? = nil
				#expect(optionalPath.extract(from: optionalSubject) == nil)

				do { // embed
					var localResult = optionalPath.embed(nil, in: optionalSubject)
					#expect(localResult == nil)

					#expect(optionalPath.embed(0, in: optionalSubject) == nil)

					optionalPath.embed(0, in: &localResult)
					#expect(localResult == nil)
				}
			}

			do { // some
				var optionalSubject: ValSubject? = ValSubject()

				#expect(optionalPath.extract(from: optionalSubject) == 0)

				do { // mutate
					optionalSubject?.$int = 1
					#expect(optionalPath.extract(from: optionalSubject) == 1)
				}

				do { // embed
					var localResult = optionalPath.embed(nil, in: optionalSubject)
					#expect(localResult?.int == 1)

					#expect(optionalPath.embed(0, in: localResult)?.int == 0)
					#expect(localResult?.int == 1) // no mutation

					optionalPath.embed(0, in: &localResult)
					#expect(localResult?.int == 0)
				}
			}
		}

		@Test
		func appending() async throws {
			let valuePath: ValuePath<RefSubject, ValSubject> = .init(\.$value)
			let intPath: ValuePath<ValSubject, Int> = .init(\.$int)
			let path = valuePath.appending(path: intPath)

			let subject = RefSubject()
			#expect(path.extract(from: subject) == 0)

			do { // modify
				subject.$value.$int = 1
				#expect(path.extract(from: subject) == 1)
			}

			do { // embed
				// writing by reference
				path.embed(0, in: subject)
				#expect(subject.value.int == 0)

				let localResult: RefSubject = path.embed(1, in: subject)
				#expect(localResult === subject)
				#expect(localResult.value.int == 1)

				path.embed(2, in: subject)
				#expect(subject.value.int == 2)
			}
		}

		@Test
		func appendingToOptional() async throws {
			let valuePath: ValuePath<RefSubject, ValSubject> = .init(\.$value)
			let optionalIntPath: ValuePath<ValSubject, Int?> = .init(\.$optionalInt)
			let path = valuePath.appending(path: optionalIntPath)

			let subject = RefSubject()
			#expect(path.extract(from: subject) == nil)

			do { // modify
				subject.$value.$optionalInt = 0
				#expect(path.extract(from: subject) == 0)
			}

			do { // embed
				// writing by reference
				path.embed(1, in: subject)
				#expect(subject.value.optionalInt == 1)

				let localResult: RefSubject = path.embed(2, in: subject)
				#expect(localResult === subject)
				#expect(localResult.value.optionalInt == 2)

				path.embed(3, in: subject)
				#expect(subject.value.optionalInt == 3)

				path.embed(nil, in: subject)
				#expect(subject.value.optionalInt == nil)
			}
		}
	}
}
