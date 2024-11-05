import 'package:flutter/material.dart';
import 'main.dart';

class ManajemenScreen extends StatefulWidget {
  final List<Product> products;
  final Function(String, int) onAddProduct;
  final Function(int, String, int) onEditProduct;
  final Function(int) onDeleteProduct;

  const ManajemenScreen({
    super.key,
    required this.products,
    required this.onAddProduct,
    required this.onEditProduct,
    required this.onDeleteProduct,
  });

  @override
  _ManajemenScreenState createState() => _ManajemenScreenState();
}

class _ManajemenScreenState extends State<ManajemenScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  void _submitForm() {
    final name = _nameController.text;
    final price = int.tryParse(_priceController.text) ?? 0;

    if (name.isNotEmpty && price > 0) {
      // Panggil fungsi onAddProduct dari MyApp untuk menyimpan produk
      widget.onAddProduct(name, price);
      Navigator.pop(context); // Kembali ke layar sebelumnya setelah produk ditambahkan
    }
  }

  void _editProduct(int index) {
    final name = _nameController.text;
    final price = int.tryParse(_priceController.text) ?? 0;

    if (name.isNotEmpty && price > 0) {
      widget.onEditProduct(index, name, price);
      Navigator.pop(context); // Kembali setelah produk diedit
    }
  }

  void _deleteProduct(int index) {
    widget.onDeleteProduct(index);
    Navigator.pop(context); // Kembali setelah produk dihapus
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Produk'),
      ),
      body: ListView.builder(
        itemCount: widget.products.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(widget.products[index].name),
            subtitle: Text('Harga: ${widget.products[index].price}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    _nameController.text = widget.products[index].name;
                    _priceController.text = widget.products[index].price.toString();

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Edit Produk'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(labelText: 'Nama Produk'),
                            ),
                            TextField(
                              controller: _priceController,
                              decoration: const InputDecoration(labelText: 'Harga Produk'),
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () => _editProduct(index),
                            child: const Text('Simpan'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteProduct(index),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _nameController.clear();
          _priceController.clear();

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Tambah Produk Baru'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nama Produk'),
                  ),
                  TextField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Harga Produk'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: _submitForm, // Memanggil fungsi untuk menambah produk
                  child: const Text('Simpan'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
