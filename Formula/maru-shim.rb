class MaruShim < Formula
  desc "Hot-path shim binary. argv[0] dispatches to the right harness adapter."
  homepage "https://github.com/itsgg/maru"
  version "0.1.0-alpha.2"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.2/maru-shim-aarch64-apple-darwin.tar.xz"
      sha256 "7b99d57ccf99afa39f0c725609b4b6a449e7439955c4937f0b63ddbbed688901"
    end
    if Hardware::CPU.intel?
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.2/maru-shim-x86_64-apple-darwin.tar.xz"
      sha256 "8239204b2cc91a475efcee39686a2986c338e390bfa81c121d6200c53245a072"
    end
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.2/maru-shim-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "6cb3869c374d0fd543ed3af6ba1329edf732b54ff283b3db7c488d3635f8566b"
    end
    if Hardware::CPU.intel?
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.2/maru-shim-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "7253b1f8dd5a447375c153973843e1ef217216d67b3faa65f589821b18aa3275"
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
