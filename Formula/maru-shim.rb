class MaruShim < Formula
  desc "Hot-path shim binary. argv[0] dispatches to the right harness adapter."
  homepage "https://github.com/itsgg/maru"
  version "0.1.0-alpha.3"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.3/maru-shim-aarch64-apple-darwin.tar.xz"
      sha256 "ff1a7ad639debfb4e6ba684706229835f3d88f5d2fb823b1781da0116d8b17bc"
    end
    if Hardware::CPU.intel?
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.3/maru-shim-x86_64-apple-darwin.tar.xz"
      sha256 "1d4a47cd73ea30127fe014b89bb24e906b9626a3ec8cd188f724dba1e54d7392"
    end
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.3/maru-shim-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "eb9e9067ad09839baa96d954f29471c98768b070764a4288fecb2bff61a9d900"
    end
    if Hardware::CPU.intel?
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.3/maru-shim-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "073e57e8a747ae7c791370c3b017f889e9c9574ee53e3e828a37c81947b745a1"
    end
  end
  license any_of: ["Apache-2.0", "MIT"]

  BINARY_ALIASES = {
    "aarch64-apple-darwin": {},
    "aarch64-unknown-linux-gnu": {},
    "x86_64-apple-darwin": {},
    "x86_64-pc-windows-gnu": {},
    "x86_64-unknown-linux-gnu": {}
  }

  def target_triple
    cpu = Hardware::CPU.arm? ? "aarch64" : "x86_64"
    os = OS.mac? ? "apple-darwin" : "unknown-linux-gnu"

    "#{cpu}-#{os}"
  end

  def install_binary_aliases!
    BINARY_ALIASES[target_triple.to_sym].each do |source, dests|
      dests.each do |dest|
        bin.install_symlink bin/source.to_s => dest
      end
    end
  end

  def install
    if OS.mac? && Hardware::CPU.arm?
      bin.install "maru-shim"
    end
    if OS.mac? && Hardware::CPU.intel?
      bin.install "maru-shim"
    end
    if OS.linux? && Hardware::CPU.arm?
      bin.install "maru-shim"
    end
    if OS.linux? && Hardware::CPU.intel?
      bin.install "maru-shim"
    end

    install_binary_aliases!

    # Homebrew will automatically install these, so we don't need to do that
    doc_files = Dir["README.*", "readme.*", "LICENSE", "LICENSE.*", "CHANGELOG.*"]
    leftover_contents = Dir["*"] - doc_files

    # Install any leftover files in pkgshare; these are probably config or
    # sample files.
    pkgshare.install(*leftover_contents) unless leftover_contents.empty?
  end
end
