# PassGod: Secure Password and Social Account Manager

## Table of Contents
- [About PassGod](#about-passgod)
- [Features](#features)
- [Technologies Used](#technologies-used)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Backend Setup](#backend-setup)
  - [Frontend (Web) Setup](#frontend-web-setup)
  - [Frontend (Mobile) Setup](#frontend-mobile-setup)
- [Usage](#usage)
- [Screenshots](#screenshots)
- [Contributing](#contributing)
- [License](#license)

## About PassGod
PassGod is a robust and user-friendly application designed to help you securely manage your digital credentials and monitor online breaches. It offers a comprehensive suite of features including a secure password vault, social account management, proactive breach monitoring using Have I Been Pwned (HIBP) API, and activity notifications. Available as both a web application and a mobile app, PassGod ensures your online security is always within reach.

## Features
-   **🔐 Secure Password Vault**: Safely store and manage all your passwords with full Create, Read, Update, and Delete (CRUD) functionalities. Passwords are encrypted for maximum security.
-   **📱 Social Account Management**: Organize and monitor your social media accounts. Add, edit, and delete social profiles with platform-specific details and an "Other" option for custom platforms.
-   **🚨 Breach Monitoring**: Stay informed about potential data breaches. PassGod proactively checks for compromised passwords and emails using the Have I Been Pwned (HIBP) API, alerting you if your data is found in known breaches.
-   **🔔 Activity Notifications**: Keep track of important account activities and security alerts through an integrated notification system.
-   **👤 User Profile Management**: Easily update your personal information and change your password directly from the settings page.
-   **🌐 Cross-Platform Accessibility**: Access your secure data from anywhere with dedicated web and mobile (Flutter) applications.
-   **✨ Modern UI/UX**: Enjoy a captivating and intuitive user experience across all platforms, designed for ease of use and visual appeal.

## Technologies Used

### Backend
-   **Python**: Primary language for the backend logic.
-   **FastAPI**: Modern, fast (high-performance) web framework for building APIs.
-   **SQLAlchemy**: Python SQL toolkit and Object Relational Mapper (ORM).
-   **`cryptography`**: For secure encryption and decryption of sensitive data.
-   **`requests`**: For making HTTP requests to external APIs like HIBP.
-   **SQLite**: Default database for local development.
-   **PostgreSQL**: Recommended for production deployments.

### Frontend (Web)
-   **React**: A JavaScript library for building user interfaces.
-   **TypeScript**: A superset of JavaScript that adds static types.
-   **Tailwind CSS**: A utility-first CSS framework for rapid UI development.
-   **React Router**: For declarative routing in the web application.

### Frontend (Mobile)
-   **Flutter**: Google's UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.
-   **`provider`**: For state management in Flutter.
-   **`go_router`**: For declarative routing in the mobile application.

## Getting Started

Follow these instructions to set up and run the PassGod application on your local machine.

### Prerequisites
-   **Git**: For cloning the repository.
-   **Python 3.8+**: For the backend.
-   **Node.js & npm (or yarn)**: For the web frontend.
-   **Flutter SDK**: For the mobile application.
-   **Visual Studio with "Desktop development with C++" and "C++ ATL" components (for Windows desktop Flutter development)**.

### Backend Setup

1.  Navigate to the `backend` directory:
    ```bash
    cd backend
    ```
2.  Create and activate a Python virtual environment:
    ```bash
    python -m venv venv
    # On Windows
    .\venv\Scripts\activate
    # On macOS/Linux
    source venv/bin/activate
    ```
3.  Install backend dependencies:
    ```bash
    pip install -r requirements.txt
    ```
4.  Create a `.env` file in the `backend` directory with the following content. **Replace placeholders with your actual keys.**
    ```env
    SECRET_KEY="YOUR_FERNET_SECRET_KEY" # Generate using `python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"`
    HIBP_API_KEY="YOUR_HIBP_API_KEY"   # Obtain from https://haveibeenpwned.com/API/Key
    DATABASE_URL="sqlite:///./sql_app.db" # Or your PostgreSQL connection string
    ```
5.  Run database migrations:
    ```bash
    alembic upgrade head
    ```
6.  Start the backend server:
    ```bash
    uvicorn app.main:app --reload
    ```
    The backend API will be available at `http://localhost:8000`.

### Frontend (Web) Setup

1.  Navigate to the `frontend` directory:
    ```bash
    cd frontend
    ```
2.  Install frontend dependencies:
    ```bash
    npm install
    # or
    yarn install
    ```
3.  Start the development server:
    ```bash
    npm run dev
    # or
    yarn dev
    ```
    The web application will typically open in your browser at `http://localhost:3000`.

### Frontend (Mobile) Setup

1.  Navigate to the `mobile` directory:
    ```bash
    cd mobile
    ```
2.  Ensure Flutter is configured for your desired platform (e.g., web or Windows desktop):
    ```bash
    flutter config --enable-web
    flutter config --enable-windows-desktop # If targeting Windows desktop
    ```
    If you encounter Visual Studio related errors on Windows, ensure you have "Desktop development with C++" and "C++ ATL" components installed via the Visual Studio Installer.
3.  Get Flutter dependencies:
    ```bash
    flutter pub get
    ```
4.  Run the application:
    ```bash
    flutter run
    ```
    This will launch the app on an available device or web browser.

## Usage
1.  **Register/Login**: Start by registering a new account or logging in with existing credentials on either the web or mobile app.
2.  **Password Vault**: Add, view, edit, and delete your passwords securely.
3.  **Social Accounts**: Manage your various social media accounts, including custom platforms.
4.  **Breach Monitor**: Check if your registered email or passwords have been compromised in known data breaches.
5.  **Settings**: Update your profile information or change your account password.

## Screenshots
*(Add screenshots of the web and mobile applications here to showcase the UI/UX and key features.)*

## Contributing
We welcome contributions! If you'd like to contribute, please fork the repository and create a pull request with your changes.

## License
This project is licensed under the MIT License - see the LICENSE file for details. 