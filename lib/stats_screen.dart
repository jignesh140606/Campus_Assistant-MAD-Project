// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Lab 11 – Option D: Data Visualization using fl_chart
// Displays:
//   1. Bar Chart – classes per day of week (from today_classes collection)
//   2. Pie Chart – campus events by month (from events collection)
// ─────────────────────────────────────────────────────────────────────────────
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Map<String, int> _classesPerDay = {};
  Map<String, int> _eventsPerMonth = {};
  int _totalClasses = 0;
  int _totalEvents = 0;
  bool _loading = true;

  static const _days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  static const _pieColors = [
    Color(0xFF2196F3),
    Color(0xFFFF9800),
    Color(0xFF4CAF50),
    Color(0xFF9C27B0),
    Color(0xFFF44336),
    Color(0xFF009688),
    Color(0xFFE91E63),
    Color(0xFFFFEB3B),
    Color(0xFF00BCD4),
    Color(0xFF3F51B5),
    Color(0xFF8BC34A),
    Color(0xFF795548),
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      // ── 1. Classes per day of week (today_classes collection) ─────────────
      final classesSnap = await FirebaseFirestore.instance
          .collection('today_classes')
          .get();

      final classesPerDay = {for (final d in _days) d: 0};
      for (final doc in classesSnap.docs) {
        final day = doc.data()['day'] as String?;
        if (day != null && classesPerDay.containsKey(day)) {
          classesPerDay[day] = classesPerDay[day]! + 1;
        }
      }

      // ── 2. Events per month (events collection) ───────────────────────────
      final eventsSnap = await FirebaseFirestore.instance
          .collection('events')
          .get();

      // Events stored as 'dd/MM/yyyy' by the date picker in campus_events_screen
      // Also try ISO 'yyyy-MM-dd' as fallback for any future-proofing
      final eventsPerMonth = <String, int>{};
      for (final doc in eventsSnap.docs) {
        final dateStr = doc.data()['date'] as String?;
        if (dateStr != null && dateStr.isNotEmpty) {
          try {
            DateTime date;
            // Try dd/MM/yyyy first (format used by campus_events_screen)
            if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(dateStr)) {
              final parts = dateStr.split('/');
              date = DateTime(int.parse(parts[2]),
                  int.parse(parts[1]), int.parse(parts[0]));
            } else {
              // Fallback: ISO format yyyy-MM-dd
              date = DateTime.parse(dateStr);
            }
            final key = _monthNames[date.month - 1];
            eventsPerMonth[key] = (eventsPerMonth[key] ?? 0) + 1;
          } catch (_) {
            // skip malformed date strings
          }
        }
      }

      if (mounted) {
        setState(() {
          _classesPerDay = classesPerDay;
          _eventsPerMonth = eventsPerMonth;
          _totalClasses = classesSnap.docs.length;
          _totalEvents = eventsSnap.docs.length;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Statistics'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchData,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => _fetchData(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  // ── Summary cards ─────────────────────────────────────────
                  Row(
                    children: [
                      _SummaryCard(
                        title: 'Total Classes',
                        value: '$_totalClasses',
                        icon: Icons.menu_book_rounded,
                        color: const Color(0xFF3F51B5),
                      ),
                      const SizedBox(width: 12),
                      _SummaryCard(
                        title: 'Total Events',
                        value: '$_totalEvents',
                        icon: Icons.event_rounded,
                        color: const Color(0xFFFF9800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Bar Chart – Classes per Day ───────────────────────────
                  _ChartCard(
                    title: 'Classes per Day of Week',
                    subtitle: 'Timetable distribution across campus',
                    icon: Icons.bar_chart_rounded,
                    iconColor: theme.colorScheme.primary,
                    child: SizedBox(height: 220, child: _buildBarChart(theme)),
                  ),
                  const SizedBox(height: 16),

                  // ── Pie Chart – Events by Month ───────────────────────────
                  _ChartCard(
                    title: 'Campus Events by Month',
                    subtitle: 'Distribution of scheduled events',
                    icon: Icons.pie_chart_rounded,
                    iconColor: const Color(0xFFFF9800),
                    child: _eventsPerMonth.isEmpty
                        ? const SizedBox(
                            height: 120,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.event_busy,
                                      size: 48, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text('No events added yet',
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              SizedBox(
                                  height: 220,
                                  child: _buildPieChart()),
                              const SizedBox(height: 12),
                              _buildPieLegend(),
                            ],
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  // ── Bar Chart ──────────────────────────────────────────────────────────────
  Widget _buildBarChart(ThemeData theme) {
    final maxVal = _classesPerDay.values.isEmpty
        ? 1
        : _classesPerDay.values.reduce((a, b) => a > b ? a : b);
    final effectiveMax = (maxVal == 0 ? 4 : maxVal + 1).toDouble();

    return BarChart(
      BarChartData(
        maxY: effectiveMax,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final day = _days[group.x];
              return BarTooltipItem(
                '$day\n${rod.toY.toInt()} class${rod.toY.toInt() == 1 ? '' : 'es'}',
                const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        barGroups: List.generate(_days.length, (i) {
          final day = _days[i];
          final count = (_classesPerDay[day] ?? 0).toDouble();
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: count == 0 ? 0.15 : count,
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.7),
                    theme.colorScheme.primary,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 24,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: effectiveMax,
                  color: theme.colorScheme.primary.withOpacity(0.07),
                ),
              ),
            ],
          );
        }),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (val, meta) {
                if (val == meta.max) return const SizedBox.shrink();
                return Text(
                  val.toInt().toString(),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (val, meta) {
                final idx = val.toInt();
                if (idx < 0 || idx >= _days.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _days[idx],
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                );
              },
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.grey.withOpacity(0.15),
            strokeWidth: 1,
          ),
        ),
      ),
    );
  }

  // ── Pie Chart ──────────────────────────────────────────────────────────────
  Widget _buildPieChart() {
    final entries = _eventsPerMonth.entries.toList();
    return PieChart(
      PieChartData(
        sections: List.generate(entries.length, (i) {
          return PieChartSectionData(
            value: entries[i].value.toDouble(),
            title: '${entries[i].value}',
            color: _pieColors[i % _pieColors.length],
            radius: 72,
            titleStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }),
        borderData: FlBorderData(show: false),
        sectionsSpace: 3,
        centerSpaceRadius: 40,
      ),
    );
  }

  // ── Pie Legend ─────────────────────────────────────────────────────────────
  Widget _buildPieLegend() {
    final entries = _eventsPerMonth.entries.toList();
    return Wrap(
      spacing: 14,
      runSpacing: 8,
      children: List.generate(entries.length, (i) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _pieColors[i % _pieColors.length],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              '${entries[i].key} (${entries[i].value})',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable widgets
// ─────────────────────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      title,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Text(subtitle,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
