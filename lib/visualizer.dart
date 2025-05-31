// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
//
// class Visualizer extends StatelessWidget {
//   final Map<String, double> healthData; // Example: {"BP": 120, "Sugar": 90}
//
//   const Visualizer({super.key, required this.healthData});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Health Data Visualization"),
//         backgroundColor: Colors.black,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "Health Data Visualization",
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFFE57300), // Orange color
//                 ),
//               ),
//               const SizedBox(height: 20),
//               AspectRatio(
//                 aspectRatio: 1.5,
//                 child: BarChart(
//                   BarChartData(
//                     alignment: BarChartAlignment.spaceAround,
//                     maxY: healthData.values.reduce((a, b) => a > b ? a : b) + 20,
//                     barGroups: healthData.entries.map((entry) {
//                       return BarChartGroupData(
//                         x: entry.key.hashCode, // Use hashcode as unique identifier
//                         barRods: [
//                           BarChartRodData(
//                             toY: entry.value,
//                             color: Colors.orange,
//                             width: 20,
//                           ),
//                         ],
//                         showingTooltipIndicators: [0],
//                       );
//                     }).toList(),
//                     titlesData: FlTitlesData(
//                       show: true,
//                       bottomTitles: AxisTitles(
//                         sideTitles: SideTitles(
//                           showTitles: true,
//                           getTitlesWidget: (value, meta) {
//                             String title = healthData.keys.elementAt(value.toInt());
//                             return Text(title, style: const TextStyle(color: Colors.white));
//                           },
//                         ),
//                       ),
//                       leftTitles: AxisTitles(
//                         sideTitles: SideTitles(
//                           showTitles: true,
//                           getTitlesWidget: (value, meta) {
//                             return Text(value.toStringAsFixed(0), style: const TextStyle(color: Colors.white));
//                           },
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }