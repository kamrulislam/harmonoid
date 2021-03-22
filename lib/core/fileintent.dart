import 'dart:io';
import 'package:flutter/services.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:path/path.dart' as path;

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/interface/home.dart';


FileIntent fileIntent;


const _methodChannel = const MethodChannel('com.alexmercerind.harmonoid/openFile');


class FileIntent {
  Screen startScreen;
  File openedFile;

  FileIntent({this.startScreen, this.openedFile});

  static Future<void> init() async {
    try {
      File file = await FileIntent._getOpenFile();
      fileIntent = new FileIntent(
        startScreen: Screen.nowPlaying,
        openedFile: file,
      );
    }
    catch(exception) {
      fileIntent = new FileIntent(
        startScreen: Screen.collection,
      );
    }
  }

  static Future<File> _getOpenFile() async {
    String filePath = await _methodChannel.invokeMethod('getOpenFile');
    File file = new File(filePath);
    if (await file.exists()) return file;
    else throw FileSystemException("File does not exists.");
  }

  Future<void> play() async {
    MetadataRetriever retriever = new MetadataRetriever();
    await retriever.setFile(this.openedFile);
    Track track = Track.fromMap((await retriever.metadata).toMap());
    if (track.trackName == 'Unknown Track') {
      track.trackName = path.basename(this.openedFile.path).split('.').first;
    }
    track.filePath = this.openedFile.path;
    if (retriever.albumArt != null) {
      File albumArtFile = new File(
        path.join(
          configuration.cacheDirectory.path,
          'albumArts',
          '${track.albumArtistName}_${track.albumName}'.replaceAll(new RegExp(r'[^\s\w]'), ' ') + '.PNG',
        ),
      );
      await albumArtFile.writeAsBytes(retriever.albumArt);
    }
    Playback.play(
      tracks: <Track>[track],
      index: 0,
    );
  }
}
