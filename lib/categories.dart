// import 'package:flutter/material.dart';
// import 'Doctorpage.dart';

// class AllCategoriesPage extends StatelessWidget {
//   const AllCategoriesPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // You can replace this with your real doctors list
//     final List<Map<String, dynamic>> doctorsList = [];

//     final List<CategoryItem> allCategories = [
//       CategoryItem("General", Icons.medical_services, const Color(0xff009688)),
//       CategoryItem("Cardiology", Icons.favorite, const Color(0xffFF6F91)),
//       CategoryItem("Dermatology", Icons.face, const Color(0xff845EC2)),
//       CategoryItem("Neurology", Icons.psychology, const Color(0xff0081CF)),
//       CategoryItem("Pediatrics", Icons.child_care, const Color(0xffF9F871)),
//       CategoryItem(
//         "Orthopedics",
//         Icons.accessibility_new,
//         const Color(0xff00C9A7),
//       ),
//       CategoryItem("Psychology", Icons.psychology_alt, const Color(0xffFF8A65)),
//     ];

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("All Categories"),
//         backgroundColor: Colors.teal,
//         elevation: 4,
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: GridView.builder(
//           itemCount: allCategories.length,
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 3,
//             mainAxisSpacing: 16,
//             crossAxisSpacing: 16,
//             childAspectRatio: 0.9,
//           ),
//           itemBuilder: (context, index) {
//             final item = allCategories[index];
//             return CategoryCard(
//               category: item,
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => DoctorsPage(
//                       categoryName: item.name,
//                       doctors: doctors, // replace when you add real doctors
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// // Category model
// class CategoryItem {
//   final String name;
//   final IconData icon;
//   final Color color;

//   CategoryItem(this.name, this.icon, this.color);
// }

// // Category card widget
// class CategoryCard extends StatelessWidget {
//   final CategoryItem category;
//   final VoidCallback onTap;

//   const CategoryCard({super.key, required this.category, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(18),
//       splashColor: Colors.white24,
//       child: Container(
//         decoration: BoxDecoration(
//           color: category.color,
//           borderRadius: BorderRadius.circular(18),
//           boxShadow: [
//             BoxShadow(
//               color: category.color.withOpacity(0.4),
//               blurRadius: 8,
//               offset: const Offset(2, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 60,
//               height: 60,
//               decoration: const BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white24,
//               ),
//               child: Icon(category.icon, color: Colors.white, size: 30),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               category.name,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
