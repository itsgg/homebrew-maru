class Maru < Formula
  desc "Unified profile manager for AI coding agents (Claude, Codex, Gemini)"
  homepage "https://github.com/itsgg/maru"
  version "0.1.0-alpha.4"
  license any_of: ["Apache-2.0", "MIT"]

  on_macos do
    on_arm do
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.4/maru-cli-aarch64-apple-darwin.tar.xz"
      sha256 "ccc44dc70f89a0eee337d413ed7497824afcb011a14e3aad22bc8fff1ef73bf3"
    end
    on_intel do
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.4/maru-cli-x86_64-apple-darwin.tar.xz"
      sha256 "72104b11f6fcdcd638845fe2a0fd71be843351a75f7e06e4a8c78d4213904ac7"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.4/maru-cli-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "c11aecc66b5ef7ccf5b7eb4d352db5f372bad972e2338dd333ff566a74901cfd"
    end
    on_intel do
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.4/maru-cli-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "fe2513228146f90d0b129d523beb479f498f61bc00015c450478d6e005a07f6a"
    end
  end

  resource "maru-shim" do
    on_macos do
      on_arm do
        url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.4/maru-shim-aarch64-apple-darwin.tar.xz"
        sha256 "c4259fd2f23c07d42eb2e0ba7218ef0abf1481f5047eb564401d906490c888dd"
      end
      on_intel do
        url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.4/maru-shim-x86_64-apple-darwin.tar.xz"
        sha256 "84aff4da8689c549b3759fc2226057a67ae845b282bcfaa6559dc7ce4ae6dca4"
      end
    end

    on_linux do
      on_arm do
        url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.4/maru-shim-aarch64-unknown-linux-gnu.tar.xz"
        sha256 "8a51f3ae9c567d31f2484a25289e3bf6e27709159527428ef46d0bc4648d6e17"
      end
      on_intel do
        url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.4/maru-shim-x86_64-unknown-linux-gnu.tar.xz"
        sha256 "8e204433bb7e7c29c8d99b6ea753f697875d1b1535161873156699baea99e016"
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

  def caveats
    <<~EOS
      One more step — wire the per-harness shims into a maru-owned PATH
      entry that beats your existing claude / codex / gemini installs:

        maru install

      Then open a new terminal (or `source ~/.zshrc`). Verify with:

        which claude   # should be inside $MARU_HOME/bin

      Heads-up on macOS: until the binaries are notarized, the FIRST run
      of `maru install` (or any `maru` / `maru-shim` invocation) can sit
      for 30 s – 2 min while macOS Gatekeeper does an online verification
      against Apple's servers. Subsequent runs are ~5 ms. Tracked in
      docs/notes/phase-4-handoff.md (APPLE_TEAM_ID etc).

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
