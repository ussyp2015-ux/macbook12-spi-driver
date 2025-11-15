obj-m += applespi.o
obj-m += apple-ibridge.o
obj-m += apple-ib-tb.o
obj-m += apple-ib-als.o

CFLAGS_applespi.o = -I$(src)	# for tracing

KVERSION := $(KERNELRELEASE)
ifeq ($(origin KERNELRELEASE), undefined)
KVERSION := $(shell uname -r)
endif
KDIR := /lib/modules/$(KVERSION)/build
PWD := $(shell pwd)

all:
	$(MAKE) -C $(KDIR) M=$(PWD) KBUILD_MODPOST_WARN=1 modules


clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean


install:
	$(MAKE) -C $(KDIR) M=$(PWD) KBUILD_MODPOST_WARN=1 modules_install

test: all
	sync
	-rmmod applespi
	insmod ./applespi.ko
