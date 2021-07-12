format:
	swift-format --in-place --recursive \
		./Package.swift ./Sources ./Tests

test:
	swift test --enable-test-discovery