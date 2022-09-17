install_formatter:
	@chmod +x ./scripts/install_swift-format.sh
	@./scripts/install_swift-format.sh

format:
	./scripts/.bin/swift-format \
		--in-place --recursive \
		./Package.swift ./Sources ./Tests

test:
	swift test --enable-test-discovery
