import 'package:flutter/material.dart';
import '../services/bookmark_service.dart';
import '../services/read_articles_service.dart';

/// Tampilan detail artikel dengan tombol Bookmark dan Tandai Sudah Dibaca,
/// menggunakan state ringan (tanpa listener global) agar tidak freeze.
class ArticleDetailScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final String content;
  final String? id;

  const ArticleDetailScreen({
    super.key,
    this.title = 'Detail Artikel',
    this.subtitle = 'Deskripsi singkat artikel.',
    this.content = '',
    this.id,
  });

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  bool _isBookmarked = false;
  bool _isRead = false;
  bool _loadingState = false;
  double _textScale = 1.0; // kontrol ukuran teks ringan

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    if (widget.id == null) return;
    setState(() => _loadingState = true);
    try {
      final bookmarked = await BookmarkService.isBookmarked(widget.id!);
      final read = await ReadArticlesService.isRead(widget.id!);
      if (mounted) {
        setState(() {
          _isBookmarked = bookmarked;
          _isRead = read;
        });
      }
    } finally {
      if (mounted) setState(() => _loadingState = false);
    }
  }

  Future<void> _toggleBookmark() async {
    if (widget.id == null) return;
    setState(() => _isBookmarked = !_isBookmarked);
    await BookmarkService.toggle(widget.id!);
  }

  Future<void> _markAsRead() async {
    if (widget.id == null || _isRead) return;
    setState(() => _isRead = true);
    await ReadArticlesService.toggle(widget.id!);
  }

  void _setTextScale(double scale) {
    setState(() => _textScale = scale);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          PopupMenuButton<double>(
            tooltip: 'Ukuran Teks',
            onSelected: _setTextScale,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 0.9, child: Text('Teks Kecil')),
              PopupMenuItem(value: 1.0, child: Text('Teks Sedang')),
              PopupMenuItem(value: 1.15, child: Text('Teks Besar')),
            ],
            icon: const Icon(Icons.text_fields),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero header sederhana
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: theme.colorScheme.primary.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.eco, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Subtitle
            Text(
              widget.subtitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),

            // Info row ringan
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(DateTime.now()),
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.article_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text('Eco Tips', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700])),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Tips',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Kategori chips dengan warna lebih menarik
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: const Text('Lingkungan'),
                  backgroundColor: Colors.green.withOpacity(0.2),
                  labelStyle: const TextStyle(color: Colors.green),
                ),
                Chip(
                  label: const Text('Hemat Energi'),
                  backgroundColor: Colors.orange.withOpacity(0.2),
                  labelStyle: const TextStyle(color: Colors.orange),
                ),
                Chip(
                  label: const Text('Gaya Hidup'),
                  backgroundColor: Colors.blue.withOpacity(0.2),
                  labelStyle: const TextStyle(color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Content
            _ArticleContent(
              content: widget.content,
              textScale: _textScale,
            ),

            const SizedBox(height: 16),

            // Quote box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.35)),
                boxShadow: [
                  BoxShadow(color: Colors.amber.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.format_quote, color: Colors.amber, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Perubahan kecil yang konsisten dapat berdampak besar bagi bumi.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.amber[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Bullet points ringan dengan styling
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Langkah Sederhana:', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: Colors.blue[800])),
                  const SizedBox(height: 8),
                  _BulletList(items: _getSimpleSteps(widget.title), textScale: 1.0),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Sumber ringkas dengan styling
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sumber Bacaan:', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: Colors.purple[800])),
                  const SizedBox(height: 8),
                  _BulletList(items: _getReferenceSources(widget.title), textScale: 1.0),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, -2)),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.id == null || _loadingState || _isRead ? null : _markAsRead,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.done),
                  label: Text(_isRead ? 'Sudah Dibaca' : 'Tandai Sudah Dibaca'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.id == null || _loadingState ? null : _toggleBookmark,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border),
                  label: Text(_isBookmarked ? 'Bookmarked' : 'Bookmark'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    // Format sederhana: 19 Jan 2026
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  List<String> _getSimpleSteps(String title) {
    // Return langkah sederhana yang relevan berdasarkan judul artikel
    final lowerTitle = title.toLowerCase();
    
    if (lowerTitle.contains('plastik') || lowerTitle.contains('sampah')) {
      return const [
        'Bawa tas kain belanja sendiri dari rumah.',
        'Gunakan botol minum isi ulang, hindari botol plastik sekali pakai.',
        'Tolak sedotan plastik di restoran atau kafe.',
        'Pilih produk dengan kemasan minimal atau ramah lingkungan.',
      ];
    } else if (lowerTitle.contains('energi') || lowerTitle.contains('listrik')) {
      return const [
        'Matikan lampu dan elektronik saat meninggalkan ruangan.',
        'Ganti lampu pijar dengan lampu LED yang hemat energi.',
        'Cabut charger dari stop kontak setelah selesai digunakan.',
        'Atur suhu AC pada 24-26°C untuk efisiensi optimal.',
      ];
    } else if (lowerTitle.contains('air')) {
      return const [
        'Periksa dan perbaiki keran atau pipa yang bocor sesegera mungkin.',
        'Batasi waktu mandi maksimal 5-7 menit.',
        'Tampung air hujan untuk menyiram tanaman atau cuci kendaraan.',
        'Gunakan shower hemat air atau keran aerator.',
      ];
    } else if (lowerTitle.contains('pohon') || lowerTitle.contains('tanam')) {
      return const [
        'Pilih bibit pohon lokal yang sesuai dengan iklim daerah Anda.',
        'Siram tanaman secara rutin, terutama di musim kering.',
        'Lakukan pemangkasan secara berkala agar pohon tumbuh sehat.',
        'Ajak tetangga atau komunitas untuk menanam pohon bersama.',
      ];
    } else if (lowerTitle.contains('elektronik') || lowerTitle.contains('daur ulang')) {
      return const [
        'Kumpulkan perangkat elektronik bekas di satu tempat.',
        'Hapus semua data pribadi sebelum membuang perangkat.',
        'Pisahkan baterai dari perangkat sebelum didaur ulang.',
        'Cari dropbox atau tempat daur ulang resmi terdekat.',
      ];
    } else if (lowerTitle.contains('kompos') || lowerTitle.contains('organik')) {
      return const [
        'Pisahkan sampah organik dari sampah anorganik di rumah.',
        'Siapkan wadah tertutup atau komposter sederhana.',
        'Tambahkan sampah dapur seperti sisa sayuran dan kulit buah.',
        'Aduk kompos setiap minggu agar proses pembusukan merata.',
      ];
    } else if (lowerTitle.contains('iklim') || lowerTitle.contains('ramah lingkungan')) {
      return const [
        'Gunakan transportasi umum, sepeda, atau berjalan kaki untuk jarak dekat.',
        'Kurangi konsumsi daging dan makanan olahan.',
        'Belanja produk lokal untuk mengurangi jejak karbon transportasi.',
        'Tanam pohon di sekitar rumah untuk menyerap karbon.',
      ];
    } else {
      // Default langkah umum
      return const [
        'Mulai dari kebiasaan kecil yang konsisten.',
        'Ajak keluarga dan teman untuk ikut serta.',
        'Edukasi diri dengan membaca artikel dan panduan terkait.',
        'Bagikan pengalaman Anda di media sosial untuk menginspirasi orang lain.',
      ];
    }
  }

  List<String> _getReferenceSources(String title) {
    // Return sumber bacaan yang relevan berdasarkan judul artikel
    final lowerTitle = title.toLowerCase();
    
    if (lowerTitle.contains('plastik') || lowerTitle.contains('sampah')) {
      return const [
        'Panduan Pengurangan Sampah Plastik - Kementerian Lingkungan',
        'The Ocean Cleanup Project: Menyelamatkan Lautan dari Plastik',
        'Zero Waste Living: Panduan Gaya Hidup Tanpa Sampah',
      ];
    } else if (lowerTitle.contains('energi') || lowerTitle.contains('listrik')) {
      return const [
        'Panduan Hemat Energi untuk Rumah Tangga - PLN',
        'Efisiensi Energi dan Peralatan Hemat Daya',
        'Tips Menghemat Listrik: Investasi Jangka Panjang',
      ];
    } else if (lowerTitle.contains('air')) {
      return const [
        'Konservasi Air Bersih untuk Masa Depan',
        'Sistem Penampung Air Hujan: Panduan Praktis',
        'Strategi Hemat Air di Era Perubahan Iklim',
      ];
    } else if (lowerTitle.contains('pohon') || lowerTitle.contains('tanam')) {
      return const [
        'Program Penghijauan Nasional dan Manfaatnya',
        'Pemilihan dan Perawatan Pohon Buah Lokal',
        'Reforestasi: Solusi Nyata Serap Karbon',
      ];
    } else if (lowerTitle.contains('elektronik') || lowerTitle.contains('daur ulang')) {
      return const [
        'Panduan Daur Ulang Limbah Elektronik dengan Aman',
        'Pencegahan Pencemaran dari E-Waste',
        'Tempat Resmi Daur Ulang Elektronik di Indonesia',
      ];
    } else if (lowerTitle.contains('energi terbarukan') || lowerTitle.contains('komunitas')) {
      return const [
        'Panel Surya: Investasi Energi Terbarukan Jangka Panjang',
        'Program Subsidi Energi Bersih di Indonesia',
        'Kerjasama Komunitas untuk Energi Berkelanjutan',
      ];
    } else if (lowerTitle.contains('kompos') || lowerTitle.contains('organik')) {
      return const [
        'Panduan Lengkap Pembuatan Kompos Rumah Tangga',
        'Manfaat Kompos Organik vs Pupuk Kimia',
        'Vermikompos: Teknik Kompos Cepat dengan Cacing',
      ];
    } else if (lowerTitle.contains('iklim') || lowerTitle.contains('ramah')) {
      return const [
        'Panduan Gaya Hidup Ramah Iklim Sehari-hari',
        'Jejak Karbon Pribadi: Menghitung dan Mengurangi',
        'Kontribusi Individual untuk Perlambatan Perubahan Iklim',
      ];
    } else {
      // Default sumber umum
      return const [
        'Panduan Umum Gaya Hidup Berkelanjutan',
        'Komitmen Kita untuk Planet yang Lebih Hijau',
        'Edukasi Lingkungan untuk Generasi Masa Depan',
      ];
    }
  }
}

class _ArticleContent extends StatelessWidget {
  final String content;
  final double textScale;

  const _ArticleContent({required this.content, required this.textScale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final displayText = content.isEmpty
        ? _defaultContent()
        : content;

    return Text(
      displayText,
      textScaleFactor: textScale,
      style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
    );
  }

  String _defaultContent() {
    return [
      'Menjaga lingkungan dimulai dari kebiasaan kecil yang dilakukan setiap hari. '
          'Dengan mengubah pola konsumsi dan cara kita menggunakan energi, kita dapat '
          'mengurangi jejak karbon secara signifikan.',
      '',
      'Mulailah dari rumah: matikan perangkat yang tidak digunakan, gunakan lampu hemat energi, '
          'dan kurangi sampah plastik. Kebiasaan sederhana ini tidak hanya baik untuk bumi, '
          'namun juga dapat menghemat biaya listrik.',
      '',
      'Untuk transportasi, pertimbangkan berjalan kaki, bersepeda, atau naik transportasi umum ketika memungkinkan. '
          'Selain mengurangi polusi udara, hal ini juga baik untuk kesehatan.',
    ].join('\n');
  }
}

class _BulletList extends StatelessWidget {
  final List<String> items;
  final double textScale;

  const _BulletList({required this.items, required this.textScale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(
                    child: Text(
                      e,
                      textScaleFactor: textScale,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
