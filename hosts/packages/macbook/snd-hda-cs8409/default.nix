{ stdenv, lib, fetchgit, linuxKernel, kernel ? linuxKernel.kernels.linux_6_12 }:

let
  pname = "snd-hda-macbookpro";
  version = "259cc39e243daef170f145ba87ad134239b5967f";

  moduleSrc = fetchgit {
    url = "https://github.com/davidjo/snd_hda_macbookpro.git";
    rev = version;
    sha256 = "sha256-M1dE4QC7mYFGFU3n4mrkelqU/ZfCA4ycwIcYVsrA4MY=";
  };

  kernelDev = kernel.dev;
  kernelModDirVersion = kernel.modDirVersion;
  kernelBuild = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
in

stdenv.mkDerivation {
  inherit pname version;

  src = moduleSrc;

  nativeBuildInputs = kernel.moduleBuildDependencies;

  buildPhase = ''
    mkdir -p build/kernel_sources
    mkdir -p build/sound/pci/hda
    mkdir ${tmpBuildDir}

    # Копируем нужные файлы из ядра
    cp ${kernelSrc}/sound/pci/hda/patch_cs8409.c build/kernel_sources/
    cp ${kernelSrc}/sound/pci/hda/patch_cs8409.h build/kernel_sources/

    cp ${moduleSrc}/patch_cirrus/patch_cirrus_apple.h build/kernel_sources/


    cd build

    patch -p1 < ${moduleSrc}/patch_patch_cs8409.c.diff
    patch -p1 < ${moduleSrc}/patch_patch_cs8409.h.diff
    substituteInPlace kernel_sources/patch_cirrus_apple.h \
      --replace ".force_status_change = 1," ""

    # Копируем патченные файлы
    cp ${moduleSrc}/patch_cirrus/patch_cirrus_new84.h sound/pci/hda/
    cp ${moduleSrc}/patch_cirrus/patch_cirrus_boot84.h sound/pci/hda/
    cp ${moduleSrc}/patch_cirrus/patch_cirrus_real84.h sound/pci/hda/
    cp ${moduleSrc}/patch_cirrus/patch_cirrus_real84_i2c.h sound/pci/hda/
    cp ${moduleSrc}/patch_cirrus/patch_cirrus_hda_generic_copy.h sound/pci/hda/
    cp ${kernelSrc}/sound/pci/hda/patch_cs8409-tables.c sound/pci/hda/
    cp ${kernelSrc}/sound/pci/hda/hda_*.h sound/pci/hda/
    cp kernel_sources/patch_cs8409.c sound/pci/hda/
    cp kernel_sources/patch_cs8409.h sound/pci/hda/
    cp kernel_sources/patch_cirrus_apple.h sound/pci/hda/

    cd sound/pci/hda

    # Дописываем Makefile для сборки единого модуля
    echo "obj-m := ${pname}.o" >> Makefile
    echo "${pname}-objs := patch_cs8409.o patch_cs8409-tables.o" >> Makefile

    make -C ${kernelBuild} M=$(pwd) modules
  '';

  installPhase = ''
    install -D -m 0644 ${pname}.ko $out/lib/modules/${kernelModDirVersion}/extra/${pname}.ko
  '';

  meta = with lib; {
    description = "Out-of-tree patched snd-hda-codec-cs8409 module for MacBookPro";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };
}
