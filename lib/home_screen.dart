import 'package:flutter/material.dart';
import 'dart:async';

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
  Timer? _timer;
  
  late AnimationController _pandaAnimationController;
  late Animation<double> _pandaAnimation;
  
  int _completedPomodoros = 0;
  int _currentSession = 0; // Track current session in a cycle

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _focusMinutes * 60;
    
    _pandaAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pandaAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(
        parent: _pandaAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pandaAnimationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isPaused) {
      _isPaused = false;
    } else {
      _isRunning = true;
    }
    
    _pandaAnimationController.repeat(reverse: true);
    
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
    _pandaAnimationController.stop();
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _remainingSeconds = _getTimerDuration();
    });
    _timer?.cancel();
    _pandaAnimationController.reset();
  }

  void _timerComplete() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
    });
    _pandaAnimationController.stop();
    
    // Show completion dialog
    _showCompletionDialog();
    
    // Move to next timer type
    _moveToNextTimer();
  }

  void _moveToNextTimer() {
    setState(() {
      if (_currentTimerType == TimerType.focus) {
        _completedPomodoros++;
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
                  ? 'assets/images/pomo_panda.png'
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
        return 'assets/images/pomo_panda.png';
      case TimerType.shortBreak:
        return 'assets/images/shortbreak.png';
      case TimerType.longBreak:
        return 'assets/images/longbreak.png';
    }
  }

  Color _getTimerColor() {
    switch (_currentTimerType) {
      case TimerType.focus:
        return Colors.black;
      case TimerType.shortBreak:
        return Colors.grey[800]!;
      case TimerType.longBreak:
        return Colors.grey[600]!;
    }
  }

  double _getProgress() {
    final total = _getTimerDuration();
    return 1.0 - (_remainingSeconds / total);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
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
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PomoPanda',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                '${_completedPomodoros} pomodoros completed',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
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
                              color: _getTimerColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getTimerColor().withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              _getTimerTypeLabel(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getTimerColor(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Timer display
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Panda image with animation
                          AnimatedBuilder(
                            animation: _pandaAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, _isRunning ? _pandaAnimation.value : 0),
                                child: Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: _getTimerColor().withOpacity(0.2),
                                        blurRadius: 30,
                                        spreadRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Image.asset(
                                    _getTimerImage(),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 30),
                          // Circular progress indicator
                          SizedBox(
                            width: 260,
                            height: 260,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Background circle
                                Container(
                                  width: 260,
                                  height: 260,
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
                                    strokeWidth: 8,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _getTimerColor(),
                                    ),
                                  ),
                                ),
                                // Time display
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _formatTime(_remainingSeconds),
                                      style: TextStyle(
                                        fontSize: 56,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.black,
                                        letterSpacing: -2,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _getTimerTypeLabel(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
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
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _getTimerColor(),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getTimerColor().withOpacity(0.4),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                                  icon: Icon(
                                    _isRunning ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
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
                      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildTimerTypeButton(
                            TimerType.focus,
                            'Focus',
                            'assets/images/pomo_panda.png',
                          ),
                          _buildTimerTypeButton(
                            TimerType.shortBreak,
                            'Short',
                            'assets/images/shortbreak.png',
                          ),
                          _buildTimerTypeButton(
                            TimerType.longBreak,
                            'Long',
                            'assets/images/longbreak.png',
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
    String imagePath,
  ) {
    final isSelected = _currentTimerType == type;
    final color = type == TimerType.focus
        ? Colors.black
        : type == TimerType.shortBreak
            ? Colors.grey[800]!
            : Colors.grey[600]!;

    return GestureDetector(
      onTap: () {
        if (!_isRunning) {
          setState(() {
            _currentTimerType = type;
            _remainingSeconds = _getTimerDuration();
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              imagePath,
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

