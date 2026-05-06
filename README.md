# Smart Appointment Scheduling & Queue Management App

A Flutter-based Smart Appointment Scheduling & Queue Management Application designed to simplify appointment booking, queue handling, and admin queue management with offline-first functionality.

---

# Project Overview

Manual appointment systems in clinics, salons, service centers, and college offices often create:

- Long waiting times
- Queue confusion
- Scheduling conflicts
- Overbooking issues
- Lack of real-time queue visibility

This application provides a digital solution where users can book appointments, track their queue position, and administrators can efficiently manage queues in real time.

---

# Features

## Appointment Booking Module
- Book appointments using:
  - User Name
  - Service Type
  - Date
  - Time Slot
- Automatic Appointment ID generation
- Time slot availability tracking

## Queue Management Module
- Automatic queue token generation
- Real-time queue updates
- Current serving token display
- Estimated waiting time
- Queue position tracking

## Admin Control Module
- View all appointments
- Call next person
- Mark appointments as completed
- Cancel appointments
- Manage queue flow dynamically

## Conflict Detection Logic
- Prevents overbooking
- Maximum 2 appointments per slot
- Fully booked slots are disabled
- Prevents past time slot selection

## Appointment Status Tracking
Supports:
- Scheduled
- In Progress
- Completed
- Cancelled

## Search & Filter Module
- Search by:
  - Name
  - Appointment ID
- Filter by:
  - Date
  - Status
  - Service Type

## Offline Functionality
- Offline-first approach using Hive database
- Data persists after app restart
- No internet required for booking and queue management

---

# Tech Stack

| Technology | Usage |
|---|---|
| Flutter | Frontend Framework |
| Dart | Programming Language |
| Provider | State Management |
| Hive | Local Offline Database |
| GitHub | Version Control |

---

# Project Structure

```plaintext
lib/
│
├── models/
├── providers/
├── screens/
├── services/
├── utils/
├── widgets/
└── main.dart
