class MaruCli < Formula
  desc "The `maru` profile-manager binary."
  homepage "https://github.com/itsgg/maru"
  version "0.1.0-alpha.3"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.3/maru-cli-aarch64-apple-darwin.tar.xz"
      sha256 "54bb0c2482ed6f1fde07d7ce17362157d2cf76ed6f2c01ce5177f24fd7b1abdf"
    end
    if Hardware::CPU.intel?
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.3/maru-cli-x86_64-apple-darwin.tar.xz"
      sha256 "c4533bf4cdcc45ae20c59577c1362e8e20047e95362da0a8c99c3b5499c35a75"
    end
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.3/maru-cli-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "9026264c202033d085a44d12f8dbbf02d1cccd5b5e740d4b70d0f123cb13334f"
    end
    if Hardware::CPU.intel?
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.3/maru-cli-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "c31084e05dff41386dccd6799da010bdfd8ecf283a90cff6e04dcd75f88184ae"
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
      bin.install "maru"
    end
    if OS.mac? && Hardware::CPU.intel?
      bin.install "maru"
    end
    if OS.linux? && Hardware::CPU.arm?
      bin.install "maru"
    end
    if OS.linux? && Hardware::CPU.intel?
      bin.install "maru"
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
