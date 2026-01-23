# 🌱 EcoHelper – Your Daily Environmental Companion

## 📖 Tentang Proyek

**EcoHelper** adalah aplikasi mobile berbasis Flutter yang dirancang untuk membantu meningkatkan kesadaran masyarakat terhadap isu lingkungan melalui edukasi, tips ramah lingkungan, dan habit tracking yang mudah dipraktikkan dalam kehidupan sehari-hari.

---

## 🎯 Latar Belakang & Motivasi

Permasalahan lingkungan seperti **sampah plastik**, **pemborosan energi**, dan **krisis air bersih** sering kali terjadi bukan karena kurangnya teknologi, tetapi karena:

- ❌ Kurangnya kesadaran masyarakat
- ❌ Minimnya akses informasi yang mudah dipahami
- ❌ Tidak adanya motivasi untuk memulai kebiasaan baik
- ❌ Sulit untuk konsisten menjalankan aksi ramah lingkungan

### 💡 Solusi: EcoHelper

**EcoHelper** hadir sebagai solusi digital yang:

✅ **Tidak hanya menyajikan informasi** – tetapi juga mendorong aksi nyata pengguna  
✅ **Menggabungkan belajar, beraksi, dan melacak progress** dalam satu aplikasi  
✅ **Membuat kebiasaan ramah lingkungan menjadi mudah dan menyenangkan**  
✅ **Menyediakan sistem achievement & impact visualization** untuk memotivasi pengguna  

---

## ✨ Fitur Utama

### 🏠 **Home Dashboard**
- Tampilan overview aplikasi yang clean dan modern dengan desain eco-themed
- Quick action buttons untuk akses cepat ke fitur utama
- Daily tips dan eco awareness highlights
- Navigasi bottom navigation yang intuitif ke semua section

### 📰 **Artikel Lingkungan (Articles)**
- **Koleksi artikel edukasi** tentang isu lingkungan dari berbagai sumber
- Dikelompokkan berdasarkan **kategori**: 
  - 🗑️ Sampah & Daur Ulang
  - ⚡ Energi Terbarukan
  - 💧 Penghematan Air
  - 🌫️ Polusi Udara
  - 🌍 Perubahan Iklim
  - 🌳 Konservasi Alam
- Halaman detail artikel lengkap dengan gambar dan sumber
- **Fitur Search** untuk mencari artikel spesifik
- **Bookmark artikel favorit** untuk dibaca ulang
- List view dengan infinite scroll

### 🔥 **Eco Tracker (Habit Tracker)**
- Track kebiasaan ramah lingkungan harian:
  - 🚫 Tidak menggunakan plastik sekali pakai
  - 💧 Menghemat penggunaan air
  - ⚡ Menghemat energi listrik
  - 🚴 Bersepeda atau jalan kaki
  - ♻️ Daur ulang sampah
- **Statistik & Progress Tracking**:
  - 🔥 **Streak Counter**: Hitung berapa hari berturut-turut berhasil
  - 📊 **Progress 7 Hari Terakhir**: Visualisasi pencapaian mingguan
  - 📅 **Total Bulan Ini**: Lihat konsistensi bulanan
- **Badge System**: Dapatkan achievement (⭐ → 🔥 → 🥇 → 🏆)
- **Auto-reset harian** dengan penyimpanan history
- Data tersimpan lokal menggunakan **Shared Preferences**

### 💡 **Daily Eco Tips**
- Tips harian yang terupdate untuk menjaga lingkungan
- Notifikasi reminder untuk konsistensi kebiasaan
- Kategori tips yang beragam dan praktis
- Desain yang menarik dan mudah dipahami

### 🏆 **Achievements**
- Sistem pencapaian yang memotivasi pengguna
- Unlock badges melalui aktivitas ramah lingkungan
- Tampilan progress menuju badge level selanjutnya
- Leaderboard dan milestone tracking

### 📊 **Impact Visualization**
- Visualisasi dampak personal dari aksi ramah lingkungan
- Carbon footprint calculator
- Estimasi pengurangan limbah yang telah dicapai
- Kontribusi terhadap kelestarian alam

