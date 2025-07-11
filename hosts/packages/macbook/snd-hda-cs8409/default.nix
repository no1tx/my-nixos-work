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
    cp ${kernelSrc}/sound/pci/hda/patch_cs8409.c build/kernel_sources/
    cp ${kernelSrc}/sound/pci/hda/patch_cs8409.h build/kernel_sources/
    cp ${kernelSrc}/sound/pci/hda/patch_cirrus_apple.h build/kernel_sources/

    # Копируем патчи в patch_cirrus с именами, как в патче
    cp ${moduleSrc}/patch_patch_cs8409.c.diff build/patch_cirrus/patch_cs8409.c
    cp ${moduleSrc}/patch_patch_cs8409.h.diff build/patch_cirrus/patch_cs8409.h
    cp ${moduleSrc}/patch_patch_cirrus_apple.h.diff build/patch_cirrus/patch_cirrus_apple.h

    cd build

    # Применяем патчи с -p1 (удаляем только первый элемент 'a/')
    patch -p1 < patch_patch_cs8409.c.diff
    patch -p1 < patch_patch_cs8409.h.diff
    patch -p1 < patch_patch_cirrus_apple.h.diff

    # Потом копируем файлы из kernel_sources в sound/pci/hda/
    mkdir -p sound/pci/hda
    cp kernel_sources/* sound/pci/hda/

    # Теперь копируем исходники модуля из moduleSrc
    cp ${moduleSrc}/*.c sound/pci/hda/
    cp ${moduleSrc}/*.h sound/pci/hda/
    cp ${moduleSrc}/Makefile sound/pci/hda/

    cd sound/pci/hda

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
