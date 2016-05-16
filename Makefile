default: build-image

require-%:
	@ if [ "${${*}}" = "" ]; then \
		echo "Variable $* not set"; \
		exit 1; \
	fi

clean:
	rm -f build/*

build-docker-image:
	docker build -t rootfs-builder .

download-archlinux-latest:
ifeq ($(wildcard archlinux-latest/ArchLinuxARM-rpi-2-latest.tar.gz),)
	wget -O archlinux-latest/ArchLinuxARM-rpi-2-latest.tar.gz https://archlinuxarm.org/os/ArchLinuxARM-rpi-2-latest.tar.gz
endif

rpi2: clean download-archlinux-latest build-docker-image require-USER_NAME require-USER_SSH_KEY
	docker run -e USERNAME="$(USER_NAME)" -e PASSWORD="$(USER_PASSWORD)" -e SSH_KEY="$(USER_SSH_KEY)" -e BUILD_NUMBER="$(BUILD_NUMBER)" \
		 --net=host --rm -v $(shell pwd)/build:/image -v $(shell pwd)/archlinux-latest:/archlinuxlatest --privileged rootfs-builder
