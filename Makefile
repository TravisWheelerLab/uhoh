help:
	@echo "binary - build a native executable"
	@echo "format - format the code"

binary:
	@dart2native -o uhoh bin/uhoh.dart

format:
	dartfmt -w -l 80 --fix .

