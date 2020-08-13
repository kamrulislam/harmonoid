library addsavedmusic;

import 'package:harmonoid/globals.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;


class AddSavedMusic extends SaveTrack {
  @override
  int trackNumber;
  @override
  String trackId;
  @override
  Map<String, dynamic> albumJson;

  AddSavedMusic(this.trackNumber, this.trackId, this.albumJson);

  Future<bool> save() async {

    await createAppDirectory();
    bool isAlbumSaved = !(await albumSaved());

    if (isAlbumSaved) {
      saveAlbumAssets();
      saveAlbumArt();
    }

    await saveTrackAssets();
    await saveTrackFile();

    return this.saveSuccess;
  }
}


abstract class GenerateDirectories {

  Directory externalDirectory;
  Directory applicationDirectory;
  Directory musicDirectory;

  Future<void> createAppDirectory() async {
    this.externalDirectory = (await path.getExternalStorageDirectory());

    this.applicationDirectory = Directory(path.join(this.externalDirectory.path, '.harmonoid'));
    this.musicDirectory = Directory(path.join(this.applicationDirectory.path, 'musicLibrary'));

    if (!(await applicationDirectory.exists())) {
      await musicDirectory.create(recursive: true);
    }
  }
}



abstract class SaveAlbumAssets extends GenerateDirectories {
  int trackNumber;
  String trackId;
  Map<String, dynamic> albumJson;
  Directory albumDirectory;
  bool saveSuccess = true;

  Future<bool> albumSaved() async {
    this.albumDirectory = Directory(path.join(this.musicDirectory.path, this.albumJson['album_id']));
    
    if (this.albumDirectory.existsSync()) {
      return true;
    }
    else {
      await this.albumDirectory.create(recursive: true);
      return false;
    }
  }

  Future<void> saveAlbumAssets() async {
    File albumAssets = File(path.join(this.albumDirectory.path, 'albumAssets.json'));
    
    try {
      await albumAssets.writeAsString(convert.jsonEncode(this.albumJson));
    }
    catch(error) {
      this.saveSuccess = false;
    }
  }

  Future<void> saveAlbumArt() async {
    File albumAssets = File(path.join(this.albumDirectory.path, 'albumArt.png'));
    
    try {
      var imageBinary = (await http.get(this.albumJson['album_art_640'])).bodyBytes;
      await albumAssets.writeAsBytes(imageBinary);
    }
    catch(error) {
      this.saveSuccess = false;
    }
  }
}


abstract class SaveTrack extends SaveAlbumAssets {

  Future<void> saveTrackFile() async {
    File trackFile = File(path.join(this.albumDirectory.path, '${this.trackNumber}.m4a'));

    Uri trackDownloadUri = Uri.https(Globals.STRING_HOME_URL, '/trackdownload', {'track_id': this.trackId});
    try {
      var trackBinary = (await http.get(trackDownloadUri)).bodyBytes;
      await trackFile.writeAsBytes(trackBinary);
    }
    catch(error) {
      this.saveSuccess = false;
    }
  }

  Future<void> saveTrackAssets() async {
    File trackAssets = File(path.join(this.albumDirectory.path, '${this.trackNumber}.json'));

    try {
      if (await trackAssets.exists()) {}
      else {

        Uri uri = Uri.https(Globals.STRING_HOME_URL, '/albuminfo', {'album_id': this.albumJson['album_id']});
        Map<String, dynamic> albumTracks = convert.jsonDecode((await http.get(uri)).body);
        String trackJson = convert.jsonEncode(albumTracks['tracks'][this.trackNumber - 1]);

        await trackAssets.create(recursive: true);
        await trackAssets.writeAsString(trackJson);
      }
    }
    catch(error) {
      this.saveSuccess = false;
    }
  }
}