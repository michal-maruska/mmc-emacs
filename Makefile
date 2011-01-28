
pkgname=mmc-emacs
install=install
pkgdir=$(DESTDIR)/usr/share/emacs/site-lisp/$(pkgname)


# todo: compile!
all:


install:
	$(install) -d   $(pkgdir)
	$(install) *.el $(pkgdir)


clean:
