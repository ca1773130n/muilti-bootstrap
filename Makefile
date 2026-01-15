.PHONY: setup bootstrap clean analyze test format generate
.PHONY: run-dev run-stage run-prod run-web
.PHONY: build-web build-android build-ios

MELOS := dart run melos

# === Setup ===
setup:
	@echo "Installing Flutter dependencies..."
	@command -v flutter >/dev/null 2>&1 || { echo "Flutter not installed. Please install Flutter first."; exit 1; }
	@dart pub get
	@echo "Setup complete!"

bootstrap: setup
	$(MELOS) bootstrap

clean:
	$(MELOS) clean

# === Development ===
analyze:
	$(MELOS) analyze

test:
	$(MELOS) run test --no-select

format:
	$(MELOS) format

format-check:
	$(MELOS) format:check

generate:
	$(MELOS) run generate --no-select

# === Run ===
run-dev:
	$(MELOS) run:dev

run-stage:
	$(MELOS) run:stage

run-prod:
	$(MELOS) run:prod

run-web:
	$(MELOS) run:web

# === Build ===
build-web:
	$(MELOS) build:web

build-android:
	$(MELOS) build:android

build-ios:
	$(MELOS) build:ios

# === Aliases ===
dev: run-dev
web: run-web
lint: analyze
all: analyze test
