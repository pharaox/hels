NAME := hels_paintings
VERSION := $(shell cat VERSION)

.PHONY: download
download:
	scripts/download.sh images.csv

.PHONY: convert
convert: download
	scripts/convert.sh images.csv

.PHONY: generate
generate: convert
	scripts/generate.sh images.csv

.PHONY: build
build: clean-build generate
	mkdir -p tmp/$(NAME)
	rsync -r --exclude=".*" --exclude=tmp --exclude=images --exclude=scripts --exclude=images.csv --exclude=Makefile --exclude=VERSION --exclude=ck3-tiger.conf . tmp/$(NAME)
	cp descriptor.mod tmp/$(NAME).mod
	echo "path=\"mod/$(NAME)\"" >> tmp/$(NAME).mod
	pandoc README.md -t html5 -o tmp/$(NAME)-$(VERSION).pdf
	cd tmp && zip -r $(NAME)-$(VERSION).zip . && cd ..

.PHONY: clean-download
clean-download:
	rm -rf images

.PHONY: clean-convert
clean-convert:
	rm -rf gfx/interface/illustrations/loading_screens/*.dds

.PHONY: clean-generate
clean-generate:
	rm -rf gfx/interface/illustrations/loading_screens/*.txt
	rm -f images.md

.PHONY: clean-build
clean-build:
	rm -rf tmp
	rm -f ck3-tiger.out

.PHONY: clean
clean: clean-download clean-convert clean-generate clean-build

.PHONY: tiger
tiger:
	ck3-tiger --no-color . > ck3-tiger.out
	cat ck3-tiger.out

.PHONY: update-version
update-version:
	sed -i 's/$(VERSION)/$(NEW_VERSION)/g' descriptor.mod VERSION
