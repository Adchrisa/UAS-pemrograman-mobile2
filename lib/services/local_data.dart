import '../models/article_model.dart';

class LocalData {
  static final List<Article> articles = [
    Article(
      id: 'a1',
      title: 'Kurangi Sampah Plastik',
      subtitle: 'Langkah sederhana untuk mengurangi plastik sekali pakai',
      content: 'Mengurangi plastik bisa dimulai dengan membawa tas kain saat belanja, menggunakan botol minum isi ulang, dan menghindari sedotan sekali pakai.\n\nPisahkan sampah plastik untuk didaur ulang dan pilih produk dengan kemasan minimal. Kebiasaan kecil ini membantu mengurangi sampah yang berakhir di lingkungan.\n\nSetiap tahun, jutaan ton plastik mengotamakan lautan dan merusak ekosistem laut. Dengan mengurangi penggunaan plastik sekali pakai, Anda turut melindungi kehidupan laut dan makhluk hidup lainnya. Mulai dari hal sederhana seperti membawa tas belanja sendiri, menggunakan produk perawatan dengan kemasan refill, dan memilih produk yang tidak berlebihan kemasannya.\n\nJangan lupa juga untuk mengedukasi keluarga dan teman tentang pentingnya mengurangi plastik. Bersama-sama kita bisa membuat perbedaan nyata untuk planet kita.',
      category: 'Sampah',
      imageUrl: null,
      date: DateTime(2025, 5, 20),
    ),
    Article(
      id: 'a2',
      title: 'Hemat Energi di Rumah',
      subtitle: 'Cara mengurangi konsumsi listrik sehari-hari',
      content: 'Hemat listrik dengan beralih ke lampu LED, mematikan lampu ruangan kosong, dan mencabut charger saat tidak digunakan.\n\nAtur suhu AC secukupnya dan manfaatkan ventilasi alami. Selain ramah lingkungan, langkah ini menurunkan tagihan listrik.\n\nLampu LED menggunakan energi 75% lebih sedikit dibanding lampu pijar tradisional dan tahan 25 kali lebih lama. Coba ganti semua lampu di rumah dengan LED dan rasakan perbedaannya dalam tagihan listrik bulan depan.\n\nSelain itu, hindari menggunakan peralatan elektronik pada jam-jam puncak listrik (biasanya pukul 17-22), dan atur termostat AC pada suhu 24-26°C. Investasi kecil pada perangkat hemat energi akan memberikan keuntungan jangka panjang bagi kesehatan finansial dan lingkungan Anda.',
      category: 'Energi',
      imageUrl: null,
      date: DateTime(2025, 6, 5),
    ),
    Article(
      id: 'a3',
      title: 'Hemat Air untuk Masa Depan',
      subtitle: 'Praktik hemat air di rumah dan kebun',
      content: 'Hemat air dengan segera memperbaiki kebocoran, mandi lebih singkat, dan menampung air hujan untuk menyiram tanaman.\n\nGunakan keran aerator agar aliran lebih efisien dan biasakan menutup keran rapat setelah digunakan.\n\nAir adalah sumber daya yang sangat berharga dan tidak tergantikan. Setiap tetes air yang Anda hemat hari ini akan berdampak pada generasi mendatang. Hanya dengan memperbaiki satu keran yang bocor, Anda bisa menghemat hingga 20 liter air per hari!\n\nInstalasi penampung air hujan di atap rumah bisa memberikan pasokan air gratis untuk menyiram tanaman dan cuci mobil. Selain menghemat air bersih, ini juga mengurangi banjir di musim hujan. Ajak keluarga untuk menciptakan kebiasaan hemat air sejak dini agar generasi muda menghargai setiap tetes air.',
      category: 'Air',
      imageUrl: null,
      date: DateTime(2025, 4, 12),
    ),
    Article(
      id: 'a4',
      title: 'Aksi Tanam Pohon',
      subtitle: 'Mengapa menanam pohon penting untuk iklim',
      content: 'Menanam pohon lokal membantu meningkatkan keanekaragaman hayati dan menyerap emisi karbon.\n\nRawat secara rutin: siram, pangkas seperlunya, dan periksa hama. Ajak tetangga untuk membuat area hijau bersama.\n\nSatu pohon dapat menyerap hingga 20 kg CO2 per tahun dan memberikan oksigen untuk 2 orang selama setahun. Bayangkan dampak jika jutaan orang menanam pohon di komunitas mereka masing-masing!\n\nPilih pohon lokal yang sesuai dengan kondisi iklim dan tanah setempat agar pertumbuhannya optimal. Pohon buah lokal tidak hanya indah tetapi juga memberikan hasil yang bermanfaat. Sisihkan waktu setiap minggu untuk merawat pohon Anda dengan menyiram dan membuang ranting mati. Program penanaman bersama dengan tetangga juga bisa memperkuat ikatan komunitas sambil berkontribusi pada lingkungan.',
      category: 'Iklim',
      imageUrl: null,
      date: DateTime(2025, 3, 8),
    ),
    Article(
      id: 'a5',
      title: 'Daur Ulang Elektronik',
      subtitle: 'Cara aman membuang elektronik dan baterai',
      content: 'Buang limbah elektronik (e-waste) ke dropbox resmi agar didaur ulang dengan aman.\n\nSebelum membuang, hapus data perangkat dan pisahkan baterai. Hindari membuang elektronik ke tempat sampah biasa.\n\nLimbah elektronik mengandung bahan beracun seperti merkuri, timbal, dan kadmium yang dapat meracuni tanah dan air. Jika tidak ditangani dengan benar, e-waste bisa membahayakan kesehatan manusia dan ekosistem selama bertahun-tahun.\n\nSebelum membuang perangkat lama, pastikan Anda telah menghapus semua data pribadi dengan aman. Banyak perangkat elektronik masih bisa digunakan ulang atau diperbaiki, jadi pertimbangkan untuk menyumbangkannya. Jika benar-benar harus dibuang, bawa ke pusat daur ulang resmi di kota Anda. Beberapa kota bahkan menyediakan program pickup gratis untuk e-waste dari rumah.',
      category: 'Sampah',
      imageUrl: null,
      date: DateTime(2025, 7, 1),
    ),
    Article(
      id: 'a6',
      title: 'Energi Terbarukan di Komunitas',
      subtitle: 'Solusi kecil menuju penggunaan energi terbarukan',
      content: 'Dorong penggunaan energi terbarukan di komunitas, seperti panel surya bersama.\n\nMulai dari audit energi sederhana dan kampanye hemat listrik. Edukasi warga agar penggunaan listrik lebih bijak dan efisien.\n\nEnergi terbarukan seperti panel surya tidak hanya mengurangi tagihan listrik tetapi juga emisi karbon. Investasi awal memang lebih tinggi, tetapi dalam 5-7 tahun Anda sudah bisa balik modal.\n\nMulai dengan audit energi sederhana: catat penggunaan listrik bulanan, identifikasi peralatan yang paling banyak memakai energi, dan buat rencana pengurangan. Ajukan program subsidi panel surya ke pemerintah lokal atau bank. Bersama komunitas, Anda bisa membuat proposal untuk memasang panel surya di bangunan umum seperti sekolah atau balai desa. Edukasi warga tentang manfaat energi bersih akan meningkatkan kesadaran dan partisipasi komunitas.',
      category: 'Energi',
      imageUrl: null,
      date: DateTime(2025, 2, 14),
    ),
    Article(
      id: 'a7',
      title: 'Pengelolaan Sampah Organik',
      subtitle: 'Membuat kompos dari sisa makanan',
      content: 'Pisahkan sampah organik untuk dijadikan kompos sederhana di rumah.\n\nGunakan wadah tertutup dan aduk secara berkala agar kompos matang. Kompos membantu menyuburkan tanah dan mengurangi sampah.\n\nKompos adalah emas hitam bagi tanaman dan tanah. Sampah organik yang semula menjadi beban dapat diubah menjadi pupuk organik berkualitas tinggi. Tidak perlu lahan luas, kompos bisa dibuat dalam wadah sederhana di sudut rumah atau balkon.\n\nProses pembuatan kompos cukup mudah: cuci wadah berlubang, susun lapisan sampah dapur (sayuran, buah, ampas kopi) dan daun kering bergantian, lalu aduk setiap minggu. Dalam 3-4 bulan, kompos sudah matang dan siap digunakan. Kompos organik membuat tanah lebih subur, meningkatkan retensi air, dan mengurangi kebutuhan pupuk kimia yang mahal dan merusak lingkungan.',
      category: 'Sampah',
      imageUrl: null,
      date: DateTime(2025, 1, 9),
    ),
    Article(
      id: 'a8',
      title: 'Hidup Ramah Iklim',
      subtitle: 'Kebiasaan yang membantu mitigasi perubahan iklim',
      content: 'Gaya hidup ramah iklim dimulai dari penggunaan transportasi publik, bersepeda, atau berjalan kaki untuk jarak dekat.\n\nKurangi konsumsi daging dan makanan olahan, pilih produk lokal, serta tanam pohon untuk menyerap emisi karbon. Perubahan kecil berdampak besar.\n\nPerubahan iklim adalah tantangan global yang memerlukan tindakan lokal dari setiap individu. Pilihan sehari-hari Anda seperti cara transportasi dan pola makan memiliki dampak emisi karbon yang signifikan.\n\nTransportasi merupakan penyumbang emisi terbesar. Beralih ke transportasi publik, bersepeda, atau carpooling bisa mengurangi emisi karbon hingga 75%. Pola makan juga penting: produksi daging memerlukan energi dan lahan yang sangat besar, jadi kurangi porsi daging dan pilih makanan nabati lebih banyak. Belanja produk lokal mengurangi jejak karbon transportasi dan mendukung ekonomi lokal. Setiap keputusan kecil yang konsisten akan menciptakan perubahan besar untuk masa depan yang lebih sejuk dan sehat.',
      category: 'Iklim',
      imageUrl: null,
      date: DateTime(2025, 8, 21),
    ),
  ];

