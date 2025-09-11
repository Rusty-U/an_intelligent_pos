import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrinterSettingsScreen extends StatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  State<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends State<PrinterSettingsScreen> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  List<BluetoothDevice> devices = [];
  BluetoothDevice? selectedDevice;
  bool connected = false;

  // Settings
  String paperSize = "48mm"; // default

  @override
  void initState() {
    super.initState();
    loadSettings();
    initBluetooth();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      paperSize = prefs.getString("paperSize") ?? "48mm";
    });
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("paperSize", paperSize);
    if (selectedDevice != null) {
      await prefs.setString("lastPrinter", selectedDevice!.address ?? "");
    }
  }

  Future<void> initBluetooth() async {
    List<BluetoothDevice>? bondedDevices = await bluetooth.getBondedDevices();
    setState(() {
      devices = bondedDevices;
    });

    // Auto reconnect last saved printer
    final prefs = await SharedPreferences.getInstance();
    String? lastPrinter = prefs.getString("lastPrinter");
    try {
      final device = bondedDevices.firstWhere((d) => d.address == lastPrinter,
          orElse: () => bondedDevices.first);
      connectToDevice(device, auto: true);
    } catch (_) {}

    bluetooth.onStateChanged().listen((state) {
      if (state == 12) {
        setState(() => connected = true);
      } else if (state == 10) {
        setState(() {
          connected = false;
          selectedDevice = null;
        });
      }
    });
  }

  void connectToDevice(BluetoothDevice device, {bool auto = false}) async {
    try {
      if (connected) {
        await bluetooth.disconnect();
      }
      await bluetooth.connect(device);
      setState(() => selectedDevice = device);
      await saveSettings();
      if (!auto) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Connected to ${device.name}")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to connect: $e")),
      );
    }
  }

  void disconnectPrinter() async {
    await bluetooth.disconnect();
    setState(() {
      connected = false;
      selectedDevice = null;
    });
  }

  void testPrint() async {
    if (!connected || selectedDevice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please connect a printer first!')),
      );
      return;
    }

    bluetooth.printNewLine();
    bluetooth.printCustom("Intelligent POS", 3, 1);
    bluetooth.printCustom("Test Receipt ($paperSize)", 1, 1);
    bluetooth.printLeftRight("Burger", "200", 1);
    bluetooth.printLeftRight("Coke", "50", 1);
    bluetooth.printCustom("Thank You!", 2, 1);
    bluetooth.printNewLine();
    bluetooth.paperCut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Printer Settings"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Printers list
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Available Printers",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        itemCount: devices.length,
                        itemBuilder: (context, index) {
                          BluetoothDevice device = devices[index];
                          bool isSelected =
                              selectedDevice?.address == device.address;
                          return ListTile(
                            leading: const Icon(Icons.print),
                            title: Text(device.name ?? "Unknown"),
                            subtitle: Text(device.address ?? ""),
                            trailing: isSelected
                                ? const Icon(Icons.check, color: Colors.green)
                                : null,
                            onTap: () => connectToDevice(device),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Paper Size Setting
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Paper Size",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: paperSize, // 🔹 updated line
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: ["80mm", "48mm"]
                          .map((size) =>
                              DropdownMenuItem(value: size, child: Text(size)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => paperSize = val);
                          saveSettings();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        minimumSize: const Size.fromHeight(50)),
                    icon: const Icon(Icons.print),
                    label: const Text("Test Print"),
                    onPressed: testPrint,
                  ),
                ),
                const SizedBox(width: 10),
                if (connected)
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: const Size.fromHeight(50)),
                      icon: const Icon(Icons.close),
                      label: const Text("Disconnect"),
                      onPressed: disconnectPrinter,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // Status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: connected ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                connected
                    ? "Connected to ${selectedDevice?.name}"
                    : "No Printer Connected",
                style: TextStyle(
                  color: connected ? Colors.green[900] : Colors.red[900],
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
