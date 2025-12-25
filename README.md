# SnapLife 🚀 (Social Media App)

SnapLife is a full-featured social networking application. While the UI is kept minimalist, the core focus of this project is a **highly scalable and complex Backend architecture.**

## 🧠 Backend Deep-Dive (The Core)
The backend is built with **Django 5** and focuses on high-performance features:

* **Real-time Communication:** Uses **Django Channels (WebSockets)** for instant messaging. I used **Redis** as a channel layer to handle asynchronous message passing efficiently.
* **Cloud Infrastructure:** * **AWS S3 & Google Cloud:** Implemented for secure and scalable media storage.
    * **Firebase Admin SDK:** Integrated for automated push-notifications on friend requests and messages.
* **Complex Social Logic:** * Custom friendship system handling complex querysets.
    * Optimized News Feed algorithms using PostgreSQL indexing for faster data retrieval.

## 🛠 Tech Stack
- **Backend:** Python 3.12, Django 5.x, Django Rest Framework (DRF).
- **Real-time:** Channels, Redis.
- **Database:** PostgreSQL (with complex indexing and relations).
- **DevOps/Cloud:** AWS S3, Google Cloud, Firebase.
- **Frontend:** Flutter (Dart).

## 📱 Frontend (Flutter)
Built with Flutter, primarily as a client-side interface to demonstrate the robust API. 
* **Status:** Functional/Minimalist.
* **Highlights:** Full API integration, real-time socket connection, and push notification handling.

## 🚀 Installation & Setup

### Backend
1. Clone the repo
2. Install dependencies: `pip install -r requirements.txt`
3. Set up `.env` (Database and Cloud credentials)
4. Run migrations: `python manage.py migrate`
5. Start server: `python manage.py runserver`

### Frontend
1. `cd frontend`
2. `flutter pub get`
3. `flutter run`

## 🔗 Project Links
- **Google Play:** [Play Market Linki]
- **Video Demo:** [Video Linki]
