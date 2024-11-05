import 'package:flutter/material.dart';

class TransaksiScreen extends StatefulWidget {
  final List<Map<String, dynamic>> transactionHistory;

  const TransaksiScreen({super.key, required this.transactionHistory});

  @override
  _TransaksiScreenState createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  // Fungsi untuk menghapus transaksi berdasarkan indeks
  void _deleteTransaction(int index) {
    setState(() {
      widget.transactionHistory.removeAt(index); // Menghapus transaksi
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
      ),
      body: ListView.builder(
        itemCount: widget.transactionHistory.length,
        itemBuilder: (context, index) {
          final transaction = widget.transactionHistory[index];
          final items = transaction['items'] as List<Map<String, dynamic>>;
          final totalPrice = transaction['totalPrice'] as int;
          final notaNumber = transaction['notaNumber'] as String;
          final timestamp = transaction['timestamp'] as DateTime;

          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text('Nota: $notaNumber'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tanggal: ${timestamp.toLocal().toString().split(' ')[0]}'),
                  Text('Jam: ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}'),
                  Text('Total: Rp$totalPrice'),
                  const SizedBox(height: 4),
                  ...items.map((item) {
                    return Text('${item['quantity']} x ${item['name']}');
                  }),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  // Konfirmasi penghapusan transaksi
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Konfirmasi Hapus'),
                        content: const Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () {
                              _deleteTransaction(index); // Hapus transaksi
                              Navigator.of(context).pop();
                            },
                            child: const Text('Hapus'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              onTap: () {
                // Menampilkan detail transaksi
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Detail Transaksi'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: [
                            Text('Nomor Nota: $notaNumber'),
                            Text('Tanggal Transaksi: ${timestamp.toLocal().toString().split(' ')[0]}'),
                            Text('Jam Transaksi: ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}'),
                            const SizedBox(height: 8),
                            const Text('Product:'),
                            ...items.map((item) {
                              return Text('${item['quantity']} x ${item['name']}');
                            }),
                            const SizedBox(height: 8),
                            Text('Total: Rp$totalPrice'),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Tutup'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
