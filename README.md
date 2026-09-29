# Convoy — "Ride together. Stay together."

A native, production-quality iOS motorcycle group-riding companion built with **SwiftUI**, **SwiftData**, and **MapKit**.

---

## Overview

Motorcycle group rides often suffer from fragmentation: riders get separated at traffic lights, miss highway exits, or fall behind without the group knowing. **Convoy** solves this with native real-time group awareness:
- **Where is everyone?** Live MapKit view showing all riders with real-time speed and status.
- **Who is leading and who is behind?** Real-time Convoy Formation Tape displaying the exact riding order (Lead, Mid-pack, Sweep) and separation distance in meters.
- **Did someone stop?** Automated separation detection alerting the group if a rider stops or falls behind > 800m.
- **Glove-friendly communication:** Large 1-tap quick signals for Fuel Stop ⛽️, Pull Over 🛑, Road Hazard ⚠️, and Thumbs Up 👍.
- **Emergency Safety:** 10-second pulsating SOS beacon broadcasting GPS coordinates and Medical ID to the pack and emergency contacts.

---

## Requirements

- **iOS 17.0+**
- **Xcode 15.0+**
- **Swift 5.9+**

---

## Getting Started

### Opening in Xcode
Double-click `Convoy.xcodeproj` or run:
```bash
open Convoy.xcodeproj
```

Select any iOS Simulator (e.g., iPhone 15 Pro, iPhone 16 Pro) or your connected iPhone, and press **Cmd + R** to run.

---

## App Features & Screen Architecture

### 1. Home (`HomeView.swift`)
- Hero time-of-day greeting
- "Start a Ride" primary call-to-action
- Live upcoming ride card with route details and roster avatars
- Quick actions grid (Plan Ride, Join by Code/QR, Emergency SOS, Safety Center)
- Recent completed ride recap with simulated route curve

### 2. Live Convoy Mode (`LiveRideView.swift`)
- **Interactive MapKit View:** 3D pitch/heading map with custom annotated rider markers for Lead, Mid-pack, Sweep, and Waypoints.
- **Convoy Formation Ribbon:** Top real-time chain showing rider positions and safety spacing.
- **Separation Alerts:** Animated alerts notifying the group when a rider falls behind.
- **Glove-Friendly Telemetry HUD:** High-contrast 52pt speedometer, live lean angle indicator (°), compass heading, and remaining trip distance.
- **1-Tap Quick Signals:** Audio/haptic broadcast triggers for instant group communication.
- **Emergency SOS:** Top-right red beacon button for immediate crisis handling.

### 3. Ride Planning & AI Twisties Engine (`PlanRideView.swift`)
- Route builder from start point to destination.
- **Convoy AI Route Engine:** Curviness slider to prioritize mountain switchbacks and avoid commercial expressways.
- Interactive waypoint management (Meeting point, Fuel refill, Breakfast/Chai, Scenic viewpoints).
- Group formation settings (Staggered, Single File, Free Pace) and pacing guidelines.

### 4. Rides Tab & Itinerary Details (`RidesView.swift`, `RideDetailView.swift`)
- Filter by Upcoming, Past, or All rides.
- Detailed route overview with MapKit camera framing.
- Full convoy roster with Road Captain (Lead) and Sweep assignments.
- Step-by-step route itinerary timeline with estimated stops.
- Shareable QR code and invite link modal (`ShareRideSheet`).

### 5. Clubs & Regional Chapters (`ClubsView.swift`)
- Browse verified clubs (e.g. *Royal Enfield Brotherhood*, *Western Ghats Riders*).
- Member rosters, riding etiquette, safety rules, and cumulative distance stats.
- Create new chapters with description and city tags.

### 6. Friends & Live Pack (`FriendsView.swift`)
- Live status banner displaying friends currently on the road.
- Roster cards with bike models and quick "Invite to Ride" buttons.
- Personal Rider Card with QR code for instant pairing at meeting points.

### 7. Safety Center & Emergency SOS (`SafetyCenterView.swift`, `SOSView.swift`)
- **Pulsating SOS Countdown:** 10-second timer with continuous haptic pulse and single-tap cancellation.
- Automated SMS / notification broadcast simulation with exact GPS coordinates.
- Critical Medical ID snapshot (Blood group, allergies, emergency contacts).
- Crash detection toggle and High-G impact simulator.

### 8. Ride Journal & Memories (`RideJournalView.swift`, `RideCompleteView.swift`)
- Post-ride celebration screen capturing max left/right lean angles and elevation climbed.
- Preserved trip narratives, milestone highlights, and photo moments.

---

## Design System & Styling

- **Theme Palette:**
  - Dark Mode Hero Background: `#0A0A0C`
  - Elevated Surface: `#1C1C1E` / `#2C2C2E`
  - Accent Color: `#FF6B35` (Warm amber-orange)
  - Safety Alert: `#FF3B30`
  - Success Indicator: `#34C759`
  - Warning: `#FF9500`
- **Typography:** Native Apple San Francisco with curved numbers for speed and telemetry.
- **Haptics:** Contextual tactile feedback via `HapticManager.swift` for button taps, tab selection, ride start/finish, and emergency alerts.

---

## Demo Mode

The application automatically seeds a rich set of demo data on first launch via `DemoDataService.swift`:
- Active user: **Kevin Mathews** (Riding an *RE Himalayan 450* & *KTM Duke 390*).
- 4 realistic upcoming and completed rides across scenic South Indian routes (Western Ghats, Yelagiri Hills, Ooty Nilgiri Pass).
- Motorcycle clubs and active riding friends.
