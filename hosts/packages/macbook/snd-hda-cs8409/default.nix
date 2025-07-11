{ stdenv, lib, fetchgit, kernel ? linuxKernel.kernels.linux_6_12
, version ? "f30643972f47f63f340e49aadddbcb61729dac03" }:

let
  moduleSrc = fetchgit {
    url = "https://github.com/davidjo/snd-hda-macbookpro.git";
    rev = version;
    sha256 = "sha256-wZbRcen6uLahb/goX4t2ECtzv8XqZ6kRPN8bp1NTCR0=";
  };

  kernelSrc = kernel.dev;

in stdenv.mkDerivation {
  name = "snd-hda-codec-cs8409-module-${version}-${kernel.modDirVersion}";
  inherit version;

  src = moduleSrc;

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernel.makeFlags ++ [
    "INSTALL_MOD_PATH=$(out)"
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KERNEL_DIR=${kernelSrc}/lib/modules/${kernel.modDirVersion}/build"
  ];

  buildPhase = ''
    mkdir -p build
    cp -r ${kernelSrc}/lib/modules/${kernel.modDirVersion}/source/sound/pci/hda build/

    # Применяем патчи из src
    patch -d build/sound/pci/hda -p1 < ${src}/patch_patch_cs8409.c.diff
    patch -d build/sound/pci/hda -p1 < ${src}/patch_patch_cs8409.h.diff
    patch -d build/sound/pci/hda -p1 < ${src}/patch_patch_cirrus_apple.h.diff

    cp ${src}/*.c build/sound/pci/hda/
    cp ${src}/*.h build/sound/pci/hda/
    cp ${src}/Makefile build/sound/pci/hda/

    cd build/sound/pci/hda

    make KERNELRELEASE=${kernel.modDirVersion} KERNEL_DIR=${kernelSrc}/lib/modules/${kernel.modDirVersion}/build
    make INSTALL_MOD_PATH=$(out) modules_install
  '';

  installPhase = "true";

  meta = with lib; {
    description = "Patched snd-hda-codec-cs8409 kernel module for MacBookPro audio";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };
}
