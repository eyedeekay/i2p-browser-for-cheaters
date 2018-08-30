
UNAME ?= $(shell uname -s | tr '[:upper:]' '[:lower:]')
UARCH ?= $(shell uname -m | tr '[:upper:]' '[:lower:]' | sed 's|x86_64|amd64|g')

browser=$(PWD)/browser

UPDATE_URL=https://www.torproject.org/projects/torbrowser/RecommendedTBBVersions

#COMMENT THE FOLLOWING LINE IF YOU WANT TO USE THE EXPERIMENTAL TBB
BROWSER_VERSION=$(shell curl $(UPDATE_URL) 2> /dev/null | grep -vi macos | grep -vi windows | grep -vi linux | head -n 2 | tail -n 1 | tr -d '",')

#UNCOMMENT THE FOLLOWING LINES IF YOU WANT TO USE THE EXPERIMENTAL TBB
#BROWSER_VERSION=8.0a10

DEFAULT_PORT=4444
DEFAULT_ADDR=127.0.0.1

VARIANT=cheaters
PORT=$(DEFAULT_PORT)

PKG_VERSION=0.$(EXPERIMENTAL)$(BROWSER_VERSION)

DISPLAY=:0

TOR_CONTROL_IPC_PATH=/var/run/cheater-i2p-browser_en-US/i2p.sock

echo:
	@echo "Building variant: $(VARIANT):$(PORT)"
	@echo "$(BROWSER_VERSION) $(PKG_VERSION) $(browser)"

all: cheater di privoxy

build: echo clean docker-browser browse docker-copy docker-clean unpack checkinstall shasum sigsum

torbrowser: tbb$(BROWSER_VERSION).tar.xz

tbb$(BROWSER_VERSION).tar.xz:
	/usr/bin/wget -c -O tbb$(BROWSER_VERSION).tar.xz "https://www.torproject.org/dist/torbrowser/"$(BROWSER_VERSION)"/tor-browser-linux64-"$(BROWSER_VERSION)"_en-US.tar.xz"
	/usr/bin/wget -c -O tbb$(BROWSER_VERSION).tar.xz.asc "https://www.torproject.org/dist/torbrowser/"$(BROWSER_VERSION)"/tor-browser-linux64-"$(BROWSER_VERSION)"_en-US.tar.xz.asc"

checksig: torbrowser
	gpg --keyserver ha.pool.sks-keyservers.net \
      --recv-keys "EF6E 286D DA85 EA2A 4BA7  DE68 4E2C 6E87 9329 8290"
	gpg --verify tbb$(BROWSER_VERSION).tar.xz.asc || rm tbb$(BROWSER_VERSION).tar.xz

download: torbrowser checksig
	rm -rf $(browser) && mkdir -p $(browser)
	cd $(browser) && \
		tar xf ../tbb$(BROWSER_VERSION).tar.xz

easy: download
	./setup-i2p-browser.sh ./browser/tor-browser_en-US $(DEFAULT_PORT) $(DEFAULT_ADDR)

easysocket: download
	./setup-i2p-browser.sh ./browser/tor-browser_en-US "socket"

run:
	$(browser)/tor-browser_en-US/Browser/start-i2p-browser

cheater:
	VARIANT=cheaters PORT=4444 make build

di:
	VARIANT=di PORT=4443 make build

privoxy:
	VARIANT=privoxy PORT=8118 make build

release: release-cheater release-di release-privoxy

release-cheater:
	VARIANT=cheaters PORT=4444 make cheater upload-cheater

release-di:
	VARIANT=di PORT=4443 make di upload-di

release-privoxy:
	VARIANT=privoxy PORT=8118 make privoxy upload-privoxy

all-upload: upload-cheater upload-di upload-privoxy

upload-cheater:
	VARIANT=cheaters PORT=4444 make upload

upload-di:
	VARIANT=di PORT=4443 make upload

upload-privoxy:
	VARIANT=privoxy PORT=8118 make upload

docker-browser:
	docker build --force-rm \
		--build-arg BROWSER_VERSION="$(BROWSER_VERSION)" \
		--build-arg PORT="$(PORT)" \
		-f Dockerfile -t eyedeekay/$(VARIANT)i2p-browser .

browse:
	docker run --rm -i -t \
		-e DISPLAY=$(DISPLAY) \
		-e BROWSER_VERSION="$(BROWSER_VERSION)" \
		--net host \
		--name i2p-browser \
		--volume /tmp/.X11-unix:/tmp/.X11-unix:ro \
		eyedeekay/$(VARIANT)i2p-browser

docker-copy:
	docker cp i2p-browser:/home/anon/i2p-browser.tar.gz $(VARIANT)-i2p-browser_$(PKG_VERSION).tar.gz

docker-clean:
	docker rm -f i2p-browser; true

docker-clobber:
	docker rmi -f eyedeekay/$(VARIANT)i2p-browser

docker-clobber-all:
	docker rmi -f eyedeekay/cheatersi2p-browser eyedeekay/dii2p-browser

