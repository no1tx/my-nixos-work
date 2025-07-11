{ stdenv, lib, fetchgit, linuxKernel, kernel ? linuxKernel.kernels.linux_6_6
, version ? "f30643972f47f63f340e49aadddbcb61729dac03" }:

stdenv.mkDerivation {

  inherit version;
  name = "sna-hda-codec-cs8409-${version}-module-${kernel.modDirVersion}";

  # Upstream: https://github.com/davidjo/snd_hda_macbookpro

  src = fetchgit {
    url = "https://github.com/no1tx/snd-hda-macbookpro.git";
    rev = version;
    sha256 = "sha256-wZbRcen6uLahb/goX4t2ECtzv8XqZ6kRPN8bp1NTCR0=";
  };

  hardeningDisable = [ "pic" ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  NIX_CFLAGS_COMPILE = [ "-g" "-Wall" "-Wno-unused-variable" "-Wno-unused-function" ];

  makeFlags = kernel.makeFlags ++ [
    "INSTALL_MOD_PATH=$(out)"
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  postPatch = ''
    printf '
    snd-hda-codec-cs8409-objs := patch_cs8409.o patch_cs8409-tables.o
    obj-$(CONFIG_SND_HDA_CODEC_CS8409) += snd-hda-codec-cs8409.o

    KBUILD_EXTRA_CFLAGS = "-DAPPLE_PINSENSE_FIXUP -DAPPLE_CODECS -DCONFIG_SND_HDA_RECONFIG=1"

    KERNELRELEASE ?= $(shell uname -r)
    KERNEL_DIR    ?= /lib/modules/$(KERNELRELEASE)/build
    PWD           := $(shell pwd)

    default:
    	make -C $(KERNEL_DIR) M=$(PWD) CFLAGS_MODULE=$(KBUILD_EXTRA_CFLAGS)

    install:
    	make -C $(KERNEL_DIR) M=$(PWD) modules_install
    ' \
    > Makefile

    sed --in-place 's|<sound/cs42l42.h>|"${kernel.dev}/lib/modules/${kernel.modDirVersion}/source/include/sound/cs42l42.h"|'  patch_cs8409.h
    sed --in-place 's|hda_local.h|${kernel.dev}/lib/modules/${kernel.modDirVersion}/source/sound/pci/hda/hda_local.h|'                                                      patch_cs8409.h
    sed --in-place 's|hda_jack.h|${kernel.dev}/lib/modules/${kernel.modDirVersion}/source/sound/pci/hda/hda_jack.h|'                                                        patch_cs8409.h
    sed --in-place 's|hda_generic.h|${kernel.dev}/lib/modules/${kernel.modDirVersion}/source/sound/pci/hda/hda_generic.h|'                                                  patch_cs8409.h
    sed --in-place 's|hda_auto_parser.h|${kernel.dev}/lib/modules/${kernel.modDirVersion}/source/sound/pci/hda/hda_auto_parser.h|'                                          patch_cs8409.h
  '';

  meta = { platforms = lib.platforms.linux; };
}