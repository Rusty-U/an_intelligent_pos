import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../screens/recipt_screen.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  DateTime? _startDate = DateTime.now();
  DateTime? _endDate;

  /// 🔹 normalize current date (00:00:00)
  DateTime _todayOnlyDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Future<void> _pickStartDate() async {
    final DateTime today = _todayOnlyDate();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? today,
      firstDate: DateTime(2000),
      lastDate: today, // ✅ not beyond today
    );

    if (picked != null) {
      final pickedDay = DateTime(picked.year, picked.month, picked.day);
      setState(() {
        _startDate = pickedDay;
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final DateTime today = _todayOnlyDate();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (_startDate != null && _startDate!.isBefore(today))
          ? _startDate!
          : today,
      firstDate: _startDate ?? DateTime(2000),
      lastDate: today, // ✅ not beyond today
    );

    if (picked != null) {
      final pickedDay = DateTime(picked.year, picked.month, picked.day);
      setState(() {
        // ✅ store end as exclusive next-day
        _endDate = pickedDay.add(const Duration(days: 1));
      });
    }
  }

  void _resetToToday() {
    final today = _todayOnlyDate();
    setState(() {
      _startDate = today;
      _endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final todayStart = _todayOnlyDate();

    final effectiveStart = (_startDate != null)
        ? DateTime(_startDate!.year, _startDate!.month, _startDate!.day)
        : todayStart;

    final effectiveEnd = (_endDate != null)
        ? _endDate! // already exclusive
        : effectiveStart.add(const Duration(days: 1));

    final titleText = (_endDate == null)
        ? "Receipts - ${DateFormat('dd MMM yyyy').format(effectiveStart)}"
        : "Receipts - ${DateFormat('dd MMM yyyy').format(effectiveStart)} → ${DateFormat('dd MMM yyyy').format(effectiveEnd.subtract(const Duration(days: 1)))}";

    final query = FirebaseFirestore.instance
        .collection('receipts')
        .where('date', isGreaterThanOrEqualTo: effectiveStart)
        .where('date', isLessThan: effectiveEnd)
        .orderBy('date', descending: true);

    return Scaffold(
      appBar: AppBar(title: Text(titleText)),
      body: Column(
        children: [
          // 🔹 Date Picker Row
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickStartDate,
                        child: Row(
                          children: [
                            const Icon(Icons.date_range, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              _startDate == null
                                  ? "Start Date"
                                  : DateFormat('dd MMM yyyy')
                                      .format(effectiveStart),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: _pickEndDate,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(Icons.date_range, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              _endDate == null
                                  ? "End Date"
                                  : DateFormat('dd MMM yyyy').format(
                                      effectiveEnd
                                          .subtract(const Duration(days: 1))),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: "Reset to Today",
                      onPressed: _resetToToday,
                      icon: const Icon(Icons.refresh, color: Colors.red),
                    )
                  ],
                ),
              ),
            ),
          ),

          // 🔹 Receipts List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snap.hasData || snap.data!.docs.isEmpty) {
                  return const Center(child: Text('No receipts found'));
                }

                final docs = snap.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final doc = docs[i];
                    final data = doc.data() as Map<String, dynamic>;
                    final receiptNo = (data['receiptNo'] ?? 'N/A').toString();
                    final ts = data['date'] as Timestamp?;
                    final dt = ts?.toDate() ?? DateTime.now();
                    final formatted =
                        DateFormat('dd MMM yyyy • hh:mm a').format(dt);

                    final cart = List<Map<String, dynamic>>.from(
                      (data['cart'] as List? ?? [])
                          .map((e) => Map<String, dynamic>.from(e)),
                    );

                    final itemsCount = cart.isEmpty
                        ? 0
                        : cart.fold<int>(
                            0,
                            (varl, item) => varl +
                                (item['qty'] ?? item['quantity'] ?? 1) as int,
                          );

                    final totalAmount = (data['totalAmount'] is num)
                        ? (data['totalAmount'] as num).toDouble()
                        : 0.0;

                    return Dismissible(
                      key: ValueKey(doc.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Delete Receipt"),
                            content: Text(
                                "Are you sure you want to delete Bill #$receiptNo?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text("Delete"),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) async {
                        await FirebaseFirestore.instance
                            .collection('receipts')
                            .doc(doc.id)
                            .delete();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("Receipt #$receiptNo deleted")),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: const Icon(Icons.receipt_long),
                          title: Text('Bill #$receiptNo',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('$formatted\nItems: $itemsCount'),
                          isThreeLine: true,
                          trailing: Text(
                            'Rs ${totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReceiptScreen(
                                  cart: cart,
                                  cashReceived: (data['cashReceived'] as num?)
                                          ?.toDouble() ??
                                      0.0,
                                  totalAmount: totalAmount,
                                  change:
                                      (data['change'] as num?)?.toDouble() ??
                                          0.0,
                                ),
                              ),
                            );
                          },
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
