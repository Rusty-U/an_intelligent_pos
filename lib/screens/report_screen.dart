import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReportDateRangeScreen extends StatefulWidget {
  const ReportDateRangeScreen({super.key});

  @override
  State<ReportDateRangeScreen> createState() => _ReportDateRangeScreenState();
}

class _ReportDateRangeScreenState extends State<ReportDateRangeScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final startOfDay = _startDate ?? DateTime(now.year, now.month, now.day);
    final endOfDay = (_endDate ?? startOfDay).add(const Duration(days: 1));

    final receiptsStream = FirebaseFirestore.instance
        .collection('receipts')
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThan: endOfDay)
        .snapshots();

    final inventoryStream =
        FirebaseFirestore.instance.collection('inventory').snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text("Today's / Date Range Summary")),
      body: Column(
        children: [
          // 🔹 Date Picker Card
          Card(
            margin: const EdgeInsets.all(12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_startDate != null
                        ? DateFormat('dd MMM yyyy').format(_startDate!)
                        : "Start Date"),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? now,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _startDate = picked;
                        });
                      }
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_endDate != null
                        ? DateFormat('dd MMM yyyy').format(_endDate!)
                        : "End Date"),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? now,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _endDate = picked;
                        });
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                      });
                    },
                  )
                ],
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: receiptsStream,
              builder: (context, receiptsSnap) {
                if (receiptsSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final receiptsDocs = receiptsSnap.data?.docs ?? [];
                final totalReceipts = receiptsDocs.length;

                double totalSales = 0;
                double totalCost = 0;
                int totalItems = 0;

                for (var doc in receiptsDocs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final cart = List<Map<String, dynamic>>.from(
                    (data['cart'] as List?)
                            ?.map((e) => Map<String, dynamic>.from(e)) ??
                        const [],
                  );
                  for (var item in cart) {
                    final qty = (item['qty'] ?? item['quantity'] ?? 1) as int;
                    final price =
                        ((item['sellingPrice'] ?? item['price']) as num)
                            .toDouble();
                    final cost = ((item['costPrice'] ?? 0) as num).toDouble();
                    totalSales += price * qty;
                    totalCost += cost * qty;
                    totalItems += qty;
                  }
                }

                final profit = totalSales - totalCost;
                final avgSale = totalItems > 0 ? totalSales / totalItems : 0;

                return StreamBuilder<QuerySnapshot>(
                  stream: inventoryStream,
                  builder: (context, invSnap) {
                    if (invSnap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final invDocs = invSnap.data?.docs ?? [];
                    double totalStockCost = 0;
                    double totalStockSelling = 0;

                    for (var doc in invDocs) {
                      final data = doc.data() as Map<String, dynamic>;

                      final qty = (data['stock'] ?? 0) as int;
                      final cost = ((data['costPrice'] ?? 0) as num).toDouble();
                      final selling =
                          ((data['sellingPrice'] ?? 0) as num).toDouble();

                      totalStockCost += qty * cost;
                      totalStockSelling += qty * selling;
                    }

                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 🔹 Sales Summary
                            Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Sales Summary",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    InfoRow(
                                        label: "Total Sales",
                                        value:
                                            "Rs ${totalSales.toStringAsFixed(0)}"),
                                    InfoRow(
                                        label: "Total Cost",
                                        value:
                                            "Rs ${totalCost.toStringAsFixed(0)}"),
                                    InfoRow(
                                        label: "Profit",
                                        value:
                                            "Rs ${profit.toStringAsFixed(0)}",
                                        valueColor: Colors.green),
                                    InfoRow(
                                        label: "Average Sale per Item",
                                        value:
                                            "Rs ${avgSale.toStringAsFixed(2)}"),
                                    InfoRow(
                                        label: "Total Receipts",
                                        value: "$totalReceipts"),
                                    InfoRow(
                                        label: "Total Items Sold",
                                        value: "$totalItems"),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // 🔹 Inventory Summary (Table removed ✅)
                            Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Inventory Summary",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    InfoRow(
                                        label: "Total Stock Cost Value",
                                        value:
                                            "Rs ${totalStockCost.toStringAsFixed(0)}"),
                                    InfoRow(
                                        label: "Total Stock Sell Value",
                                        value:
                                            "Rs ${totalStockSelling.toStringAsFixed(0)}"),
                                    InfoRow(
                                        label: "Expected Profit",
                                        value:
                                            "Rs ${(totalStockSelling - totalStockCost).toStringAsFixed(0)}",
                                        valueColor: Colors.blue),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 🔹 Helper widget for summary rows
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const InfoRow(
      {super.key, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.black)),
        ],
      ),
    );
  }
}
