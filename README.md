# Welcome to your Lovable project

This project was built with [Lovable](https://lovable.dev).

## Build with Lovable

Open your project in the [Lovable editor](https://lovable.dev) and keep building.

- **Ship faster**: describe what you want to build and Lovable handles the code.
- **Stay in sync**: connect the project to GitHub and every change made in Lovable is committed straight to your repository.
- **Full ownership**: this code is yours. Push to your repository and your changes sync back into Lovable, ready for your next prompt.

## Development

Prefer working locally? You need Node.js and npm — [install with nvm](https://github.com/nvm-sh/nvm#installing-and-updating).

```sh
git clone <this-repository-url>
cd <repository-name>
npm i
npm run dev
```

## Built with

- TanStack Start
- TypeScript
- React
- Tailwind CSS

## iOS app (Capacitor)

The web app is wrapped as a native iOS app with Capacitor.

Requirements: a Mac with Xcode installed.

1. Export the project to GitHub and `git clone` it locally.
2. `npm install`
3. `npx cap add ios`
4. `npm run build && npx cap sync ios`
5. `npx cap open ios` — then run on a simulator or device from Xcode.

The app is fully self-contained: `npm run build` outputs the bundled app to
`dist/client`, and `npx cap sync ios` copies it into the native app. It runs
from its own bundled code (no website needed) and works offline thanks to the
built-in service worker. Sign-in and bookings still use the cloud backend over
the network when available.

## App Store submission checklist

1. Run `npm run build && npx cap sync ios` so the native app contains the
   latest bundled code — the app does not load the website, so whatever you
   build is what users get.
2. In Xcode: set the display name, app icon (1024px App Store icon), launch
   screen and signing team (Capabilities > Signing).
3. In App Store Connect, create the app with bundle ID `app.lovable.charlottes`.
4. Privacy policy URL: https://charlottes.lovable.app/privacy
   Terms of use (EULA) URL: https://charlottes.lovable.app/terms
   (these are hosted on the published site, so keep the site published even
   though the app itself is bundled).
5. Add screenshots (6.7" and 5.5" iPhone) and an app description, then
   Product > Archive in Xcode and upload the build.

Note: the app uses sign-in and sends booking requests over the network, so
select "Yes" for account creation in the App Privacy section if asked.

To publish to the App Store you need an Apple Developer account ($99/yr).
