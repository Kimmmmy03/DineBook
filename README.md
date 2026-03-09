# DineBook - Restaurant Package Reservation System

## Original Authors
This project is created and maintained by:

* **Akmal Hakimi Bin Abd Rashid**
* **Khairul Aqif Danial Bin Khairul Nizam**
* **Ahmad Azri Bin Anuar**
* **Danial Mikail Bin Md Ismail**

## Introduction
**DineBook** is a Flutter mobile application developed as part of the **ISB26603 - Mobile and Ubiquitous Computing** course at **Universiti Kuala Lumpur (UniKL MIIT)** during the March 2025 session. The application serves as a restaurant package reservation system for **"The Gourmet Haven"**, an Italian restaurant.

The goal of this project is to provide a fully functional mobile app that allows customers to browse curated Italian menu packages, make reservations, and manage their profiles — while giving administrators a real-time dashboard to oversee all users and bookings. The app is powered by **Firebase Authentication** and **Cloud Firestore** for secure, real-time data management.



## Problem Statements & Objectives

### Problem Statements
* **Manual Reservation Handling**: Managing restaurant bookings manually through phone calls or walk-ins is inefficient, error-prone, and difficult to track.
* **Lack of Centralized Management**: Without a digital system, administrators have no unified view of all users, bookings, and menu selections.
* **Limited Customer Access**: Customers cannot easily browse available menu packages, make reservations, or manage their bookings on the go.

### Objectives
* Develop a mobile application that allows customers to **browse**, **book**, and **manage** Italian menu package reservations
* Implement **Firebase Authentication** for secure user registration and login with email verification
* Use **Cloud Firestore** as a real-time NoSQL database for storing user profiles and booking records
* Provide an **administrator dashboard** with real-time oversight of all users and bookings
* Support full **CRUD operations** for both bookings (customer-side) and user management (admin-side)
* Deliver a polished, Italian-themed **UI/UX** with a consistent warm color palette

## Program Scope
The DineBook application allows users to:
* **Browse Menu Packages** — View 5 curated Italian menu packages with food images, accessible without login
* **Register & Login** — Create an account with email verification, or log in with existing credentials
* **Make Reservations** — Book one or more menu packages with guest count, date, and time selection
* **Manage Bookings** — View, edit, and delete existing reservations
* **Update Profile** — Change name, phone, email (with re-authentication), and password
* **Admin Dashboard** — Administrators can view all users/bookings, edit user details, and delete users

The application is built with **Flutter** (Dart SDK ^3.8.1) and uses **Firebase** for authentication and database services.

## Menu Packages

| Package | Items |
| :--- | :--- |
| `Classic Italiano` | Pizza Margherita, Spaghetti Carbonara, Tiramisu |
| `Romano Delight` | Lasagna, Garlic Bread, Cannoli |
| `Napoli Feast` | Seafood Linguine, Caprese Salad, Panna Cotta |
| `Tuscan Table` | Grilled Chicken Risotto, Bruschetta, Gelato |
| `Venetian Vibes` | Beef Bolognese, Focaccia Bread, Affogato |

## Tech Stack

| Layer | Technology |
| :--- | :--- |
| `Framework` | Flutter (Dart SDK ^3.8.1) |
| `Authentication` | Firebase Authentication (email/password) |
| `Database` | Cloud Firestore (real-time NoSQL) |
| `State Management` | StatefulWidgets with direct Firebase calls |
| `Linting` | flutter_lints ^5.0.0 |
| `Firebase Project` | dinebook-68fcd |

### Dependencies

```yaml
firebase_core: ^3.14.0
firebase_auth: ^5.6.0
cloud_firestore: ^5.6.9
firebase_ui_auth: ^1.17.0
provider: ^6.1.5
cupertino_icons: ^1.0.8
```

## Prerequisites
* **Flutter SDK** installed and added to your PATH
* **Dart SDK** ^3.8.1
* **Android Studio** or **VS Code** with Flutter extensions
* An Android emulator or physical device (USB debugging enabled)
* Firebase project already configured (`firebase.json` and `lib/firebase_options.dart` are included)

