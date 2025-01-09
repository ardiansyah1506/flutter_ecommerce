import 'package:flutter/material.dart';
import 'package:frontend/screens/history_page.dart';
import 'package:frontend/services/order_service.dart';

class ManajemenUserPage extends StatefulWidget {
  @override
  _ManajemenUserPageState createState() => _ManajemenUserPageState();
}

class _ManajemenUserPageState extends State<ManajemenUserPage> {
  final OrderService _orderService = OrderService();
  late Future<List<Map<String, dynamic>>> _futureUsers;

  @override
  void initState() {
    super.initState();
    _futureUsers = _orderService.getUsers(); // Menggunakan metode yang benar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manajemen User',
          style: TextStyle(color: Color(0xFFD0C05B)),
        ),
        backgroundColor: Colors.brown,
        iconTheme: const IconThemeData(color: Color(0xFFD0C05B)),
      ),
      body: Container(
        color: Color.fromARGB(255, 252, 252, 252), // Background utama
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _futureUsers,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFD0C05B),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Color(0xFFD0C05B)),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'Tidak ada data user.',
                  style: TextStyle(color: Color(0xFFD0C05B)),
                ),
              );
            } else {
              final users = snapshot.data!;
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    color: Color(0xFFD0C05B), // Warna card
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: const Icon(
                        Icons.person,
                        color: Colors.brown, // Warna ikon
                      ),
                      title: Text(
                        user['username'],
                        style: const TextStyle(color: Colors.brown),
                      ),
                      subtitle: Text(
                        user['email'],
                        style: const TextStyle(color: Colors.brown), // Warna teks tambahan
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.history,
                          color: Colors.brown,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HistoryBelanjaPage(
                                userId: user['user_id'],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}