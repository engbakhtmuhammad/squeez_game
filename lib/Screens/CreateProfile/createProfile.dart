import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:squeez_game/Components/app_widgets.dart';
import 'package:squeez_game/Components/background.dart';
import 'package:squeez_game/Components/game_graphics.dart';
import 'package:squeez_game/Components/custom_button.dart';
import 'package:squeez_game/data/game_data.dart';
import 'package:squeez_game/models/profile.dart';
import 'package:squeez_game/theme/app_theme.dart';

class CreateProfile extends StatefulWidget {
  const CreateProfile({super.key});

  @override
  State<CreateProfile> createState() => _CreateProfileState();
}

class _CreateProfileState extends State<CreateProfile> {
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _photoPath;
  String? _refereePhotoPath;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isProfileComplete => _nameController.text.trim().isNotEmpty;

  Future<String?> _pickAndSave(ImageSource source, String prefix) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (image == null) return null;
    final dir = await getApplicationDocumentsDirectory();
    final fileName = '${prefix}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPath = '${dir.path}/$fileName';
    await File(image.path).copy(savedPath);
    return savedPath;
  }

  Future<void> _showPhotoOptions({required bool isReferee}) async {
    final prefix = isReferee ? 'referee' : 'profile';
    void apply(String? path) {
      if (path == null) return;
      setState(() {
        if (isReferee) {
          _refereePhotoPath = path;
        } else {
          _photoPath = path;
        }
      });
    }

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpace.md),
              child: Text(
                isReferee ? 'GAME OVER CAN' : 'YOUR CAN',
                style: AppText.heading(18),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded,
                  color: AppColors.accent),
              title: Text('Take a Photo', style: AppText.body(15)),
              onTap: () async {
                Navigator.pop(ctx);
                apply(await _pickAndSave(ImageSource.camera, prefix));
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: AppColors.primary),
              title: Text('Choose from Gallery', style: AppText.body(15)),
              onTap: () async {
                Navigator.pop(ctx);
                apply(await _pickAndSave(ImageSource.gallery, prefix));
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _finishProfile() async {
    if (!_isProfileComplete) return;

    final profile = PlayerProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      photoPath: _photoPath,
      refereePhotoPath: _refereePhotoPath,
    );

    await GameData.addProfile(profile);
    await GameData.setSelectedProfileId(profile.id);

    if (_photoPath != null && _refereePhotoPath != null) {
      await GameData.unlockAchievement('customizer');
    }

    if (mounted) Navigator.pop(context);
  }

  Widget _canPicker({
    required String label,
    required String sublabel,
    required String? path,
    required bool isReferee,
    required Color color,
    required double height,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _showPhotoOptions(isReferee: isReferee),
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Text(label, style: AppText.heading(15)),
            const SizedBox(height: AppSpace.sm),
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                SodaCan(
                  height: height,
                  color: color,
                  isReferee: isReferee,
                  photoPath: path,
                ),
                Positioned(
                  bottom: -4,
                  right: height * 0.10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isReferee ? AppColors.danger : AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [
                        BoxShadow(color: Colors.black45, blurRadius: 6),
                      ],
                    ),
                    child: Icon(
                      path == null ? Icons.add_a_photo_rounded : Icons.edit_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.md),
            Text(
              sublabel,
              textAlign: TextAlign.center,
              style: AppText.body(11, color: AppColors.onSurfaceMuted),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final canHeight = size.height * .14;
    return Scaffold(
      body: Background(
        child: Stack(
          fit: StackFit.expand,
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpace.lg,
                  size.height * .05,
                  AppSpace.lg,
                  size.height * .18,
                ),
                child: Column(
                  children: [
                    const SectionTitle('CREATE\nPLAYER', size: 34),
                    const SizedBox(height: AppSpace.xs),
                    Text(
                      'Customize your cans, then name your player',
                      textAlign: TextAlign.center,
                      style: AppText.body(13, color: AppColors.onSurfaceMuted),
                    ),
                    const SizedBox(height: AppSpace.lg),
                    GlassCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _canPicker(
                            label: 'YOUR CAN',
                            sublabel: 'Squeeze these\nto score',
                            path: _photoPath,
                            isReferee: false,
                            color: AppColors.can1,
                            height: canHeight,
                          ),
                          Container(
                            width: 1,
                            height: canHeight * 1.4,
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                          _canPicker(
                            label: 'GAME OVER',
                            sublabel: 'Avoid these\nat all costs',
                            path: _refereePhotoPath,
                            isReferee: true,
                            color: AppColors.danger,
                            height: canHeight,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpace.md),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.badge_rounded,
                                  color: AppColors.accent, size: 22),
                              const SizedBox(width: AppSpace.sm),
                              Text('PLAYER NAME', style: AppText.heading(15)),
                            ],
                          ),
                          const SizedBox(height: AppSpace.sm),
                          TextField(
                            controller: _nameController,
                            onChanged: (_) => setState(() {}),
                            textAlign: TextAlign.center,
                            style: AppText.heading(20),
                            cursorColor: AppColors.accent,
                            decoration: InputDecoration(
                              hintText: 'Enter a name…',
                              hintStyle: AppText.body(16,
                                  color: AppColors.onSurfaceFaint),
                              filled: true,
                              fillColor: AppColors.stroke,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 16),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                                borderSide: const BorderSide(
                                    color: Colors.white24, width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                                borderSide: const BorderSide(
                                    color: AppColors.accent, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpace.lg),
                    CustomButton(
                      text: 'START PLAYING',
                      onPressed: _isProfileComplete ? _finishProfile : () {},
                      backgroundColor: AppColors.success,
                      enabled: _isProfileComplete,
                      iconData: Icons.check_rounded,
                      fontSize: 18,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40.0, vertical: 14.0),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: size.height * .04,
              left: 0,
              right: 0,
              child: ConveyorBelt(width: size.width, height: size.height * .07),
            ),
            Positioned(
              bottom: size.height * .05,
              left: 20,
              child: GameBackButton(onTap: () => Navigator.pop(context)),
            ),
          ],
        ),
      ),
    );
  }
}
