# Screenshots

From a fresh install, on the real (fake) backend:
- **iOS:** the iPhone 17 Pro simulator, debug build;
- **Android:** the Pixel 10 Pro emulator (API 36), **release build**.

The status bar is set to 9:41 on iOS.

---

## Light

| Feed | Post detail | Search | Create post |
|:---:|:---:|:---:|:---:|
| <img src="screenshots/feed-light.png" width="200" alt="The feed: Ada Lovelace's post with a mountain photo, 142 likes and 3 comments, and Grace Hopper's post below; the Notifications tab shows a badge of 3"> | <img src="screenshots/post-detail-light.png" width="200" alt="Post detail for Ada's post, with comments from Grace Hopper (4 likes) and Alan Turing, and a comment field at the bottom"> | <img src="screenshots/search-light.png" width="200" alt="Search for ada: Ada Lovelace under People, and her post under Posts, with All, People and Posts chips"> | <img src="screenshots/create-post-light.png" width="200" alt="New post with 93 of 280 characters typed, an optional image URL field, and an enabled Post button"> |

| Someone else's profile |
|:---:|
| <img src="screenshots/profile-other-light.png" width="200" alt="Ada Lovelace's profile: 4.8K followers, 312 following, 3 posts, a back button and no Saved tab"> |

## Dark

| Notifications | My profile | Settings |
|:---:|:---:|:---:|
| <img src="screenshots/notifications-dark.png" width="200" alt="Notifications in dark mode: three unread at the top, tinted and with dots; Mark all read in the app bar"> | <img src="screenshots/profile-dark.png" width="200" alt="My profile in dark mode: Demo User, 128 followers, 87 following, 2 posts, Posts and Saved tabs, and the Settings gear"> | <img src="screenshots/settings-dark.png" width="200" alt="Settings in dark mode: Appearance (System, Light, Dark), Show unread badge, Clear cache, Simulate network failure, and About with version 1.0.0 (1)"> |

## Large text (iOS AX3, about 235 %)

| Feed | My profile | Settings |
|:---:|:---:|:---:|
| <img src="screenshots/large-text-feed.png" width="200" alt="The feed at the largest text size: the post text wraps over many lines"> | <img src="screenshots/large-text-profile.png" width="200" alt="My profile at the largest text size: the counts wrap onto two rows"> | <img src="screenshots/large-text-settings.png" width="200" alt="Settings at the largest text size: Appearance becomes a radio list of System, Light and Dark"> |

At large sizes, side-by-side controls stack (`prefersStackedLayout`, above 130 %):
- Appearance becomes a radio list;
- the profile's counts wrap.

## Wallpaper colors (Android 12+, release build)

| Settings | Feed |
|:---:|:---:|
| <img src="screenshots/android-dynamic-color-settings.png" width="200" alt="Settings on Android with Use wallpaper colors turned on: the switches and the selected segment take the wallpaper's blue"> | <img src="screenshots/android-dynamic-color-feed.png" width="200" alt="The feed on Android with wallpaper colors: blue-tinted surfaces and a blue New post button"> |

- "Use wallpaper colors" appears only where the platform has a palette (`platformColorSchemesProvider` is `null` on iOS).
- Turning it on restyles the app at once, and the choice survives a restart.

---

## How they were taken

```bash
xcrun simctl status_bar <udid> override --time 9:41 --dataNetwork wifi --wifiBars 3 --cellularBars 4 \
  --batteryState charged --batteryLevel 100
xcrun simctl ui <udid> appearance dark                          # or light
xcrun simctl ui <udid> content_size accessibility-extra-large   # AX3; back with `large`
xcrun simctl io <udid> screenshot feed-light.png
sips -Z 1000 feed-light.png                                     # the repo copies are 1000 px tall

fvm flutter build apk --release
adb install -r build/app/outputs/flutter-apk/app-release.apk
adb shell pm clear co.bitfuse.flutter.connect_hub_riverpod      # a fresh install
adb exec-out screencap -p > android-dynamic-color-feed.png
```
