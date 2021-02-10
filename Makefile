help:
	@echo "binary           - build a native executable"
	@echo "check            - run the test suite"
	@echo "container        - build the container image"
	@echo "container-binary - build a binary using the container image"
	@echo "format           - format the code"
	@echo "package          - build a binary and zip it with documentation"
	@echo "setup            - install build dependencies"

PLATFORM := $(shell uname -s | tr '[:upper:]' '[:lower:]')
VERSION := $(shell git describe --tags)

binary:
	@dart2native -o uhoh-$(PLATFORM) bin/uhoh.dart

check:
	@pub run test

check-format:
	@test "$(shell dartfmt -l 80 --fix -n .)" = ""

container:
	@docker build -t traviswheelerlab/uhoh:latest .
	@docker push traviswheelerlab/uhoh:latest

container-binary:
	@docker run \
		--mount type=bind,src=$(PWD),dst=/code \
		traviswheelerlab/uhoh:latest

format:
	@dartfmt -w -l 80 --fix .

package: setup check check-format binary
	@zip uhoh-$(PLATFORM)-$(VERSION).zip uhoh-$(PLATFORM) README.md LICENSE AUTHORS

setup:
	@pub get
