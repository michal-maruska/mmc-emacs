
pkgname=mmc-emacs
install=install
pkgdir=$(DESTDIR)/usr/share/emacs/site-lisp/$(pkgname)


# todo: compile!
all:


install:
	$(install) -d   $(pkgdir)
	$(install) --mode=444 *.el $(pkgdir)


clean:
	rm -f *.elc
#	@echo "nothing to do to clean"
# [ -d .git ] && git clean -f -d -x

