# K-Splash

Plasma 6 wallpaper widget that fetches random photos from a small backend that talks to the Unsplash API.

## Features

- Uses a backend endpoint so the Unsplash access key stays off the client
- Supports a category or custom query such as `dark`, `fun`, `skyline`, and `happy`
- Lets users choose how often the wallpaper refreshes
- Can change the KDE desktop wallpaper automatically
- Shows photographer attribution with Unsplash referral links
- Can save a copy of the current wallpaper from the widget icon

## Settings

The widget settings page includes:

- `Backend URL`
- `Category / query`
- `Saved custom categories` for your own reusable queries
- `Refresh interval (minutes)`
- `Change wallpaper after each refresh`
- `Saved downloads` toggle
- `Download folder`
- target `Resolution width` and `Resolution height`

Point `Backend URL` at a service that returns an Unsplash photo object from an endpoint such as `http://YOUR-NAS:8787/api/random-photo?query=nature`.

## Backend

A minimal self-hosted backend for a NAS is included at `backend/unsplash-proxy.js`.

It expects:

- `UNSPLASH_ACCESS_KEY`
- optional `PORT` (defaults to `8787`)
- optional `UNSPLASH_APP_NAME` (defaults to `k_splash_backend`)

Start it with:

```bash
UNSPLASH_ACCESS_KEY=your_key_here node backend/unsplash-proxy.js
```

The plasmoid only calls your backend. The backend keeps the key secret, requests a random photo from Unsplash, performs the download tracking call server-side, and returns the photo JSON back to the widget.

## Package

Build a clean upload package with:

```bash
./package-release.sh
```

This excludes Git metadata, Codex files, and the legacy `contents/config/local.json`.

Install a packaged widget locally with:

```bash
./install-local.sh ./K-Splash.plasmoid
```

The installer uses `${XDG_DATA_HOME:-$HOME/.local/share}/plasma/plasmoids` and still preserves a legacy `contents/config/local.json` if one already exists from an older install.

## Snapcraft

The project includes a Snapcraft definition at `snap/snapcraft.yaml`.

- Base: `core24`
- Confinement: `strict`
- Target architectures: `amd64`, `arm64`, `armhf`

Build locally in a clean provider (recommended):

```bash
snapcraft pack
```

Do not rely on `--destructive-mode` for release builds. It is host-OS specific and can fail when the host version does not match the base build environment.

For upload-ready multi-architecture artifacts, use remote builders:

```bash
snapcraft remote-build --build-on=amd64,arm64,armhf
```

Or use the helper script:

```bash
./snap/build-for-store.sh
```

Release upload:

```bash
snapcraft upload --release=stable *.snap
```

User install flow (strict confinement):

```bash
sudo snap install k-splash
sudo snap connect k-splash:dot-local-share-plasma-plasmoids
k-splash.install-widget
```

This keeps builds reproducible for users across Linux distributions and avoids machine-specific build behavior.

## Publishing

Files prepared for store upload:

- `STORE-LISTING.md`
- `RELEASE-NOTES.md`
- `UPLOAD-CHECKLIST.md`

## License

MIT. See `LICENSE`.
