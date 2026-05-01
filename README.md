🔐 Secure Notes System (Flutter)

A simple yet secure mobile application built using Flutter that allows users to create, store, and manage personal notes with encryption. This app ensures privacy by encrypting all notes before saving them locally.

✨ Features
🔑 User Authentication (Login & Signup)
🔐 AES Encryption for secure note storage
📝 Add, view, and delete notes
💾 Local storage using SharedPreferences
🚪 Logout functionality
🌙 Dark theme UI for better user experience
🛠️ Tech Stack
Flutter (Dart) – Frontend framework
SharedPreferences – Local data storage
encrypt package (AES) – Data encryption
🔒 Security

All notes are encrypted using AES encryption before being stored locally. Only decrypted when displayed to the authenticated user.

📱 How It Works
User signs up and credentials are stored locally.
On login, credentials are verified.
Notes are added and encrypted before saving.
Stored notes are decrypted only when displayed.
Users can delete notes anytime.
🚀 Future Improvements
Biometric authentication (Fingerprint/Face ID)
Cloud backup (Firebase)
Stronger key management
Password hashing instead of plain storage
