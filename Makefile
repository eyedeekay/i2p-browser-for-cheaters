
UNAME ?= $(shell uname -s | tr '[:upper:]' '[:lower:]')
UARCH ?= $(shell uname -m | tr '[:upper:]' '[:lower:]' | sed 's|x86_64|amd64|g')

browser=$(PWD)/browser
BROWSER_VERSION ?= $(shell curl https://www.torproject.org/projects/torbrowser.html.en 2>&1 | grep '<th>GNU/Linux<br>' | sed 's|<th>GNU/Linux<br><em>(||g' | sed 's|)</em></th>||g' | tr -d ' ')


PKG_VERSION = 0.$(BROWSER_VERSION)

VARIANT ?= cheaters
#VARIANT ?= di

PORT ?= 4444
#PORT ?= 4443

DISPLAY = :0

all: cheater di

echo:
	@echo "Building variant: $(VARIANT):$(PORT)"
	sleep 3

build: echo clean docker-browser browse docker-copy docker-clean unpack shasum sigsum checkinstall

cheater:
	VARIANT=cheaters PORT=4444 make build

di:
	VARIANT=di PORT=4443 make build

docker-browser:
	docker build --force-rm \
		--build-arg VERSION="$(BROWSER_VERSION)" \
		--build-arg PORT="$(PORT)" \
		-f Dockerfile -t eyedeekay/$(VARIANT)i2p-browser .

browse:
	docker run --rm -i -t -d \
		-e DISPLAY=$(DISPLAY) \
		-e VERSION="$(BROWSER_VERSION)" \
		--net host \
		--name i2p-browser \
		--volume /tmp/.X11-unix:/tmp/.X11-unix:ro \
		--volume $(browser):/home/anon/tor-browser_en-US/Browser/Desktop \
		eyedeekay/$(VARIANT)i2p-browser; true

docker-copy:
	docker cp i2p-browser:/home/anon/i2p-browser.tar.gz $(VARIANT)-i2p-browser_$(PKG_VERSION).tar.gz

docker-clean:
	docker rm -f i2p-browser

docker-clobber:
	docker rmi -f eyedeekay/$(VARIANT)i2p-browser

docker-clobber-all:
	docker rmi -f eyedeekay/cheatersi2p-browser eyedeekay/dii2p-browser

clean:
	rm -rf $(VARIANT)-i2p-browser_$(PKG_VERSION).tar.gz $(VARIANT)-i2p-browser_en-US $(VARIANT)-i2p-browser*.asc

unpack:
	tar -xzf $(VARIANT)-i2p-browser_$(PKG_VERSION).tar.gz
	mv i2p-browser_en-US $(VARIANT)-i2p-browser_en-US

run:
	./i2p-browser_en-US/Browser/start-i2p-browser

shasum:
	sha256sum $(VARIANT)-i2p-browser_$(PKG_VERSION).tar.gz 2>&1 | tee $(VARIANT)-i2p-browser_$(PKG_VERSION).tar.gz.sha256sum

sigsum:
	gpg --batch --clear-sign -u "$(SIGNING_KEY)" $(VARIANT)-i2p-browser_$(PKG_VERSION).tar.gz.sha256sum

user:
	adduser --home /var/lib/$(VARIANT)-i2p-browser_en-US --disabled-login --disabled-password --gecos ',,,,' i2pbrowser; true

install: user
	rm -rf /var/lib/$(VARIANT)-i2p-browser_en-US
	cp -Rv $(VARIANT)-i2p-browser_en-US /var/lib/$(VARIANT)-i2p-browser_en-US
	install -m755 bin/$(VARIANT)-i2p-browser /usr/bin/$(VARIANT)-i2p-browser
	ln -s /usr/bin/$(VARIANT)-i2p-browser /usr/bin/$(VARIANT)i2pbrowser
	chown -R i2pbrowser /var/lib/$(VARIANT)-i2p-browser_en-US
	chmod -R o-rwx /var/lib/$(VARIANT)-i2p-browser_en-US
	chmod a+x /usr/bin/start-i2p-browser

checkinstall: postinstall-pak postremove-pak description-pak
	fakeroot-ng checkinstall --default \
		--install=no \
		--fstrans=yes \
		--maintainer=problemsolver@openmailbox.org \
		--pkgname="$(VARIANT)-i2p-browser" \
		--pkgversion="$(PKG_VERSION)" \
		--arch "$(UARCH)" \
		--pkggroup=net \
		--pkgsource=./ \
		--pkgaltsource="https://github.com/eyedeekay/i2p-browser-for-cheaters" \
		--deldoc=yes \
		--deldesc=yes \
		--delspec=yes \
		--backup=no \
		--pakdir=./

postinstall-pak:
	@echo "#! /bin/sh" | tee postinstall-pak
	@echo "adduser --system --home /var/lib/$(VARIANT)-i2p-browser_en-US --disabled-login --disabled-password --gecos ',,,,' i2pbrowser; true" | tee -a postinstall-pak
	@echo "exit 0" | tee -a postinstall-pak
	chmod +x postinstall-pak

postremove-pak:
	@echo "#! /bin/sh" | tee postremove-pak
	@echo "deluser i2pbrowser; true" | tee -a postremove-pak
	@echo "exit 0" | tee -a postremove-pak
	chmod +x postremove-pak

description-pak:
	@echo "$(VARIANT)-i2p-browser" | tee description-pak
	@echo "" | tee -a description-pak
	@echo "A modified TorBrowser that uses i2p instead." | tee -a description-pak
