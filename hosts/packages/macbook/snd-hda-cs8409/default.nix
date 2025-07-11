{ stdenv, lib, fetchgit, linuxKernel, kernel ? linuxKernel.kernels.linux_6_12
, version ? "259cc39e243daef170f145ba87ad134239b5967f" }:

let
  moduleSrc = fetchgit {
    url = "https://github.com/davidjo/snd_hda_macbookpro.git";
    rev = version;
    sha256 = "sha256-M1dE4QC7mYFGFU3n4mrkelqU/ZfCA4ycwIcYVsrA4MY=";
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
    mkdir -p build/sound/pci/
    cp -r ${kernelSrc}/lib/modules/${kernel.modDirVersion}/source/sound/pci/hda build/sound/pci/

    # Применяем патчи из src
    patch -d build/sound/pci/hda -p2 < ${moduleSrc}/patch_patch_cs8409.c.diff
    patch -d build/sound/pci/hda -p2 < ${moduleSrc}/patch_patch_cs8409.h.diff
    patch -d build/sound/pci/hda -p2 < ${moduleSrc}/patch_patch_cirrus_apple.h.diff

    cp ${moduleSrc}/*.c build/sound/pci/hda/
    cp ${moduleSrc}/*.h build/sound/pci/hda/
    cp ${moduleSrc}/Makefile build/sound/pci/hda/

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
