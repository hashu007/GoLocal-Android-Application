******🗺️ Go Local — Android Tourism & Events Guide App******

Go Local is a Flutter-based Android application that helps users explore nearby attractions, events, and places of interest across major cities of Pakistan.
It provides both public and admin dashboards, allowing visitors to discover destinations while giving admins the ability to manage attractions, events, and user reviews in real time.

****📱 Features****
**👥 Public Dashboard**

Browse attractions and events by city (Karachi, Lahore, Islamabad, etc.)

Search with live filters by name or title

View detailed information for each attraction/event

Open location in Google Maps

Add and view reviews with live ratings

Personalized profile with image upload

**🛠️ Admin Dashboard**

Manage Attractions (Add / Edit / Delete)

Manage Events (Add / Edit / Delete)

Review moderation system

Upload images via Firebase Storage

Real-time Firestore updates

**🔐 Authentication**

Firebase Authentication for secure login/signup

Logout and session management

☁️ Cloud Integration

Firebase Firestore (Database)

Firebase Storage (Image Hosting)

Firebase Auth (User Access Control)

**⚙️ Tech Stack**
Layer	Technology
Frontend	Flutter (Dart)
Backend	Firebase Firestore
Cloud Storage	Firebase Storage
Authentication	Firebase Auth
IDE Used	Android Studio
Platform	Android
**🧩 Folder Structure**
lib/
├── admin_dashboard.dart
├── ProfilePage.dart
├── PublicDashboard.dart
├── _ImagePlaceholder.dart
├── SignIn.dart
├── SignUp.dart
├── SplashScreen.dart
├── main.dart

****🧰 Installation Guide****
Prerequisites

Install Flutter SDK

Create and configure a Firebase Project

Connect Firebase using google-services.json

Install Android Studio or VS Code

****Steps****

**Clone the repository**

git clone https://github.com/YOUR_USERNAME/go-local.git
cd go-local


**Install dependencies**

flutter pub get


**Add Firebase**

Place your google-services.json inside /android/app/

Enable Firestore, Authentication, and Storage in Firebase Console

**Run the app**

flutter run

****🚀 How to Use****

Launch the app and sign in or register.

Browse attractions or events by city.

Tap a card to view full details and location.

Add your review and star rating.

(Admin) Use the dashboard to manage content dynamically.

## 📸 App Screenshots  

### 🧭 User Interface  

| Splash Screen | Login | Signup |  
|:--------------:|:------:|:------:|  
| ![SplashScreen](https://raw.githubusercontent.com/hashu007/GoLocal-Android-Application/main/screenshots/SplashScreen.jpeg) | ![Login](https://raw.githubusercontent.com/hashu007/GoLocal-Android-Application/main/screenshots/Login.jpeg) | ![Signup](https://raw.githubusercontent.com/hashu007/GoLocal-Android-Application/main/screenshots/Signup.jpeg) |  

---

### 👤 User Dashboard  

| Public Dashboard | City Filter | Detail Page |  
|:-----------------:|:------------:|:------------:|  
| ![Public Dashboard](https://raw.githubusercontent.com/hashu007/GoLocal-Android-Application/main/screenshots/Public%20Dashboard.jpeg) | ![City Filter](https://raw.githubusercontent.com/hashu007/GoLocal-Android-Application/main/screenshots/City%20Filter.jpeg) | ![Detail Page](https://raw.githubusercontent.com/hashu007/GoLocal-Android-Application/main/screenshots/Detail%20Page.jpeg) |  

| Review Section | Reviews | Profile Page |  
|:---------------:|:--------:|:-------------:|  
| ![review section](https://raw.githubusercontent.com/hashu007/GoLocal-Android-Application/main/screenshots/review%20section.jpeg) | ![Reviews](https://raw.githubusercontent.com/hashu007/GoLocal-Android-Application/main/screenshots/Reviews.jpeg) | ![profile page](https://raw.githubusercontent.com/hashu007/GoLocal-Android-Application/main/screenshots/profile%20page.jpeg) |  

---

### 🧑‍💻 Admin Dashboard  

| Admin Dashboard | Add Portion | Admin Events Tab |  
|:----------------:|:------------:|:----------------:|  
| ![Admin dash](https://raw.githubusercontent.com/hashu007/GoLocal-Android-Application/main/screenshots/Admin%20dash.jpeg) | ![Add Portion](https://raw.githubusercontent.com/hashu007/GoLocal-Android-Application/main/screenshots/Add%20Portion.jpeg) | ![admin events tab](https://raw.githubusercontent.com/hashu007/GoLocal-Android-Application/main/screenshots/admin%20events%20tab.jpeg) |  

| Events Tab | Sidebar | Forget Password |  
|:-----------:|:--------:|:----------------:|  
| ![Events Tab](https://raw.githubusercontent.com/hashu007/GoLocal-Android-Application/main/screenshots/Events%20Tab.jpeg) | ![Sidebar](https://raw.githubusercontent.com/hashu007/GoLocal-Android-Application/main/screenshots/Sidebar.jpeg) | ![Forget Password](https://raw.githubusercontent.com/hashu007/GoLocal-Android-Application/main/screenshots/Forget%20Password.jpeg) |  


****📄 License****

This project is licensed under the
Creative Commons Attribution-NoDerivatives 4.0 International (CC BY-ND 4.0) license.

🛡️ You may share this project freely, but cannot modify or redistribute altered versions.
📘 Learn more: https://creativecommons.org/licenses/by-nd/4.0/

