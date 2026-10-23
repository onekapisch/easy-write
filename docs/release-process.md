# Safe release preparation

Updated 2026-10-23. The public 2.0.1 artifacts remain immutable. This process is for a
future, explicitly approved release, not a reason to rebuild an existing release.

## Boundaries

- `./release.sh VERSION --build NUMBER` prints a read-only plan. It does not check
  credentials, build, sign, submit, mount, edit files or contact a remote service.
- Adding `--prepare` is a separate, consequential operation: builds locally, signs with
  the selected Developer ID and submits the app and DMG to Apple's notary service.
  Obtain owner approval before doing this. Credentials and private keys stay in Keychain.
- Preparation never commits, tags, pushes, creates a GitHub draft, or publishes a feed.
- Every attempt uses a new owner-only `dist/release-VERSION-bNUMBER.*` directory.
  Old accepted/rejected candidates and the root app are left alone. Failed candidates
  are retained for inspection, never automatically retried, certified or distributed.

## Prerequisites

1. Update and commit `Info.plist` with the intended marketing version and an explicit
   build number higher than every item in the latest production feed. Add the matching
   exact `## [VERSION]` changelog entry. The script does not modify source version files.
2. Obtain the latest signed production appcast and keep an unchanged local copy.
   Do not pass an old feed that omits newer releases. Preparation verifies its signature
   with Sparkle, freezes those verified bytes, retains its release history, and rejects reused/downgraded versions.
3. Use the existing Developer ID and notarization Keychain profile. With multiple
   certificates, select the intended certificate fingerprint with `--identity SHA1`.
4. Prepare a build-only Python environment separately, never as an implicit release step:

   ```sh
   python3 -m venv .venv-release
   .venv-release/bin/python -m pip install dmgbuild==1.6.7 ds_store==1.3.3 mac_alias==2.2.3
   ```

   Node, Swift/Xcode command-line tools, Keychain identities and Sparkle's resolved
   `sign_update` are also required. No dependency is bundled into the app by this setup.

## Commands

Example only. The example is not approval to submit or publish a new version:

```sh
./release.sh 2.0.2 --build 28

# Only after explicit notarization approval and the committed version bump:
./release.sh 2.0.2 --build 28 --prepare \
  --previous-appcast /absolute/path/to/latest-signed-appcast.xml \
  --dmg-python "$PWD/.venv-release/bin/python"
```

`EW_NOTARY_PROFILE` or `--profile` selects an existing Keychain profile. Never pass a
password or private key in arguments. `--no-eval` explicitly skips the 40-sentence
register evaluation, not self-tests or real-model smoke tests. Any skip is recorded.
Evaluation results are synthetic and isolated under the candidate's evaluation folder.

## Gates

- Clean, unchanged source commit; no existing local or remote release tag.
- Isolated app build, strict signature checks, self-tests and real-model smoke tests.
- Complete 40-sentence shipping-prompt evaluation with no model errors and at most two
  definite formal-register leaks, unless explicitly skipped. This is not an accuracy score.
- App notarization must report `Accepted`, followed by stapling, Gatekeeper and signature checks.
- Pinned `dmgbuild` uses `dmg/settings.py`. No Finder automation or post-signing bundle metadata edits.
- The enclosed app is verified from a read-only mount before DMG submission and again after
  final DMG stapling. Mounts are detached on verification failures.
- Final DMG checksum, strict signature, notarization ticket and Gatekeeper checks.
- Sparkle payload signature verified both with Sparkle and against `Info.plist`'s public key.
- A newly signed/verified feed prepends the update while preserving older items.
- Versioned/stable DMGs and feed hashes, source commit, notarization IDs/statuses and skip
  state are recorded in `VERIFIED.json` only after all gates pass. Keep signed bytes unchanged.

## Separate publication checklist

Review the exact candidate and manifest. Confirm acceptance on another Mac and an installed
Sparkle upgrade where possible. Then, with owner publication approval:

1. Tag the manifest's exact source commit. Push only that approved commit/tag.
2. Create a draft GitHub release for that existing tag with `--verify-tag`; attach the exact
   versioned and stable DMGs, signed appcast and release notes. Do not regenerate the files.
3. Review and publish the draft. Download and compare the public payload against the manifest.
4. Deploy the matching signed feed byte-for-byte and update version-pinned website links.
5. Test actual update discovery, download, installation and relaunch. A current-version
   "up to date" dialog only verifies checking, not the complete upgrade path.

The script intentionally does not automate these publication actions. A candidate manifest is
not proof of clean-Mac compatibility, physical cross-app delivery or VoiceOver acceptance.

## Local verification without release side effects

```sh
bash -n build.sh release.sh setup-signing.sh
python3 -m unittest discover -s tools -p test_release.py
python3 -m unittest discover -s dmg -p test_settings.py
node --check tools/verify-update.mjs
./release.sh 2.0.2 --build 28
```

Tests exercise real parsers, feed construction and cryptographic verification. Apple/GitHub
side effects are not performed. External-command failure tests use controlled fakes.
The first full `--prepare` run remains an integration gate for the next approved release.

## Verification performed, 2026-10-23

- Observed regressions fail before implementation, including broad candidate deletion,
  mutable previous-feed history and partial-attachment cleanup. All 18 safety tests now pass.
- Safe DMG layout test, four appearance/positioning checks and shell/Node syntax checks pass.
- Built a separate app in a new temporary directory and passed strict signature verification;
  requesting that same output again correctly refuses to overwrite it. Root/installed apps were not replaced.
- The new read-only mount verifier passed against the already accepted 2.0.1 DMG. Its
  SHA-256 remains `be47cf44102634baa07c79dac0dbe390ddc8e755ef2c75d18d48864ebf1ead03`.
  Independent payload verification against the configured public key also passes.
- Native build, self-tests and six synthetic real-model smoke checks passed on the working tree.
  Concurrent replacement/self-test edits are separate work, excluded from this release-tooling commit.
- Read-only review found no remaining important issues after two cleanup/snapshot fixes.
- No new app/DMG was notarized or published. Full preparation uses controlled external-tool
  fakes in the safety suite; no fresh Apple or installed-Sparkle round trip is claimed.
