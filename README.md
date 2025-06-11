# PASSGOD Monorepo

Universal Password Manager for Web, Mobile, and Social Accounts

## Projects
- **backend/** — FastAPI backend
- **frontend/** — React + Tailwind web app
- **mobile/** — Flutter mobile app
- **docs/** — Documentation

## Quick Start

### Backend
```
cd backend
cp .env.example .env
pip install -r requirements.txt
uvicorn app.main:app --reload
```

### Frontend
```
cd frontend
npm install
npm run dev
```

### Mobile
```
cd mobile
flutter pub get
flutter run
```

---

See each subproject for more details.

## 🌟 Features

- **Cross-Platform Support**
  - Web Application (Responsive)
  - Mobile Apps (iOS & Android)
  - Browser Extensions

- **Social Media Integration**
  - WhatsApp
  - Instagram
  - Reddit
  - Discord
  - Facebook
  - LinkedIn
  - Custom Site Support

- **Security Features**
  - End-to-End Encryption
  - Biometric Authentication
  - Two-Factor Authentication
  - Password Strength Analyzer
  - Breach Monitoring
  - Phishing Detection

- **User Experience**
  - Password Generator
  - Auto-fill Capabilities
  - Password Sharing (Secure)
  - Emergency Access
  - Password History
  - Secure Notes

## 🚀 Tech Stack

### Frontend
- React (Web)
- Flutter (Mobile)
- TailwindCSS
- Material Design

### Backend
- Python (FastAPI)
- PostgreSQL
- Redis (Caching)
- Firebase (Auth & Push Notifications)

### Security
- AES-256 Encryption
- Argon2 Password Hashing
- JWT Authentication
- SSL/TLS

## 📦 Project Structure

```
passgod/
├── frontend/                 # Web Application
│   ├── src/
│   ├── public/
│   └── package.json
├── mobile/                   # Flutter Mobile App
│   ├── lib/
│   └── pubspec.yaml
├── backend/                  # FastAPI Backend
│   ├── app/
│   ├── tests/
│   └── requirements.txt
├── browser-extension/        # Browser Extension
│   ├── src/
│   └── manifest.json
└── docs/                     # Documentation
```

## 🛠️ Setup Instructions

1. Clone the repository
2. Install dependencies
3. Set up environment variables
4. Run development servers

Detailed setup instructions for each component can be found in their respective directories.

## 🔒 Security

PASSGOD implements industry-standard security practices:
- Zero-knowledge architecture
- End-to-end encryption
- Regular security audits
- GDPR compliance
- Data privacy by design

## 📄 License

This project is proprietary and confidential. Unauthorized copying, distribution, or use is strictly prohibited.

## 🤝 Contributing

For internal development only. Please contact the development team for access.

## 📞 Support

For support, please contact support@passgod.com 