### 🧮 **Carbon Calculator**
- Kalkulator jejak karbon pribadi
- Estimasi dampak lingkungan dari kebiasaan sehari-hari
- Rekomendasi untuk mengurangi emisi karbon

### 📌 **Bookmark**
- Simpan artikel favorit untuk dibaca ulang
- Organisasi bookmark yang rapi
- Hapus bookmark dengan mudah
- Persistent storage dengan **Shared Preferences**

### 👤 **Profile & Settings**
- Informasi profil pengguna
- **Dark Mode Toggle** (tema gelap/terang)
- Halaman **About EcoHelper** dengan informasi aplikasi
- Pengaturan notifikasi
- Logout functionality

### 🔐 **Authentication**
- Login dan Register dengan Supabase
- Email verification
- Password reset
- Secure session management

---

## 🛠 Tech Stack

### **Frontend & Framework**
- **Flutter** – Cross-platform mobile framework
- **Dart** – Programming language (v3.9.2+)

### **State Management**
- **BLoC (Business Logic Component)** – untuk Articles & data flow management
- **Provider / ValueNotifier** – untuk local state

### **Backend & API**
- **Supabase** – Backend-as-a-Service untuk authentication & database
- **News API / Custom API** – Untuk konten artikel lingkungan
- **Local API** – Mock data untuk tips, events, dan achievements

### **Data & Storage**
- **Supabase PostgreSQL** – Cloud database untuk user data
- **Shared Preferences** – Local storage untuk:
  - Bookmark
  - Tracker history & achievements
  - Theme preferences
  - User settings
- **Local JSON** – Dummy data untuk eco tips dan events

### **UI/UX**
- **Material Design 3**
- **Custom Theming** (Light & Dark Mode)
- **Google Fonts** – Typography yang modern
- **Responsive Layout** – Support berbagai ukuran layar
- **Smooth Animations & Transitions**

### **Dependencies Utama**
```yaml
supabase_flutter: ^2.5.6  # Backend & Auth
flutter_bloc: ^9.1.1      # State management
google_fonts: ^6.1.0      # Typography
shared_preferences: ^2.1.1 # Local storage
equatable: ^2.0.5         # Equality comparison
```

---

## 📂 Struktur Proyek

```
lib/
├── main.dart                      # Entry point aplikasi
├── bloc/                          # BLoC untuk state management
│   ├── article_bloc.dart         # BLoC untuk articles
│   ├── article_event.dart        # Events untuk article BLoC
│   └── article_state.dart        # States untuk article BLoC
├── core/                          # Constants, Theme, & Config
│   ├── constants.dart            # App constants
│   ├── env.dart                  # Environment variables
│   └── theme.dart                # Custom theming (light & dark)
├── models/                        # Data models
│   ├── article_model.dart        # Model untuk artikel
│   ├── achievement_model.dart    # Model untuk achievements
│   ├── event_model.dart          # Model untuk events
│   ├── tip_model.dart            # Model untuk eco tips
│   └── tree_model.dart           # Model untuk tree/carbon tracking
├── screens/                       # Halaman UI aplikasi
│   ├── splash_screen.dart        # Splash screen saat startup
│   ├── login_screen.dart         # Login screen
│   ├── register_screen.dart      # Register screen
│   ├── home_screen.dart          # Home/Dashboard
│   ├── articles_screen.dart      # List artikel
│   ├── article_detail_screen.dart # Detail artikel
│   ├── category_articles_screen.dart # Artikel per kategori
│   ├── tracker_screen.dart       # Habit tracker
│   ├── daily_tips_screen.dart    # Daily tips
│   ├── eco_tips_screen.dart      # Eco tips collection
│   ├── achievements_screen.dart  # Achievements & badges
│   ├── impact_visualization_screen.dart # Impact stats
│   ├── carbon_calculator_screen.dart # Carbon calculator
│   ├── event_screen.dart         # Event listing
│   ├── event_detail_screen.dart  # Event details
│   ├── bookmark_screen.dart      # Bookmarked articles
│   ├── search_screen.dart        # Search functionality
│   ├── profile_screen.dart       # User profile
│   ├── settings_screen.dart      # Settings & preferences
│   ├── category_screen.dart      # Category listing
│   └── main_nav.dart             # Main navigation wrapper
├── services/                      # API & Local services
│   ├── api_service.dart          # API calls & data fetching
│   ├── bookmark_service.dart     # Bookmark management
│   ├── settings_service.dart     # Settings & theme management
│   ├── daily_tips_service.dart   # Daily tips service
│   ├── achievements_service.dart # Achievements & badges logic
│   └── tracker_service.dart      # Habit tracking service
└── widgets/                       # Reusable components
    ├── article_card.dart         # Article card widget
    ├── habit_item.dart           # Tracker habit item
    ├── achievement_badge.dart    # Achievement badge widget
    └── ... (komponen UI lainnya)
```

