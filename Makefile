VFLAGS=
ifeq (1,${RELEASE})
	VFLAGS:=$(VFLAGS) -prod
endif
ifeq (1,${ARM})
	VFLAGS:=-cflags "-target arm64-apple-darwin" $(VFLAGS)
endif

all: check build test

check:
	v fmt -w .
	v vet .

build:
	v $(VFLAGS) -o newchanges .

test:
	v -use-os-system-to-run test .
	./test.sh
