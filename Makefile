default:
	$(error Missing command)
	@exit 1

%:
	$(error Unknown command: $@)
	@exit 1

TEST_RUNNER_CI ?= $(CI)
MAKEFILE_PATH ?= ./swift-package-action/Makefile

SCHEME ?= DeclarativeConfiguration
PLATFORM ?= iOS
CONFIG ?= Debug

DERIVED_DATA=./DerivedData

BOLD=\033[1m
RESET=\033[0m

test-all:
	$(MAKE) test-library
	$(MAKE) test-library-macros
	$(MAKE) test-docs

test-library:
	@make loop-platforms \
		-f $(MAKEFILE_PATH) \
		PLATFORMS=iOS,macOS \
		GOAL=xcodebuild \
	  COMMAND=test \
		SCHEME=$(SCHEME) \
		CONFIG=$(CONFIG) \
		DERIVED_DATA=$(DERIVED_DATA)

test-library-macros:
	@make loop-platforms \
		-f $(MAKEFILE_PATH) \
		PLATFORMS=iOS,macOS,macCatalyst,watchOS,tvOS \
		GOAL=xcodebuild-macros \
	  COMMAND=test \
		SCHEME=$(SCHEME) \
		CONFIG=$(CONFIG) \
		DERIVED_DATA=$(DERIVED_DATA)
	$(MAKE) xcodebuild-macros-plugin COMMAND=test PLATFORM=macOS

xcodebuild:
	@make xcodebuild \
		-f $(MAKEFILE_PATH) \
		COMMAND=$(COMMAND) \
		DERIVED_DATA=$(DERIVED_DATA) \
		CONFIG=$(CONFIG) \
		SCHEME=$(SCHEME) \
		PLATFORM=$(PLATFORM)

xcodebuild-macros:
	@make xcodebuild-macros \
		-f $(MAKEFILE_PATH) \
		COMMAND=$(COMMAND) \
		DERIVED_DATA=$(DERIVED_DATA) \
		CONFIG=$(CONFIG) \
		SCHEME=$(SCHEME) \
		PLATFORM=$(PLATFORM)

xcodebuild-macros-plugin:
	@make xcodebuild-macros-plugin \
		-f $(MAKEFILE_PATH) \
		COMMAND=$(COMMAND) \
		DERIVED_DATA=$(DERIVED_DATA) \
		CONFIG=$(CONFIG) \
		SCHEME=$(SCHEME) \
		PLATFORM=$(PLATFORM)

build-for-library-evolution:
	@make build-for-library-evolution \
		-f $(MAKEFILE_PATH) \
		SCHEME=$(SCHEME)

test-docs:
	@make test-docs \
		-f $(MAKEFILE_PATH) \
		SCHEME=$(SCHEME) \
		PLATFORM=$(PLATFORM)

test-example:
	@make test-example \
		-f $(MAKEFILE_PATH) \
		DERIVED_DATA=$(DERIVED_DATA) \
		SCHEME=$(SCHEME) \
		PLATFORM=$(PLATFORM)

test-integration:
	@make test-integration \
		-f $(MAKEFILE_PATH) \
		SCHEME=Integration \
		PLATFORM=$(PLATFORM)

benchmark:
	@make benchmark -f $(MAKEFILE_PATH)

format:
	@make format -f $(MAKEFILE_PATH)
