Build a production-ready Flutter application named **"Remindly – Smart Life Reminder"**.

---

## 🎯 PRODUCT GOAL

Create a **minimal, fast, offline-first reminder app** designed for Indian users to track important life events such as bills, recharge, EMI, subscriptions, taxes, and personal reminders.

The app must feel:

* Premium
* Smooth
* Extremely simple to use
* Visually modern (glassmorphism inspired, iOS-like)

---

## 📱 PLATFORM

* Primary: Android
* Future-ready for iOS (write platform-agnostic code)

---

## 🧱 ARCHITECTURE

* Pattern: Clean Architecture
* State Management: Riverpod (preferred: Riverpod Generator)
* Local Database: Hive (with type adapters)
* Notifications: flutter_local_notifications
* Localization: intl (English + Hindi)
* No backend (offline-first)

---

## 🎨 UI / UX DESIGN SYSTEM

### Design Style:

* Glassmorphism (subtle, not overdone)
* Frosted cards with blur (BackdropFilter)
* Semi-transparent surfaces
* Soft shadows + elevation

### Color System:

* Neutral base (light grey / off-white)
* Accent colors per category (not global theme)
* Maintain consistency (do NOT overuse colors)

### Typography:

* Premium font (Google Fonts: Inter / SF Pro style)
* Clear hierarchy:

  * Heading
  * Subheading
  * Body
  * Caption

### Animations:

* Smooth and subtle
* Use:

  * AnimatedContainer
  * Hero transitions (optional)
  * Fade + slide transitions
* No lag, 60fps performance

---

## 🌐 LOCALIZATION

* Language selection on first launch:

  * English
  * Hindi

* All UI strings must support localization

---

## 📊 CORE FEATURES

### 1. SMART REMINDER SYSTEM

User can:

* Create reminder via templates
* Create custom reminder

---

### 2. PRE-BUILT TEMPLATES

#### Financial:

* Mobile Recharge
* Electricity Bill
* Water Bill
* Credit Card Bill
* Loan EMI
* Rent
* Insurance Premium
* SIP Investment
* GST Filing
* Income Tax Filing

#### Subscriptions:

* OTT (Netflix, Prime)
* Music (Spotify, etc.)
* App subscriptions

#### Personal:

* Exams
* Fees
* Medicine
* Gym
* Birthdays / Anniversaries

#### Utility:

* Vehicle Service
* Insurance Renewal
* Pollution (PUC)

---

### 3. AUTO REPEAT SYSTEM

User selectable:

* Daily
* Weekly
* Monthly
* Yearly
* Custom interval (e.g. every 28 days)

---

### 4. SMART NOTIFICATION ENGINE

User selects reminder time.

Each reminder supports:

* Same day notification
* Optional:

  * 1 day before
  * 3 days before

Requirements:

* Schedule local notifications
* Persist after app restart
* Handle repeating reminders correctly
* Timezone-safe scheduling

---

### 5. DASHBOARD (HOME SCREEN)

Sections:

* Today’s Reminders
* Upcoming Reminders
* Overdue Reminders (highlighted)

Design:

* Card-based glass UI
* Smooth scroll
* Clean spacing

---

### 6. QUICK ADD SYSTEM

Floating Action Button:

* Opens bottom sheet
* Shows templates grid
* Add reminder in < 3 taps

---

### 7. REMINDER MANAGEMENT

* Mark as completed (manual only)
* Edit reminder
* Delete reminder
* Highlight overdue items

---

## 🧾 DATA MODEL

Reminder:

* id (string)
* title
* category
* dateTime
* repeatType
* customInterval (nullable)
* notifyOffsets (list<int>)
* isCompleted (bool)
* createdAt

---

## 💾 LOCAL STORAGE

* Hive Boxes:

  * reminders
  * settings

* Efficient queries:

  * today
  * upcoming
  * overdue

---

## 🔔 NOTIFICATION SYSTEM

* Use flutter_local_notifications
* Schedule:

  * exact time notifications
* Re-register notifications on app launch
* Handle repeating logic properly

---

## 💰 MONETIZATION (AdMob)

IMPORTANT: Keep ad experience non-intrusive.

### Banner Ads:

* Show on dashboard bottom only

### Interstitial Ads:

* Show after reminder creation
* Max: 1 per session

### Rewarded Ads:

* Unlock:

  * Extra themes
  * Snooze feature

DO NOT:

* Show ads during core actions
* Interrupt user flow

---

## ⚡ PERFORMANCE REQUIREMENTS

* App size under 20MB
* Fast startup
* No frame drops
* Efficient rebuilds (use const widgets)

---

## 🧭 UX RULES

* Reminder creation < 5 seconds
* No login/signup
* No unnecessary permissions
* Fully offline

---

## 📁 PROJECT STRUCTURE

Follow modular clean architecture:

/features
/reminders
/data
/domain
/presentation

/core
/theme
/widgets
/services (notifications, ads)
/utils

---

## 📱 SCREENS TO BUILD

1. Splash Screen
2. Language Selection Screen
3. Dashboard Screen
4. Add Reminder Bottom Sheet
5. Reminder Detail/Edit Screen

---

## 🧩 REQUIRED COMPONENTS

* Glass Card Widget
* Reminder Tile
* Category Chip
* Floating Add Button
* Notification Service
* Hive Service
* Ad Service

---

## 🧪 OPTIONAL (IF EASY)

* Dark Mode
* Local backup/export

---

## OUTPUT EXPECTATION

* Complete Flutter project
* Clean folder structure
* Working reminder logic
* Notification scheduling implemented
* Hive integrated
* AdMob integrated
* Clean UI implemented

Code must be:

* Readable
* Modular
* Production-ready

---

Focus on:
Simplicity + Speed + UX polish

Avoid:
Overengineering, unnecessary complexity, heavy UI
