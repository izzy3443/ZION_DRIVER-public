<div align="center">

#  ZION Driver

### The other side of the ride.

*Firebase auth · Document verification · Native Android overlay for ride alerts · Real-time navigation · Live in-app payments*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Kotlin](https://img.shields.io/badge/Kotlin-7F52FF?style=for-the-badge&logo=kotlin&logoColor=white)](https://kotlinlang.org)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Razorpay](https://img.shields.io/badge/Razorpay-02042B?style=for-the-badge&logo=razorpay&logoColor=white)](https://razorpay.com)

</div>

---

## 📌 Table of Contents

- [Intro](#intro)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Screenshots](#screenshots)
- [Architecture](#architecture)
- [Key Implementation Highlights](#key-implementation-highlights)
- [Roadmap](#roadmap)

---

<a id="intro"></a>
## 🧠 Intro

**ZION Driver** is the counterpart app to the ZION rider platform — built for drivers to onboard, get verified, go online, and earn. It handles the full driver lifecycle: phone-based OTP signup, vehicle and license document collection, admin-side verification through a separate internal panel, real-time ride request alerts delivered through a native Android system overlay, in-app navigation handoff to Google Maps, and live subscription payments processed through Razorpay — actual money moving through actual production endpoints.

The app is fully localized across **English, Hindi, and Telugu**, with the selected language persisted locally so drivers never have to reselect it.

This repo contains the **Driver App**. Documents submitted here are verified through **ZION Panel** — a separate internal admin dashboard repo — before a driver is approved to go online.

---

<a id="features"></a>
## ✨ Features

- **Force-Stop-Safe Fare Calculation** — Trip end isn't a flat lookup. On ending a trip, a Cloud Function re-queries the **Google Directions API live** using the rider's pickup coordinates and the driver's *current* GPS position (not the original drop-off) to recompute actual distance and duration traveled. Fare is derived from real road distance and time using per-vehicle rate curves (Bike / Car / Auto each have distinct base + per-km + per-minute multipliers). If the driver is still more than 500m from the intended drop-off, the function rejects the end-trip request as `overlimit` unless explicitly force-ended — meaning even a ride cancelled or cut short mid-route is billed for exactly the distance actually covered, never a placeholder amount.

- **Native Android Overlay for Ride Requests** — When a new ride request comes in, a system-level overlay window renders on top of *any* app the driver is currently using — built with a dedicated Kotlin `OverlayService` running as a proper foreground service, bridged to Flutter through a `MethodChannel`. This is OS-level UI, not an in-app modal, so a request can't be missed just because the driver tabbed away to WhatsApp or Maps.

- **Granular Runtime Permission Management** — Beyond the standard location/camera prompts, the app explicitly tracks and requests Android-specific permissions critical to background reliability: **Draw Over Other Apps** (required for the overlay itself), **Autostart in Background**, **Battery Optimization exemption**, and **Notification Access** — each shown with live Granted/Not Granted status and routed to the correct OEM-specific system settings screen (battery vendors like MIUI/realme intercept this differently, handled via `app_settings` + `android_intent_plus`).

- **Kotlin ↔ Flutter Trip Handoff** — Accepting a ride inside the native overlay doesn't process the trip in Kotlin at all — it calls back into Flutter through a second `MethodChannel` (`trip_channel`) with just the `tripId`. Flutter then fetches the full trip document from Firestore, hydrates it into a typed model, and pushes it into Riverpod state — a full round-trip between native and Dart layers with zero duplicated business logic.

- **Document Onboarding Pipeline** — A guided checklist walks drivers through uploading their **Vehicle RC**, **Driving License (front & back)**, and a **live-captured profile photo** — each uploaded directly to Firebase Storage and tracked through a real-time onboarding progress bar that updates as each document clears review.

- **Camera-Only Profile Capture** — The profile photo step opens the device camera directly with no gallery picker, enforcing a genuine live capture that can be matched against the submitted ID photo — closing an obvious identity-fraud gap most onboarding flows leave open.

- **Admin-Side Document Verification** — Uploaded documents are never auto-approved. They're reviewed through **ZION Panel**, a separate internal admin dashboard repo, where the vehicle is categorized and named according to the actual RC before a driver's checklist can reach 100% and they're allowed to go online.

- **Animated Accept/Reject UI with Auto-Timeout** — The overlay includes a live countdown progress bar animated over 10 seconds, auto-rejecting the trip if the driver doesn't respond, alongside custom native toast notifications — preventing a stuck or ignored ride request from hanging indefinitely.

- **Go Online / Go Offline with Live Geo-Indexing** — A single toggle controls driver availability; going online writes the driver's live location to Firestore via geo-hash indexing, making them immediately discoverable by nearby riders without any polling on either side.

- **Turn-by-Turn Navigation Handoff** — Once a trip is accepted, the app hands off directly into Google Maps for live external navigation to pickup and drop-off, rather than reinventing turn-by-turn guidance in-app.

- **Ride PIN Verification & Full Trip State Machine** — Drivers confirm a rider-shared PIN to start a trip, with explicit state transitions through arrived → in-progress → completed, plus an early end-trip flow with confirmation that still routes through the same distance-aware fare engine.

- **Live Production Payments via Razorpay** — Drivers subscribe to a monthly package (e.g. ₹499/month Auto Owner Package) to remain active on the platform. This is a real, production Razorpay integration — UPI, cards, netbanking, wallets — not a sandbox flow, with subscription status (Active/Inactive), expiry tracking, and full payment history written to Firestore.

- **Multi-Language Support with Persisted Preference** — Fully localized in **English, Hindi, and Telugu** via `easy_localization`, with the selected language written to local device storage through `shared_preferences` so it survives app restarts without re-prompting.

- **Push Notifications via FCM** — Device tokens are collected and stored in Firestore per driver, enabling targeted ride-request and status notifications even when the app is fully backgrounded.

- **Trip History** — A complete log of past trips with route, fare, and timing details.

- **Crash Reporting** — Firebase Crashlytics integrated for production stability monitoring.

- **OTP Phone Authentication** — Passwordless sign-in via Firebase Auth SMS verification, the same security model used across both the rider and driver apps.

- **Account Type Selection** — Drivers choose between **Car Owner** or **Auto Owner** during onboarding, which determines the vehicle category and pricing tier applied to their profile for the lifetime of the account.

---

<a id="tech-stack"></a>
## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter 3.x |
| **Native Overlay Layer** | Kotlin (Android `Service`, `MethodChannel`, `FlutterEngineCache`) |
| **State Management** | Riverpod 2.x |
| **Authentication** | Firebase Auth (Phone OTP) |
| **Database** | Cloud Firestore |
| **File Storage** | Firebase Storage (RC, License, Profile Photo) |
| **Backend Logic** | Firebase Cloud Functions |
| **Maps & Navigation** | Google Maps Flutter, Polyline Points, external Maps redirect |
| **Location Services** | Geolocator, GeoFlutterFire+ |
| **Payments** | Razorpay Flutter (live production integration) |
| **Push Notifications** | Firebase Cloud Messaging |
| **Localization** | easy_localization (English / Hindi / Telugu) |
| **Local Persistence** | shared_preferences (language preference) |
| **Crash Monitoring** | Firebase Crashlytics |
| **Security** | Firebase App Check |
| **Device Info** | device_info_plus, app_settings, android_intent_plus |
| **UI** | flutter_screenutil, slide_to_act |

---

<a id="screenshots"></a>
## 📱 Screenshots

<div align="center">

> 📂 View all screenshots in [`assets/screenshots/`](assets/screenshots/)

<br/>

**🌐 Onboarding — Language, Identity & Account Type**
<br/>
<img src="assets/screenshots/02_language_selection.jpg" width="220"/>&emsp;&emsp;&emsp;<img src="assets/screenshots/04_phone_number_entry.jpg" width="220"/>&emsp;&emsp;&emsp;<img src="assets/screenshots/05_choose_account_type.jpg" width="220"/>
<br/><br/><br/>
<img src="assets/screenshots/06_enter_name.jpg" width="220"/>&emsp;&emsp;&emsp;<img src="assets/screenshots/07_onboarding_checklist_0pct.jpg" width="220"/>&emsp;&emsp;&emsp;<img src="assets/screenshots/08_vehicle_registration_entry.jpg" width="220"/>
<br/><br/><br/>

**📄 Document Verification — RC, License & Live Photo**
<br/>
<img src="assets/screenshots/10_upload_rc_empty_slots.jpg" width="220"/>&emsp;&emsp;&emsp;<img src="assets/screenshots/11_upload_rc_filled.jpg" width="220"/>&emsp;&emsp;&emsp;<img src="assets/screenshots/13_driver_license_entry.jpg" width="220"/>
<br/><br/><br/>
<img src="assets/screenshots/16_upload_license_images.jpg" width="220"/>&emsp;&emsp;&emsp;<img src="assets/screenshots/18_upload_profile_photo_empty.jpg" width="220"/>&emsp;&emsp;&emsp;<img src="assets/screenshots/17_onboarding_checklist_dl_success.jpg" width="220"/>
<br/><br/><br/>

**🔐 Native Permissions — Required for the Overlay to Work**
<br/>
<img src="assets/screenshots/21_permissions_list.jpg" width="220"/>&emsp;&emsp;&emsp;<img src="assets/screenshots/22_permissions_dialog.jpg" width="220"/>&emsp;&emsp;&emsp;<img src="assets/screenshots/24_permissions_all_granted.jpg" width="220"/>
<br/><br/><br/>

**🟢 Going Online — Subscription Gate & Live Map**
<br/>
<img src="assets/screenshots/28_home_map_subscription_inactive.jpg" width="220"/>&emsp;&emsp;&emsp;<img src="assets/screenshots/29_subscription_inactive_package.jpg" width="220"/>&emsp;&emsp;&emsp;<img src="assets/screenshots/payment_options_screen.PNG" width="220"/>
<br/><br/><br/>
<img src="assets/screenshots/payment_success_screen.PNG" width="220"/>&emsp;&emsp;&emsp;<img src="assets/screenshots/subscription_active_screen.PNG" width="220"/>&emsp;&emsp;&emsp;<img src="assets/screenshots/30_home_map_online.jpg" width="220"/>
<br/><br/><br/>

**🚗 On a Ride — Navigation, Pickup & Fare Collection**
<br/>
<img src="assets/screenshots/driver_navigation_external_maps.jpg" width="220"/>&emsp;&emsp;&emsp;<img src="assets/screenshots/driver_start_ride_otp.jpg" width="220"/>&emsp;&emsp;&emsp;<img src="assets/screenshots/arrived.jpg" width="220"/>
<br/><br/><br/>
<img src="assets/screenshots/trip_started.jpg" width="220"/>&emsp;&emsp;&emsp;<img src="assets/screenshots/driver_end_trip_early_confirm.jpg" width="220"/>&emsp;&emsp;&emsp;<img src="assets/screenshots/driver_trip_completed_collect_fare.jpg" width="220"/>
<br/><br/><br/>

**📊 Earnings & History**
<br/>
<img src="assets/screenshots/31_home_dashboard.jpg" width="220"/>&emsp;&emsp;&emsp;<img src="assets/screenshots/32_trip_history.jpg" width="220"/>

</div>

---

<a id="architecture"></a>
## 🏗️ Architecture

ZION Driver follows the same **feature-first, W&F (Work & Function) architecture** as the rider app on the Flutter side — but adds a dedicated **native Kotlin layer** to handle system-level overlay alerts that Flutter alone cannot do.

```
lib/
└── pages/
    └── HOME_W&F/                  ← one folder per feature, same pattern as rider app
        ├── screen_Home.dart       # UI only — no logic here
        ├── controller_Home.dart   # Firebase calls, business rules
        └── provider_Home.dart     # Riverpod state providers
```

**Native overlay layer** — replaces the rider app's Cloud Functions as the "special backend piece" of this app:

```
android/app/src/main/kotlin/com/example/zion_driver_553/
├── MainActivity.kt                  # Hosts the FlutterEngine + MethodChannel bridge
├── OverlayService.kt                # Builds & manages the system-level ride-alert overlay
└── MyFirebaseMessagingService.kt    # Receives FCM pushes, triggers the overlay from background
```

**Overlay UI** — styled natively, not in Flutter:

```
android/app/src/main/res/drawable/
├── bg_accept_button.xml
├── bg_card.xml
├── bg_close_button.xml
├── bg_progress_fill.xml
├── bg_white_rounded.xml
├── ic_clock.xml
├── ic_close.xml
└── toast_bg.xml
```

**Other key folders:**

```
assets/
├── screenshots/        # App screenshots (numbered by onboarding step)
└── translations/       # en.json / hi.json / te.json for easy_localization
```

Document verification happens outside this repo entirely, in **ZION Panel** — a separate admin dashboard repo where uploaded RC and license documents are reviewed, vehicles are named/categorized per the RC, and drivers are approved to go online.

---

<a id="key-implementation-highlights"></a>
## 📐 Key Implementation Highlights

**Native Android Overlay for Ride Requests**
The single most distinctive piece of this app. A Kotlin `OverlayService` draws a system-level window on top of whatever app the driver is currently using — even if ZION Driver is backgrounded — so a ride request is never missed. `MainActivity.kt` caches the running `FlutterEngine` via `FlutterEngineCache` and exposes a `MethodChannel` (`overlay_permission_channel`) so Kotlin can request the overlay permission, start the service as a proper foreground service on Android O+, and tear it down cleanly when a trip is accepted or rejected.

**Kotlin ↔ Flutter Trip Handoff**
When a driver taps Accept inside the native overlay, `OverlayService` doesn't process the trip itself — it calls back into Flutter through a second channel (`trip_channel`), passing the `tripId`. Flutter picks this up via `setMethodCallHandler`, fetches the full trip document from Firestore, hydrates it into a `TripDetailsModel`, and pushes it into a Riverpod provider — completing a clean round-trip between native code and the Dart layer with no UI duplication.

**Foreground-Service-Backed Reliability**
On Android 8+, the overlay is launched as a foreground service rather than a regular background service, which is the difference between a ride alert reliably appearing versus the OS silently killing the process. The implementation explicitly branches on SDK version to handle this correctly.

**Live Production Payments via Razorpay**
The subscription flow isn't a sandbox demo — Razorpay is wired in production mode, so completing a payment moves real money. The flow covers method selection (UPI apps, cards, netbanking, wallets), payment confirmation, and writes a subscription record to Firestore with active/inactive status and expiry tracking, mirrored back into the UI instantly.

**Document Upload → External Admin Verification**
RC, license front/back, and a live camera-captured profile photo are uploaded to Firebase Storage during onboarding. Rather than auto-approving, every document is reviewed manually through **ZION Panel**, a separate admin repo, where the vehicle is named and categorized according to the actual RC before the driver's onboarding checklist can reach 100%.

**Persisted Localization**
Language selection (English / Hindi / Telugu) is handled by `easy_localization` and persisted directly to device storage with `shared_preferences`, so a driver's language choice survives app restarts without re-fetching or re-prompting.

---

<a id="roadmap"></a>
## 🗺️ Roadmap

- [x] Driver App — this repo
- [x] Rider App — companion repo
- [ ] ZION Panel public release — admin verification dashboard

---

## 👤 Author

**izzy3443** — designed, built, and shipped solo. Figma → Flutter → Kotlin → Firebase.

[![GitHub](https://img.shields.io/badge/GitHub-izzy3443-181717?style=flat&logo=github)](https://github.com/izzy3443)

---

<div align="center">
  <sub> · Flutter + Kotlin + Firebase · 2026</sub>
</div>
