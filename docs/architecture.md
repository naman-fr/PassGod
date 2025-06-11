# PASSGOD Architecture

## Overview
PASSGOD is a cross-platform password manager supporting web, mobile, and social account integrations. It uses a FastAPI backend, React web frontend, and Flutter mobile app.

## Components
- **Backend:** FastAPI, PostgreSQL, Redis, Firebase, HaveIBeenPwned API
- **Frontend:** React, TailwindCSS
- **Mobile:** Flutter (Android/iOS/Web)

## Security
- End-to-end encryption (AES-256)
- Argon2 password hashing
- JWT authentication
- 2FA, biometric login

## Data Flow
1. User authenticates (JWT, OAuth, or biometrics)
2. All sensitive data is encrypted client-side
3. Backend stores only encrypted blobs
4. Breach monitoring via HaveIBeenPwned API

## Extensibility
- Add new social platforms easily
- Modular frontend and backend
- API-first design 