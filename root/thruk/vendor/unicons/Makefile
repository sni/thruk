all: build clean

build: node_modules
	rm -rf fonts css
	cp -rp ./node_modules/@iconscout/unicons/fonts .
	cp -rp ./node_modules/@iconscout/unicons/css .
	# firefox: "downloadable font: rejected by sanitizer"
	#sed -i '/unicons-[0-9]*.woff2/d' ./css/line.css
	#find fonts/ -name \*.woff2 -delete
	rm -rf fonts/thinline
	rm -rf fonts/solid
	rm -rf css/solid.css
	rm -rf css/thinline.css
	rm -rf css/animation.css
	rm -rf css/before.css
	sed -i 's/@font-face[[:space:]]*{/&\nfont-display: swap;/g' ./css/line.css
	rm -rf unicons-*
	set -x; VERSION=$$(npm info "@iconscout/unicons" version); \
		mkdir -p unicons-$$VERSION; \
		mv fonts css unicons-$$VERSION; \

node_modules:
	npm install --save @iconscout/unicons --prefix=$(shell pwd)/.

clean:
	rm -rf \
		node_modules \
		package.json \
		package-lock.json
