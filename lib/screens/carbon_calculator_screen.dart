import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CarbonCalculatorScreen extends StatefulWidget {
  const CarbonCalculatorScreen({super.key});

  @override
  State<CarbonCalculatorScreen> createState() => _CarbonCalculatorScreenState();
}

class _CarbonCalculatorScreenState extends State<CarbonCalculatorScreen> {
  // Controllers for inputs
  final _electricityController = TextEditingController();
  final _transportController = TextEditingController();
  final _waterController = TextEditingController();
  final _wasteController = TextEditingController();

  String _transportType = 'mobil';
  double _totalCO2 = 0;
  bool _hasCalculated = false;

  // Carbon factors (kg CO2 per unit)
  static const double electricityFactor = 0.85; // per kWh
  static const double waterFactor = 0.298; // per liter
  static const double wasteFactor = 0.5; // per kg

  // Transport factors (kg CO2 per km)
  static const Map<String, double> transportFactors = {
    'mobil': 0.21,
    'motor': 0.11,
    'bus': 0.089,
    'sepeda': 0.0,
    'jalan_kaki': 0.0,
  };

  void _calculateFootprint() {
    final electricity = double.tryParse(_electricityController.text) ?? 0;
    final transport = double.tryParse(_transportController.text) ?? 0;
    final water = double.tryParse(_waterController.text) ?? 0;
    final waste = double.tryParse(_wasteController.text) ?? 0;

    final electricityCO2 = electricity * electricityFactor;
    final transportCO2 = transport * (transportFactors[_transportType] ?? 0);
    final waterCO2 = water * waterFactor;
    final wasteCO2 = waste * wasteFactor;

    setState(() {
      _totalCO2 = electricityCO2 + transportCO2 + waterCO2 + wasteCO2;
      _hasCalculated = true;
    });

    _saveHistory();
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('carbon_history') ?? [];
    
    final entry = jsonEncode({
      'date': DateTime.now().toIso8601String(),
      'co2': _totalCO2,
      'electricity': _electricityController.text,
      'transport': _transportController.text,
      'water': _waterController.text,
      'waste': _wasteController.text,
      'transportType': _transportType,
    });
    
    history.add(entry);
    if (history.length > 30) history.removeAt(0); // Keep last 30 entries
    
    await prefs.setStringList('carbon_history', history);
  }

  void _reset() {
    setState(() {
      _electricityController.clear();
      _transportController.clear();
      _waterController.clear();
      _wasteController.clear();
      _transportType = 'mobil';
      _totalCO2 = 0;
      _hasCalculated = false;
    });
  }

  String _getFootprintCategory() {
    if (_totalCO2 < 5) return 'Sangat Baik';
    if (_totalCO2 < 10) return 'Baik';
    if (_totalCO2 < 20) return 'Sedang';
    return 'Perlu Diperbaiki';
  }

