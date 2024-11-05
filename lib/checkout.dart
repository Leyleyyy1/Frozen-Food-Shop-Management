import 'package:flutter/material.dart';

class CheckoutScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final Function(List<Map<String, dynamic>>, String, int) onNotaPrinted;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.onNotaPrinted,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nota Pembelian',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return ListTile(
                    title: Text(item['name']),
                    subtitle: Text('Harga: ${item['price']}'),
                    trailing: Text('Jumlah: ${item['quantity']}'),
                  );
                },
              ),
            ),
            const Divider(thickness: 2),
            ElevatedButton(
              onPressed: () {
                _printNota(context);
              },
              child: const Text('Cetak Nota'),
            ),
          ],
        ),
      ),
    );
  }

  void _printNota(BuildContext context) {
    // Menghitung total harga
    int totalPrice = cartItems.fold<int>(
        0, (sum, item) => sum + (item['price'] * item['quantity'] as int)); // Cast ke int

    // Membuat nomor nota
    String notaNumber = DateTime.now().millisecondsSinceEpoch.toString(); // atau gunakan format yang lain

    // Menampilkan pop-up nota
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nota Pembelian'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nomor Nota:'),
                Text(notaNumber),
                const SizedBox(height: 8),
                const Text('Tanggal Transaksi:'),
                Text(DateTime.now().toLocal().toString().split(' ')[0]), // Tanggal
                const SizedBox(height: 8),
                const Text('Jam Transaksi:'),
                Text(DateTime.now().toLocal().toString().split(' ')[1].split('.')[0]), // Jam
                const SizedBox(height: 16),
                const Text('Produk:'),
                const Divider(),
                ...cartItems.asMap().entries.map((entry) {
                  int index = entry.key;
                  var item = entry.value;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text('${index + 1}. ${item['name']}'),
                      ),
                      Text(
                        'Rp${item['price']}',
                        style: const TextStyle(fontSize: 12), // Font lebih kecil
                      ),
                    ],
                  );
                }),
                const Divider(),
                Text('Total = Rp$totalPrice', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text('TERIMA KASIH TELAH BERBELANJA!'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Mengirim cartItems ke TransaksiScreen
                onNotaPrinted(cartItems, notaNumber, totalPrice); // Panggil fungsi untuk mengupdate riwayat transaksi
                Navigator.pop(context); // Kembali ke halaman sebelumnya setelah mencetak nota
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
