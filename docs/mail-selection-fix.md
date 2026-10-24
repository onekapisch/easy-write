# Mail selection capture fix

Date: 2026-10-23. Published baseline: Easy Write 2.0.1, build 27.
Local test build: 27.1, not a public release and not newly notarized.

## Cause and evidence

The reported notch message originates in `Runner.capture()`, before model inference.
On a focused Mail composer AXWebArea, a live metadata-only probe observed:

- `AXSelectedText`: `kAXErrorNoValue` (-25212).
- `AXSelectedTextRange`: `kAXErrorNoValue` (-25212).
- `AXSelectedTextMarkerRange`: success, opaque system marker-range value.
- `AXStringForTextMarkerRange` using that value: success.
- Two consecutive actual marker-range values compare equal using `CFEqual`.

No private selection text, recipient, subject, document content, marker bytes or clipboard value
was recorded in diagnostics. Only technical statuses, type IDs, equality and length metadata
were inspected. WebKit's implementation exposes marker-based selection operations; ordinary
native character-range assumptions do not cover Mail's rich-text composer.

## Change

`Replacer` keeps native character-range capture and adds the WebKit marker path. It retrieves the
text from the exact marker range and rechecks the marker before accepting capture. Empty or
unstable selections fail. Text without a verifiable window/range remains review-only.

`SelectionTarget` represents character ranges and text-marker ranges distinctly. Paste eligibility
still requires the same process, window, element, range identity and selected text. WebKit bounds
use `AXBoundsForTextMarkerRange` for Bar placement. There is no Copy fallback, no new text storage
and no model/network change.

## Verification

- Before implementation: 113 self-tests passed, two new capture assertions failed, reproducing
  the missing marker support. The injected AX read boundary still used the legacy behavior.
- After implementation and safety cases: release build passes without compiler warnings;
  123 isolated self-tests pass, including moved markers over identical text, edited text,
  collapsed selections, missing windows, mid-capture changes, bounds and untouched clipboard.
- All six synthetic real-model smoke scenarios pass. These verify the engine, not Mail delivery.
- Appearance/positioning tests: 4/4. DMG-layout test: 1/1. Shell syntax and diff checks pass.
- Independent review found no important actionable issue. Separate exported-system-constructor
  tests confirmed equality of separately allocated markers/ranges with identical endpoints and
  inequality when endpoints differ. The CFData test fixture alone is not platform proof.
- Local bundle is Developer-ID signed; strict deep signature verification passes. Its designated
  signing requirement matches the installed release. Version is 2.0.1, local build 27.1.
- Existing public update configuration was retained; update consent/settings were not changed.
  The public feed/release assets and source version files were not modified.

## Local installation and rollback

The local app is installed at `/Applications/Easy Write.app` and reopened. The previous app is
preserved at `dist/local-mail-selection.Ol9Szh/released-backup/Easy Write.app`.
The signed local candidate is `dist/local-mail-selection.Ol9Szh/Easy Write.app`.
Both paths are local, ignored artifacts. Restoring the backup is a local rollback, not a release.

## Owner retry and remaining acceptance

On 2026-10-23, after installation of local build 27.1, the owner retried the shortcut in Mail
and reported: "Translation or preview now works." This confirms the reported capture failure
is resolved in that user's retry. The response does not distinguish preview from completed
in-place replacement, certify every Mail field/version, or establish the full compatibility matrix.

The physical global-shortcut → capture → model → replacement workflow in Mail is not yet certified.
Mail AppleScript draft creation timed out; later native automation could not retain Mail focus.
An owned synthetic compose/paste run therefore did not complete and is not marked as a pass.
The successful owner retry above is separate evidence from those incomplete automated attempts.

Native fields, other WebKit editors, changed window/selection, clipboard copies during inference,
VoiceOver and eventual signed update installation retain their independent acceptance requirements.
The initial local-fix work performed no publication. The owner subsequently authorized the
public 2.0.2 build-28 patch; see `notarization-2.0.2-build28.md` for the separate release evidence.
