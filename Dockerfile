FROM ubuntu:trusty as ipxe

# Dependencies
RUN apt-get update && apt-get install -y git make gcc liblzma-dev syslinux \
                                         genisoimage gcc-aarch64-linux-gnu \
                                         binutils-dev binutils-aarch64-linux-gnu

# Make directories
RUN mkdir -p /usr/pxeboot/build/ipxe

# Project Working Directory
WORKDIR /usr/pxeboot

# Clone iPXE source
RUN git clone --depth 1 https://github.com/ipxe/ipxe.git ipxe

# Copy disk configurations to iPXE source
COPY ./ipxe/disks/* ./ipxe/disks/

# Copy local configuration to iPXE source
COPY ./ipxe/local/* ./ipxe/src/config/local/

# Copy local certificates to iPXE source
COPY .ssh/*.crt ./ipxe/src/

# iPXE Repo Directory
WORKDIR /usr/pxeboot/ipxe

# Set iPXE env hash
RUN export IPXE_HASH=$(git log -n 1 --pretty=format:"%H")

# iPXE Source Directory
WORKDIR /usr/pxeboot/ipxe/src

# Make D9 PXE BOOTLOADER disks
RUN make bin/ipxe.dsk bin/ipxe.iso bin/ipxe.lkrn bin/ipxe.usb bin/ipxe.kpxe bin/undionly.kpxe \
    EMBED=../../ipxe/disks/d9pxeboot TRUST=ca-ipxe-org.crt,d9pxeboot.crt
RUN mv bin/ipxe.dsk ../../build/ipxe/d9pxeboot.dsk
RUN mv bin/ipxe.iso ../../build/ipxe/d9pxeboot.iso
RUN mv bin/ipxe.lkrn ../../build/ipxe/d9pxeboot.lkrn
RUN mv bin/ipxe.usb ../../build/ipxe/d9pxeboot.usb
RUN mv bin/ipxe.kpxe ../../build/ipxe/d9pxeboot.kpxe
RUN mv bin/undionly.kpxe ../../build/ipxe/d9pxeboot-undionly.kpxe

# Make D9 PXE BOOTLOADER disk for Google Compute Engine
#RUN make bin/ipxe.usb CONFIG=cloud EMBED=../../ipxe/disks/d9pxeboot-gce \
#    TRUST=ca-ipxe-org.crt,d9pxeboot.crt
#RUN cp -f bin/ipxe.usb disk.raw
#RUN tar Sczvf d9pxeboot-gce.tar.gz disk.raw
#RUN mv d9pxeboot-gce.tar.gz ../../build/ipxe/d9pxeboot-gce.tar.gz

# Make D9 PXE BOOTLOADER disk for Packet
#RUN make bin/undionly.kpxe EMBED=../../ipxe/disks/d9pxeboot-packet \
#    TRUST=ca-ipxe-org.crt,d9pxeboot.crt
#RUN mv bin/undionly.kpxe ../../build/ipxe/d9pxeboot-packet.kpxe

# Make D9 PXE BOOTLOADER disk for Packet-arm64
#RUN make clean
#RUN make CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm64 \
#    EMBED=../../ipxe/disks/d9pxeboot-packet TRUST=ca-ipxe-org.crt,d9pxeboot.crt \
#    bin-arm64-efi/snp.efi
#RUN mv bin-arm64-efi/snp.efi ../../build/ipxe/d9pxeboot-packet-arm64.efi

# Make D9 PXE BOOTLOADER disks for EFI
RUN cp config/local/general.h.efi config/local/general.h
RUN make clean
RUN make bin-x86_64-efi/ipxe.efi EMBED=../../ipxe/disks/d9pxeboot \
    TRUST=ca-ipxe-org.crt,d9pxeboot.crt
RUN mkdir -p efi_tmp/EFI/BOOT/
RUN cp bin-x86_64-efi/ipxe.efi efi_tmp/EFI/BOOT/bootx64.efi
RUN genisoimage -o ipxe.eiso efi_tmp
RUN mv bin-x86_64-efi/ipxe.efi ../../build/ipxe/d9pxeboot.efi
RUN mv ipxe.eiso ../../build/ipxe/d9pxeboot-efi.iso

# Make D9 PXE BOOTLOADER disks for EFI-arm64
RUN make clean
RUN make CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm64 \
    EMBED=../../ipxe/disks/d9pxeboot TRUST=ca-ipxe-org.crt,d9pxeboot.crt \
    bin-arm64-efi/snp.efi
RUN mv bin-arm64-efi/snp.efi ../../build/ipxe/d9pxeboot-arm64.efi

# Make D9 PXE BOOTLOADER for arm64 experimental
#RUN cp config/local/nap.h.efi config/local/nap.h
#RUN cp config/local/usb.h.efi config/local/usb.h
#RUN make clean
#RUN make CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm64 \
#    EMBED=../../ipxe/disks/d9pxeboot TRUST=ca-ipxe-org.crt,d9pxeboot.crt \
#    bin-arm64-efi/snp.efi
#RUN mv bin-arm64-efi/snp.efi ../../build/ipxe/d9pxeboot-arm64-experimental.efi

# Project Working Directory
WORKDIR /usr/pxeboot

#RUN ./script/prep-release.sh
