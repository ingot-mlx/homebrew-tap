class Ingot < Formula
  desc "LLM inference engine for Apple silicon (M5+) with an OpenAI-compatible server"
  homepage "https://github.com/ingot-mlx/ingot"
  url "https://github.com/ingot-mlx/ingot/archive/refs/tags/v0.1.2.tar.gz"
  sha256 "72335090ce62df194e1eaef2c0af5d3c50dbd3906452af58205290fca0a1bbec"
  license all_of: ["MIT", "Apache-2.0"]
  head "https://github.com/ingot-mlx/ingot.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/ingot-mlx/ingot/releases/download/v0.1.2"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "093a6342f1ab20bd69d7aebf8890aeb1747ca91836e65afdf1b4bf190366dd97"
  end

  depends_on arch: :arm64
  depends_on macos: :golden_gate
  uses_from_macos "swift" => :build

  # SwiftPM fetches swift-jinja (Package.resolved pins the revision).
  allow_network_access! :build

  def install
    system "swift", "build", "--product", "ingot", *std_swift_args
    # Bundle.module looks for ingot_Ingot.bundle next to the real executable: keep both in libexec and put an
    # exec script (not a symlink) in bin, so Bundle.main resolves to libexec.
    libexec.install ".build/release/ingot", ".build/release/ingot_Ingot.bundle"
    bin.write_exec_script libexec/"ingot"
    prefix.install "THIRD_PARTY_NOTICES.md", "LICENSES"
  end

  def caveats
    <<~EOS
      ingot needs a Mac with an M5 chip or later and macOS 27. Models come from the Hugging Face cache:
        hf download LiquidAI/LFM2.5-8B-A1B-MLX-4bit
        ingot serve --model LiquidAI/LFM2.5-8B-A1B-MLX-4bit
    EOS
  end

  test do
    assert_match "ingot #{version}", shell_output("#{bin}/ingot --version")
    assert_match "usage: ingot", shell_output("#{bin}/ingot help")
    assert_path_exists libexec/"ingot_Ingot.bundle/Contents/Resources/Shaders/qmm.metal"
    assert_path_exists libexec/"ingot_Ingot.bundle/Contents/Resources/Calibration"
  end
end
