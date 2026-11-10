# Security Policy

## Supported Versions

ConnectHub Riverpod is a learning/reference project. Security fixes are applied to the latest `main` only.

| Version | Supported |
|---------|:---------:|
| `main`  | ✅ |

## Reporting a Vulnerability

Please **do not** open a public issue for security problems.

Instead, email **muhammadfaheem004@gmail.com** with:

- a description of the issue and its impact;
- steps to reproduce (a proof of concept if possible);
- any suggested remediation.

You can expect an acknowledgement within a few business days.

## What the App Holds

The app has **no real backend, no accounts and no API keys**. Its "server" is an in-memory fake inside the app, so nothing you type leaves the device. The only network traffic is image downloads: the seed's placeholder pictures (pravatar.cc, picsum.photos), and any image URL you enter when creating a post.

- **No sign-in:** a demo user is always signed in. There are no passwords or tokens to protect.
- **The cache** (drift / SQLite) holds the fake server's posts, profiles, comments and notifications, plus recent searches. Settings → Clear cache deletes everything but saved posts and recent searches.
- **Preferences** (`SharedPreferencesWithCache`) hold only the appearance, "Use wallpaper colors" and "Show unread badge".

The practical attack surface is small. Reports about unsafe patterns (for example in how entered URLs are validated or loaded), dependency issues or data-handling concerns are still very welcome.