---

## 📱 Demo Aplikasi

### Screenshot

(Dokumentasi screenshot menyusul)

### 🎥 Video Demo

(Video demo menyusul)

---

## 🚀 Cara Menjalankan Aplikasi

### Prerequisites
- **Flutter SDK** v3.9.2 atau lebih tinggi ([Download di sini](https://flutter.dev))
- **Dart SDK** (ter-bundle dengan Flutter)
- **Android Studio** atau **Xcode** (untuk emulator/device)
- **Git**

### Setup Awal

1. **Clone Repository**
   ```bash
   git clone <repository-url>
   cd flutter_application_1
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Konfigurasi Environment**
   - Buat file `.env` atau update file `lib/core/env.dart` dengan:
     ```dart
     class Env {
       static const String supabaseUrl = 'YOUR_SUPABASE_URL';
       static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
     }
     ```

4. **Setup Supabase**
   - Buat project di [Supabase](https://supabase.com)
   - Setup authentication & database
   - Update kredensial di `env.dart`

5. **Jalankan Aplikasi**
   ```bash
   # Untuk Android
   flutter run -d android
   
   # Untuk iOS
   flutter run -d ios
   
   # Untuk Web
   flutter run -d web
   ```

### Development Commands
```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Run tests
flutter test

# Build APK
flutter build apk

# Build iOS
flutter build ios

# Build Web
flutter build web
```

---

## 🧪 Testing

Unit tests dan widget tests ada di folder `test/`:

```bash
# Jalankan semua tests
flutter test

# Jalankan specific test
flutter test test/bookmark_service_test.dart
```

---

## 🎓 Konsep yang Diterapkan

Proyek ini mengimplementasikan berbagai konsep **Pemrograman Mobile** modern:

- ✅ **State Management** dengan BLoC Pattern
- ✅ **Backend Integration** dengan Supabase
- ✅ **Authentication & Authorization**
- ✅ **REST API Integration**
- ✅ **Local Storage** dengan Shared Preferences
- ✅ **Navigation & Routing** (Multi-screen)
- ✅ **Custom Theming** (Light/Dark Mode)
- ✅ **Responsive UI Design** (Adaptive Layout)
- ✅ **CRUD Operations** (Bookmark, Tracker, Settings)
- ✅ **List Views & Infinite Scroll**
- ✅ **Search & Filter Functionality**
- ✅ **Form Validation**
- ✅ **Error Handling & Exception Management**
- ✅ **Asynchronous Programming** (async/await, Future, Stream)
- ✅ **Widget Lifecycle Management**
- ✅ **Custom Widget Composition**
- ✅ **Data Persistence & Caching**

---

## 📋 Fitur yang Masih Dalam Pengembangan

- [ ] Push Notifications untuk reminder habit
- [ ] Community features (share achievement, leaderboard)
- [ ] Advanced analytics & reporting
- [ ] Offline-first capability dengan Hive
- [ ] Video tutorials untuk eco tips
- [ ] Integrasi dengan smart home devices

---