  // Data event sederhana untuk tampilan event
  static final List<Map<String, dynamic>> events = [
    {
      'id': 'e1',
      'title': 'Bersih-Bersih Sungai',
      'description': 'Aksi gotong royong membersihkan bantaran sungai dan memilah sampah organik/anorganik.',
      'date': DateTime(2025, 9, 12),
      'location': 'Sungai Ciliwung, Jakarta',
    },
    {
      'id': 'e2',
      'title': 'Workshop Kompos Rumah',
      'description': 'Pelatihan membuat kompos dari sampah dapur, cocok untuk pemula dan keluarga.',
      'date': DateTime(2025, 10, 5),
      'location': 'Balai Warga, Bandung',
    },
    {
      'id': 'e3',
      'title': 'Penanaman 1.000 Pohon',
      'description': 'Gerakan tanam pohon di area terbuka hijau untuk serap emisi dan kurangi banjir.',
      'date': DateTime(2025, 11, 2),
      'location': 'Taman Kota, Surabaya',
    },
  ];

  static final List<Map<String, String>> tips = [
    {'id': 't1', 'title': 'Bawa botol minum sendiri', 'subtitle': 'Kurangi sampah plastik setiap hari'},
    {'id': 't2', 'title': 'Matikan lampu ruangan kosong', 'subtitle': 'Hemat energi secara sederhana'},
    {'id': 't3', 'title': 'Gunakan tas kain saat belanja', 'subtitle': 'Kurangi penggunaan kantong plastik'},
    {'id': 't4', 'title': 'Hemat air saat mandi', 'subtitle': 'Kurangi durasi mandi hingga 5 menit'},
    {'id': 't5', 'title': 'Jangan buang limbah ke sungai', 'subtitle': 'Jaga kelestarian ekosistem air'},
    {'id': 't6', 'title': 'Gunakan transportasi umum', 'subtitle': 'Kurangi polusi udara dan kemacetan'},
    {'id': 't7', 'title': 'Tanam tanaman di rumah', 'subtitle': 'Ciptakan area hijau dan serap karbon'},
    {'id': 't8', 'title': 'Pilah sampah dengan benar', 'subtitle': 'Organik, anorganik, dan B3 terpisah'},
    {'id': 't9', 'title': 'Gunakan lampu LED hemat energi', 'subtitle': 'Hemat listrik hingga 80% lebih banyak'},
    {'id': 't10', 'title': 'Beli produk lokal dan ramah lingkungan', 'subtitle': 'Dukung ekonomi lokal dan kurangi jejak karbon'},
    {'id': 't11', 'title': 'Jangan buang elektronik sembarangan', 'subtitle': 'Kumpulkan di tempat daur ulang resmi'},
    {'id': 't12', 'title': 'Gunakan sunscreen alami', 'subtitle': 'Cegah kerusakan terumbu karang'},
  ];

  static Article? getById(String id) {
    for (final article in articles) {
      if (article.id == id) return article;
    }
    return null;
  }

  static List<Article> getByCategory(String category) {
    final target = category.toLowerCase();
    return articles.where((a) => a.category.toLowerCase() == target).toList();
  }

  static List<Article> search(String query) {
    final q = query.toLowerCase();
    return articles.where((a) {
      return a.title.toLowerCase().contains(q) ||
          a.subtitle.toLowerCase().contains(q) ||
          a.content.toLowerCase().contains(q);
    }).toList();
  }

  static List<Map<String, dynamic>> getEvents() => events;

  static List<Map<String, String>> getTips({int limit = 3}) => tips.take(limit).toList();
}
