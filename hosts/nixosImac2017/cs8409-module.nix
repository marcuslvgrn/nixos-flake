{
  fetchFromGitHub,
  kernel,
  lib,
  python3,
  xz,
}:

let
  kbuild = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
in
kernel.stdenv.mkDerivation {
  pname = "imac-cs8409-linux-audio";
  version = "0.1-b08d074";

  src = fetchFromGitHub {
    owner = "armin-haghi";
    repo = "imac-cs8409-linux-audio";
    rev = "b08d0745e1b78d6949d5a231d91351e73ddf8079";
    hash = "sha256-T0hiCQFVE7ii6UwRANHFKWo8nwLdBXqpUALqO9WpcEw=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies ++ [ python3 xz ];
  dontStrip = true;

  postPatch = ''
    substituteInPlace verify-abi.py \
      --replace-fail 'RUNNING = os.uname().release' \
        'RUNNING = os.uname().release
    KBUILD_TREE = os.environ.get("KBUILD_TREE", f"/lib/modules/{RUNNING}/build")
    KERNEL_VMLINUX = os.environ.get("KERNEL_VMLINUX")
    KERNEL_MODULES = os.environ.get("KERNEL_MODULES")'

    substituteInPlace verify-abi.py \
      --replace-fail '/lib/modules/{kver}/build' '{KBUILD_TREE}'

    substituteInPlace verify-abi.py \
      --replace-fail 'def btf_sources(kver, tmp):' \
        'def btf_sources(kver, tmp):
        if KERNEL_VMLINUX and KERNEL_MODULES:
            out = []
            for module in SND_MODULES:
                hits = glob.glob(f"{KERNEL_MODULES}/lib/modules/{kver}/kernel/**/{module}.ko*", recursive=True)
                if not hits:
                    continue
                src, dst = hits[0], os.path.join(tmp, module + ".ko")
                if src.endswith(".xz"):
                    if sh(f"xz -dcf {src} > {dst}").returncode != 0:
                        continue
                elif src.endswith(".zst"):
                    if sh(f"zstd -dqf {src} -o {dst}").returncode != 0:
                        continue
                else:
                    shutil.copy(src, dst)
                out.append((dst, KERNEL_VMLINUX))
            out.append((KERNEL_VMLINUX, None))
            return out'
  '';

  buildPhase = ''
    runHook preBuild

    export KBUILD_TREE="${kbuild}"
    export KERNEL_VMLINUX="${kernel.dev}/vmlinux"
    export KERNEL_MODULES="${kernel.modules}"
    python3 verify-abi.py --kver "${kernel.modDirVersion}"

    make -C "$KBUILD_TREE" \
      CFLAGS_MODULE="-DAPPLE_PINSENSE_FIXUP -DAPPLE_CODECS -DCONFIG_SND_HDA_RECONFIG=1 -Wno-unused-variable -Wno-unused-function" \
      M="$PWD" modules

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -D -m 0444 snd-hda-codec-cs8409.ko \
      "$out/lib/modules/${kernel.modDirVersion}/updates/snd-hda-codec-cs8409.ko"
    runHook postInstall
  '';

  meta = {
    description = "Apple iMac CS8409 HD-audio codec module";
    homepage = "https://github.com/armin-haghi/imac-cs8409-linux-audio";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
  };
}
