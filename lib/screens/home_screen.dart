import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:developer';
import '../services/api_service.dart';

import 'login_screen.dart';
import 'new_sale_screen.dart';
import 'report_screen.dart';
import 'today_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Map<String, dynamic>> cart = [];

  final List<Widget> _screens = [
    const HomeContent(),
    const NewSaleScreen(),
    const ReportDateRangeScreen(),
    const TodayScreen(),
  ];

  Future<void> _scanBarcode() async {
    final String? barcode = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BarcodeScannerScreen(),
      ),
    );

    if (barcode != null) {
      debugPrint("✅ Scanned barcode: $barcode");

      final snapshot = await FirebaseFirestore.instance
          .collection('inventory')
          .where('barcode', isEqualTo: barcode)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final item = snapshot.docs.first.data();
        setState(() {
          cart.add(item);
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${item['name']} added to cart ✅")),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Item not found in inventory")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade100,
      appBar: AppBar(
        title: Text(_getAppBarTitle(_currentIndex)),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _scanBarcode,
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_shopping_cart),
            label: 'Items',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: 'Today',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF1565C0)),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text('Intelligent POS',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2),
              title: const Text('Inventory Management'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/inventory');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('General Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/general_settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text('Printer Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/printer_settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Receipt Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/recipt_settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Staff'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/staff');
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Reports'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/reports');
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'New Sale';
      case 2:
        return 'Reports';
      case 3:
        return 'Today';
      default:
        return '';
    }
  }
}

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  String? scannedCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Scan Barcode"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.white),
            onPressed: () {
              MobileScannerController().toggleTorch();
            },
          )
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (barcodeCapture) {
              final List<Barcode> barcodes = barcodeCapture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  setState(() {
                    scannedCode = barcode.rawValue!;
                  });

                  Navigator.pop(context, scannedCode);
                  break;
                }
              }
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.deepPurple, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  double? todaySale;
  double? tomorrowSale;
  double? weekSale;
  double? halfMonthSale;
  double? monthSale;

  List<double> actualSales = [];
  bool _showPrediction = false;

  @override
  void initState() {
    super.initState();
    _fetchPredictions();
    _listenToActualSales();
  }

  Future<void> _fetchPredictions() async {
    final input = {
      "price": 100,
      "discount": 5,
      "qty_last_7d": 300,
      "qty_last_30d": 1200,
      "dow": DateTime.now().weekday,
      "month": DateTime.now().month
    };

    try {
      final double? prediction = await ApiService.getPrediction(input);

      setState(() {
        todaySale = prediction ?? 0;
        tomorrowSale = (prediction ?? 0) * 1.05;
        weekSale = (prediction ?? 0) * 7;
        halfMonthSale = (prediction ?? 0) * 15;
        monthSale = (prediction ?? 0) * 30;
      });
    } catch (e) {
      log("❌ Prediction fetch error: $e");
      setState(() {
        todaySale = 0;
        tomorrowSale = 0;
        weekSale = 0;
        halfMonthSale = 0;
        monthSale = 0;
      });
    }
  }

  void _listenToActualSales() {
    FirebaseFirestore.instance
        .collection("sales")
        .orderBy("timestamp", descending: false)
        .snapshots()
        .listen((snapshot) {
      final salesList = snapshot.docs.map((doc) {
        final data = doc.data();
        final totalValue = data["total"];
        if (totalValue == null) return 0.0;
        if (totalValue is num) return totalValue.toDouble();
        if (totalValue is String) return double.tryParse(totalValue) ?? 0.0;
        return 0.0;
      }).toList();

      setState(() {
        actualSales = salesList;
      });

      log("📊 Firestore Actual Sales: $actualSales");
    });
  }

  double get _maxY {
    final allValues = actualSales +
        [
          todaySale ?? 0,
          tomorrowSale ?? 0,
        ];
    return (allValues.isNotEmpty
            ? allValues.reduce((a, b) => a > b ? a : b)
            : 1) *
        1.2;
  }

  @override
  Widget build(BuildContext context) {
    // sirf last 3 actual sales lena (agar kam hain to utne hi show karna)
    final recentSales = actualSales.length >= 3
        ? actualSales.sublist(actualSales.length - 3)
        : actualSales;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          // 🔹 Full Width "New Sale" Button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewSaleScreen()),
              );
            },
            child: Container(
              width: double.infinity,
              height: 200,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  "+ New Sale",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ✅ Forecast + Graphs Card
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "AI Forecast vs Actual",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _ForecastTile(
                            label: "Today",
                            value: todaySale?.toStringAsFixed(0) ?? "..."),
                        _ForecastTile(
                            label: "Tomorrow",
                            value: tomorrowSale?.toStringAsFixed(0) ?? "..."),
                        _ForecastTile(
                            label: "7 Days",
                            value: weekSale?.toStringAsFixed(0) ?? "..."),
                        _ForecastTile(
                            label: "15 Days",
                            value: halfMonthSale?.toStringAsFixed(0) ?? "..."),
                        _ForecastTile(
                            label: "30 Days",
                            value: monthSale?.toStringAsFixed(0) ?? "..."),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ✅ Toggle Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showPrediction = !_showPrediction;
                          });
                        },
                        child: Text(
                          _showPrediction
                              ? "Hide Predictions"
                              : "Show Predictions",
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ✅ Line Chart (actual last 3 + predicted)
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          minY: 0,
                          maxY: _maxY,
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final labels = [
                                    "Day -2",
                                    "Yesterday",
                                    "Today",
                                    "Tomorrow"
                                  ];
                                  int index = value.toInt();
                                  if (index >= 0 && index < labels.length) {
                                    return Text(labels[index],
                                        style: const TextStyle(fontSize: 10));
                                  }
                                  return const Text("");
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            // Actual line
                            LineChartBarData(
                              spots: recentSales
                                  .asMap()
                                  .entries
                                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                                  .toList(),
                              isCurved: true,
                              barWidth: 3,
                              color: Colors.blue,
                              dotData: FlDotData(show: true),
                            ),
                            if (_showPrediction)
                              LineChartBarData(
                                spots: [
                                  FlSpot(2, todaySale ?? 0),
                                  FlSpot(3, tomorrowSale ?? 0),
                                ],
                                isCurved: true,
                                barWidth: 3,
                                color: Colors.green,
                                dotData: FlDotData(show: true),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ✅ Bar Chart (same as before)
                    SizedBox(
                      height: 250,
                      child: BarChart(
                        BarChartData(
                          maxY: _maxY,
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true, reservedSize: 40),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final labels = [
                                    "Yesterday",
                                    "Today",
                                    "Tomorrow"
                                  ];
                                  int index = value.toInt();
                                  if (index >= 0 && index < labels.length) {
                                    return Text(labels[index],
                                        style: const TextStyle(fontSize: 10));
                                  }
                                  return const Text("");
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          groupsSpace: 30,
                          barGroups: [
                            // Yesterday -> sirf actual
                            BarChartGroupData(
                              x: 0,
                              barRods: [
                                BarChartRodData(
                                  toY: recentSales.isNotEmpty
                                      ? recentSales[recentSales.length - 2 < 0
                                          ? 0
                                          : recentSales.length - 2]
                                      : 0,
                                  color: Colors.blue,
                                  width: 14,
                                ),
                              ],
                            ),
                            // Today -> actual + predicted
                            BarChartGroupData(
                              x: 1,
                              barRods: [
                                BarChartRodData(
                                  toY: recentSales.isNotEmpty
                                      ? recentSales.last
                                      : 0,
                                  color: Colors.blue,
                                  width: 14,
                                ),
                                BarChartRodData(
                                  toY: todaySale ?? 0,
                                  color: Colors.green,
                                  width: 14,
                                ),
                              ],
                            ),
                            // Tomorrow -> sirf predicted
                            BarChartGroupData(
                              x: 2,
                              barRods: [
                                BarChartRodData(
                                  toY: tomorrowSale ?? 0,
                                  color: Colors.green,
                                  width: 14,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForecastTile extends StatelessWidget {
  final String label;
  final String value;
  const _ForecastTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
      ],
    );
  }
}