## Getting Started

1. **Clone or extract** the project to your local machine.

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app** on a connected device or emulator:
   ```bash
   flutter run
   ```

4. **Build a release APK:**
   ```bash
   flutter build apk
   ```

5. **Run static analysis:**
   ```bash
   flutter analyze
   ```

6. **Run tests:**
   ```bash
   flutter test
   ```

## Project Structure

```
lib/
├── main.dart                  # App entry point, Firebase init, route definitions
├── welcome_page.dart          # Landing/splash screen
├── login_page.dart            # Email/password login with admin role detection
├── register_page.dart         # New user registration with email verification
├── main_page.dart             # Bottom navigation shell (Home, Booking, Profile)
├── home_page.dart             # Menu package listing with food images
├── menu_detail_page.dart      # Package detail view with image carousel
├── booking_page.dart          # Booking CRUD with date/time/package selection
├── profile_page.dart          # User profile view/edit and password change
├── admin_dashboard_page.dart  # Admin tabbed view (Users / Bookings)
├── admin_edit_user_page.dart  # Admin form to edit user details
├── firebase_options.dart      # Auto-generated Firebase configuration
├── services/
│   └── database.dart          # Centralized DatabaseService for all Firestore/Auth ops
└── widgets/
    └── menu_card.dart         # Reusable menu card widget

assets/                        # Food images and app logo (dinebook.png)
test/
└── widget_test.dart           # Widget tests
```

### Class Diagram Structure
* **main.dart (App Entry)**: Initializes Firebase, defines named routes, and launches the MaterialApp.
* **DatabaseService (Service Layer)**: Single class centralizing all Firestore and Firebase Auth operations.
* **MainPage (Navigation Shell)**: Bottom navigation bar managing Home, Booking, and Profile tabs.
* **AdminDashboardPage (Admin Panel)**: Tabbed interface with real-time StreamBuilders for users and bookings.

| Class | Responsibility |
| :--- | :--- |
| `DatabaseService` | All Firestore CRUD and Firebase Auth operations (sign in, sign out, user/booking management) |
| `MainPage` | Navigation shell with `BottomNavigationBar` managing 3 child pages and menu detail overlay |
| `HomePage` | Displays 5 hardcoded Italian menu packages as scrollable cards with images |
| `BookingPage` | Booking form dialog with multi-select packages, date/time pickers, and CRUD operations |
| `ProfilePage` | User profile display, inline editing, email change with re-auth, and password update |
| `LoginPage` | Email/password authentication with admin role detection and routing |
| `RegisterPage` | New user sign-up with Firestore profile creation and email verification |
| `MenuDetailPage` | Package detail view with auto-sliding image carousel and "Book Now" callback |
| `AdminDashboardPage` | Tabbed admin view (Users/Bookings) with real-time Firestore streams |
| `AdminEditUserPage` | Form to edit user details including admin role toggle |

## Database Schema

### Cloud Firestore Collections

**`users`** — Document ID = Firebase Auth UID

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | String | User's full name |
| `email` | String | User's email address |
| `phone` | String | User's phone number |
| `isAdmin` | Boolean | Admin role flag (default: `false`) |
| `updatedAt` | Timestamp | Last profile update time |

**`bookings`** — Auto-generated Document ID

| Field | Type | Description |
| :--- | :--- | :--- |
| `userId` | String | Reference to the user's Auth UID |
| `guests` | Number | Number of guests |
| `menuPackages` | Array\<String\> | Selected menu package names |
| `date` | String | Booking date (ISO 8601 format) |
| `time` | String | Booking time (formatted string) |
| `timestamp` | Timestamp | Record creation/update time |

## Application Flow

