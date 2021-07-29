install_format:
	./scripts/install_swift-format

format:
	./scripts/.installed/swift-format --in-place --recursive \
		./Package.swift ./Sources ./Tests

test:
	swift test --enable-test-discovery