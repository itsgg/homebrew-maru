class Maru < Formula
  desc "Unified profile manager for AI coding agents (Claude, Codex, Gemini)"
  homepage "https://github.com/itsgg/maru"
  version "0.1.0-alpha.5"
  license any_of: ["Apache-2.0", "MIT"]

  on_macos do
    on_arm do
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.5/maru-cli-aarch64-apple-darwin.tar.xz"
      sha256 "cec4739a978465bf5ecb5e330ebd449c7bc2c4f31434affc870af07c411a6638"
    end
    on_intel do
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.5/maru-cli-x86_64-apple-darwin.tar.xz"
      sha256 "b75d3d2dd27ed1298b00073d2ba0eb022d46286e897f7576c60611ceb4f3a5d2"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.5/maru-cli-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "05b5df2eac4e8a59b4007af9a05e3336ed762c0a549115f85251e21304086da0"
    end
    on_intel do
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.5/maru-cli-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "2509e8cddbfc10a0e0666d5ae1e741be48f35e06c64f62381a8daecd590983ef"
    end
  end

  resource "maru-shim" do
    on_macos do
      on_arm do
        url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.5/maru-shim-aarch64-apple-darwin.tar.xz"
        sha256 "350a1986eb94b1631687ebebf7a94a1afee2b3fb57403b807efd6c2d31e5735c"
      end
      on_intel do
        url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.5/maru-shim-x86_64-apple-darwin.tar.xz"
        sha256 "70dbc3970398bd07189f3701d75e358bb98cd512adb0ec9e8cb0d71ff8b3e0a1"
      end
    end

    on_linux do
      on_arm do
        url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.5/maru-shim-aarch64-unknown-linux-gnu.tar.xz"
        sha256 "a6571483b7ef0564f8998feafa198722286074bac50838b5cb0b165560f2813e"
      end
      on_intel do
        url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.5/maru-shim-x86_64-unknown-linux-gnu.tar.xz"
        sha256 "417775f758f05aea335c6bf4d529bb2b25f4abeed2fe074c81bf1d9ca050afb9"
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
      Wire the per-harness shims and authenticate Claude per profile:

        maru install                       # one-time PATH setup
        maru profile create work --harness claude
        maru profile login work            # runs `claude setup-token`, saves
                                           # CLAUDE_CODE_OAUTH_TOKEN per profile
        maru profile use work
        claude                             # uses the work-profile token

      Why `maru profile login`: Claude Code's macOS Keychain entry is not
      reliably partitioned per CLAUDE_CONFIG_DIR; logging out from one
      profile can clear credentials shared with another. The env-var
      token (auth precedence step 5) wins over Keychain and gives each
      profile real isolation. See docs/adapters/claude.md for details.

      Heads-up on macOS: until the binaries are notarized, the FIRST run
      of any maru / maru-shim command can sit for 30 s – 2 min while
      macOS Gatekeeper does an online verification. Subsequent runs are
      ~5 ms. Tracked in docs/notes/phase-4-handoff.md.

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
