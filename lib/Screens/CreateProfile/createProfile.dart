import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:squeez_game/Components/background.dart';
import 'package:squeez_game/Components/custom_button.dart';
import 'package:squeez_game/constants.dart';
import 'package:squeez_game/data/game_data.dart';
import 'package:squeez_game/models/profile.dart';

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

  bool get _isProfileComplete =>
      _nameController.text.trim().isNotEmpty;

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
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () async {
                Navigator.pop(ctx);
                final path = await _pickAndSave(ImageSource.camera, prefix);
                if (path != null) {
                  setState(() {
                    if (isReferee) {
                      _refereePhotoPath = path;
                    } else {
                      _photoPath = path;
                    }
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(ctx);
                final path = await _pickAndSave(ImageSource.gallery, prefix);
                if (path != null) {
                  setState(() {
                    if (isReferee) {
                      _refereePhotoPath = path;
                    } else {
                      _photoPath = path;
                    }
                  });
                }
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

    // Customizer achievement: both icons set
    if (_photoPath != null && _refereePhotoPath != null) {
      await GameData.unlockAchievement('customizer');
    }

    if (mounted) Navigator.pop(context);
  }

  Widget _iconPicker({
    required String label,
    required String? path,
    required String placeholderAsset,
    required IconData fallbackIcon,
    required bool isReferee,
    required double size,
  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: size * .15),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _showPhotoOptions(isReferee: isReferee),
          child: CircleAvatar(
            radius: size,
            backgroundColor: kBackgroundColor,
            backgroundImage: path != null
                ? FileImage(File(path))
                : AssetImage(placeholderAsset) as ImageProvider,
            child: path == null
                ? Icon(fallbackIcon, color: Colors.white, size: 26)
                : null,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final avatarRadius = size.height * .055;
    return Scaffold(
      body: Background(
        child: Stack(
          fit: StackFit.expand,
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: size.height * .08),
                  Container(
                    width: size.width * .85,
                    padding: EdgeInsets.symmetric(
                      vertical: size.height * .03,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: kBackgroundColor, width: 4),
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _iconPicker(
                              label: 'YOUR CAN',
                              path: _photoPath,
                              placeholderAsset: 'assets/avatar.png',
                              fallbackIcon: Icons.add,
                              isReferee: false,
                              size: avatarRadius,
                            ),
                            _iconPicker(
                              label: 'GAME OVER',
                              path: _refereePhotoPath,
                              placeholderAsset: 'assets/avatar.png',
                              fallbackIcon: Icons.sports,
                              isReferee: true,
                              size: avatarRadius,
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: size.height * .03,
                            bottom: size.height * .02,
                          ),
                          child: const Text(
                            'WRITE THE NAME',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 22,
                            ),
                          ),
                        ),
                        Container(
                          height: size.height * .07,
                          width: size.width * .65,
                          decoration: BoxDecoration(
                            color: kBackgroundColor,
                            border: Border.all(color: Colors.white, width: 3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextField(
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            controller: _nameController,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              hintText: 'USER_1',
                              hintStyle: TextStyle(color: Colors.white54),
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'FINISH',
                    onPressed: _isProfileComplete ? _finishProfile : () {},
                    backgroundColor: Color(0xFFC08552),
                    textColor: Colors.white,
                    borderColor: Colors.black,
                    borderWidth: 2.0,
                    enabled: _isProfileComplete,
                    fontSize: 20,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50.0,
                      vertical: 12.0,
                    ),
                  ),
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
