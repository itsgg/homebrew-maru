class Maru < Formula
  desc "Unified profile manager for AI coding agents (Claude, Codex, Gemini)"
  homepage "https://github.com/itsgg/maru"
  version "0.1.0-alpha.3"
  license any_of: ["Apache-2.0", "MIT"]

  on_macos do
    on_arm do
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.3/maru-cli-aarch64-apple-darwin.tar.xz"
      sha256 "54bb0c2482ed6f1fde07d7ce17362157d2cf76ed6f2c01ce5177f24fd7b1abdf"
    end
    on_intel do
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.3/maru-cli-x86_64-apple-darwin.tar.xz"
      sha256 "c4533bf4cdcc45ae20c59577c1362e8e20047e95362da0a8c99c3b5499c35a75"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.3/maru-cli-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "9026264c202033d085a44d12f8dbbf02d1cccd5b5e740d4b70d0f123cb13334f"
    end
    on_intel do
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.3/maru-cli-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "c31084e05dff41386dccd6799da010bdfd8ecf283a90cff6e04dcd75f88184ae"
    end
  end

  resource "maru-shim" do
    on_macos do
      on_arm do
        url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.3/maru-shim-aarch64-apple-darwin.tar.xz"
        sha256 "ff1a7ad639debfb4e6ba684706229835f3d88f5d2fb823b1781da0116d8b17bc"
      end
      on_intel do
        url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.3/maru-shim-x86_64-apple-darwin.tar.xz"
        sha256 "1d4a47cd73ea30127fe014b89bb24e906b9626a3ec8cd188f724dba1e54d7392"
      end
    end

    on_linux do
      on_arm do
        url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.3/maru-shim-aarch64-unknown-linux-gnu.tar.xz"
        sha256 "eb9e9067ad09839baa96d954f29471c98768b070764a4288fecb2bff61a9d900"
      end
      on_intel do
        url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.3/maru-shim-x86_64-unknown-linux-gnu.tar.xz"
        sha256 "073e57e8a747ae7c791370c3b017f889e9c9574ee53e3e828a37c81947b745a1"
      end
    end
  end

  def install
    bin.install "maru"
    resource("maru-shim").stage do
      bin.install "maru-shim"
    end
    # The per-harness shim symlinks (claude/codex/gemini) are deliberately
    # NOT installed into brew's bin: users typically already have those
    # binaries from other brew packages (claude-code cask, codex cask,
    # gemini-cli formula), and brew skips conflicting symlinks. The shim
    # would never win. Instead, `maru install` creates a dedicated
    # $MARU_HOME/bin and prepends it to PATH — that dir has only maru's
    # symlinks, so the shim wins regardless of what else is installed.
  end

  def post_install
    # Pre-warm macOS Gatekeeper. On macOS Sequoia (15+), first execution
    # of an unsigned binary triggers `syspolicy` to do an online check
    # that can take 30s–2min. Doing it here folds that latency into the
    # `brew install` step (where users already expect to wait) instead
    # of the subsequent `maru install` (which would otherwise appear to
    # hang). Once cached, every later run is ~5ms. No-op on Linux.
    system bin/"maru", "--version" if OS.mac?
  end

  def caveats
    <<~EOS
      One more step — wire the per-harness shims into a maru-owned PATH
      entry that beats your existing claude / codex / gemini installs:

        maru install

      Then open a new terminal (or `source ~/.zshrc`). Verify with:

        which claude   # should be inside $MARU_HOME/bin

      Default $MARU_HOME (per GENESIS §3):
        macOS:   ~/Library/Application Support/maru
        Linux:   $XDG_DATA_HOME/maru
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/maru --version")
    assert_predicate bin/"maru-shim", :executable?
  end
end
