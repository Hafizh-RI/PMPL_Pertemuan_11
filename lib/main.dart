import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Identitas untuk pembuktian latihan Pertemuan 11
const String kNim = '2411500014';
const String kNama = 'Hafizh';
const String kVersi = '1.0.1+2';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Demo Platform Channel',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const PlatformChannelPage(),
    );
  }
}

class PlatformChannelPage extends StatefulWidget {
  const PlatformChannelPage({super.key});

  @override
  State<PlatformChannelPage> createState() => _PlatformChannelPageState();
}

class _PlatformChannelPageState extends State<PlatformChannelPage> {
  // Nama MethodChannel harus identik dengan yang di MainActivity (case-sensitive)
  static const platform = MethodChannel('com.example.app/battery');

  String _batteryLevel = 'Belum diketahui';
  final TextEditingController _toastController = TextEditingController();
  bool _isLong = false;

  Future<void> _getBatteryLevel() async {
    String batteryStatus;
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      batteryStatus = 'Level baterai saat ini: $result%';
    } on PlatformException catch (e) {
      batteryStatus = "Gagal mengambil level baterai: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryStatus;
    });
  }

  Future<void> _showNativeToast() async {
    final String textToSend = _toastController.text.trim().isEmpty
        ? 'Ini adalah Native Toast dari Flutter!'
        : _toastController.text.trim();

    try {
      await platform.invokeMethod('showToast', {
        'message': textToSend,
        'isLong': _isLong,
      });
    } on PlatformException catch (e) {
      debugPrint("Gagal menampilkan Toast: ${e.message}");
    }
  }

  // Latihan Pertemuan 11: Toast berisi NIM + nama
  Future<void> _showIdentityToast() async {
    try {
      await platform.invokeMethod('showToast', {
        'message': '$kNim - $kNama',
        'isLong': true,
      });
    } on PlatformException catch (e) {
      debugPrint("Gagal menampilkan Toast: ${e.message}");
    }
  }

  @override
  void dispose() {
    _toastController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pertemuan 11: Build & Deploy'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            tooltip: 'About',
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const AboutPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bagian 1: Native -> Flutter (Battery Level)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.battery_charging_full,
                        size: 48, color: Colors.green),
                    const SizedBox(height: 12),
                    Text(
                      _batteryLevel,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _getBatteryLevel,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Cek Level Baterai (Native)'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Bagian 2: Flutter -> Native (Toast dengan Parameter)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Kirim Pesan ke Native Toast',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _toastController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Tulis pesan Toast',
                        hintText: 'Contoh: Halo dari mahasiswa Flutter!',
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Durasi panjang (LENGTH_LONG)'),
                      subtitle: Text(
                          _isLong ? 'Toast tampil lama' : 'Toast tampil singkat'),
                      value: _isLong,
                      onChanged: (value) {
                        setState(() {
                          _isLong = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: _showNativeToast,
                      icon: const Icon(Icons.notifications_active),
                      label: const Text('Tampilkan Native Toast'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _showIdentityToast,
                      icon: const Icon(Icons.badge_outlined),
                      label: const Text('Toast NIM + Nama'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Layar About: pembuktian latihan (NIM + nama)
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.battery_charging_full, size: 80, color: Colors.green),
              SizedBox(height: 16),
              Text(
                'Pertemuan 11: Build & Deploy',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Text('NIM : $kNim', style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text('Nama : $kNama', style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text('Versi : $kVersi', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
