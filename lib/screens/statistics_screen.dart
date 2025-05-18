import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:habit_tracker/models/habit.dart';

IconData _getCategoryIcon(HabitCategory category) {
  switch (category) {
    case HabitCategory.health:
      return Icons.favorite;
    case HabitCategory.work:
      return Icons.work;
    case HabitCategory.learning:
      return Icons.school;
    case HabitCategory.fitness:
      return Icons.fitness_center;
    case HabitCategory.mindfulness:
      return Icons.self_improvement;
    case HabitCategory.other:
      return Icons.category;
  }
}

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.transparent,
              title: Text(
                'Your Progress',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: OverallProgressCard(),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CompletionChart(),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CategoryBreakdown(),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: StreakAchievements(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OverallProgressCard extends StatelessWidget {
  const OverallProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final progress = provider.getOverallProgress();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overall Progress',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard(
                context,
                'Average Streak',
                '${progress.toStringAsFixed(1)} days',
              ),
              _buildStatCard(
                context,
                'Total Habits',
                provider.habits.length.toString(),
              ),
              _buildStatCard(
                context,
                'Active Streaks',
                provider.habits
                    .where((h) => h.hasActiveStreak())
                    .length
                    .toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class CompletionChart extends StatelessWidget {
  const CompletionChart({super.key});

  List<FlSpot> _getWeeklyData(List<Habit> habits) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final spots = List<FlSpot>.filled(7, const FlSpot(0, 0));

    for (var i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      var activeStreaks = 0;

      for (final habit in habits) {
        // Check if the habit was active (no relapse) on this date
        if (habit.startDate.isBefore(date) &&
            (habit.lastRelapseDate == null ||
                habit.lastRelapseDate!.isBefore(date))) {
          activeStreaks++;
        }
      }

      spots[i] = FlSpot(i.toDouble(), activeStreaks.toDouble());
    }

    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final weeklyData = _getWeeklyData(provider.habits);

    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Active Habits',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        if (value >= 0 && value < days.length) {
                          return Text(
                            days[value.toInt()],
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: weeklyData,
                    isCurved: true,
                    color: Theme.of(context).colorScheme.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryBreakdown extends StatelessWidget {
  const CategoryBreakdown({super.key});

  List<_CategoryData> _getCategoryData(List<Habit> habits) {
    final categoryData = <HabitCategory, _CategoryData>{};

    for (final category in HabitCategory.values) {
      final categoryHabits =
          habits.where((h) => h.category == category).toList();
      if (categoryHabits.isNotEmpty) {
        var totalDuration = Duration.zero;
        for (var habit in categoryHabits) {
          totalDuration += habit.getStreakDuration();
        }
        final avgDuration =
            totalDuration.inHours / (categoryHabits.length * 24);

        categoryData[category] = _CategoryData(
          category: category,
          averageStreak: avgDuration,
          totalHabits: categoryHabits.length,
        );
      }
    }

    return categoryData.values.toList()
      ..sort((a, b) => b.averageStreak.compareTo(a.averageStreak));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final categoryData = _getCategoryData(provider.habits);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Breakdown',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          ...categoryData.map((data) => _buildCategoryRow(context, data)),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(BuildContext context, _CategoryData data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            _getCategoryIcon(data.category),
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.category.toString().split('.').last,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${data.totalHabits} habits · ${data.averageStreak.toStringAsFixed(1)} days avg streak',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${(data.averageStreak * 100 ~/ 30)}%',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryData {
  final HabitCategory category;
  final double averageStreak;
  final int totalHabits;

  _CategoryData({
    required this.category,
    required this.averageStreak,
    required this.totalHabits,
  });
}

class StreakAchievements extends StatelessWidget {
  const StreakAchievements({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final habits = provider.habits;

    // Sort habits by streak duration in descending order
    final sortedHabits = [...habits]
      ..sort((a, b) => b.getStreakDuration().compareTo(a.getStreakDuration()));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Streaks',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          if (sortedHabits.isEmpty)
            const Text(
              'No streaks yet. Start building habits!',
              style: TextStyle(color: Colors.white70),
            )
          else
            ...sortedHabits
                .take(5)
                .map((habit) => _buildStreakRow(context, habit)),
        ],
      ),
    );
  }

  Widget _buildStreakRow(BuildContext context, Habit habit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            habit.icon,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  habit.getFormattedStreakDuration(),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          if (habit.hasActiveStreak())
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Active',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.timer,
                    color: Colors.orange,
                    size: 14,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
