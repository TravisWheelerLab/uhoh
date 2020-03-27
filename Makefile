help:
	@echo "binary - build a native executable"
	@echo "format - format the code"
	@echo "setup  - install build dependencies"

PLATFORM := $(shell uname -s)

binary:
	@dart2native -o uhoh-$(PLATFORM) bin/uhoh.dart

format:
	dartfmt -w -l 80 --fix .

setup:
	pub get
