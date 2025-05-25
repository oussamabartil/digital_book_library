# 📚 Book Manager - Flutter App

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-07405E?style=for-the-badge&logo=sqlite&logoColor=white)

A Flutter application for searching books using Google Books API and managing favorites with SQLite local storage.


*(Replace with your actual screenshot)*

##  Features

-  Search books by title/author using Google Books API
-  Save favorite books to local SQLite database
-  Remove books from favorites
-  Responsive design for mobile and web
-  Cross-platform (Android, iOS, Web)
-  Handles missing book covers gracefully

## 🛠️ Installation

1. Clone the repository:
   ```bash
   git clone https://github.comoussamabartil/digital_book_library.git
   cd book_manager

2. Install dependencies:
   ```bash
   flutter pub get
3. Run the app:
  ```bash
  flutter run

```


📂 Project Structure
```bash
lib/
├── models/
│   └── book.dart          # Book data model
├── services/
│   ├── api_service.dart   # Google Books API service
│   └── db_service.dart   # SQLite database service
├── widgets/
│   └── book_card.dart     # Reusable book card widget
└── main.dart              # App entry point
```
⚙️ Configuration
For Web Support
Update image URLs in book.dart:
```bash
String? imageUrl = json['volumeInfo']['imageLinks']?['thumbnail']
    ?.replaceFirst('http:', 'https:')
    ?.replaceAll('&edge=curl', '');
```
For Mobile (Android/iOS)
SQLite works automatically. No additional setup needed.
🗃️ Database Schema
```bash
CREATE TABLE favorites (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  author TEXT,
  imageUrl TEXT
)
```
🌐 API Usage
Uses Google Books API:

Endpoint: https://www.googleapis.com/books/v1/volumes?q={query}

Example: Search for "Flutter"

