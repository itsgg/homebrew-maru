class Maru < Formula
  desc "Unified profile manager for AI coding agents (Claude, Codex, Gemini)"
  homepage "https://github.com/itsgg/maru"
  version "0.1.0-alpha.6"
  license any_of: ["Apache-2.0", "MIT"]

  on_macos do
    on_arm do
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.6/maru-cli-aarch64-apple-darwin.tar.xz"
      sha256 "64fb74c85cdd350f0ce285879d8cda2180d020207d772580c88e08b9e22c5da5"
    end
    on_intel do
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.6/maru-cli-x86_64-apple-darwin.tar.xz"
      sha256 "7d5fb7a655f97a0529a7aa0985c46bdd68a3aea82e6e84a5f140703f2ca06155"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.6/maru-cli-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "4d99ea47671f3f106a86a7964ed0751b641d927da90ad7ea96bb6a520e943cec"
    end
    on_intel do
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.6/maru-cli-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "350cccea30243a0b02e7b89324810e0cb62094dc216a5d949ab553c6e8a24a4d"
    end
  end

  resource "maru-shim" do
    on_macos do
      on_arm do
        url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.6/maru-shim-aarch64-apple-darwin.tar.xz"
        sha256 "024a587ad31ca0537d48e511623156b6b61b2efe3fa1be339b833e17d4156e0b"
      end
      on_intel do
        url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.6/maru-shim-x86_64-apple-darwin.tar.xz"
        sha256 "8305b41a0224176fa765122e71f3a38b79c618f98ee36f1d7f9362c430ce8115"
      end
    end

    on_linux do
      on_arm do
        url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.6/maru-shim-aarch64-unknown-linux-gnu.tar.xz"
        sha256 "9ca42d70b292b8f42d1aef42247c6155331154c6314528601da47179516f8ae7"
      end
      on_intel do
        url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.6/maru-shim-x86_64-unknown-linux-gnu.tar.xz"
        sha256 "ecfb8ea7dc4f791e29d1dc217308d2edcaa0b7bff552117d11a8f0bbc41d20cf"
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
