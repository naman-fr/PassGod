<!-- ====================================== -->
<!--             🚀 PASSGOD README           -->
<!-- ====================================== -->

<p align="center">
  <img src="docs/assets/passgod-logo.png" alt="PASSGOD Logo" width="120" />
</p>
<h1 align="center">PASSGOD</h1>
<p align="center"><em>Universal Password Manager for Web, Mobile, and Social Accounts</em></p>

<p align="center">
  <a href="https://github.com/naman-fr/PassGod/actions">
    <img src="https://img.shields.io/github/actions/workflow/status/naman-fr/PassGod/ci.yml?branch=master&style=for-the-badge" alt="CI Status" />
  </a>
  <a href="https://github.com/naman-fr/PassGod/releases">
    <img src="https://img.shields.io/github/v/release/naman-fr/PassGod?style=for-the-badge" alt="Release Version" />
  </a>
  <a href="https://github.com/naman-fr/PassGod/blob/master/LICENSE">
    <img src="https://img.shields.io/github/license/naman-fr/PassGod?style=for-the-badge" alt="License" />
  </a>
</p>

## 📖 Table of Contents

1. [About](#ℹ️-about)
2. [Features](#✨-features)
3. [Tech Stack](#🛠️-tech-stack)
4. [Getting Started](#🚀-getting-started)
5. [Security](#🔒-security)
6. [Contributing](#🤝-contributing)
7. [License](#📄-license)
8. [Support](#💬-support)

## ℹ️ About
PassGod is a robust and user-friendly application designed to help you securely manage your digital credentials and monitor online breaches. It offers a comprehensive suite of features including a secure password vault, social account management, proactive breach monitoring using Have I Been Pwned (HIBP) API, and activity notifications. Available as both a web application and a mobile app, PassGod ensures your online security is always within reach.

## ✨ Features
- **🔐 Secure Password Vault**: Safely store and manage all your passwords with full Create, Read, Update, and Delete (CRUD) functionalities. Passwords are encrypted for maximum security.
- **📱 Social Account Management**: Organize and monitor your social media accounts. Add, edit, and delete social profiles with platform-specific details and an "Other" option for custom platforms.
- **🚨 Breach Monitoring**: Stay informed about potential data breaches. PassGod proactively checks for compromised passwords and emails using the Have I Been Pwned (HIBP) API, alerting you if your data is found in known breaches.
- **🔔 Activity Notifications**: Keep track of important account activities and security alerts through an integrated notification system.
- **👤 User Profile Management**: Easily update your personal information and change your password directly from the settings page.
- **🌐 Cross-Platform Accessibility**: Access your secure data from anywhere with dedicated web and mobile (Flutter) applications.
- **✨ Modern UI/UX**: Enjoy a captivating and intuitive user experience across all platforms, designed for ease of use and visual appeal.

## 🛠️ Tech Stack

### Backend
- **Python**: Primary language for the backend logic.
- **FastAPI**: Modern, fast (high-performance) web framework for building APIs.
- **SQLAlchemy**: Python SQL toolkit and Object Relational Mapper (ORM).
- **`cryptography`**: For secure encryption and decryption of sensitive data.
- **`requests`**: For making HTTP requests to external APIs like HIBP.
- **SQLite**: Default database for local development.
- **PostgreSQL**: Recommended for production deployments.

### Frontend (Web)
- **React**: A JavaScript library for building user interfaces.
- **TypeScript**: A superset of JavaScript that adds static types.
- **Tailwind CSS**: A utility-first CSS framework for rapid UI development.
- **React Router**: For declarative routing in the web application.

### Frontend (Mobile)
- **Flutter**: Google's UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.
- **`provider`**: For state management in Flutter.
- **`go_router`**: For declarative routing in the mobile application.

## 🚀 Getting Started

### Prerequisites
- **Git**: For cloning the repository.
- **Python 3.8+**: For the backend.
- **Node.js & npm (or yarn)**: For the web frontend.
- **Flutter SDK**: For the mobile application.
- **Visual Studio with "Desktop development with C++" and "C++ ATL" components (for Windows desktop Flutter development)**.

### Backend Setup

1. Navigate to the `backend` directory:
   ```bash
   cd backend
   ```
2. Create and activate a Python virtual environment:
   ```bash
   python -m venv venv
   # On Windows
   .\venv\Scripts\activate
   # On macOS/Linux
   source venv/bin/activate
   ```
3. Install backend dependencies:
   ```bash
   pip install -r requirements.txt
   ```
4. Create a `.env` file in the `backend` directory with the following content. **Replace placeholders with your actual keys.**
   ```env
   SECRET_KEY="YOUR_FERNET_SECRET_KEY" # Generate using `python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"`
   HIBP_API_KEY="YOUR_HIBP_API_KEY"   # Obtain from https://haveibeenpwned.com/API/Key
   DATABASE_URL="sqlite:///./sql_app.db" # Or your PostgreSQL connection string
   ```
5. Run database migrations:
   ```bash
   alembic upgrade head
   ```
6. Start the backend server:
   ```bash
   uvicorn app.main:app --reload
   ```
   The backend API will be available at `http://localhost:8000`.

### Frontend (Web) Setup

1. Navigate to the `frontend` directory:
   ```bash
   cd frontend
   ```
2. Install frontend dependencies:
   ```bash
   npm install
   # or
   yarn install
   ```
3. Start the development server:
   ```bash
   npm run dev
   # or
   yarn dev
   ```
   The web application will typically open in your browser at `http://localhost:3000`.

### Frontend (Mobile) Setup

1. Navigate to the `mobile` directory:
   ```bash
   cd mobile
   ```
2. Get Flutter dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

## 🔒 Security
- End-to-end AES-256 encryption
- Argon2 password hashing
- Biometric unlock & recovery codes
- Two-Factor Authentication
- Breach monitoring & phishing detection

## 🤝 Contributing
We welcome contributions! If you'd like to contribute, please fork the repository and create a pull request with your changes.

## 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.

## 💬 Support
For support, please open an issue in the GitHub repository or contact the maintainers.
