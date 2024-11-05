import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'checkout.dart';
import 'manajemen.dart';
import 'transaksi.dart'; // Mengimpor transaksi.dart untuk digunakan

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<Product> products = []; // Daftar produk
  final List<int> quantities = []; // Jumlah produk
  final List<Map<String, dynamic>> transactionHistory = []; // Riwayat transaksi

  @override
  void initState() {
    super.initState();
    loadProducts(); // Load products on startup
  }
  void addProduct(String name, int price) {
    setState(() {
      products.add(Product(name, price));
      quantities.add(0); // Menambahkan jumlah untuk produk baru
    });
    saveProducts();
  }

  void editProduct(int index, String name, int price) {
    setState(() {
      products[index].name = name;
      products[index].price = price;
    });
    saveProducts();
  }

  void deleteProduct(int index) {
    setState(() {
      products.removeAt(index);
      quantities.removeAt(index); // Hapus jumlahnya juga
    });
    saveProducts();
  }

  void saveProducts() async {
  final prefs = await SharedPreferences.getInstance();
  List<String> productNames = products.map((p) => p.name).toList();
  List<int> productPrices = products.map((p) => p.price).toList();
  List<String> productQuantities = quantities.map((q) => q.toString()).toList();

  await prefs.setStringList('productNames', productNames);
  await prefs.setStringList('productPrices', productPrices.map((e) => e.toString()).toList());
  await prefs.setStringList('productQuantities', productQuantities);
}

  void loadProducts() async {
  final prefs = await SharedPreferences.getInstance();
  List<String>? productNames = prefs.getStringList('productNames');
  List<String>? productPrices = prefs.getStringList('productPrices');
  List<String>? productQuantities = prefs.getStringList('productQuantities');

  if (productNames != null && productPrices != null && productQuantities != null) {
    setState(() {
      products.clear();
      quantities.clear();
      
      for (int i = 0; i < productNames.length; i++) {
        products.add(Product(productNames[i], int.parse(productPrices[i])));
        quantities.add(int.parse(productQuantities[i]));
      }
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toko Frozen Food',
            theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF1976D2), // Warna biru tua
        scaffoldBackgroundColor: const Color.fromARGB(255, 213, 238, 250), // Latar belakang biru muda
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF37474F)), // Warna teks abu-abu gelap
          bodyMedium: TextStyle(color: Color(0xFF37474F)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1976D2)),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 228, 241, 243), // Biru pastel
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFF37474F),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color(0xFF2196F3), // Tombol berwarna biru tua
          textTheme: ButtonTextTheme.primary,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFBBDEFB), // Warna biru segar
        ),
      ),

      home: ProductListScreen(
        products: products,
        quantities: quantities,
        transactionHistory: transactionHistory,
        onAddProduct: addProduct,
        onEditProduct: editProduct,
        onDeleteProduct: deleteProduct,
      ),
    );
  }
}

class Product {
  String name;
  int price;

  Product(this.name, this.price);
}

class ProductListScreen extends StatefulWidget {
  final List<Product> products;
  final List<int> quantities;
  final List<Map<String, dynamic>> transactionHistory;
  final Function(String, int) onAddProduct;
  final Function(int, String, int) onEditProduct;
  final Function(int) onDeleteProduct;

  const ProductListScreen({
    super.key,
    required this.products,
    required this.quantities,
    required this.transactionHistory,
    required this.onAddProduct,
    required this.onEditProduct,
    required this.onDeleteProduct,
  });

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String searchQuery = '';

  void _addProductToCart(int index) {
    setState(() {
      widget.quantities[index]++;
    });
  }

  void _removeProductFromCart(int index) {
    setState(() {
      if (widget.quantities[index] > 0) {
        widget.quantities[index]--;
      }
    });
  }

  void _navigateToCheckout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          cartItems: widget.products.asMap().entries
              .where((entry) => widget.quantities[entry.key] > 0)
              .map((entry) => {
                    'name': entry.value.name,
                    'price': entry.value.price,
                    'quantity': widget.quantities[entry.key],
                  })
              .toList(),
          onNotaPrinted: (List<Map<String, dynamic>> printedItems, String notaNumber, int totalPrice) {
            setState(() {
              widget.transactionHistory.add({
                'notaNumber': notaNumber,
                'items': printedItems,
                'totalPrice': totalPrice,
                'timestamp': DateTime.now(),
              });
              for (var i = 0; i < widget.quantities.length; i++) {
                widget.quantities[i] = 0;
              }
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter products based on the search query
    List<Product> filteredProducts = widget.products
        .where((product) => product.name.toLowerCase().contains(searchQuery))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Produk'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.8,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                return Card(
                  color: const Color(0xFFB2EBF2), // Kartu berwarna biru segar
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          filteredProducts[index].name,
                          style: const TextStyle(
                            color: Color(0xFF424242),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'Harga: ${filteredProducts[index].price}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, color: Color(0xFF0D47A1)),
                            onPressed: () => _removeProductFromCart(widget.products.indexOf(filteredProducts[index])),
                          ),
                          Text(
                            '${widget.quantities[widget.products.indexOf(filteredProducts[index])]}' ,
                            style: const TextStyle(fontSize: 16),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: Color(0xFF0D47A1)),
                            onPressed: () => _addProductToCart(widget.products.indexOf(filteredProducts[index])),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.manage_accounts),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManajemenScreen(
                      products: widget.products,
                      onAddProduct: widget.onAddProduct,
                      onEditProduct: widget.onEditProduct,
                      onDeleteProduct: widget.onDeleteProduct,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.receipt, color: Color(0xFF0D47A1)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransaksiScreen(transactionHistory: widget.transactionHistory),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCheckout(context),
        child: Stack(
          children: [
            const Icon(Icons.shopping_cart),
            if (widget.quantities.fold(0, (sum, quantity) => sum + quantity) > 0)
              Positioned(
                right: 0,
                child: CircleAvatar(
                  backgroundColor: Colors.red,
                  radius: 10,
                  child: Text(
                    widget.quantities.fold(0, (sum, quantity) => sum + quantity).toString(),
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
