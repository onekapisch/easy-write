# Homebrew cask for the onekapisch/homebrew-tap repository.
#   brew install --cask onekapisch/tap/easy-write
# After each release, set `version` and `sha256` (shasum -a 256 dist/EasyWrite-<version>.dmg).
cask "easy-write" do
  version "2.0"
  sha256 "REPLACE_WITH_SHA256_OF_EasyWrite-2.0.dmg"

  url "https://github.com/onekapisch/easy-write/releases/download/v#{version}/EasyWrite-#{version}.dmg"
  name "Easy Write"
  desc "Translate and rewrite selected text in place with Apple's on-device model"
  homepage "https://www.onekapisch.com/products/easy-write/"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true
  depends_on arch: :arm64
  depends_on macos: ">= :tahoe"

  app "Easy Write.app"

  zap trash: [
    "~/Library/Application Support/Easy Write",
    "~/Library/Caches/com.onekapisch.easywrite",
    "~/Library/HTTPStorages/com.onekapisch.easywrite",
    "~/Library/Preferences/com.onekapisch.easywrite.plist",
  ]
end
