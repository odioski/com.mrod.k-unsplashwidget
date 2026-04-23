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

## Publishing

Files prepared for store upload:

- `STORE-LISTING.md`
- `RELEASE-NOTES.md`
- `UPLOAD-CHECKLIST.md`

## License

MIT. See `LICENSE`.