  Color _getFootprintColor() {
    if (_totalCO2 < 5) return Colors.green;
    if (_totalCO2 < 10) return Colors.lightGreen;
    if (_totalCO2 < 20) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator Jejak Karbon'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade400,
                  Colors.teal.shade400,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.eco,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Hitung Jejak Karbon Harian Anda',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Masukkan aktivitas harian untuk mengetahui emisi CO₂ Anda',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Input Section
          _buildInputCard(
            icon: Icons.bolt,
            title: 'Listrik (kWh/hari)',
            hint: 'Contoh: 10',
            controller: _electricityController,
            color: Colors.amber,
          ),
          const SizedBox(height: 16),

          _buildTransportCard(),
          const SizedBox(height: 16),

          _buildInputCard(
            icon: Icons.water_drop,
            title: 'Air (liter/hari)',
            hint: 'Contoh: 150',
            controller: _waterController,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),

          _buildInputCard(
            icon: Icons.delete_outline,
            title: 'Sampah (kg/hari)',
            hint: 'Contoh: 2',
            controller: _wasteController,
            color: Colors.brown,
          ),
          const SizedBox(height: 24),

          // Calculate Button
          ElevatedButton(
            onPressed: _calculateFootprint,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calculate, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Text(
                  'Hitung Jejak Karbon',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Result Section
          if (_hasCalculated) ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getFootprintColor().withOpacity(0.2),
                    _getFootprintColor().withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getFootprintColor().withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.co2,
                    size: 64,
                    color: _getFootprintColor(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${_totalCO2.toStringAsFixed(2)} kg CO₂',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: _getFootprintColor(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Emisi per Hari',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _getFootprintColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getFootprintCategory(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildComparisonText(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh),
              label: const Text('Hitung Ulang'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Tips Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'Tips Mengurangi Jejak Karbon',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTip('Matikan peralatan elektronik saat tidak digunakan'),
                _buildTip('Gunakan transportasi umum atau sepeda'),
                _buildTip('Kurangi pemborosan air'),
                _buildTip('Pilah dan daur ulang sampah'),
                _buildTip('Gunakan produk ramah lingkungan'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard({
    required IconData icon,
    required String title,
    required String hint,
    required TextEditingController controller,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.directions_car, color: Colors.purple),
              ),
              const SizedBox(width: 12),
              const Text(
                'Transportasi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _transportController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Jarak tempuh (km/hari)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _transportType,
            decoration: InputDecoration(
              labelText: 'Jenis Transportasi',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'mobil', child: Text('🚗 Mobil')),
              DropdownMenuItem(value: 'motor', child: Text('🏍️ Motor')),
              DropdownMenuItem(value: 'bus', child: Text('🚌 Bus')),
              DropdownMenuItem(value: 'sepeda', child: Text('🚲 Sepeda')),
              DropdownMenuItem(value: 'jalan_kaki', child: Text('🚶 Jalan Kaki')),
            ],
            onChanged: (value) {
              setState(() {
                _transportType = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonText() {
    final treesNeeded = (_totalCO2 / 21.77).ceil(); // 1 pohon serap ~21.77 kg CO2/tahun
    final annualCO2 = _totalCO2 * 365 / 1000;
    
    return Column(
      children: [
        Text(
          '🌳 Untuk menetralkan emisi ini, Anda perlu:',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '$treesNeeded pohon selama 1 tahun',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '📊 Target Nasional: < 3 ton CO₂/orang/tahun',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          'Emisi tahunan Anda: ${annualCO2.toStringAsFixed(2)} ton CO₂',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 20),
        _buildSuggestions(),
      ],
    );
  }

  Widget _buildSuggestions() {
    final suggestions = <String>[];
    
    final electricity = double.tryParse(_electricityController.text) ?? 0;
    final transport = double.tryParse(_transportController.text) ?? 0;
    final water = double.tryParse(_waterController.text) ?? 0;
    final waste = double.tryParse(_wasteController.text) ?? 0;
    
    if (electricity > 15) {
      suggestions.add('💡 Kurangi penggunaan listrik. Target: < 8 kWh/hari');
    }
    if (transport > 30 && _transportType == 'mobil') {
      suggestions.add('🚌 Gunakan transportasi umum atau carpool untuk mengurangi emisi');
    }
    if (water > 200) {
      suggestions.add('💧 Hemat penggunaan air. Matikan keran saat tidak digunakan');
    }
    if (waste > 3) {
      suggestions.add('♻️ Kurangi sampah dengan memilah dan mendaur ulang');
    }
    
    if (suggestions.isEmpty) {
      suggestions.add('✨ Pertahankan gaya hidup ramah lingkungan Anda!');
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Saran Pengurangan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...suggestions.map((suggestion) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      suggestion,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _electricityController.dispose();
    _transportController.dispose();
    _waterController.dispose();
    _wasteController.dispose();
    super.dispose();
  }
}
