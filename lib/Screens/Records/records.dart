import 'dart:io';
import 'package:flutter/material.dart';
import 'package:squeez_game/Components/background.dart';
import 'package:squeez_game/Components/custom_button.dart';
import 'package:squeez_game/Screens/CreateProfile/createProfile.dart';
import 'package:squeez_game/Screens/Game/game.dart';
import 'package:squeez_game/constants.dart';
import 'package:squeez_game/data/game_data.dart';
import 'package:squeez_game/models/game_mode.dart';
import 'package:squeez_game/models/profile.dart';

class RecordPage extends StatefulWidget {
  final GameMode mode;
  const RecordPage({super.key, this.mode = GameMode.endless});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  List<PlayerProfile> _profiles = [];
  List<LeaderboardEntry> _leaderboard = [];
  PlayerProfile? _selectedProfile;
  int _pageStart = 0;
  static const int _pageSize = 3;
  bool _showLeaderboard = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profiles = await GameData.getProfiles();
    profiles.sort((a, b) {
      if (a.bestScore == 0 && b.bestScore == 0) return 0;
      if (a.bestScore == 0) return 1;
      if (b.bestScore == 0) return -1;
      return b.bestScore.compareTo(a.bestScore);
    });
    final selected = await GameData.getSelectedProfile();
    final leaderboard = await GameData.getLeaderboard();
    if (mounted) {
      setState(() {
        _profiles = profiles;
        _selectedProfile = selected;
        _leaderboard = leaderboard;
      });
    }
  }

  void _prevPage() {
    if (_pageStart > 0) {
      setState(() => _pageStart -= _pageSize);
    }
  }

  void _nextPage() {
    if (_pageStart + _pageSize < _profiles.length) {
      setState(() => _pageStart += _pageSize);
    }
  }

  Future<void> _selectProfile(PlayerProfile profile) async {
    await GameData.setSelectedProfileId(profile.id);
    setState(() => _selectedProfile = profile);
  }

  void _startGame() {
    if (_selectedProfile == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GamePage(profile: _selectedProfile!, mode: widget.mode),
      ),
    );
  }

  Widget _buildProfileAvatar(PlayerProfile profile, double radius) {
    if (profile.photoPath != null && File(profile.photoPath!).existsSync()) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: kBackgroundColor,
        backgroundImage: FileImage(File(profile.photoPath!)),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: kBackgroundColor,
      backgroundImage: const AssetImage('assets/avatar-2.png'),
    );
  }

  Widget _tabButton(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: active ? kSecondaryColor : kPrimaryColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBackgroundColor, width: 2),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboard() {
    if (_leaderboard.isEmpty) {
      return const Center(
        child: Text(
          'No records yet.\nPlay a game to set one!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }
    return ListView.builder(
      itemCount: _leaderboard.length,
      itemBuilder: (context, index) {
        final e = _leaderboard[index];
        final rank = index + 1;
        return ListTile(
          dense: true,
          leading: SizedBox(
            width: 28,
            child: Text(
              '$rank',
              style: TextStyle(
                color: rank <= 3 ? Colors.amber : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          title: Text(
            e.playerName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            '${e.formattedTime}  •  ${e.formattedDate}',
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          trailing: Text(
            '${e.score} pts',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        );
      },
    );
  }

  Widget _buildProfileList(List<PlayerProfile> visibleProfiles) {
    if (_profiles.isEmpty) {
      return const Center(
        child: Text(
          'No profiles yet.\nCreate one to play!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: visibleProfiles.length,
            itemBuilder: (context, index) {
              final profile = visibleProfiles[index];
              final rank = _pageStart + index + 1;
              final isSelected = _selectedProfile?.id == profile.id;
              return ListTile(
                onTap: () => _selectProfile(profile),
                selected: isSelected,
                selectedTileColor: Colors.white.withValues(alpha: 0.15),
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          color: rank <= 3 ? Colors.amber : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildProfileAvatar(profile, 20),
                  ],
                ),
                title: Text(
                  profile.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Text(
                  '${profile.bestScore} pts',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: _pageStart > 0 ? _prevPage : null,
              child: Image.asset('assets/arrow.png', height: 30),
            ),
            TextButton(
              onPressed: _pageStart + _pageSize < _profiles.length
                  ? _nextPage
                  : null,
              child: Image.asset('assets/arrow-2.png', height: 30),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final visibleProfiles = _profiles.skip(_pageStart).take(_pageSize).toList();

    return Scaffold(
      body: Background(
        child: Stack(
          fit: StackFit.expand,
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: size.height * .08),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _tabButton('PLAYERS', !_showLeaderboard,
                          () => setState(() => _showLeaderboard = false)),
                      const SizedBox(width: 12),
                      _tabButton('RECORDS', _showLeaderboard,
                          () => setState(() => _showLeaderboard = true)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Scoreboard
                  Container(
                    height: size.height * .4,
                    width: size.width * .8,
                    decoration: BoxDecoration(
                      border: Border.all(color: kBackgroundColor, width: 4),
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _showLeaderboard
                        ? _buildLeaderboard()
                        : _buildProfileList(visibleProfiles),
                  ),
                  const SizedBox(height: 10),
                  if (!_showLeaderboard) ...[
                    if (_selectedProfile != null) ...[
                      _buildProfileAvatar(_selectedProfile!, size.height * .06),
                      Padding(
                        padding: EdgeInsets.only(top: size.height * .02),
                        child: Text(
                          _selectedProfile!.name.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomButton(
                          text: 'SELECT',
                          onPressed:
                              _selectedProfile != null ? _startGame : () {},
                          backgroundColor: kPrimaryColor,
                          textColor: Colors.white,
                          borderColor: Colors.black,
                          borderWidth: 2.0,
                          enabled: _selectedProfile != null,
                          fontSize: 16,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 35.0,
                            vertical: 12.0,
                          ),
                        ),
                        const SizedBox(width: 15),
                        CustomButton(
                          text: 'NEW',
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CreateProfile(),
                              ),
                            );
                            _loadData();
                          },
                          backgroundColor: kSecondaryColor,
                          textColor: Colors.white,
                          borderColor: Colors.black,
                          borderWidth: 2.0,
                          fontSize: 16,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40.0,
                            vertical: 12.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: size.height * .15),
                ],
              ),
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
}
