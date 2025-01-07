// import 'package:flutter/material.dart';
// import 'user_page.dart';
// import 'history_page.dart';

// class MainUserPage extends StatefulWidget {
//   final String role; // Parameter role jika Anda perlu membedakan UI

//   const MainUserPage({Key? key, required this.role}) : super(key: key);

//   @override
//   State<MainUserPage> createState() => _MainUserPageState();
// }

// class _MainUserPageState extends State<MainUserPage> {
//   int _currentIndex = 0;

//   // Daftar halaman: UserPage & HistoryPage
//   final List<Widget> _pages = const [
//     UserPage(),
//     HistoryPage(),
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Jika ingin mengakses role, gunakan widget.role
//     // Contoh debug: print("Role: ${widget.role}");

//     return Scaffold(
//       body: _pages[_currentIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: _onItemTapped,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home', // ke UserPage
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.history),
//             label: 'Riwayat', // ke HistoryPage
//           ),
//         ],
//       ),
//     );
//   }
// }
