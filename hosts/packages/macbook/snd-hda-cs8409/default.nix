{ stdenv, lib, fetchgit, linuxKernel, kernel ? linuxKernel.kernels.linux_6_12
, version ? "f30643972f47f63f340e49aadddbcb61729dac03" }:

let
  # Загружаем репо с патчами и модулем
  moduleSrc = fetchgit {
    url = "https://github.com/davidjo/snd-hda-macbookpro.git";
    rev = version;
    sha256 = "sha256-wZbRcen6uLahb/goX4t2ECtzv8XqZ6kRPN8bp1NTCR0=";
  };

  # Путь к исходникам ядра, где будем патчить
  kernelSrc = kernel.dev;

in stdenv.mkDerivation {
  name = "snd-hda-codec-cs8409-module-${version}-${kernel.modDirVersion}";
  inherit version;

  # В качестве src берем только файлы из модуля (копируем их отдельно)
  # Патчи будут применяться к исходникам ядра, а не сюда
  src = moduleSrc;

  nativeBuildInputs = kernel.moduleBuildDependencies;

  # Параметры сборки
  makeFlags = kernel.makeFlags ++ [
    "INSTALL_MOD_PATH=$(out)"
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KERNEL_DIR=${kernelSrc}/lib/modules/${kernel.modDirVersion}/build"
  ];

  # На этапе patchPhase: применяем патчи к исходникам ядра в build/sound/pci/hda,
  # а не к модулю из репо

  buildPhase = ''
    # Копируем исходники ядра в локальную папку build
    mkdir -p build
    cp -r ${kernelSrc}/lib/modules/${kernel.modDirVersion}/source/sound/pci/hda build/

    # Применяем патчи к исходникам ядра
    patch -d build/sound/pci/hda -p1 < ${moduleSrc}/patch_patch_cs8409.c.diff
    patch -d build/sound/pci/hda -p1 < ${moduleSrc}/patch_patch_cs8409.h.diff
    patch -d build/sound/pci/hda -p1 < ${moduleSrc}/patch_patch_cirrus_apple.h.diff

    # Копируем файлы модуля из репо в каталог с исходниками ядра, чтобы собрать модуль
    cp ${moduleSrc}/*.c build/sound/pci/hda/
    cp ${moduleSrc}/*.h build/sound/pci/hda/
    cp ${moduleSrc}/Makefile build/sound/pci/hda/

    # Переходим в директорию с исходниками ядра
    cd build/sound/pci/hda

    # Запускаем сборку модуля
    make KERNELRELEASE=${kernel.modDirVersion} KERNEL_DIR=${kernelSrc}/lib/modules/${kernel.modDirVersion}/build

    # Установка в $(out)
    make INSTALL_MOD_PATH=$(out) modules_install
  '';

  installPhase = "true";  # все сделано в buildPhase

  meta = with lib; {
    description = "Patched snd-hda-codec-cs8409 kernel module for MacBookPro audio";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ no1tx ];
  };
}
