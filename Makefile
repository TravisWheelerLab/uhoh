help:
	@echo "binary         - build a native executable"
	@echo "builder-binary - build a binary using the builder image"
	@echo "builder        - build the builder image"
	@echo "check          - run the test suite"
	@echo "check-format   - check code formatting"
	@echo "clean          - remove built assets for all platforms"
	@echo "format         - format the code"
	@echo "setup          - install build dependencies"
	@echo "zip            - build a binary and zip it with documentation"

PLATFORM := $(shell uname -s | tr '[:upper:]' '[:lower:]')
VERSION := $(shell git describe --tags)

binary:
	@dart2native -o uhoh-$(PLATFORM) bin/uhoh.dart

builder:
	@docker build -f Dockerfile_build -t traviswheelerlab/uhoh:latest .
	@docker push traviswheelerlab/uhoh:latest

builder-binary:
	@docker run \
		--mount type=bind,src=$(PWD),dst=/code \
		traviswheelerlab/uhoh:latest

check:
	@pub run test

check-format:
	@test "$(shell dartfmt -l 80 --fix -n .)" = ""

clean:
	@rm uhoh-*

format:
	@dartfmt -w -l 80 --fix .

setup:
	@pub get

zip: binary
	@zip uhoh-$(PLATFORM)-$(VERSION).zip uhoh-$(PLATFORM) README.md LICENSE AUTHORS
