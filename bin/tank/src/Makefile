include arch.make

# Tortunnel
TORTUNNEL_URL=https://github.com/hornos/tortunnel/tarball/master
TORTUNNEL_TGZ=tortunnel.tgz

.PHONY: tortunnel proxychains all

all: tortunnel proxychains

tortunnel:
	if ! test -d ./tortunnel;then     \
	  if ! test -f $(TORTUNNEL_TGZ);then \
	    $(DL) -O $(TORTUNNEL_TGZ) $(TORTUNNEL_URL);fi; \
	  $(TAR) xvzf $(TORTUNNEL_TGZ); \
	  mv ./hornos-tortunnel-* ./tortunnel; fi;
	cd ./tortunnel; ./build

proxchains:
	if ! test -d ./proxychains;then     \
	  if ! test -f $(PROXYCHAINS_TGZ);then \
	    $(DL) -O $(PROXYCHAINS_TGZ) $(PROXYCHAINS_URL);fi; \
	  $(TAR) xvzf $(PROXYCHAINS_TGZ); \
	  mv ./hornos-proxychains-* ./proxychains; fi;
	cd ./proxychains; ./configure CC=gcc-4.2; make

clean:
	rm -f *.tgz
	rm -fR ./tortunnel
	rm -fR ./proxychains
