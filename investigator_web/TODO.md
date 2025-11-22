# TODO List for Investigator Web App Fixes

## Language Change
- [x] Change UI language from Arabic to English
  - Update main.dart to force English locale
  - Add locale and supportedLocales to MaterialApp
  - Ensure all UI elements display in English

## Notifications Duplication Fix
- [x] Remove duplicate notifications display
  - Remove "New Notifications" stat card from dashboard_screen.dart
  - Keep notifications only in the bottom navigation tab
  - Removed the entire second row containing "New Notifications" card

## Navigation Enhancement
- [x] Add click functionality to stat cards
  - Make "Under Review" stat card clickable to navigate to filtered reports list
  - Make "New Reports" stat card clickable to navigate to filtered reports list
  - Make "Closed Reports" stat card clickable to navigate to filtered reports list

## Database Connection Confirmation
- [x] Confirm web app is connected to Supabase database
  - Verify Supabase initialization in main.dart
  - Check if services are using Supabase for data fetching
