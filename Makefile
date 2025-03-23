VFLAGS=
ifeq (1,${RELEASE})
	VFLAGS:=$(VFLAGS) -prod
endif
ifeq (1,${MACOS_ARM})
	VFLAGS:=-cflags "-target arm64-apple-darwin" $(VFLAGS)
endif
ifeq (1,${LINUX_ARM})
	VFLAGS:=-cc aarch64-linux-gnu-gcc $(VFLAGS)
endif
ifeq (1,${LINUX_RISCV})
	VFLAGS:=-cc riscv64-linux-gnu-gcc $(VFLAGS)
endif
ifeq (1,${WINDOWS})
	VFLAGS:=-os windows $(VFLAGS)
endif

all: check build test

check:
	v fmt -w .
	v vet .

build:
	v $(VFLAGS) -o newchanges .

test:
	v test .
	./test.sh

clean:
	rm -rf src/*_test src/*.dSYM vp
