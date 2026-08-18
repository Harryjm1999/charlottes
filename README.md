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

`capacitor.config.ts` points the app at https://charlottes.lovable.app so content
stays up to date without resubmitting the app. To ship a fully self-contained
build, delete the `server` block and re-run step 4.

To publish to the App Store you need an Apple Developer account ($99/yr), then
set the bundle ID, signing team, app icon and launch screen in Xcode and use
Product > Archive.
