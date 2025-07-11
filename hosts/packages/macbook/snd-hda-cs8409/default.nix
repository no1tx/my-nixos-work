{ stdenv, lib, fetchgit, linuxKernel, kernel ? linuxKernel.kernels.linux_6_12
, version ? "259cc39e243daef170f145ba87ad134239b5967f" }:

stdenv.mkDerivation {

  inherit version;
  name = "snd-hda-codec-cs8409-${version}-module-${kernel.modDirVersion}";

  src = fetchgit {
    url = "https://github.com/davidjo/snd_hda_macbookpro.git";
    rev = version;
    sha256 = "sha256-M1dE4QC7mYFGFU3n4mrkelqU/ZfCA4ycwIcYVsrA4MY=";
  };

  patches = [
    ./patch_patch_cs8409.c.diff
    ./patch_patch_cs8409.h.diff
    ./patch_patch_cirrus_apple.h.diff
  ];

  hardeningDisable = [ "pic" ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  NIX_CFLAGS_COMPILE = [ "-g" "-Wall" "-Wno-unused-variable" "-Wno-unused-function" ];

  makeFlags = kernel.makeFlags ++ [
    "INSTALL_MOD_PATH=$(out)"
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  # Подготовка Makefile и исправление include-путей в patch_cs8409.h
  postPatch = ''
    # Создаем Makefile вручную, аналогично скрипту
    cat > Makefile << EOF
snd-hda-codec-cs8409-objs := patch_cs8409.o patch_cs8409-tables.o
obj-$(CONFIG_SND_HDA_CODEC_CS8409) += snd-hda-codec-cs8409.o

KBUILD_EXTRA_CFLAGS := -DAPPLE_PINSENSE_FIXUP -DAPPLE_CODECS -DCONFIG_SND_HDA_RECONFIG=1

default:
	\$(MAKE) -C \$(KERNEL_DIR) M=\$(PWD) CFLAGS_MODULE="\$(KBUILD_EXTRA_CFLAGS)"

install:
	\$(MAKE) -C \$(KERNEL_DIR) M=\$(PWD) modules_install
EOF

    # Исправляем пути include в patch_cs8409.h для корректной сборки с исходниками ядра
    sed -i "s|<sound/cs42l42.h>|${kernel.dev}/lib/modules/${kernel.modDirVersion}/source/include/sound/cs42l42.h|" patch_cs8409.h
    sed -i "s|hda_local.h|${kernel.dev}/lib/modules/${kernel.modDirVersion}/source/sound/pci/hda/hda_local.h|" patch_cs8409.h
    sed -i "s|hda_jack.h|${kernel.dev}/lib/modules/${kernel.modDirVersion}/source/sound/pci/hda/hda_jack.h|" patch_cs8409.h
    sed -i "s|hda_generic.h|${kernel.dev}/lib/modules/${kernel.modDirVersion}/source/sound/pci/hda/hda_generic.h|" patch_cs8409.h
    sed -i "s|hda_auto_parser.h|${kernel.dev}/lib/modules/${kernel.modDirVersion}/source/sound/pci/hda/hda_auto_parser.h|" patch_cs8409.h
  '';


  meta = with lib; {
    description = "Patched snd-hda-codec-cs8409 kernel module for MacBookPro audio";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ no1tx ];
  };
}
