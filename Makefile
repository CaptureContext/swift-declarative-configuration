install_formatter:
	@chmod +x ./scripts/install_swift-format.sh
	@./scripts/install_swift-format.sh

update_formatter:
	@rm ./scripts/.bin/swift-format
	@make install_formatter

format:
	@chmod +x ./scripts/format.sh
	@./scripts/format.sh

test:
	@swift test --enable-test-discovery
