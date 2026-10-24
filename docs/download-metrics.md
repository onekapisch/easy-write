# Download and traffic measurement

Reviewed 2026-10-24. These are existing GitHub service counters, not Easy Write telemetry.

## Installer downloads

GitHub exposes `download_count` for each uploaded release asset. Count DMGs only; do not add
appcast or checksum downloads. Both the versioned DMG and stable `EasyWrite.dmg` are the same
installer, so add their counters for that release without treating them as different products.

```sh
gh api repos/onekapisch/easy-write/releases --paginate \
  --jq '.[] | {version: .tag_name, installers: [.assets[] | select(.name | endswith(".dmg")) | {name, downloads: .download_count}]}'
```

These counts include repeat downloads, Sparkle updates and maintainer/test verification.
They are not unique people, first installations, retained users, successful installs or revenue.
Older releases with no uploaded installer assets have no DMG counter to sum. GitHub-generated
source archives and repository clones are separate from installer downloads.

[GitHub release API documentation](https://docs.github.com/en/rest/releases/releases)
and [release-asset fields](https://docs.github.com/en/rest/releases/assets) describe these counters.

## Repository traffic

With repository access, open [Insights → Traffic](https://github.com/onekapisch/easy-write/graphs/traffic).
GitHub documents a rolling 14-day window; retain dated snapshots if a longer history is needed.
Always report the response's actual date range. Repository views and unique visitors are not
website visits or app users. Clones can include automation and do not represent app installs.

```sh
gh api repos/onekapisch/easy-write/traffic/views
gh api repos/onekapisch/easy-write/traffic/clones
```

Do not publish private repository-traffic snapshots without the owner's approval.
[GitHub traffic documentation](https://docs.github.com/en/repositories/viewing-activity-and-data-for-your-repository/viewing-traffic-to-a-repository).

## Website download-button taps

The Easy Write product, guide and shared-action routes currently exclude website analytics.
There is no download-button event counter to query, and historical clicks cannot be recovered
from GitHub download counts. An unavailable analytics API response is not evidence of zero traffic.

Future aggregate click measurement would need an explicit change to that no-analytics policy,
appropriate privacy disclosures and a defined event such as `easy_write_download_click`.
A click would still not prove that the installer downloaded or that the app was installed.
Keep selected text, history, device identifiers and personal data out of measurement events.