clean:
	rm -rf $(VARIANT)*-i2p-browser_$(PKG_VERSION).tar.gz $(VARIANT)*-i2p-browser_en-US $(VARIANT)*-i2p-browser_$(PKG_VERSION)*.asc $(VARIANT)*-i2p-browser_$(PKG_VERSION)*.deb $(VARIANT)*-i2p-browser_$(PKG_VERSION)*.sha256sum $(browser)/* *.tar.xz *.asc

unpack:
	tar -xzf $(VARIANT)-i2p-browser_$(PKG_VERSION).tar.gz
	mv i2p-browser_en-US $(VARIANT)-i2p-browser_en-US

shasum:
	sha256sum $(VARIANT)-i2p-browser_$(PKG_VERSION).tar.gz 2>&1 | tee $(VARIANT)-i2p-browser_$(PKG_VERSION).tar.gz.sha256sum

sigsum:
	gpg --batch --clear-sign -u "$(SIGNING_KEY)" $(VARIANT)-i2p-browser_$(PKG_VERSION).tar.gz.sha256sum

user:
	adduser --home /var/lib/$(VARIANT)-i2p-browser_en-US --disabled-login --disabled-password --gecos ',,,,' i2pbrowser; true

install:
	install -d -o i2pbrowser -g i2pbrowser -m700 /var/run/$(VARIANT)-i2p-browser_en-US /var/lib/$(VARIANT)-i2p-browser_en-US
	cp -Rv $(VARIANT)-i2p-browser_en-US /var/lib/$(VARIANT)-i2p-browser_en-US
	install -m755 bin/$(VARIANT)-i2p-browser /usr/bin/$(VARIANT)-i2p-browser
	ln -sf /usr/bin/$(VARIANT)-i2p-browser /usr/bin/$(VARIANT)i2pbrowser
	chmod a+x /usr/bin/start-i2p-browser

remove:
	rm -rf /var/run/$(VARIANT)-i2p-browser_en-US \
		/var/lib/$(VARIANT)-i2p-browser_en-US \
		/usr/bin/$(VARIANT)-i2p-browser \
		/usr/bin/$(VARIANT)i2pbrowser

remove-all:
	make remove; true
	VARIANT=di make remove; true
	VARIANT=privoxy make remove; true


checkinstall: postinstall-pak postremove-pak description-pak
	fakeroot-ng checkinstall --default \
		--install=no \
		--fstrans=yes \
		--maintainer=eyedeekay@safe-mail.net \
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

delrelease:
	"$(GITHUB_RELEASE_PATH)" delete --user eyedeekay \
		--repo "i2p-browser-for-cheaters" \
		--tag "$(VARIANT)-i2p-browser-$(PKG_VERSION)"; true


createrelease:
	"$(GITHUB_RELEASE_PATH)" release --user eyedeekay \
		--repo "i2p-browser-for-cheaters" \
		--tag "$(VARIANT)-i2p-browser-$(PKG_VERSION)" \
		--description "TBB modified to use i2p instead; $(VARIANT) version"

rerelease: delrelease createrelease

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
	VARIANT=di PORT=4443 make filterbranch
	git gc --prune=now
	git commit -am "Filtering large file from branch"; true

filter-privoxy:
	git commit -am "Filtering large file from branch"; true
	VARIANT=privoxy PORT=8118 make filterbranch
	git gc --prune=now
	git commit -am "Filtering large file from branch"; true

filter: filter-cheater filter-di filter-privoxy

overrides:
	cp ./cheaters-i2p-browser_en-US/Browser/TorBrowser/Data/Browser/profile.default/preferences/extension-overrides.js ./extension-overrides.js

cleanbranches:
	rm -rf .git/refs/original/
	git reflog expire --expire=now --all
	git fsck --full --unreachable
	git repack -A -d
	git gc --aggressive --prune=now

issue:
	surf https://forums.whonix.org/t/i2p-integration/4981/140

socket:
	./bin/assure-socket-$(VARIANT)

.checkforum:
	torsocks pandoc -t markdown https://forums.whonix.org/t/i2p-integration/4981/1000 > .checkforum || rm .checkforum
	cat .checkforum

.diffcheck: .checkforum
	torsocks pandoc -t markdown https://forums.whonix.org/t/i2p-integration/4981/1000 > .diffcheck || rm .diffcheck
	diff .checkforum .diffcheck && mv .diffcheck .checkforum

diffcheck: .diffcheck

index:
	@echo '<!DOCTYPE html>' | tee i2p-diffs.html
	@echo '<html>' | tee -a i2p-diffs.html
	@echo '    <title>Unofficial i2p Browser</title>' | tee -a i2p-diffs.html
	@echo '<body>' | tee -a i2p-diffs.html
	@echo '<style>' | tee -a i2p-diffs.html
	@echo '    body {background-color: khaki; border: 3px dotted sienna; font-family: monospace; margin-left: auto; margin-right: auto; width: 80%; font-size: 14px;}' | tee -a i2p-diffs.html
	@echo '    h1 {color: greenviolet; border: 10px solid seagreen; text-align: center; background-color: gold; margin-left: auto; margin-right: auto; width: 50%; font-size: 30px;}' | tee -a i2p-diffs.html
	@echo '    h2 {color: darkviolet; border: 10px dotted darksalmon; text-align: center; background-color: gold; margin-left: auto; margin-right: auto; width: 50%; font-size: 24px;}' | tee -a i2p-diffs.html
	@echo '    p {color: indigo; border: 3px solid seagreen; margin-left: auto; margin-right: auto; width: 80%;}' | tee -a i2p-diffs.html
	@echo '</style>' | tee -a i2p-diffs.html
	markdown WARNING.md | tee -a i2p-diffs.html
	@echo '</body>' | tee -a i2p-diffs.html
	@echo '</html>' | tee -a i2p-diffs.html

profile:
	rm -rf ../tb-profile-i2p/var/lib/tb-profile-i2p/profile.i2p/
	mkdir -p ../tb-profile-i2p/var/lib/tb-profile-i2p/profile.i2p/
	cp -rv ./browser/tor-browser_en-US/Browser/TorBrowser/Data/Browser/profile.i2p/ ../tb-profile-i2p/var/lib/tb-profile-i2p/profile.i2p/
