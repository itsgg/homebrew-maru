class Maru < Formula
  desc "Unified profile manager for AI coding agents (Claude, Codex, Gemini)"
  homepage "https://github.com/itsgg/maru"
  version "0.1.0-alpha.8"
  license any_of: ["Apache-2.0", "MIT"]

  on_macos do
    on_arm do
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.8/maru-cli-aarch64-apple-darwin.tar.xz"
      sha256 "e06a66fbf51b09ea8f4e02130f1a9eb2e624bc3dfe47f8d6de4089b43dbd8202"
    end
    on_intel do
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.8/maru-cli-x86_64-apple-darwin.tar.xz"
      sha256 "a17db03eb4c9813ffce41420d26a7f7bb2b4cb53108d441fdf033da44092d796"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.8/maru-cli-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "8b1c5ca74f01fa367d6fd1a9a35e7b95f2fe1c3424fd481872444b1ca3333ce2"
    end
    on_intel do
      url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.8/maru-cli-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "8f7b764c105c9623cc196c98742889f8fd2d197d50798142a489acba9b8bf92d"
    end
  end

  resource "maru-shim" do
    on_macos do
      on_arm do
        url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.8/maru-shim-aarch64-apple-darwin.tar.xz"
        sha256 "552ce6caea5e62be636db99fbc14a318ff54a82b46203935953bbd7503a438bf"
      end
      on_intel do
        url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.8/maru-shim-x86_64-apple-darwin.tar.xz"
        sha256 "427cea64275b7f1d567f8877183f0572a4a3c592c577d9690abcac212f44e29c"
      end
    end

    on_linux do
      on_arm do
        url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.8/maru-shim-aarch64-unknown-linux-gnu.tar.xz"
        sha256 "4a7eb46eeb673bb8a6a426715babafcd81ac27324c97cb0c5bc70f7260ddb7c9"
      end
      on_intel do
        url "https://github.com/itsgg/maru/releases/download/v0.1.0-alpha.8/maru-shim-x86_64-unknown-linux-gnu.tar.xz"
        sha256 "9cad83abbf5a36ff7b5e75d2c3ab418dfcaf60588382f85eb138bcd3f20d5f07"
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
