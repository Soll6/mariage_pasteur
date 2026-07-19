import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/drinks.dart';

class DrinkPieChart extends StatelessWidget {
  final Map<String, int> drinkStats;

  const DrinkPieChart({super.key, required this.drinkStats});

  @override
  Widget build(BuildContext context) {
    if (drinkStats.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text(
              'Aucune préférence de boisson enregistrée',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    final sortedEntries = drinkStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = sortedEntries.fold<int>(0, (sum, e) => sum + e.value);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Préférences de boissons',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  sections: sortedEntries.map((entry) {
                    final color = getDrinkColor(entry.key);
                    final pct = (entry.value / total * 100).toStringAsFixed(0);
                    return PieChartSectionData(
                      color: color,
                      value: entry.value.toDouble(),
                      title: '$pct%',
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: sortedEntries.map((entry) {
                final color = getDrinkColor(entry.key);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${entry.key} (${entry.value})',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
