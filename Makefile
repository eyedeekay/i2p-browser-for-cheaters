

browser=$(PWD)/browser
BROWSER_VERSION ?= $(shell curl https://www.torproject.org/projects/torbrowser.html.en 2>&1 | grep '<th>GNU/Linux<br>' | sed 's|<th>GNU/Linux<br><em>(||g' | sed 's|)</em></th>||g' | tr -d ' ')

DISPLAY = :0

all: clean docker-browser browse docker-copy docker-clean unpack

docker-browser:
	docker build --force-rm --build-arg VERSION="$(BROWSER_VERSION)" \
		-f Dockerfile -t eyedeekay/i2p-browser .

browse:
	docker run --rm -i -t -d \
		-e DISPLAY=$(DISPLAY) \
		-e VERSION="$(BROWSER_VERSION)" \
		--net host \
		--name i2p-browser \
		--volume /tmp/.X11-unix:/tmp/.X11-unix:ro \
		--volume $(browser):/home/anon/tor-browser_en-US/Browser/Desktop \
		eyedeekay/i2p-browser; true

docker-copy:
	docker cp i2p-browser:/home/anon/i2p-browser.tar.gz cheaters-i2p-browser_0.$(BROWSER_VERSION).tar.gz

docker-clean:
	docker rm -f i2p-browser

clean:
	rm -rf *.tar.gz Browser *.desktop i2p-browser_en-US

unpack:
	tar -xzf cheaters-i2p-browser_0.$(BROWSER_VERSION).tar.gz

run:
	./i2p-browser_en-US/Browser/start-i2p-browser
