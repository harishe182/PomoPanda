import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'services/stats_service.dart';


enum TimerType { focus, shortBreak, longBreak }

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  TimerType _currentTimerType = TimerType.focus;
  int _focusMinutes = 25;
  int _shortBreakMinutes = 5;
  int _longBreakMinutes = 15;
  
  int _remainingSeconds = 25 * 60; // Start with 25 minutes
  bool _isRunning = false;
  bool _isPaused = false;
  bool _focusStarted = false;
  Timer? _timer;
  
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  int _completedPomodoros = 0;
  int _currentSession = 0; // Track current session in a cycle

  @override
  void initState() {
    super.initState();
    _loadStats();
    _remainingSeconds = _getTimerDuration();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Slower breathing
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isPaused) {
      _isPaused = false;
    } else {
      _isRunning = true;
      if (_currentTimerType == TimerType.focus) {
        _focusStarted = true;
      }
    }
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timerComplete();
      }
    });
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
      _isPaused = true;
    });
    _timer?.cancel();
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _focusStarted = false;
      _remainingSeconds = _getTimerDuration();
    });
    _timer?.cancel();
  }

  void _timerComplete() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
    });
    
    // Show completion dialog
    _showCompletionDialog();
    
    // Move to next timer type
    _moveToNextTimer();
  }

  void _moveToNextTimer() {
    setState(() {
      _focusStarted = false;
      if (_currentTimerType == TimerType.focus) {
        _completedPomodoros++;
        _saveStats(TimerType.focus);
        _currentSession++;
        
        // After 4 focus sessions, take a long break
        if (_currentSession >= 4) {
          _currentTimerType = TimerType.longBreak;
          _currentSession = 0;
        } else {
          _currentTimerType = TimerType.shortBreak;
        }
      } else {
        _currentTimerType = TimerType.focus;
      }
      
      _remainingSeconds = _getTimerDuration();
    });
  }

  Future<void> _loadStats() async {
    final statsService = StatsService();
    final stats = await statsService.getTotalStats();
    setState(() {
      _completedPomodoros = stats['totalSessions'] as int;
    });
  }

  Future<void> _saveStats(TimerType type, {int? durationOverride}) async {
    final statsService = StatsService();
    int duration = 0;
    String typeStr = 'focus';
    
    switch (type) {
      case TimerType.focus:
        duration = durationOverride ?? (_focusMinutes * 60);
        typeStr = 'focus';
        break;
      case TimerType.shortBreak:
        duration = durationOverride ?? (_shortBreakMinutes * 60);
        typeStr = 'shortBreak';
        break;
      case TimerType.longBreak:
        duration = durationOverride ?? (_longBreakMinutes * 60);
        typeStr = 'longBreak';
        break;
    }
    
    await statsService.logSession(duration, typeStr);
    
    // Reload stats to ensure UI is in sync with backend
    await _loadStats();
  }

  int _getTimerDuration() {
    switch (_currentTimerType) {
      case TimerType.focus:
        return _focusMinutes * 60;
      case TimerType.shortBreak:
        return _shortBreakMinutes * 60;
      case TimerType.longBreak:
        return _longBreakMinutes * 60;
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Image.asset(
              _currentTimerType == TimerType.focus
                  ? 'assets/images/homescreen.jpg'
                  : _currentTimerType == TimerType.shortBreak
                      ? 'assets/images/shortbreak.png'
                      : 'assets/images/longbreak.png',
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _currentTimerType == TimerType.focus
                    ? 'Focus Complete!'
                    : 'Break Complete!',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
        content: Text(
          _currentTimerType == TimerType.focus
              ? 'Great job! Time for a break.'
              : 'Ready to focus again?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _getTimerTypeLabel() {
    switch (_currentTimerType) {
      case TimerType.focus:
        return 'Focus Time';
      case TimerType.shortBreak:
        return 'Short Break';
      case TimerType.longBreak:
        return 'Long Break';
    }
  }

  String _getTimerImage() {
    switch (_currentTimerType) {
      case TimerType.focus:
        return 'assets/images/homescreen.jpg';
      case TimerType.shortBreak:
        return 'assets/images/shortbreak.png';
      case TimerType.longBreak:
        return 'assets/images/longbreak.png';
    }
  }

  Color _getTimerColor() {
    return Colors.black;
  }

  double _getProgress() {
    final total = _getTimerDuration();
    return 1.0 - (_remainingSeconds / total);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 
                             MediaQuery.of(context).padding.top - 
                             MediaQuery.of(context).padding.bottom - 80, // Account for bottom nav
                ),
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PomoPanda',
                                style: GoogleFonts.poppins(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                  letterSpacing: -1,
                                ),
                              ),
                              Text(
                                '${_completedPomodoros} pomodoros completed',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          // Timer type indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getTimerTypeLabel(),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Timer display
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Panda image with animation
                          Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ScaleTransition(
                              scale: _isRunning
                                  ? Tween<double>(begin: 1.0, end: 1.05).animate(
                                      CurvedAnimation(
                                        parent: _animationController,
                                        curve: Curves.easeInOut,
                                      ),
                                    )
                                  : const AlwaysStoppedAnimation(1.0),
                              child: ClipOval(
                                child: Padding(
                                  padding: EdgeInsets.all(
                                    _currentTimerType == TimerType.focus ? 0.0 : 30.0,
                                  ),
                                  child: Image.asset(
                                    _getTimerImage(),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),const SizedBox(height: 20),
                          // Circular progress indicator
                          SizedBox(
                            width: 230,
                            height: 230,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Background circle
                                Container(
                                  width: 230,
                                  height: 230,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[200],
                                  ),
                                ),
                                // Progress circle
                                SizedBox(
                                  width: 260,
                                  height: 260,
                                  child: CircularProgressIndicator(
                                    value: _getProgress(),
                                    strokeWidth: 24,
                                    backgroundColor: Colors.grey[200],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black,
                                    ),
                                    strokeCap: StrokeCap.butt, // Minimal look
                                  ),
                                ),
                                // Time display
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _formatTime(_remainingSeconds),
                                      style: GoogleFonts.inter(
                                        fontSize: 70,
                                        fontWeight: FontWeight.w200,
                                        color: Colors.black,
                                        letterSpacing: -4,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _getTimerTypeLabel(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Control buttons
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Reset button (positioned to the left)
                              if (_isPaused || _isRunning)
                                Positioned(
                                  left: 0,
                                  child: IconButton(
                                    onPressed: _resetTimer,
                                    icon: Icon(Icons.refresh),
                                    iconSize: 32,
                                    color: Colors.grey[600],
                                    tooltip: 'Reset',
                                  ),
                                ),
                              // Play/Pause button (centered)
                              GestureDetector(
                                onTap: () {
                                  if (_isRunning) {
                                    _pauseTimer();
                                  } else {
                                    _startTimer();
                                  }
                                },
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white, // Always white
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.2),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    color: Colors.black, // Icon black
                                    size: 40,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Timer type selector
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildTimerTypeButton(
                            TimerType.focus,
                            'Focus',
                            Icons.timer,
                          ),
                          _buildTimerTypeButton(
                            TimerType.shortBreak,
                            'Short',
                            Icons.coffee,
                          ),
                          _buildTimerTypeButton(
                            TimerType.longBreak,
                            'Long',
                            Icons.weekend,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildTimerTypeButton(
    TimerType type,
    String label,
    IconData icon,
  ) {
    final isSelected = _currentTimerType == type;

    return GestureDetector(
      onTap: () {
        if (!_isRunning) {
          setState(() {
            // Check for manual completion (Focus -> Break)
            if (_currentTimerType == TimerType.focus &&
                (type == TimerType.shortBreak || type == TimerType.longBreak)) {
              if (_focusStarted) {
                _completedPomodoros++;
                // Calculate elapsed time: Total Duration - Remaining Seconds
                final totalDuration = _focusMinutes * 60;
                final elapsedTime = totalDuration - _remainingSeconds;
                
                _saveStats(TimerType.focus, durationOverride: elapsedTime); // Log the focus session with actual time
                _saveStats(type); // Log the break session immediately
                _focusStarted = false;
              }
            } else if (_currentTimerType != TimerType.focus && type == TimerType.focus) {
               // Reset focusStarted when switching TO focus (just in case)
               _focusStarted = false;
            }

            _currentTimerType = type;
            _remainingSeconds = _getTimerDuration();
          });
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isSelected ? 70 : 60,
            height: isSelected ? 70 : 60,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.black : Colors.grey.shade300,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              size: 28,
              color: isSelected ? Colors.black : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? Colors.black : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

