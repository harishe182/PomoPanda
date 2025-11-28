import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Session {
  final DateTime startTime;
  final int durationSeconds;
  final String type; // 'focus', 'shortBreak', 'longBreak'

  Session({
    required this.startTime,
    required this.durationSeconds,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'startTime': startTime.toIso8601String(),
        'durationSeconds': durationSeconds,
        'type': type,
      };

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        startTime: DateTime.parse(json['startTime']),
        durationSeconds: json['durationSeconds'],
        type: json['type'],
      );
}

class StatsService {
  static const String _storageKey = 'pomopanda_sessions';
  static const String _apiKey = 'AIzaSyBmqUzWANS_aQjihYw9t2W_5hlJ_lj1Y-k';

  Future<void> logSession(int durationSeconds, String type) async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = await getSessions();
    
    final newSession = Session(
      startTime: DateTime.now(),
      durationSeconds: durationSeconds,
      type: type,
    );
    
    sessions.add(newSession);
    
    final String jsonString = jsonEncode(sessions.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  Future<List<Session>> getSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_storageKey);
    
    if (jsonString == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((e) => Session.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> getTotalStats() async {
    final sessions = await getSessions();
    final focusSessions = sessions.where((s) => s.type == 'focus').toList();
    
    int totalSeconds = 0;
    for (var session in focusSessions) {
      totalSeconds += session.durationSeconds;
    }
    
    final double totalHours = totalSeconds / 3600;
    
    // Calculate average sessions per day
    if (focusSessions.isEmpty) {
      return {
        'totalSessions': 0,
        'totalHours': 0.0,
        'avgSessionsPerDay': 0.0,
      };
    }

    final firstSession = focusSessions.first.startTime;
    final lastSession = focusSessions.last.startTime;
    final daysDiff = lastSession.difference(firstSession).inDays + 1;
    
    return {
      'totalSessions': focusSessions.length,
      'totalHours': totalHours,
      'avgSessionsPerDay': focusSessions.length / daysDiff,
    };
  }

  Future<List<List<double>>> getDailyStats() async {
    final sessions = await getSessions();
    final now = DateTime.now();
    final List<List<double>> data = []; // [focusMinutes, breakMinutes] for last 5 days

    for (int i = 4; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final daySessions = sessions.where((s) =>
          s.startTime.year == date.year &&
          s.startTime.month == date.month &&
          s.startTime.day == date.day);

      double focusMinutes = 0;
      double breakMinutes = 0;

      for (var session in daySessions) {
        if (session.type == 'focus') {
          focusMinutes += session.durationSeconds / 60;
        } else {
          breakMinutes += session.durationSeconds / 60;
        }
      }
      data.add([focusMinutes, breakMinutes]);
    }
    return data;
  }

  Future<List<double>> getHourlyStats() async {
    final sessions = await getSessions();
    final List<double> hourlyFocus = List.filled(12, 0.0); // 9 AM to 8 PM

    for (var session in sessions) {
      if (session.type == 'focus') {
        final hour = session.startTime.hour;
        // Map hours: 9->0, 10->1, ..., 20->11
        if (hour >= 9 && hour <= 20) {
          hourlyFocus[hour - 9] += session.durationSeconds / 60;
        }
      }
    }
    return hourlyFocus;
  }

  Future<Map<String, dynamic>> getStreaks() async {
    final sessions = await getSessions();
    final focusSessions = sessions.where((s) => s.type == 'focus').toList();
    
    if (focusSessions.isEmpty) {
      return {'current': 0, 'longest': 0};
    }

    // Sort by date
    focusSessions.sort((a, b) => a.startTime.compareTo(b.startTime));

    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;
    
    // Get unique days
    final Set<String> uniqueDays = {};
    for (var session in focusSessions) {
      uniqueDays.add('${session.startTime.year}-${session.startTime.month}-${session.startTime.day}');
    }
    
    final sortedDays = uniqueDays.toList()..sort();
    
    if (sortedDays.isEmpty) return {'current': 0, 'longest': 0};

    // Calculate streaks
    DateTime? lastDate;
    
    for (var dayStr in sortedDays) {
      final parts = dayStr.split('-');
      final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      
      if (lastDate == null) {
        tempStreak = 1;
      } else {
        final diff = date.difference(lastDate).inDays;
        if (diff == 1) {
          tempStreak++;
        } else {
          if (tempStreak > longestStreak) longestStreak = tempStreak;
          tempStreak = 1;
        }
      }
      lastDate = date;
    }
    
    if (tempStreak > longestStreak) longestStreak = tempStreak;
    
    // Check if current streak is active (today or yesterday)
    final lastSessionDate = DateTime.parse(sortedDays.last); // Reconstruct roughly
    // Actually better to check if last recorded day is today or yesterday
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month}-${now.day}';
    final yesterday = now.subtract(const Duration(days: 1));
    final yesterdayStr = '${yesterday.year}-${yesterday.month}-${yesterday.day}';
    
    if (sortedDays.last == todayStr || sortedDays.last == yesterdayStr) {
      currentStreak = tempStreak;
    } else {
      currentStreak = 0;
    }

    return {'current': currentStreak, 'longest': longestStreak};
  }

  Future<String> getAIInsights() async {
    final stats = await getTotalStats();
    final streaks = await getStreaks();
    final hourly = await getHourlyStats();
    final daily = await getDailyStats();
    final sessions = await getSessions();
    
    // Find peak hour
    int peakHourIndex = 0;
    double maxFocus = 0;
    for (int i = 0; i < hourly.length; i++) {
      if (hourly[i] > maxFocus) {
        maxFocus = hourly[i];
        peakHourIndex = i;
      }
    }
    final peakHour = peakHourIndex + 9;
    
    // Calculate break statistics
    final breakSessions = sessions.where((s) => s.type != 'focus').toList();
    final totalBreakMinutes = breakSessions.fold<double>(0.0, (sum, s) => sum + (s.durationSeconds / 60));
    
    // Find most productive day
    int bestDayIndex = 0;
    double maxDayFocus = 0;
    for (int i = 0; i < daily.length; i++) {
      if (daily[i][0] > maxDayFocus) {
        maxDayFocus = daily[i][0];
        bestDayIndex = i;
      }
    }
    final daysAgo = 4 - bestDayIndex;
    
    final prompt = '''
    Analyze these Pomodoro productivity stats and provide a unique, personalized insight (max 3 sentences).
    IMPORTANT: Vary your response style each time - be motivational, analytical, insightful, or encouraging.
    Request ID: ${DateTime.now().millisecondsSinceEpoch}
    
    User Statistics:
    - Total Focus Sessions: ${stats['totalSessions']}
    - Total Focus Time: ${stats['totalHours'].toStringAsFixed(1)} hours
    - Average Sessions per Day: ${stats['avgSessionsPerDay'].toStringAsFixed(1)}
    - Current Streak: ${streaks['current']} days
    - Longest Streak: ${streaks['longest']} days
    - Peak Productivity Hour: ${peakHour}:00
    - Most Productive Day: ${daysAgo == 0 ? 'Today' : daysAgo == 1 ? 'Yesterday' : '$daysAgo days ago'} (${maxDayFocus.toStringAsFixed(0)} minutes)
    - Total Break Time: ${totalBreakMinutes.toStringAsFixed(0)} minutes
    
    Provide actionable, data-driven insights based on these real numbers.
    ''';

    try {
      final response = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$_apiKey',
        ),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-client': 'gl-dart/3.2.0',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [{'text': prompt}]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topP': 0.9,
            'topK': 40,
          }
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        print('AI API Error: ${response.statusCode} - ${response.body}');
        return 'Keep pushing! Your focus is improving every day.';
      }

      final data = jsonDecode(response.body);

      // Handle safety blocks
      if (data['promptFeedback'] != null &&
          data['promptFeedback']['blockReason'] != null) {
        print('Prompt blocked: ${data['promptFeedback']}');
        return 'Your productivity looks strong — keep going!';
      }

      // Now extract the text safely
      final candidates = data['candidates'];
      if (candidates == null || candidates.isEmpty) {
        print('No candidates returned: $data');
        return 'Stay focused — great things are coming!';
      }

      // Content may be a map OR a list
      final content = candidates[0]['content'];

      List parts;
      if (content is Map) {
        parts = content['parts'];
      } else if (content is List) {
        parts = content.first['parts'];
      } else {
        print('Unexpected content format: $content');
        return 'You\'re building great habits — keep it up!';
      }

      if (parts == null || parts.isEmpty) {
        print('No parts found: $data');
        return 'Your consistency is paying off — stay with it!';
      }

      return parts[0]['text'] ?? 'Great progress — keep going!';
    } catch (e) {
      print('AI Insights Error: $e');
      return 'Great job staying focused! Consistency is key.';
    }
  }
}
