# Pick For Me

A Flutter Progressive Web App (PWA) that helps patients in recreational therapy
choose an activity without experiencing choice anxiety. Instead of an
overwhelming list, the user taps a large category card and the app randomly
picks **one** activity, presented with a fun reveal animation. A "View All
Activities" tab is available for therapists or users who want to browse the
full catalog.

## Features

- Large, accessible category cards: Outside, Creative, Relaxing, Physical.
- Random single-activity pick with an engaging reveal animation.
- "Pick Another" (spin again) and "Accept this Activity" buttons.
- "View All Activities" tab for manual browsing.
- Responsive layout for phones, tablets, and desktop.
- PWA-ready: `manifest.json`, service worker, and app icons included.

## Requirements

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel, 3.10+)
- Chrome (for `flutter run -d chrome`)

## Run locally

```bash
flutter pub get
flutter run -d chrome
```

## Build the production web bundle

```bash
flutter build web --release
```

The output is written to `build/web/`. It is a fully static site (HTML, JS,
CSS, assets, `manifest.json`, and a service worker) that can be hosted anywhere.

## Deploy to GitHub Pages

### 1. Create a GitHub repository and push this project

```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/<your-username>/<repo-name>.git
git push -u origin main
```

### 2. Build with the correct `--base-href`

GitHub Pages serves **project** repositories under a sub-path:

```
https://<your-username>.github.io/<repo-name>/
```

Flutter needs to know this base path so asset and route URLs resolve
correctly. Build with `--base-href` set to `/<repo-name>/` (note the
leading and trailing slashes):

```bash
flutter build web --release --base-href "/<repo-name>/"
```

> For a **user/organization site** (`<username>.github.io`), the app is
> served from the root, so use `--base-href "/"` (the default).

### 3. Publish `build/web` to GitHub Pages

Option A - **GitHub Actions (recommended):** create
`.github/workflows/deploy.yml`:

```yaml
name: Deploy to GitHub Pages
on:
  push:
    branches: [main]
permissions:
  contents: read
  pages: write
  id-token: write
concurrency:
  group: pages
  cancel-in-progress: false
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - run: flutter pub get
      - run: flutter build web --release --base-href "/${{ github.event.repository.name }}/"
      - uses: actions/upload-pages-artifact@v3
        with:
          path: build/web
  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - uses: actions/deploy-pages@v4
        id: deployment
```

Then in the repository settings, set **Pages → Source → GitHub Actions**.

Option B - **Manual:** copy the contents of `build/web/` into a `gh-pages`
branch and push. The `peaceiris/actions-gh-pages` action automates this.

### 4. Install as a PWA

Once deployed, open the site in a mobile browser. The browser will offer
"Add to Home Screen" / "Install app" using the bundled `manifest.json`
and service worker.

## Project structure

```
lib/
  main.dart                 # App entry point & theme
  data/activities.dart      # Category & activity data
  screens/home_screen.dart  # Pick tab + View All tab
web/
  index.html                # HTML shell (base href placeholder)
  manifest.json             # PWA manifest
  icons/                    # App icons (192/512)
```

## Notes on service worker / caching

Flutter generates `flutter_service_worker.js` during `flutter build web`.
It caches the app shell for offline use. After a new deploy, the service
worker updates on the next visit. Hard-refresh (Ctrl/Cmd+Shift+R) if a
stale version is shown.