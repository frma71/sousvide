BAUD	?= 9600
PORT	?= /dev/ttyUSB0
FILES = svc.lua svcweb.lua inittest.lua index.html init.lua config.html



upload: $(addprefix .stamps/,$(FILES))

clean:
	rm -rf .stamps

.stamps/%: %
	mkdir -p .stamps
	./luatool.py -b $(BAUD) -p $(PORT) -f $< -t $< && touch $@

.stamps/svc.lua: svc.lua
	mkdir -p .stamps
	./luatool.py -b $(BAUD) -p $(PORT) -f $< -t $< && touch $@
