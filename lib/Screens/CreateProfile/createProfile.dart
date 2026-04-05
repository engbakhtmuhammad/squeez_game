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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isProfileComplete =>
      _nameController.text.trim().isNotEmpty;

  Future<void> _takePhoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (image != null) {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = '${dir.path}/$fileName';
      await File(image.path).copy(savedPath);
      setState(() => _photoPath = savedPath);
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (image != null) {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = '${dir.path}/$fileName';
      await File(image.path).copy(savedPath);
      setState(() => _photoPath = savedPath);
    }
  }

  Future<void> _showPhotoOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(ctx);
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickFromGallery();
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
    );

    await GameData.addProfile(profile);
    await GameData.setSelectedProfileId(profile.id);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Background(
        child: Stack(
          fit: StackFit.expand,
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: size.height * .1),
                  Container(
                    width: size.width * .8,
                    padding: EdgeInsets.symmetric(
                      vertical: size.height * .04,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: kBackgroundColor, width: 4),
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: size.height * .02),
                          child: const Text(
                            'TAKE A PHOTO',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 26,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _showPhotoOptions,
                          child: CircleAvatar(
                            radius: size.height * .07,
                            backgroundColor: kBackgroundColor,
                            backgroundImage: _photoPath != null
                                ? FileImage(File(_photoPath!))
                                : const AssetImage('assets/avatar.png')
                                    as ImageProvider,
                            child: _photoPath == null
                                ? const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 30,
                                  )
                                : null,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: size.height * .04,
                            bottom: size.height * .02,
                          ),
                          child: const Text(
                            'WRITE THE NAME',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 26,
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
