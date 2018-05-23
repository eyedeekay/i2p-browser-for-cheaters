
UNAME ?= $(shell uname -s | tr '[:upper:]' '[:lower:]')
UARCH ?= $(shell uname -m | tr '[:upper:]' '[:lower:]' | sed 's|x86_64|amd64|g')

browser=$(PWD)/browser
BROWSER_VERSION = $(shell curl https://www.torproject.org/projects/torbrowser.html.en 2>&1 | grep '<th>GNU/Linux<br>' | sed 's|<th>GNU/Linux<br><em>(||g' | sed 's|)</em></th>||g' | tr -d ' ')


PKG_VERSION = 0.$(BROWSER_VERSION)

VARIANT ?= cheaters
#VARIANT ?= di
#VARIANT ?= privoxy

PORT ?= 4444
#PORT ?= 4443
#PORT ?= 8118

DISPLAY = :0

all: cheater di privoxy

echo:
	@echo "Building variant: $(VARIANT):$(PORT)"
	sleep 3

build: echo clean docker-browser browse docker-copy docker-clean unpack shasum sigsum checkinstall

cheater:
	VARIANT=cheaters PORT=4444 make build

di:
	VARIANT=di PORT=4443 make build

privoxy:
	VARIANT=privoxy PORT=8118 make build

all-release: release-cheater release-di release-privoxy

release-cheater:
	VARIANT=cheaters PORT=4444 make release upload

release-di:
	VARIANT=di PORT=4443 make release upload

release-privoxy:
	VARIANT=privoxy PORT=8118 make release upload

release: cheater-release di-release privoxy-release

cheater-release: cheater release-cheater

di-release: di release-di

privoxy-release: privoxy release-privoxy

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
	rm -rf $(VARIANT)-i2p-browser_$(PKG_VERSION).tar.gz $(VARIANT)-i2p-browser_en-US $(VARIANT)-i2p-browser_$(PKG_VERSION)*.asc $(VARIANT)-i2p-browser_$(PKG_VERSION)*.deb $(VARIANT)-i2p-browser_$(PKG_VERSION)*.sha256sum

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

export GITHUB_RELEASE_PATH="$(HOME)/.go/bin/github-release"

release:
	"$(GITHUB_RELEASE_PATH)" release \
		--user eyedeekay \
		--repo "i2p-browser-for-cheaters" \
		--tag "$(VARIANT)-i2p-browser-$(PKG_VERSION)" \
		--name "$(VARIANT)-i2p-browser" \
		--description "A modified Tor Browser Bundle, pre-configured to use i2p."; true

upload:
	"$(GITHUB_RELEASE_PATH)" upload --user eyedeekay \
		--repo "i2p-browser-for-cheaters" \
		--tag "$(VARIANT)-i2p-browser-$(PKG_VERSION)" \
		--replace \
		--name "$(VARIANT)-i2p-browser_$(PKG_VERSION).tar.gz.sha256sum.asc" \
		--file "$(VARIANT)-i2p-browser_$(PKG_VERSION).tar.gz.sha256sum.asc"
	"$(GITHUB_RELEASE_PATH)" upload --user eyedeekay \
		--repo "i2p-browser-for-cheaters" \
		--tag "$(VARIANT)-i2p-browser-$(PKG_VERSION)" \
		--replace \
		--name "$(VARIANT)-i2p-browser_$(PKG_VERSION).tar.gz.sha256sum" \
		--file "$(VARIANT)-i2p-browser_$(PKG_VERSION).tar.gz.sha256sum"
	"$(GITHUB_RELEASE_PATH)" upload --user eyedeekay \
		--repo "i2p-browser-for-cheaters" \
		--tag "$(VARIANT)-i2p-browser-$(PKG_VERSION)" \
		--replace \
		--name "$(VARIANT)-i2p-browser_$(PKG_VERSION).tar.gz" \
		--file "$(VARIANT)-i2p-browser_$(PKG_VERSION).tar.gz"
	"$(GITHUB_RELEASE_PATH)" upload --user eyedeekay \
		--repo "i2p-browser-for-cheaters" \
		--tag "$(VARIANT)-i2p-browser-$(PKG_VERSION)" \
		--replace \
		--name "$(VARIANT)-i2p-browser_$(PKG_VERSION)-1_amd64.deb" \
		--file "$(VARIANT)-i2p-browser_$(PKG_VERSION)-1_amd64.deb"

filterbranch:
	git filter-branch -f --prune-empty -d /dev/shm/scratch --index-filter "git rm --cached -f --ignore-unmatch $(VARIANT)-i2p-browser_$(PKG_VERSION).tar.gz $(VARIANT)-i2p-browser_$(PKG_VERSION)-1_amd64.deb" --tag-name-filter cat -- --all
	git update-ref -d refs/original/refs/heads/master
	git reflog expire --expire=now --all

filter-cheater:
	git commit -am "Filtering large file from branch"; true
	VARIANT=cheaters PORT=4444 make filterbranch
	git gc --prune=now
	git commit -am "Filtering large file from branch"; true

filter-di:
	git commit -am "Filtering large file from branch"; true
	VARIANT=di PORT=4444 make filterbranch
	git gc --prune=now
	git commit -am "Filtering large file from branch"; true

filter-privoxy:
	git commit -am "Filtering large file from branch"; true
	VARIANT=privoxy PORT=4444 make filterbranch
	git gc --prune=now
	git commit -am "Filtering large file from branch"; true

filter: filter-cheater filter-di filter-privoxy

overrides:
	cp ./cheaters-i2p-browser_en-US/Browser/TorBrowser/Data/Browser/profile.default/preferences/extension-overrides.js ./extension-overrides.js
