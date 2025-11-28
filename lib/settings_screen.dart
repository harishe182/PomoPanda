import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoStartFocus = true;
  bool _vibrateOnEnd = true;
  // bool _isDarkMode = false; // Removed
  double _volume = 0.7;
  String _notificationSound = 'Soft Chime';
  List<String> _blockedApps = ['Instagram', 'TikTok'];

  Color get _background => Colors.white;
  Color get _cardColor => Colors.grey[50]!;
  Color get _primaryText => Colors.black87;
  Color get _secondaryText => Colors.grey.shade600;
  Color get _subtleBorder => Colors.grey[200]!;
  Color get _accent => Colors.black;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: _primaryText),
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            color: _primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildTimerSettingsCard(),
            const SizedBox(height: 16),
            _buildSoundCard(context),
            const SizedBox(height: 16),
            // const SizedBox(height: 16),
            _buildAppSelectionCard(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: _subtleBorder),
          ),
          child: ClipOval(
          child: Icon(
            Icons.person,
            size: 32,
            color: Colors.black,
          ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Tune your focus, sound, and blocking preferences.',
            style: GoogleFonts.inter(
              color: _secondaryText,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimerSettingsCard() {
    return _SettingsCard(
      color: _cardColor,
      borderColor: _subtleBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle('Timer Settings'),
          const SizedBox(height: 6),
          _cardSubtitle('Control how your focus timer behaves.'),
          const SizedBox(height: 8),
          const Divider(height: 20, thickness: 0.2),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Auto Start Focus Timer',
              style: TextStyle(color: _primaryText, fontSize: 14),
            ),
            subtitle: Text(
              'Jump straight into the next focus session.',
              style: TextStyle(color: _secondaryText, fontSize: 12),
            ),
            value: _autoStartFocus,
            activeColor: _accent,
            onChanged: (value) {
              setState(() => _autoStartFocus = value);
            },
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Vibrate on Timer End',
              style: TextStyle(color: _primaryText, fontSize: 14),
            ),
            subtitle: Text(
              'Subtle haptic reminder when a session finishes.',
              style: TextStyle(color: _secondaryText, fontSize: 12),
            ),
            value: _vibrateOnEnd,
            activeColor: _accent,
            onChanged: (value) {
              setState(() => _vibrateOnEnd = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSoundCard(BuildContext context) {
    return _SettingsCard(
      color: _cardColor,
      borderColor: _subtleBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle('Sound'),
          const SizedBox(height: 6),
          _cardSubtitle('Choose how PomoPanda sounds.'),
          const SizedBox(height: 8),
          const Divider(height: 20, thickness: 0.2),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Notification Sound',
              style: TextStyle(
                color: _primaryText,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              _notificationSound,
              style: TextStyle(color: _secondaryText, fontSize: 12),
            ),
            trailing: Icon(Icons.chevron_right, color: _secondaryText),
            onTap: () async {
              final result = await Navigator.push<String>(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificationSoundScreen(
                    selectedSound: _notificationSound,
                    // isDarkMode: _isDarkMode, // Removed
                  ),
                ),
              );
              if (result != null && result.isNotEmpty) {
                setState(() {
                  _notificationSound = result;
                });
              }
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                _volume == 0 ? Icons.volume_off_rounded : Icons.volume_down_rounded,
                color: _secondaryText,
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: _accent,
                    inactiveTrackColor: Colors.grey[300],
                    thumbColor: _accent,
                    overlayColor: _accent.withOpacity(0.1),
                    trackHeight: 4.0,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
                  ),
                  child: Slider(
                    value: _volume,
                    min: 0,
                    max: 1,
                    onChanged: (value) {
                      setState(() => _volume = value);
                    },
                  ),
                ),
              ),
              Icon(
                Icons.volume_up_rounded,
                color: _secondaryText,
              ),
            ],
          ),
        ],
      ),
    );
  }



  Widget _buildAppSelectionCard(BuildContext context) {

    final blockedCount = _blockedApps.length;
    final blockedSubtitle = blockedCount == 0
        ? 'No apps blocked yet.'
        : '$blockedCount app${blockedCount > 1 ? 's' : ''} blocked during focus.';

    return _SettingsCard(
      color: _cardColor,
      borderColor: _subtleBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle('App Blocking'),
          const SizedBox(height: 6),
          _cardSubtitle('Choose which apps PomoPanda should block.'),
          const SizedBox(height: 8),
          const Divider(height: 20, thickness: 0.2),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Blocked Apps',
              style: TextStyle(
                color: _primaryText,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              blockedSubtitle,
              style: TextStyle(color: _secondaryText, fontSize: 12),
            ),
            trailing: Icon(Icons.chevron_right, color: _secondaryText),
            onTap: () async {
              final result = await Navigator.push<List<String>>(
                context,
                MaterialPageRoute(
                  builder: (_) => AppSelectionScreen(
                    initiallyBlocked: _blockedApps,
                    // isDarkMode: isDarkMode, // Removed
                  ),
                ),
              );
              if (result != null) {
                setState(() {
                  _blockedApps = result;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _cardTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: _primaryText,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _cardSubtitle(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: _secondaryText,
        fontSize: 13,
        height: 1.4,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;
  final Color color;
  final Color borderColor;
  const _SettingsCard({
    required this.child,
    required this.color,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor ?? Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// Notification Sound Selection Screen
class NotificationSoundScreen extends StatefulWidget {
  final String selectedSound;
  const NotificationSoundScreen({
    super.key,
    required this.selectedSound,
    // required this.isDarkMode,
  });

  @override
  State<NotificationSoundScreen> createState() =>
      _NotificationSoundScreenState();
}

class _NotificationSoundScreenState extends State<NotificationSoundScreen> {
  late String _currentSound;

  final List<String> _sounds = const [
    'Soft Chime',
    'Gentle Bell',
    'Minimal Ping',
    'Woodblock Tap',
    'Panda Whisper',
    'Focus Gong',
  ];

  @override
  void initState() {
    super.initState();
    _currentSound = widget.selectedSound;
  }

  @override
  Widget build(BuildContext context) {
    // final isDarkMode = widget.isDarkMode;
    final background = Colors.white;
    final primaryText = Colors.black;
    final secondaryText = Colors.grey.shade700;
    final cardColor = const Color(0xFFF5F5F5);
    final borderColor = Colors.black12;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryText),
        title: Text(
          'Notification Sound',
          style: TextStyle(color: primaryText),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: _sounds.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final sound = _sounds[index];
                  final selected = sound == _currentSound;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: selected ? cardColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: selected ? borderColor : Colors.transparent,
                      ),
                    ),
                    child: RadioListTile<String>(
                      dense: true,
                      value: sound,
                      groupValue: _currentSound,
                      activeColor: primaryText,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _currentSound = value;
                        });
                      },
                      title: Text(
                        sound,
                        style: TextStyle(
                          color: primaryText,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        selected
                            ? 'Current selection'
                            : 'Tap to preview & select',
                        style:
                            TextStyle(color: secondaryText, fontSize: 11),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryText,
                    foregroundColor: background,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, _currentSound);
                  },
                  child: const Text(
                    'Save Sound',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// App Selection Screen (blocking apps UI)
class AppSelectionScreen extends StatefulWidget {
  final List<String> initiallyBlocked;
  // final bool isDarkMode;
  const AppSelectionScreen({
    super.key,
    required this.initiallyBlocked,
    // required this.isDarkMode,
  });

  @override
  State<AppSelectionScreen> createState() => _AppSelectionScreenState();
}

class _AppSelectionScreenState extends State<AppSelectionScreen> {
  final List<String> _allApps = const [
    'Instagram',
    'TikTok',
    'Reddit',
    'YouTube',
    'Twitter / X',
    'Snapchat',
    'Discord',
    'Spotify',
  ];

  late Set<String> _blockedSet;

  @override
  void initState() {
    super.initState();
    _blockedSet = widget.initiallyBlocked.toSet();
  }

  @override
  Widget build(BuildContext context) {
    // final isDarkMode = widget.isDarkMode;
    final background = Colors.white;
    final primaryText = Colors.black;
    final secondaryText = Colors.grey.shade700;
    final cardColor = const Color(0xFFF5F5F5);
    final borderColor = Colors.black12;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryText),
        title: Text(
          'Blocked Apps',
          style: TextStyle(color: primaryText),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                'Select which apps you want PomoPanda to block during a focus session.',
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: _allApps.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final app = _allApps[index];
                  final blocked = _blockedSet.contains(app);

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: blocked ? cardColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: blocked ? borderColor : Colors.transparent,
                      ),
                    ),
                    child: SwitchListTile.adaptive(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 0),
                      title: Text(
                        app,
                        style: TextStyle(color: primaryText, fontSize: 14),
                      ),
                      subtitle: Text(
                        blocked ? 'Will be blocked during focus.' : 'Allowed.',
                        style:
                            TextStyle(color: secondaryText, fontSize: 11),
                      ),
                      value: blocked,
                      activeColor: primaryText,
                      onChanged: (value) {
                        setState(() {
                          if (value) {
                            _blockedSet.add(app);
                          } else {
                            _blockedSet.remove(app);
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryText,
                    foregroundColor: background,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, _blockedSet.toList());
                  },
                  child: const Text(
                    'Save Blocked Apps',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
