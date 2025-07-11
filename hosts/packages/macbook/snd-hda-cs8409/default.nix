{ stdenv, lib, fetchgit, linuxKernel, kernel ? linuxKernel.kernels.linux_6_12
, version ? "259cc39e243daef170f145ba87ad134239b5967f" }:

let
  moduleSrc = fetchgit {
    url = "https://github.com/davidjo/snd_hda_macbookpro.git";
    rev = version;
    sha256 = "sha256-M1dE4QC7mYFGFU3n4mrkelqU/ZfCA4ycwIcYVsrA4MY=";
  };

  kernelSrc = kernel.src;
  kernelDev = kernel.dev;

in stdenv.mkDerivation {
  name = "snd-hda-codec-cs8409-module-${version}-${kernel.modDirVersion}";
  inherit version;

  src = moduleSrc;

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = []; # отключаем, неэффективны в этом контексте

  buildPhase = ''
    mkdir -p build/kernel_sources
    mkdir -p build/sound/pci/hda

    # Копируем нужные файлы
    cp ${kernelSrc}/sound/pci/hda/patch_cs8409.c build/kernel_sources/
    cp ${kernelSrc}/sound/pci/hda/patch_cs8409.h build/kernel_sources/

    cd build

    # Патчи
    patch -p1 < ${moduleSrc}/patch_patch_cs8409.c.diff
    patch -p1 < ${moduleSrc}/patch_patch_cs8409.h.diff

    # Копируем патченные файлы
    cp kernel_sources/patch_cs8409.c sound/pci/hda/
    cp kernel_sources/patch_cs8409.h sound/pci/hda/

    # Копируем Makefile
    cp ${moduleSrc}/Makefile sound/pci/hda/

    substituteInPlace sound/pci/hda/Makefile \
    --replace "/lib/modules/\$(KERNELRELEASE)" "${kernelDev}/lib/modules/${kernel.modDirVersion}" \
    --replace "\$(shell pwd)/build/hda" "."

    cd sound/pci/hda

    make \
      KERNEL_DIR=${kernelDev}/lib/modules/${kernel.modDirVersion}/build \
      KERNELRELEASE=${kernel.modDirVersion} \
      INSTALL_MOD_PATH=$out

    make \
      modules_install \
      KERNEL_DIR=${kernelDev}/lib/modules/${kernel.modDirVersion}/build \
      KERNELRELEASE=${kernel.modDirVersion} \
      INSTALL_MOD_PATH=$out
  '';

  installPhase = "true";

  meta = with lib; {
    description = "Patched snd-hda-codec-cs8409 kernel module for MacBookPro audio";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };
}
