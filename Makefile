
browser=$(PWD)/browser
BROWSER_VERSION ?= $(shell curl https://www.torproject.org/projects/torbrowser.html.en 2>&1 | grep '<th>GNU/Linux<br>' | sed 's|<th>GNU/Linux<br><em>(||g' | sed 's|)</em></th>||g' | tr -d ' ')
PORT=4444

DI_PORT=4443
PKG_VERSION = 0.$(BROWSER_VERSION)

#VARIANT = cheaters
VARIANT = di

DISPLAY = :0

all: clean docker-browser browse docker-copy docker-clean unpack shasum sigsum checkinstall

docker-browser:
	docker build --force-rm \
		--build-arg VERSION="$(BROWSER_VERSION)" \
		--build-arg PORT="$(PORT)" \
		-f Dockerfile -t eyedeekay/i2p-browser .

docker-dibrowser:
	docker build --force-rm \
		--build-arg VERSION="$(BROWSER_VERSION)" \
		--build-arg PORT="$(DI_PORT)" \
		-f Dockerfile -t eyedeekay/dii2p-browser .

browse:
	docker run --rm -i -t -d \
		-e DISPLAY=$(DISPLAY) \
		-e VERSION="$(BROWSER_VERSION)" \
		--net host \
		--name i2p-browser \
		--volume /tmp/.X11-unix:/tmp/.X11-unix:ro \
		--volume $(browser):/home/anon/tor-browser_en-US/Browser/Desktop \
		eyedeekay/i2p-browser; true

dibrowse:
	docker run --rm -i -t -d \
		-e DISPLAY=$(DISPLAY) \
		-e VERSION="$(BROWSER_VERSION)" \
		--net host \
		--name dii2p-browser \
		--volume /tmp/.X11-unix:/tmp/.X11-unix:ro \
		--volume $(browser):/home/anon/tor-browser_en-US/Browser/Desktop \
		eyedeekay/dii2p-browser; true

docker-copy:
	docker cp i2p-browser:/home/anon/i2p-browser.tar.gz cheaters-i2p-browser_0.$(BROWSER_VERSION).tar.gz

docker-dicopy:
	docker cp dii2p-browser:/home/anon/i2p-browser.tar.gz di-i2p-browser_0.$(BROWSER_VERSION).tar.gz

docker-clean:
	docker rm -f i2p-browser

clean:
	rm -rf *.tar.gz Browser *.desktop i2p-browser_en-US

unpack:
	tar -xzf cheaters-i2p-browser_0.$(BROWSER_VERSION).tar.gz
	mv i2p-browser_en-US cheaters-i2p-browser_en-US

di-unpack:
	tar -xzf di-i2p-browser_0.$(BROWSER_VERSION).tar.gz
	mv i2p-browser_en-US di-i2p-browser_en-US

run:
	./i2p-browser_en-US/Browser/start-i2p-browser

shasum:
	sha256sum $(VARIANT)-i2p-browser_0.$(BROWSER_VERSION).tar.gz 2>&1 | tee cheaters-i2p-browser_0.$(BROWSER_VERSION).tar.gz.sha256sum

sigsum:
	gpg --batch --clear-sign -u "$(SIGNING_KEY)" $(VARIANT)-i2p-browser_0.$(PKG_VERSION).tar.gz.sha256sum

user:
	adduser --home /var/lib/i2p-browser_en-US --disabled-login --disabled-password --gecos ',,,,' i2pbrowser; true

install: user
	rm -rf /var/lib/i2p-browser_en-US
	cp -Rv $(VARIANT)-i2p-browser_en-US /var/lib/$(VARIANT)-i2p-browser_en-US
	install -m755 bin/start-i2p-browser /usr/bin/start-i2p-browser
	ln -s /usr/bin/start-i2p-browser /usr/bin/i2pbrowser
	chown -R i2pbrowser /var/lib/i2p-browser_en-US
	chmod -R o-rwx /var/lib/i2p-browser_en-US
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
	@echo "adduser --system --home /var/lib/i2p-browser_en-US --disabled-login --disabled-password --gecos ',,,,' i2pbrowser; true" | tee -a postinstall-pak
	@echo "exit 0" | tee -a postinstall-pak
	chmod +x postinstall-pak

postremove-pak:
	@echo "#! /bin/sh" | tee postremove-pak
	@echo "deluser i2pbrowser; true" | tee -a postremove-pak
	@echo "exit 0" | tee -a postremove-pak
	chmod +x postremove-pak

description-pak:
	@echo "cheaters-i2p-browser" | tee description-pak
	@echo "" | tee -a description-pak
	@echo "A modified TorBrowser that uses i2p instead." | tee -a description-pak
