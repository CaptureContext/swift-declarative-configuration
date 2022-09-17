install_formatter:
	./scripts/install_swift-format

format:
	./Scripts/.bin/swift-format \
		--in-place --recursive \
		./Package.swift ./Sources ./Tests

test:
	swift test --enable-test-discovery
