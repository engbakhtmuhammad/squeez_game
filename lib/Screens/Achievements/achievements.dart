import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:squeez_game/Components/background.dart';
import 'package:squeez_game/constants.dart';
import 'package:squeez_game/data/game_data.dart';
import 'package:squeez_game/models/achievement.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  List<String> _unlocked = [];
  Map<String, DateTime> _dates = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final unlocked = await GameData.getUnlockedAchievements();
    final dates = await GameData.getAchievementDates();
    if (mounted) {
      setState(() {
        _unlocked = unlocked;
        _dates = dates;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Background(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: size.height * .12,
                    bottom: size.height * .02,
                  ),
                  child: Text(
                    'ACHIEVEMENTS',
                    style: GoogleFonts.fredoka(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 32,
                    ),
                  ),
                ),
                Text(
                  '${_unlocked.length} / ${Achievement.all.length} unlocked',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _loading
                      ? const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white))
                      : Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * .08,
                          ),
                          child: GridView.builder(
                            padding: EdgeInsets.only(
                              bottom: size.height * .2,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.95,
                            ),
                            itemCount: Achievement.all.length,
                            itemBuilder: (context, index) {
                              final ach = Achievement.all[index];
                              final unlocked = _unlocked.contains(ach.id);
                              return _card(ach, unlocked, _dates[ach.id]);
                            },
                          ),
                        ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              child: Padding(
                padding: EdgeInsets.only(bottom: size.height * .06),
                child: Image.asset(
                  'assets/conveyor.png',
                  fit: BoxFit.fitWidth,
                  width: size.width,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Padding(
                padding: EdgeInsets.only(bottom: size.height * .08, left: 15),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Image.asset('assets/back.png'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(Achievement ach, bool unlocked, DateTime? date) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unlocked
            ? kPrimaryColor
            : kBackgroundColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unlocked ? const Color(0xFFFAC05E) : Colors.white24,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: unlocked ? 1.0 : 0.3,
            child: Text(ach.iconEmoji, style: const TextStyle(fontSize: 40)),
          ),
          const SizedBox(height: 6),
          Text(
            ach.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: unlocked ? Colors.white : Colors.white38,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ach.description,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: unlocked ? Colors.white70 : Colors.white24,
              fontSize: 11,
            ),
          ),
          if (unlocked && date != null) ...[
            const SizedBox(height: 4),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: const TextStyle(
                color: Color(0xFFFAC05E),
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
