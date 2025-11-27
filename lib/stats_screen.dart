import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/stats_service.dart';

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
  
  final StatsService _statsService = StatsService();
  bool _isLoading = true;
  Map<String, dynamic> _totalStats = {'totalSessions': 0, 'totalHours': 0.0, 'avgSessionsPerDay': 0.0};
  List<List<double>> _dailyStats = List.generate(5, (_) => [0.0, 0.0]);
  List<double> _hourlyStats = List.filled(12, 0.0);
  Map<String, dynamic> _streaks = {'current': 0, 'longest': 0};
  String _aiInsights = 'Loading insights...';

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
    _loadData();
  }



  Future<void> _loadData() async {
    final totalStats = await _statsService.getTotalStats();
    final dailyStats = await _statsService.getDailyStats();
    final hourlyStats = await _statsService.getHourlyStats();
    final streaks = await _statsService.getStreaks();
    
    setState(() {
      _totalStats = totalStats;
      _dailyStats = dailyStats;
      _hourlyStats = hourlyStats;
      _streaks = streaks;
      _isLoading = false;
    });

    // Load AI insights separately as it might take longer
    _statsService.getAIInsights().then((insights) {
      if (mounted) {
        setState(() {
          _aiInsights = insights;
        });
      }
    });
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative panda elements in background
            _buildPandaDecorations(), 
            // Main content
            Column(
              children: [
                // Title
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Stats',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
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
                        const SizedBox(height: 16),
                        // Top 3 Distractions Card REMOVED
                        // Focus Streaks Card
                        _buildAnimatedCard(_buildStreaksCard(), 3),
                        const SizedBox(height: 16),
                        // AI Insights Section
                        _buildAnimatedCard(_buildAIInsightsCard(), 4),
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
        // Top right panda removed

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
              'assets/images/homescreen.png',
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Last 5 Days',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              _buildTrendIndicator('steady', ''),
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
                                    value: _totalStats['totalSessions'] > 0 ? 100 : 0,
                                    title: '',
                                    radius: 25,
                                  ),
                                  PieChartSectionData(
                                    color: Colors.grey[400],
                                    value: 0,
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
    // Real data for 5 days: [focus minutes, break minutes]
    // Note: break minutes are currently not tracked separately in dailyStats, 
    // assuming 0 or need to update service. Service returns [focus, break].
    final data = _dailyStats;
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
              decoration: BoxDecoration(
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total History',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              _buildTrendIndicator('up', ''),
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
              Text(
                '${_totalStats['totalSessions']}',
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
                  Text(
                    'Total Focus Time: ${(_totalStats['totalHours'] as double).toStringAsFixed(1)}h',
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
              Text(
                '${(_totalStats['avgSessionsPerDay'] as double).toStringAsFixed(1)}',
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Focus Streaks',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              _buildTrendIndicator('steady', ''),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStreakItem('Current Streak', '${_streaks['current']}', 'days'),
              Container(
                width: 1,
                height: 50,
                color: Colors.grey[300],
              ),
              _buildStreakItem('Longest Streak', '${_streaks['longest']}', 'days'),
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
              style: TextStyle(
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Focus Performance by Hour',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildTrendIndicator('steady', ''),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Focus minutes throughout the day',
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
                    maxY: 60,
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
                'Higher is better',
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
    // Real hourly data (9 AM - 8 PM)
    // Higher values = better focus
    final hourlyData = _hourlyStats;
    return List.generate(12, (index) {
      final value = hourlyData[index];
      // Color intensity based on focus duration
      Color barColor;
      if (value > 45) {
        barColor = Colors.black; // Great focus
      } else if (value > 20) {
        barColor = Colors.grey[700]!; // Good focus
      } else {
        barColor = Colors.grey[500]!; // Low focus
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
            _aiInsights,
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

