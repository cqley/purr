include config.mk

SUB = sed -e 's|@HOST@|$(HOST)|g' -e 's|@ROOT@|$(ROOT)|g' -e 's|@DIR@|$(DIR)|g' -e 's|@WWW@|$(WWW)|g'

all: purr.conf

purr.conf: nginx.conf config.mk
	$(SUB) nginx.conf > $@

install:
	mkdir -p $(DESTDIR)$(DIR) $(DESTDIR)$(UNITS)
	for f in ssh.sh web.sh; do \
		{ printf '#!/bin/sh\nPATH=/usr/local/bin:/usr/bin:/bin\nawk() { gawk "$$@"; }\nGITROOT=%s\nGITHOST=%s\nGITSSH=%s\n' '$(ROOT)' '$(HOST)' '$(SSH)'; sed 1,4d $$f; } > $(DESTDIR)$(DIR)/$$f; \
		chmod 755 $(DESTDIR)$(DIR)/$$f; \
	done
	cp git.css git.js theme.js $(DESTDIR)$(DIR)
	chmod 644 $(DESTDIR)$(DIR)/git.css $(DESTDIR)$(DIR)/git.js $(DESTDIR)$(DIR)/theme.js
	$(SUB) purr.socket > $(DESTDIR)$(UNITS)/purr.socket
	$(SUB) purr.service > $(DESTDIR)$(UNITS)/purr.service
	$(SUB) purrtrash.service > $(DESTDIR)$(UNITS)/purrtrash.service
	cp purrtrash.timer $(DESTDIR)$(UNITS)/purrtrash.timer

keys:
	mkdir -p $(ROOT)/.ssh
	awk '/^[A-Za-z0-9_][A-Za-z0-9._-]*[ \t]+(ssh|ecdsa|sk)-/ { o = $$1; sub(/^[^ \t]+[ \t]+/, ""); print "command=\"$(DIR)/ssh.sh " o "\",restrict " $$0 }' users > $(ROOT)/.ssh/authorized_keys
	chown -R git:git $(ROOT)/.ssh
	chmod 700 $(ROOT)/.ssh
	chmod 600 $(ROOT)/.ssh/authorized_keys

uninstall:
	rm -rf $(DESTDIR)$(DIR) $(DESTDIR)$(UNITS)/purr.socket $(DESTDIR)$(UNITS)/purr.service $(DESTDIR)$(UNITS)/purrtrash.service $(DESTDIR)$(UNITS)/purrtrash.timer

clean:
	rm -f purr.conf

.PHONY: all install keys uninstall clean
