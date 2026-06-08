import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ProfileState {
  final String name;
  final String imageUrl;

  ProfileState({required this.name, required this.imageUrl});

  ImageProvider get imageProvider {
    if (imageUrl.startsWith('http') || imageUrl.startsWith('blob:') || imageUrl.startsWith('data:')) {
      return NetworkImage(imageUrl);
    } else {
      if (kIsWeb) {
        return const NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150');
      }
      return FileImage(File(imageUrl));
    }
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  static const String _boxName = 'profile_box';
  static const String _nameKey = 'name';
  static const String _imageKey = 'imageUrl';

  ProfileNotifier()
      : super(ProfileState(
          name: _getDefaultName(),
          imageUrl: _getDefaultImageUrl(),
        ));

  static String _getDefaultName() {
    try {
      if (Hive.isBoxOpen(_boxName)) {
        return Hive.box(_boxName).get(_nameKey, defaultValue: 'Alex Johnson') as String;
      }
    } catch (_) {}
    return 'Alex Johnson';
  }

  static String _getDefaultImageUrl() {
    try {
      if (Hive.isBoxOpen(_boxName)) {
        return Hive.box(_boxName).get(_imageKey,
            defaultValue: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150') as String;
      }
    } catch (_) {}
    return 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150';
  }

  void updateProfile(String newName, String newImageUrl) {
    try {
      if (Hive.isBoxOpen(_boxName)) {
        final box = Hive.box(_boxName);
        box.put(_nameKey, newName);
        box.put(_imageKey, newImageUrl);
      }
    } catch (_) {}
    state = ProfileState(name: newName, imageUrl: newImageUrl);
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});
