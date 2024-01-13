// import 'package:flutter/material.dart';

// class CustomBottomNavigationBar extends StatelessWidget {
//   final int selectedIndex;
//   final Function(int) onItemTapped;

//   const CustomBottomNavigationBar({
//     required this.selectedIndex,
//     required this.onItemTapped,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Theme(
//       data: Theme.of(context).copyWith(
//         canvasColor: Colors
//             .black, // Set the background color of the BottomAppBar to black
//       ),
//       child: BottomAppBar(
//         color: Colors.blueGrey, // Set the BottomAppBar color to transparent
//         shape: const CircularNotchedRectangle(),
//         child: Row(
//           mainAxisSize: MainAxisSize.max,
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: <Widget>[
//             IconButton(
//               icon: Icon(
//                 Icons.car_crash,
//                 color: selectedIndex == 0 ? Colors.red : Colors.white,
//               ),
//               onPressed: () {
//                 onItemTapped(0);
//               },
//             ),
//             IconButton(
//               icon: Icon(
//                 Icons.person,
//                 color: selectedIndex == 1 ? Colors.red : Colors.white,
//               ),
//               onPressed: () {
//                 onItemTapped(1);
//               },
//             ),
//             IconButton(
//               icon: Icon(
//                 Icons.map,
//                 color: selectedIndex == 2 ? Colors.red : Colors.white,
//               ),
//               onPressed: () {
//                 onItemTapped(2);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