```
┌─────────────┐
│ WelcomePage  │──── "Get Started" ───►┌──────────┐
└─────────────┘                        │ MainPage │
                                       │ (3 tabs) │
                                       └────┬─────┘
                              ┌──────────────┼──────────────┐
                              ▼              ▼              ▼
                         ┌─────────┐   ┌──────────┐   ┌──────────┐
                         │  Home   │   │ Booking  │   │ Profile  │
                         │  Page   │   │  Page    │   │  Page    │
                         └────┬────┘   └──────────┘   └──────────┘
                              │
                     "View Details"
                              ▼
                      ┌──────────────┐
                      │ MenuDetail   │─── "Book Now" ──► Booking Tab
                      │    Page      │
                      └──────────────┘

┌──────────┐     ┌───────────┐    isAdmin?    ┌─────────────────┐
│ LoginPage│────►│ Auth Check │──── Yes ──────►│ AdminDashboard  │
└──────────┘     └───────────┘                 │  (Users/Bookings│
                       │                       │   Tabs)         │
                      No                       └─────────────────┘
                       │
                       ▼
                  ┌──────────┐
                  │ MainPage │
                  └──────────┘
```

### Navigation Routes

| Route | Page | Description |
| :--- | :--- | :--- |
| `/` | WelcomePage | Initial landing screen |
| `/main` | MainPage | Main app shell with bottom navigation |
| `/register` | RegisterPage | New user sign-up form |
| `/admin_dashboard` | AdminDashboardPage | Admin management interface |

## Features

### Customer Features
* **Welcome Screen** — Branded landing page with the DineBook logo and "Get Started" entry point
* **Menu Browsing** — Browse 5 Italian menu packages with food images, no login required
* **Menu Details** — View package details with an auto-sliding image carousel (3-second interval)
* **User Registration** — Sign up with name, email, phone, and password; email verification sent automatically
* **User Login** — Secure email/password authentication via Firebase Auth
* **Booking Management** — Create, view, edit, and delete reservations with multi-package selection, guest count, date, and time pickers
* **Profile Management** — Update name, phone, and email (with re-authentication); change password securely
* **Logout** — Sign out and return to the welcome screen

### Administrator Features
* **Role-Based Login** — Users with `isAdmin: true` in Firestore are automatically redirected to the admin dashboard
* **Users Tab** — Real-time list of all registered users with their booking history displayed inline
* **Bookings Tab** — Real-time overview of all bookings across the system with full details
* **Edit User** — Modify user details (name, email, phone, admin status) via a dedicated form page
* **Delete User** — Remove a user and all their associated bookings with a confirmation dialog
* **Secure Logout** — Sign out and return to the welcome screen

## Screenshots Guide

### Customer Flow
1. **Welcome Screen** — App launches with the DineBook logo and "Get Started" button
2. **Home Page** — Displays all 5 Italian menu packages as scrollable cards
3. **Menu Details** — Auto-sliding image carousel with package description and "Book Now" button
4. **Registration** — Fill in name, email, phone, and password; verification email is sent
5. **Login** — Enter registered email and password to authenticate
6. **New Booking** — Select menu packages (multi-select), number of guests, date, and time
7. **View Bookings** — List of all user bookings with edit and delete options
8. **Edit Booking** — Pre-filled form dialog to modify an existing booking
9. **Delete Booking** — Confirmation dialog before deletion
10. **Profile View** — Displays name, email, and phone in read-only mode
11. **Edit Profile** — Toggle edit mode to update name, email, and phone
12. **Change Password** — Enter current and new password with re-authentication

### Admin Flow
1. **Admin Login** — Same login page; admin users are auto-redirected to the dashboard
2. **Users Tab** — Lists all non-admin users with their booking details
3. **Bookings Tab** — Shows all bookings with booking ID, user ID, package, date, time, and guests
4. **Edit User** — Form to update user name, email, phone, and admin status
5. **Delete User** — Confirmation dialog; deletes user and all their bookings
6. **Admin Logout** — Returns to the welcome screen

## Theme
The app uses a consistent Italian-inspired warm color palette:

| Role | Color | Hex |
| :--- | :--- | :--- |
| Primary | Dark Red | `#7B2D26` |
| Accent | Warm Tan | `#B08968` |
| Background | Cream | `#FFF8F0` |
| Card | Light Cream | `#FAF3E0` |
| Text Primary | Dark Brown | `#5E3023` |
| Text Secondary | Deep Brown | `#3E2723` |

