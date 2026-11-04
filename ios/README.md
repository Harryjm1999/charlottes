# Charlotte's for iOS

A native SwiftUI app that talks to the same Lovable Cloud (Supabase) database as the website,
so bookings made in the app appear in the website's staff admin straight away, and the other
way round. Lovable doesn't edit anything in `ios/`.

## Keeping it in step with the website

- **Bookings and staff** are shared live, with no app update needed.
- **Restaurant details, opening hours and menus** are copies inside the app
  (`Core/Restaurants.swift`, `Resources/Menus`). A change there needs a new app version.
- **Privacy policy and terms** are in `Resources/legal.json`, generated from the website's
  `src/data/legal.ts`. If that wording changes, regenerate it.
- **Database names** in `Core/API.swift` must stay identical to the website's.

Sign-in is email and password only. No redirect URL is ever passed, because Lovable Cloud's
allow-list can't be changed: emailed confirmation and reset links open the website.

## Builds

There's no Mac involved. Both workflows run on GitHub's Macs:

- **iOS build** (`.github/workflows/ios.yml`) runs on every push that changes `ios/`. It compiles
  the app, screenshots each screen in a 6.9" simulator, and pushes the log and screenshots to the
  `ios-ci` branch.
- **iOS release to TestFlight** (`.github/workflows/ios-release.yml`) is run by hand from the
  Actions tab. It signs the app with Apple's cloud-managed certificate and uploads it.

## Setting up TestFlight

1. Register the bundle ID at developer.apple.com → Certificates, IDs & Profiles → Identifiers →
   **+** → App IDs → App, with Bundle ID (Explicit) `uk.co.inexcess.charlottes.test` and no extra
   capabilities. The ID is set by `PRODUCT_BUNDLE_IDENTIFIER` in `project.yml`.
2. Create the app in App Store Connect → Apps → **+** → New App, using that bundle ID.
3. In this repository, go to Settings → Secrets and variables → Actions, and add
   `APPLE_TEAM_ID`, `APP_STORE_CONNECT_KEY_ID`, `APP_STORE_CONNECT_ISSUER_ID` and
   `APP_STORE_CONNECT_PRIVATE_KEY` (the same values as Redbrook's; the private key is the full
   contents of the `.p8` file).
4. Actions → **iOS release to TestFlight** → **Run workflow**.
