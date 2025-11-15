import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with TickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late AnimationController _chartAnimationController;
  late Animation<double> _cardAnimation;
  late Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _cardAnimation = CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOutCubic,
    );
    _chartAnimation = CurvedAnimation(
      parent: _chartAnimationController,
      curve: Curves.easeOutCubic,
    );
    _cardAnimationController.forward();
    _chartAnimationController.forward();
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _chartAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative panda elements in background
            _buildPandaDecorations(),
            // Main content
            Column(
              children: [
                // Title
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'Stats',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        // Last 5 Days Card
                        _buildAnimatedCard(_buildLast5DaysCard(), 0),
                        const SizedBox(height: 16),
                        // Total History Card
                        _buildAnimatedCard(_buildTotalHistoryCard(), 1),
                        const SizedBox(height: 16),
                        // Hourly Focus Card
                        _buildAnimatedCard(_buildHourlyFocusCard(), 2),
                        const SizedBox(height: 16),
                        // Top 3 Distractions Card
                        _buildAnimatedCard(_buildTopDistractionsCard(), 3),
                        const SizedBox(height: 16),
                        // Focus Streaks Card
                        _buildAnimatedCard(_buildStreaksCard(), 4),
                        const SizedBox(height: 16),
                        // AI Insights Section
                        _buildAnimatedCard(_buildAIInsightsCard(), 5),
                        const SizedBox(height: 80), // Space for bottom nav
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPandaDecorations() {
    return Stack(
      children: [
        // Top right panda (waving - use pomo_panda.png)
        Positioned(
          top: 10,
          right: 20,
          child: Opacity(
            opacity: 0.08,
            child: Transform.rotate(
              angle: 0.2,
              child: Image.asset(
                'assets/images/pomo_panda.png',
                width: 60,
                height: 60,
              ),
            ),
          ),
        ),
        // Middle left panda (sitting with bamboo - use onboarding.png)
        Positioned(
          top: 300,
          left: -20,
          child: Opacity(
            opacity: 0.06,
            child: Transform.rotate(
              angle: -0.3,
              child: Image.asset(
                'assets/images/onboarding.png',
                width: 80,
                height: 80,
              ),
            ),
          ),
        ),
        // Bottom right panda (sleeping - use longbreak.png)
        Positioned(
          bottom: 200,
          right: -10,
          child: Opacity(
            opacity: 0.07,
            child: Transform.rotate(
              angle: 0.4,
              child: Image.asset(
                'assets/images/longbreak.png',
                width: 70,
                height: 70,
              ),
            ),
          ),
        ),
        // Small panda near middle (use shortbreak.png)
        Positioned(
          top: 500,
          right: 30,
          child: Opacity(
            opacity: 0.05,
            child: Image.asset(
              'assets/images/shortbreak.png',
              width: 50,
              height: 50,
            ),
          ),
        ),
        // Tiny panda accent (use homescreen.jpg - studying panda)
        Positioned(
          top: 150,
          left: 40,
          child: Opacity(
            opacity: 0.04,
            child: Image.asset(
              'assets/images/homescreen.jpg',
              width: 40,
              height: 40,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedCard(Widget child, int index) {
    return FadeTransition(
      opacity: _cardAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _cardAnimationController,
          curve: Interval(
            index * 0.1,
            0.5 + (index * 0.1),
            curve: Curves.easeOut,
          ),
        )),
        child: child,
      ),
    );
  }

  Widget _buildTrendIndicator(String trend, String percentage) {
    IconData icon;
    Color color;
    switch (trend) {
      case 'up':
        icon = Icons.arrow_upward;
        color = Colors.grey[600]!;
        break;
      case 'down':
        icon = Icons.arrow_downward;
        color = Colors.grey[600]!;
        break;
      case 'steady':
      default:
        icon = Icons.arrow_forward;
        color = Colors.grey[600]!;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            percentage,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLast5DaysCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Last 5 Days',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              _buildTrendIndicator('up', '12%'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Bar Chart
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 180,
                  child: AnimatedBuilder(
                    animation: _chartAnimation,
                    builder: (context, child) {
                      return BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 100,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '${value.toInt() + 1}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          barGroups: _buildBarGroups(),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Donut Chart
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    SizedBox(
                      height: 120,
                      width: 120,
                      child: AnimatedBuilder(
                        animation: _chartAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: (1 - _chartAnimation.value) * 3.14159 * 2,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 35,
                                startDegreeOffset: 0,
                                sections: [
                                  PieChartSectionData(
                                    color: Colors.black,
                                    value: 60 * _chartAnimation.value,
                                    title: '',
                                    radius: 25,
                                  ),
                                  PieChartSectionData(
                                    color: Colors.grey[400],
                                    value: 40 * _chartAnimation.value,
                                    title: '',
                                    radius: 25,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildLegend(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    // Mock data for 5 days: [work time, break time]
    final data = [
      [70, 25],
      [50, 18],
      [85, 30],
      [65, 22],
      [75, 28],
    ];
    return List.generate(5, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data[index][0] * _chartAnimation.value,
            color: Colors.black,
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: data[index][1] * _chartAnimation.value,
            color: Colors.grey[400],
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Short Break',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Long Break',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTotalHistoryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              _buildTrendIndicator('up', '8%'),
            ],
          ),
          const SizedBox(height: 20),
          // Total Sessions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Sessions:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Focus',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const Text(
                '125',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Divider(height: 32, color: Colors.grey[300]),
          // Total Focus Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Focus Time: 52h 30m',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Average Session/Day',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const Text(
                '3.5',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreaksCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Focus Streaks',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              _buildTrendIndicator('steady', '0%'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStreakItem('Current Streak', '7', 'days'),
              Container(
                width: 1,
                height: 50,
                color: Colors.grey[300],
              ),
              _buildStreakItem('Longest Streak', '14', 'days'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Text(
                unit,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHourlyFocusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Focus Performance by Hour',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              _buildTrendIndicator('up', '2%'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Distraction attempts throughout the day',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: AnimatedBuilder(
              animation: _chartAnimation,
              builder: (context, child) {
                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 50,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            final hours = [
                              '9',
                              '10',
                              '11',
                              '12',
                              '1',
                              '2',
                              '3',
                              '4',
                              '5',
                              '6',
                              '7',
                              '8'
                            ];
                            if (value.toInt() >= 0 &&
                                value.toInt() < hours.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  hours[value.toInt()],
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 10,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey[200],
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: _buildHourlyBarGroups(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Lower is better (fewer distractions)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildHourlyBarGroups() {
    // Mock data: distraction attempts per hour (9 AM - 8 PM)
    // Lower values = better focus
    final hourlyData = [15, 12, 8, 18, 32, 45, 38, 25, 20, 15, 10, 8];
    return List.generate(12, (index) {
      final value = hourlyData[index];
      // Color intensity based on distraction level
      Color barColor;
      if (value < 15) {
        barColor = Colors.black; // Great focus
      } else if (value < 30) {
        barColor = Colors.grey[700]!; // Good focus
      } else {
        barColor = Colors.grey[500]!; // Needs improvement
      }
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value * _chartAnimation.value,
            color: barColor,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTopDistractionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.phone_android, color: Colors.black, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Top 3 Distractions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              _buildTrendIndicator('down', '5%'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Apps you tried to access most',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          _buildDistractionBar('TikTok', 45, Icons.music_note),
          const SizedBox(height: 16),
          _buildDistractionBar('Instagram', 32, Icons.camera_alt),
          const SizedBox(height: 16),
          _buildDistractionBar('Snapchat', 28, Icons.chat_bubble),
        ],
      ),
    );
  }

  Widget _buildDistractionBar(String appName, int attempts, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: Colors.black),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _chartAnimation,
                          builder: (context, child) {
                            return Stack(
                              children: [
                                Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor:
                                      (attempts / 50) * _chartAnimation.value,
                                  child: Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.black,
                                          Colors.grey[700]!
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$attempts',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAIInsightsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey[100]!,
            Colors.grey[200]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[400]!, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.black, size: 24),
              SizedBox(width: 8),
              Text(
                'AI Insights',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Your focus tends to be strongest in the morning hours, with peak productivity between 9 AM and 11 AM. You\'ve maintained a consistent 7-day streak, which is excellent! However, your focus sessions drop significantly around 2 PM - consider scheduling a longer break or a walk during this time. Your short break usage has increased by 15% this week, suggesting you might benefit from slightly longer focus sessions to build momentum.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

}

