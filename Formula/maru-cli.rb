class MaruCli < Formula
  desc "The `maru` profile-manager binary."
  homepage "https://github.com/itsgg/maru"
  version "0.1.0-alpha.2"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.2/maru-cli-aarch64-apple-darwin.tar.xz"
      sha256 "aad37816b724f2ae70abf08493350522f38e8e9d34635405b2dda68872981fee"
    end
    if Hardware::CPU.intel?
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.2/maru-cli-x86_64-apple-darwin.tar.xz"
      sha256 "b6fb4cd04483a6573f89b485ac898565f7582a2240fc1850dfe057fe1daf6c0c"
    end
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.2/maru-cli-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "cc4e0ffa2938d1c2e17a64bf5c01ea28bb8f8d9c9aa595a6f1022ae95be0016a"
    end
    if Hardware::CPU.intel?
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.2/maru-cli-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "8ed9176cbb315871f67b30bfc439dc6190a9a2a135fe2f1224128c387dad69cd"
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
