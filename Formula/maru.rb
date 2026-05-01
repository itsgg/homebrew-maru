class Maru < Formula
  desc "Unified profile manager for AI coding agents (Claude, Codex, Gemini)"
  homepage "https://github.com/itsgg/maru"
  version "0.1.0-alpha.7"
  license any_of: ["Apache-2.0", "MIT"]

  on_macos do
    on_arm do
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.7/maru-cli-aarch64-apple-darwin.tar.xz"
      sha256 "ff0c0df67dd44505d909ba58d4ea7919c2be90e07eb837f391f5e65bcf21523f"
    end
    on_intel do
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.7/maru-cli-x86_64-apple-darwin.tar.xz"
      sha256 "098518f04cee956a41a57c016af05b5ae5de69596cecc7db59b5523f5a1e98d5"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.7/maru-cli-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "83ba849df393d578bfb3386ab970752e9cb70f78f158ebc042d85636650e48e8"
    end
    on_intel do
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.7/maru-cli-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "bd13d5f83e93a32b29ba9f5e183a879a08a62115e8622a22be6bc6681b6a8b79"
    end
  end

  resource "maru-shim" do
    on_macos do
      on_arm do
        url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.7/maru-shim-aarch64-apple-darwin.tar.xz"
        sha256 "4bbd222713e20b3ad48a250add755f23093d6f613413ce0cdb80c6854298d34f"
      end
      on_intel do
        url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.7/maru-shim-x86_64-apple-darwin.tar.xz"
        sha256 "23eaee27cff23fd09d57083c53146adbd0297f6c9bce9f17b3b3534bf3bd428c"
      end
    end

    on_linux do
      on_arm do
        url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.7/maru-shim-aarch64-unknown-linux-gnu.tar.xz"
        sha256 "a144c29462008accb9e7d676366f5be5be338ed1457e284f93fdbfceaa44883c"
      end
      on_intel do
        url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.7/maru-shim-x86_64-unknown-linux-gnu.tar.xz"
        sha256 "26acfcebcc7bbbfc15b2e12c5ee11c1246194f3a4343f6ebb977dffa111b6858"
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
