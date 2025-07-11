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
  tmpBuildDir = "/tmp/build_hda";

in stdenv.mkDerivation {
  name = "snd-hda-codec-cs8409-module-${version}-${kernel.modDirVersion}";
  inherit version;

  src = moduleSrc;

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = []; # не используем

  buildPhase = ''
    mkdir -p build/kernel_sources
    mkdir -p build/sound/pci/hda
    mkdir ${tmpBuildDir}

    # Копируем нужные файлы из ядра
    cp ${kernelSrc}/sound/pci/hda/patch_cs8409.c build/kernel_sources/
    cp ${kernelSrc}/sound/pci/hda/patch_cs8409.h build/kernel_sources/

    cp ${moduleSrc}/patch_cirrus/patch_cirrus_apple.h build/kernel_sources/


    cd build

    # Применяем патчи
    patch -p1 < ${moduleSrc}/patch_patch_cs8409.c.diff
    patch -p1 < ${moduleSrc}/patch_patch_cs8409.h.diff
    substituteInPlace kernel_sources/patch_cirrus_apple.h \
    --replace ".force_status_change = 1," ""


    # Копируем патченные файлы
    cp ${moduleSrc}/patch_cirrus/patch_cirrus_new84.h sound/pci/hda/
    cp ${moduleSrc}/patch_cirrus/patch_cirrus_boot84.h sound/pci/hda/
    cp ${kernelSrc}/sound/pci/hda/hda_*.h sound/pci/hda/
    cp kernel_sources/patch_cs8409.c sound/pci/hda/
    cp kernel_sources/patch_cs8409.h sound/pci/hda/
    cp kernel_sources/patch_cirrus_apple.h sound/pci/hda/
    
    

    # Копируем Makefile
    cp ${moduleSrc}/Makefile sound/pci/hda/

    # Создаем временную директорию с правами на запись для сборки
    TMP_BUILD_DIR=$(mktemp -d)
    cp -r sound/pci/hda/* "${tmpBuildDir}"/
    cd "${tmpBuildDir}"

    # Патчим Makefile под правильный путь к kernelDev и корректный путь M=
    substituteInPlace Makefile \
      --replace "/lib/modules/\$(KERNELRELEASE)" "${kernelDev}/lib/modules/${kernel.modDirVersion}" \
      --replace "\$(shell pwd)/build/hda" "${tmpBuildDir}"

    substituteInPlace Makefile --replace "depmod -a" ""
    echo "obj-m := patch_cs8409.o" >> Makefile

    # Собираем модуль в директории с правами записи
    make \
      KERNEL_DIR=${kernelDev}/lib/modules/${kernel.modDirVersion}/build \
      KERNELRELEASE=${kernel.modDirVersion} \
      M=${tmpBuildDir}

    echo "=== Built .ko modules ==="
    find ${tmpBuildDir}
  '';

  installPhase = ''
    install -D -m 0644 ${tmpBuildDir}/patch_cs8409.ko $out/lib/modules/${kernel.modDirVersion}/updates/patch_cs8409.ko
    # Обновляем модульный кеш
    depmod -a ${kernel.modDirVersion}
  '';

  meta = with lib; {
    description = "Patched snd-hda-codec-cs8409 kernel module for MacBookPro audio";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };
}
