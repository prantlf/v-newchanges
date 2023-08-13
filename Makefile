ifeq (1,${RELEASE})
	VFLAGS=-prod
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
