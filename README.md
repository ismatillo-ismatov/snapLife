# SnapLife 🚀 (Social Media App)

SnapLife is a full-featured social networking application. While the UI is kept minimalist, the core focus of this project is a **highly scalable and complex Backend architecture.**

## 🧠 Backend Architecture (The Core)
The backend is built with **Django 5** and focuses on high-performance features:

* **Real-time Communication:** Implemented using **Django Channels (WebSockets)** and **Redis** for instant messaging.
* **Media Management:** Integrated with **Google Cloud Storage** and **AWS S3** for efficient handling of high-resolution images and videos.
* **Smart Notifications:** Automated push-notifications using **Firebase Admin SDK**.
* **Social Logic:** Complex database relations for Friend Requests, Post interactions (Likes/Comments), and News Feed algorithms.
* **Database:** Scalable **PostgreSQL** setup.



## 📱 Frontend (Flutter)
The frontend is built with Flutter, focusing on **functionality over form**. It serves as a bridge to demonstrate the backend's capabilities in a real-world mobile environment.
* Status: Bootstrapped / Minimalist UI.
* Focus: End-to-end integration and API consumption.

## 🛠 Tech Stack
- **Backend:** Python, Django, DRF, WebSockets (Channels), Redis.
- **Cloud/Infrastructure:** Google Cloud, AWS S3, Firebase.
- **Database:** PostgreSQL.
- **Frontend:** Flutter (Dart).

## 🚀 Installation & Setup

### Backend
```bash
cd backend
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
