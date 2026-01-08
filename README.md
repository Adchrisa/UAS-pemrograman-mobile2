# 🌱 EcoHelper – Your Daily Environmental Companion

## 📖 Tentang Proyek

**EcoHelper** adalah aplikasi mobile berbasis Flutter yang dirancang untuk membantu meningkatkan kesadaran masyarakat terhadap isu lingkungan melalui edukasi, tips ramah lingkungan, dan habit tracking yang mudah dipraktikkan dalam kehidupan sehari-hari.

> *"Small actions, when multiplied by millions of people, can transform the world."*

Aplikasi ini dibuat sebagai proyek **Ujian Akhir Semester (UAS)** untuk Mata Kuliah **Pemrograman Mobile 2**, dengan fokus pada penerapan Flutter (Dart), integrasi API, state management menggunakan BLoC, serta desain antarmuka yang user-friendly.

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

---

## ✨ Fitur Utama (fitur lain menyusul, dalam progress)

### 🏠 **Home Dashboard**
- Tampilan overview aplikasi yang clean dan modern
- Quick action buttons untuk akses cepat ke fitur utama
- Highlight aktivitas ramah lingkungan harian
- Navigasi intuitif ke semua section

### 📰 **Artikel Lingkungan (Articles)**
- **200+ artikel edukasi** tentang isu lingkungan
- Diambil dari **News API** (berita lingkungan terkini)
- Dikelompokkan berdasarkan **kategori**: Sampah, Energi, Air, Polusi, dll.
- Halaman detail artikel lengkap dengan gambar dan sumber
- **Fitur Search** untuk mencari artikel spesifik
- **Bookmark artikel favorit** untuk dibaca ulang

### 🔥 **Eco Tracker (Habit Tracker)**
- Track kebiasaan ramah lingkungan harian:
	- 🚫 Tidak menggunakan plastik sekali pakai
	- 💧 Menghemat penggunaan air
	- ⚡ Menghemat energi listrik
- **Statistik & Progress Tracking**:
	- 🔥 **Streak Counter**: Hitung berapa hari berturut-turut berhasil
	- 📊 **Progress 7 Hari Terakhir**: Visualisasi pencapaian mingguan
	- 📅 **Total Bulan Ini**: Lihat konsistensi bulanan
- **Badge System**: Dapatkan achievement (⭐ → 🔥 → 🥇 → 🏆)
- **Auto-reset harian** dengan penyimpanan history
- Data tersimpan lokal menggunakan **Shared Preferences**

### 🔖 **Bookmark**
- Simpan artikel favorit untuk dibaca ulang
- Hapus bookmark dengan mudah
- Persistent storage dengan **Shared Preferences**

### 🔍 **Search**
- Pencarian artikel berdasarkan keyword
- Real-time search results
- Filter dan kategori pencarian

### 👤 **Profile & Settings**
- Informasi profil pengguna (dummy)
- **Dark Mode Toggle** (tema gelap/terang)
- Halaman **About EcoHelper**
- Pengaturan notifikasi (UI only)

### 📱 **Kategori Artikel**
- **Sampah & Daur Ulang**
- **Energi Terbarukan**
- **Penghematan Air**
- **Polusi Udara**
- **Perubahan Iklim**
- **Konservasi Alam**

---

## 🛠 Tech Stack

### **Frontend & Framework**
- **Flutter** – Cross-platform mobile framework
- **Dart** – Programming language

### **State Management**
- **BLoC (Business Logic Component)** – untuk Articles
- **Provider / ValueNotifier** – untuk Tracker & Theme

### **Data & Storage**
- **News API** – Real-time environmental news
- **MockAPI / Dummy Data** – Untuk event dan eco tips
- **Shared Preferences** – Local storage untuk:
	- Bookmark
	- Tracker history
	- Theme preferences
	- User data

### **UI/UX**
- **Material Design 3**
- **Custom Theming** (Light & Dark Mode)
- **Responsive Layout**
- **Smooth Animations**

---

## 📂 Struktur Proyek (sementara, masih progress)

```
lib/
├── main.dart                 # Entry point aplikasi
├── bloc/                     # BLoC untuk state management
│   ├── article_bloc.dart
│   ├── article_event.dart
│   └── article_state.dart
├── core/                     # Constants & Theme
│   ├── constants.dart
│   └── theme.dart
├── models/                   # Data models
│   ├── article_model.dart
│   └── event_model.dart
├── screens/                  # Halaman UI
│   ├── home_screen.dart
│   ├── articles_screen.dart
│   ├── article_detail_screen.dart
│   ├── tracker_screen.dart
│   ├── event_screen.dart
│   ├── bookmark_screen.dart
│   ├── profile_screen.dart
│   ├── settings_screen.dart
│   ├── search_screen.dart
│   ├── category_screen.dart
│   └── main_nav.dart
├── services/                 # API & Local services
│   ├── api_service.dart
│   ├── tracker_service.dart
│   ├── bookmark_service.dart
│   └── settings_service.dart
└── widgets/                  # Reusable components
		└── ...
```

---

## 📱 Demo Aplikasi

### Screenshot

(menyusul)

### 🎥 Video Demo

(menyusul)

---

## 🎓 Konsep yang Diterapkan

Proyek ini mengimplementasikan berbagai konsep Pemrograman Mobile:

- ✅ **State Management** dengan BLoC Pattern
- ✅ **REST API Integration** (News API)
- ✅ **Local Storage** dengan Shared Preferences
- ✅ **Navigation & Routing**
- ✅ **Custom Theming** (Light/Dark Mode)
- ✅ **Responsive UI Design**
- ✅ **CRUD Operations** (Bookmark, Tracker)
- ✅ **List Views & Infinite Scroll**
- ✅ **Search & Filter Functionality**
- ✅ **Form Validation**
- ✅ **Asynchronous Programming** (async/await, Future)
- ✅ **Widget Lifecycle Management**

---

<div align="center">
  
	**💚 Mari bersama menjaga bumi untuk generasi mendatang! 💚**
