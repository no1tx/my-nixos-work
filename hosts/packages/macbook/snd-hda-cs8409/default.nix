{ stdenv, lib, fetchgit, linuxKernel, kernel ? linuxKernel.kernels.linux_6_12
, version ? "259cc39e243daef170f145ba87ad134239b5967f" }:

let
  moduleSrc = fetchgit {
    url = "https://github.com/davidjo/snd_hda_macbookpro.git";
    rev = version;
    sha256 = "sha256-M1dE4QC7mYFGFU3n4mrkelqU/ZfCA4ycwIcYVsrA4MY=";
  };

  kernelSrc = kernel.src;

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
    mkdir -p build/kernel_sources
    mkdir -p build/patch_cirrus

    # Копируем файлы ядра, которые будут патчиться, в kernel_sources
    cp ${kernelSrc}/sound/pci/hda/* build/kernel_sources/

    cd build

    # Применяем патчи из исходников (moduleSrc), без переименования
    patch -p1 < ${moduleSrc}/patch_patch_cs8409.c.diff
    patch -p1 < ${moduleSrc}/patch_patch_cs8409.h.diff

    # Копируем патченные файлы в sound/pci/hda
    mkdir -p sound/pci/hda
    cp kernel_sources/* sound/pci/hda/

    cd sound/pci/hda

    make KERNELRELEASE=${kernel.modDirVersion} \
         KERNEL_DIR=${kernelSrc}/lib/modules/${kernel.modDirVersion}/build
    make INSTALL_MOD_PATH=$out modules_install
  '';

  installPhase = "true";

  meta = with lib; {
    description = "Patched snd-hda-codec-cs8409 kernel module for MacBookPro audio";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };
}
