help:
	@echo "binary        - build a native executable"
	@echo "docker        - build the docker image"
	@echo "docker-binary - build a binary using the docker image"
	@echo "format        - format the code"
	@echo "setup         - install build dependencies"

PLATFORM := $(shell uname -s)

binary:
	@dart2native -o uhoh-$(PLATFORM) bin/uhoh.dart

docker:
	@docker build -t traviswheelerlab/uhoh:latest .
	@docker push traviswheelerlab/uhoh:latest

docker-binary:
	@docker run \
		--mount type=bind,src=$(PWD),dst=/code \
		traviswheelerlab/uhoh:latest

format:
	dartfmt -w -l 80 --fix .

setup:
	pub get
