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

  makeFlags = []; # отключаем, неэффективны в этом контексте

  buildPhase = ''
    mkdir -p build/kernel_sources
    mkdir -p build/sound/pci/hda

    # Копируем только нужные файлы ядра, которые будут патчиться
    cp ${kernelSrc}/sound/pci/hda/patch_cs8409.c build/kernel_sources/
    cp ${kernelSrc}/sound/pci/hda/patch_cs8409.h build/kernel_sources/

    cd build

    # Применяем патчи
    patch -p1 < ${moduleSrc}/patch_patch_cs8409.c.diff
    patch -p1 < ${moduleSrc}/patch_patch_cs8409.h.diff

    # Копируем патченные файлы
    cp kernel_sources/patch_cs8409.c sound/pci/hda/
    cp kernel_sources/patch_cs8409.h sound/pci/hda/

    # Копируем Makefile
    cp ${moduleSrc}/Makefile sound/pci/hda/

    # Переход в рабочий каталог
    cd sound/pci/hda

    export KERNEL_DIR=${kernelSrc}/lib/modules/${kernel.modDirVersion}/build
    export KERNELRELEASE=${kernel.modDirVersion}
    export INSTALL_MOD_PATH=$out

    make
    make modules_install
  '';

  installPhase = "true";

  meta = with lib; {
    description = "Patched snd-hda-codec-cs8409 kernel module for MacBookPro audio";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };
}
