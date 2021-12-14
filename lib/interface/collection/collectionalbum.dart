/* 
 *  This file is part of Harmonoid (https://github.com/harmonoid/harmonoid).
 *  
 *  Harmonoid is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  
 *  Harmonoid is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with Harmonoid. If not, see <https://www.gnu.org/licenses/>.
 * 
 *  Copyright 2020-2021, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
 */

import 'dart:io';
import 'dart:ui';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:share_plus/share_plus.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/constants/language.dart';

class CollectionAlbumTab extends StatelessWidget {
  Widget build(BuildContext context) {
    int elementsPerRow =
        (MediaQuery.of(context).size.width.normalized - 16.0) ~/ (156.0 + 16.0);
    double tileWidth = 156.0;
    double tileHeight = 156.0 + 58.0;

    return Consumer<Collection>(
      builder: (context, collection, _) => collection.tracks.isNotEmpty
          ? CustomListView(
              padding: EdgeInsets.only(top: 16.0),
              children: tileGridListWidgets(
                context: context,
                tileHeight: tileHeight,
                tileWidth: tileWidth,
                elementsPerRow: elementsPerRow,
                subHeader: null,
                leadingSubHeader: null,
                widgetCount: collection.albums.length,
                leadingWidget: Container(),
                builder: (BuildContext context, int index) =>
                    CollectionAlbumTile(
                  height: tileHeight,
                  width: tileWidth,
                  album: collection.albums[index],
                ),
              ),
            )
          : Center(
              child: ExceptionWidget(
                height: 284.0,
                width: 420.0,
                margin: EdgeInsets.zero,
                title: language.NO_COLLECTION_TITLE,
                subtitle: language.NO_COLLECTION_SUBTITLE,
              ),
            ),
    );
  }
}

class CollectionAlbumTile extends StatelessWidget {
  final double height;
  final double width;
  final Album album;

  const CollectionAlbumTile({
    Key? key,
    required this.album,
    required this.height,
    required this.width,
  }) : super(key: key);

  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4.0,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  FadeThroughTransition(
                fillColor: Colors.transparent,
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: CollectionAlbum(
                  album: this.album,
                ),
              ),
            ),
          );
        },
        child: Container(
          height: this.height,
          width: this.width,
          child: Column(
            children: [
              ClipRect(
                child: ScaleOnHover(
                  child: Hero(
                    tag:
                        'album_art_${this.album.albumName}_${this.album.albumArtistName}',
                    child: Image.file(
                      this.album.albumArt,
                      fit: BoxFit.cover,
                      height: this.width,
                      width: this.width,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.0,
                  ),
                  width: this.width,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        this.album.albumName!,
                        style: Theme.of(context).textTheme.headline2,
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Text(
                          '${this.album.albumArtistName} ${this.album.year != null ? ' • ' : ''} ${this.album.year ?? ''}',
                          style:
                              Theme.of(context).textTheme.headline3?.copyWith(
                                    fontSize: 12.0,
                                  ),
                          maxLines: 1,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LeadingCollectionAlbumTile extends StatelessWidget {
  final double height;

  const LeadingCollectionAlbumTile({Key? key, required this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Provider.of<Collection>(context, listen: false).lastAlbum == null)
      return Container();
    return Container(
      decoration: BoxDecoration(
        border:
            Border.all(color: Theme.of(context).dividerColor.withOpacity(0.12)),
        borderRadius: BorderRadius.circular(8.0),
      ),
      margin: EdgeInsets.only(left: 8, right: 8, bottom: 4.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    FadeThroughTransition(
                  fillColor: Colors.transparent,
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  child: CollectionAlbum(
                    album: Provider.of<Collection>(context, listen: false)
                        .lastAlbum!,
                  ),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(8.0),
          child: Container(
            height: this.height - 2.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Theme.of(context).cardColor,
            ),
            width: MediaQuery.of(context).size.width.normalized - 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image(
                    image: FileImage(
                        Provider.of<Collection>(context, listen: false)
                            .lastAlbum!
                            .albumArt),
                    fit: BoxFit.cover,
                    height: this.height - 2.0,
                    width: this.height - 2.0,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 8, right: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        Provider.of<Collection>(context, listen: false)
                            .lastAlbum!
                            .albumName!,
                        style: Theme.of(context).textTheme.headline1,
                        textAlign: TextAlign.start,
                        maxLines: 2,
                      ),
                      Text(
                        Provider.of<Collection>(context, listen: false)
                            .lastAlbum!
                            .albumArtistName!,
                        style: Theme.of(context).textTheme.headline3,
                        textAlign: TextAlign.start,
                        maxLines: 1,
                      ),
                      Text(
                        '(${Provider.of<Collection>(context, listen: false).lastAlbum!.year ?? 'Unknown Year'})',
                        style: Theme.of(context).textTheme.headline3,
                        textAlign: TextAlign.start,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CollectionAlbum extends StatefulWidget {
  final Album? album;
  const CollectionAlbum({Key? key, required this.album}) : super(key: key);
  CollectionAlbumState createState() => CollectionAlbumState();
}

class CollectionAlbumState extends State<CollectionAlbum> {
  bool shouldReact = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<Collection>(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
        ),
        height:
            MediaQuery.of(context).size.width.normalized > kHorizontalBreakPoint
                ? MediaQuery.of(context).size.height.normalized
                : 324.0 + 128.0,
        width: MediaQuery.of(context).size.width.normalized / 3,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: 324.0,
                      maxHeight: 324.0,
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                        Positioned.fill(
                          bottom: -20.0,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(44.0),
                                    child: Image.file(
                                      widget.album!.albumArt,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(44.0),
                                    child: Container(
                                      color: Colors.black.withOpacity(
                                          Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? 0.1
                                              : 0.4),
                                    ),
                                  ),
                                ],
                              ),
                              ClipRect(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 8.0,
                                    sigmaY: 8.0,
                                  ),
                                  child: Container(
                                    height: 284.0,
                                    width: 284.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(48.0),
                          child: Hero(
                            tag:
                                'album_art_${widget.album?.albumName}_${widget.album?.albumArtistName}',
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4.0),
                              ),
                              child: Image.file(
                                widget.album!.albumArt,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 0.0),
              Container(
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                // decoration: BoxDecoration(
                //   color: Theme.of(context).brightness == Brightness.dark
                //       ? Colors.white.withOpacity(0.04)
                //       : Colors.black.withOpacity(0.04),
                //   borderRadius: BorderRadius.circular(8.0),
                // ),
                child: Column(
                  children: [
                    Text(
                      widget.album!.albumName!,
                      style: Theme.of(context)
                          .textTheme
                          .headline1
                          ?.copyWith(fontSize: 24.0),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      '${widget.album!.albumArtistName}\n${widget.album!.year ?? 'Unknown Year'}\n${widget.album!.tracks.length} ${language.TRACK.toLowerCase()}',
                      style: Theme.of(context).textTheme.headline3,
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                    onPressed: () {
                      Playback.play(
                        index: 0,
                        tracks: widget.album!.tracks,
                      );
                    },
                    child: Text(
                      language.PLAY_NOW,
                    ),
                  ),
                  SizedBox(
                    width: 12.0,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                    onPressed: () {
                      Playback.add(widget.album!.tracks);
                    },
                    child: Text(
                      language.ADD_TO_NOW_PLAYING,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.0),
            ],
          ),
        ),
      ),
      builder: (context, collection, child) => Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) => Container(
            height: MediaQuery.of(context).size.height.normalized,
            width: MediaQuery.of(context).size.width.normalized,
            child: Column(
              children: [
                Container(
                  height: 56.0,
                  decoration: BoxDecoration(
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    border: Border(
                      bottom: BorderSide(
                          color:
                              Theme.of(context).dividerColor.withOpacity(0.12)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      NavigatorPopButton(),
                      SizedBox(
                        width: 16.0,
                      ),
                      Text(
                        language.ALBUM_SINGLE,
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : Color(0xFF202020),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        constraints.maxWidth > kHorizontalBreakPoint
                            ? child!
                            : Container(),
                        Expanded(
                          child: CustomListView(
                            children: <Widget>[
                                  constraints.maxWidth > kHorizontalBreakPoint
                                      ? Container()
                                      : child!,
                                  SubHeader(
                                    language.COLLECTION_ALBUM_TRACKS_SUBHEADER,
                                  ),
                                ] +
                                (widget.album!.tracks
                                      ..sort((first, second) =>
                                          (first.trackNumber ?? 1).compareTo(
                                              second.trackNumber ?? 1)))
                                    .map(
                                      (Track track) => Listener(
                                        onPointerDown: (e) {
                                          shouldReact = e.kind ==
                                                  PointerDeviceKind.mouse &&
                                              e.buttons ==
                                                  kSecondaryMouseButton;
                                        },
                                        onPointerUp: (e) async {
                                          if (!shouldReact) return;
                                          final RenderObject? overlay =
                                              Overlay.of(context)!
                                                  .context
                                                  .findRenderObject();
                                          shouldReact = false;
                                          int? result = await showMenu(
                                            elevation: 4.0,
                                            context: context,
                                            position: RelativeRect.fromRect(
                                              Offset(e.position.dx,
                                                      e.position.dy - 20.0) &
                                                  Size.zero,
                                              overlay!.semanticBounds,
                                            ),
                                            items: [
                                              PopupMenuItem(
                                                padding: EdgeInsets.zero,
                                                value: 0,
                                                child: ListTile(
                                                  leading: Icon(FluentIcons
                                                      .delete_16_regular),
                                                  title: Text(
                                                    language.DELETE,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline4,
                                                  ),
                                                ),
                                              ),
                                              PopupMenuItem(
                                                padding: EdgeInsets.zero,
                                                value: 1,
                                                child: ListTile(
                                                  leading: Icon(FluentIcons
                                                      .share_16_regular),
                                                  title: Text(
                                                    language.SHARE,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline4,
                                                  ),
                                                ),
                                              ),
                                              PopupMenuItem(
                                                padding: EdgeInsets.zero,
                                                value: 2,
                                                child: ListTile(
                                                  leading: Icon(FluentIcons
                                                      .list_16_regular),
                                                  title: Text(
                                                    language.ADD_TO_PLAYLIST,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline4,
                                                  ),
                                                ),
                                              ),
                                              PopupMenuItem(
                                                padding: EdgeInsets.zero,
                                                value: 3,
                                                child: ListTile(
                                                  leading: Icon(FluentIcons
                                                      .music_note_2_16_regular),
                                                  title: Text(
                                                    language.ADD_TO_NOW_PLAYING,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline4,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                          if (result != null) {
                                            switch (result) {
                                              case 0:
                                                showDialog(
                                                  context: context,
                                                  builder: (subContext) =>
                                                      FractionallyScaledWidget(
                                                    child: AlertDialog(
                                                      title: Text(
                                                        language
                                                            .COLLECTION_ALBUM_TRACK_DELETE_DIALOG_HEADER,
                                                        style:
                                                            Theme.of(subContext)
                                                                .textTheme
                                                                .headline1,
                                                      ),
                                                      content: Text(
                                                        language
                                                            .COLLECTION_ALBUM_TRACK_DELETE_DIALOG_BODY,
                                                        style:
                                                            Theme.of(subContext)
                                                                .textTheme
                                                                .headline3,
                                                      ),
                                                      actions: [
                                                        MaterialButton(
                                                          textColor:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          onPressed: () async {
                                                            Navigator.of(
                                                                    subContext)
                                                                .pop();
                                                            await collection
                                                                .delete(track);
                                                            if (widget
                                                                .album!
                                                                .tracks
                                                                .isEmpty) {
                                                              while (Navigator.of(
                                                                      context)
                                                                  .canPop())
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                            }
                                                          },
                                                          child: Text(
                                                              language.YES),
                                                        ),
                                                        MaterialButton(
                                                          textColor:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          onPressed:
                                                              Navigator.of(
                                                                      subContext)
                                                                  .pop,
                                                          child:
                                                              Text(language.NO),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                                break;
                                              case 1:
                                                Share.shareFiles(
                                                  [track.filePath!],
                                                  subject:
                                                      '${track.trackName} • ${track.albumName}. Shared using Harmonoid!',
                                                );
                                                break;
                                              case 2:
                                                showDialog(
                                                  context: context,
                                                  builder: (subContext) =>
                                                      FractionallyScaledWidget(
                                                    child: AlertDialog(
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      actionsPadding:
                                                          EdgeInsets.zero,
                                                      title: Text(
                                                        language
                                                            .PLAYLIST_ADD_DIALOG_TITLE,
                                                        style:
                                                            Theme.of(subContext)
                                                                .textTheme
                                                                .headline1,
                                                      ),
                                                      content: Container(
                                                        height: 280,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .fromLTRB(
                                                                          24,
                                                                          8,
                                                                          0,
                                                                          16),
                                                              child: Text(
                                                                language
                                                                    .PLAYLIST_ADD_DIALOG_BODY,
                                                                style: Theme.of(
                                                                        subContext)
                                                                    .textTheme
                                                                    .headline3,
                                                              ),
                                                            ),
                                                            Container(
                                                              height: 236,
                                                              width: 280,
                                                              child: ListView
                                                                  .builder(
                                                                shrinkWrap:
                                                                    true,
                                                                itemCount:
                                                                    collection
                                                                        .playlists
                                                                        .length,
                                                                itemBuilder:
                                                                    (context,
                                                                        playlistIndex) {
                                                                  return ListTile(
                                                                    title: Text(
                                                                      collection
                                                                          .playlists[
                                                                              playlistIndex]
                                                                          .playlistName!,
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .headline2,
                                                                    ),
                                                                    leading:
                                                                        Icon(
                                                                      Icons
                                                                          .queue_music,
                                                                      size: Theme.of(
                                                                              context)
                                                                          .iconTheme
                                                                          .size,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .iconTheme
                                                                          .color,
                                                                    ),
                                                                    onTap:
                                                                        () async {
                                                                      await collection
                                                                          .playlistAddTrack(
                                                                        collection
                                                                            .playlists[playlistIndex],
                                                                        track,
                                                                      );
                                                                      Navigator.of(
                                                                              subContext)
                                                                          .pop();
                                                                    },
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      actions: [
                                                        MaterialButton(
                                                          textColor:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          onPressed:
                                                              Navigator.of(
                                                                      subContext)
                                                                  .pop,
                                                          child: Text(
                                                              language.CANCEL),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                                break;
                                              case 3:
                                                Playback.add(
                                                  [
                                                    track,
                                                  ],
                                                );
                                                break;
                                            }
                                          }
                                        },
                                        child: new Material(
                                          color: Colors.transparent,
                                          child: new ListTile(
                                            onTap: () async {
                                              await Playback.play(
                                                index: widget.album!.tracks
                                                    .indexOf(track),
                                                tracks: widget.album!.tracks,
                                              );
                                            },
                                            title: Text(
                                              track.trackName!,
                                              overflow: TextOverflow.fade,
                                              maxLines: 1,
                                              softWrap: false,
                                            ),
                                            subtitle: Text(
                                              (track.trackDuration != null
                                                      ? (Duration(
                                                                  milliseconds:
                                                                      track
                                                                          .trackDuration!)
                                                              .label +
                                                          ' • ')
                                                      : '0:00 • ') +
                                                  track.trackArtistNames!
                                                      .join(', '),
                                              overflow: TextOverflow.fade,
                                              maxLines: 1,
                                              softWrap: false,
                                            ),
                                            leading: CircleAvatar(
                                              child: Text(
                                                '${track.trackNumber ?? 1}',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              backgroundImage: FileImage(
                                                  widget.album!.albumArt),
                                            ),
                                            trailing:
                                                Platform.isAndroid ||
                                                        Platform.isIOS
                                                    ? ContextMenuButton(
                                                        color: Theme.of(context)
                                                            .appBarTheme
                                                            .backgroundColor,
                                                        elevation: 4.0,
                                                        onSelected:
                                                            (dynamic index) {
                                                          switch (index) {
                                                            case 0:
                                                              {
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (subContext) =>
                                                                          FractionallyScaledWidget(
                                                                    child:
                                                                        AlertDialog(
                                                                      title:
                                                                          Text(
                                                                        language
                                                                            .COLLECTION_ALBUM_TRACK_DELETE_DIALOG_HEADER,
                                                                        style: Theme.of(subContext)
                                                                            .textTheme
                                                                            .headline1,
                                                                      ),
                                                                      content:
                                                                          Text(
                                                                        language
                                                                            .COLLECTION_ALBUM_TRACK_DELETE_DIALOG_BODY,
                                                                        style: Theme.of(subContext)
                                                                            .textTheme
                                                                            .headline3,
                                                                      ),
                                                                      actions: [
                                                                        MaterialButton(
                                                                          textColor:
                                                                              Theme.of(context).primaryColor,
                                                                          onPressed:
                                                                              () async {
                                                                            Navigator.of(subContext).pop();
                                                                            await collection.delete(track);
                                                                            if (widget.album!.tracks.isEmpty) {
                                                                              while (Navigator.of(context).canPop())
                                                                                Navigator.of(context).pop();
                                                                            }
                                                                          },
                                                                          child:
                                                                              Text(language.YES),
                                                                        ),
                                                                        MaterialButton(
                                                                          textColor:
                                                                              Theme.of(context).primaryColor,
                                                                          onPressed:
                                                                              Navigator.of(subContext).pop,
                                                                          child:
                                                                              Text(language.NO),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                              break;
                                                            case 1:
                                                              {
                                                                Share
                                                                    .shareFiles(
                                                                  [
                                                                    track
                                                                        .filePath!
                                                                  ],
                                                                  subject:
                                                                      '${track.trackName} - ${track.albumName}.',
                                                                );
                                                              }
                                                              break;
                                                            case 2:
                                                              {
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (subContext) =>
                                                                          FractionallyScaledWidget(
                                                                    child:
                                                                        AlertDialog(
                                                                      contentPadding:
                                                                          EdgeInsets
                                                                              .zero,
                                                                      actionsPadding:
                                                                          EdgeInsets
                                                                              .zero,
                                                                      title:
                                                                          Text(
                                                                        language
                                                                            .PLAYLIST_ADD_DIALOG_TITLE,
                                                                        style: Theme.of(subContext)
                                                                            .textTheme
                                                                            .headline1,
                                                                      ),
                                                                      content:
                                                                          Container(
                                                                        height:
                                                                            280,
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            Padding(
                                                                              padding: EdgeInsets.only(left: 24, top: 8, bottom: 16),
                                                                              child: Text(
                                                                                language.PLAYLIST_ADD_DIALOG_BODY,
                                                                                style: Theme.of(subContext).textTheme.headline3,
                                                                              ),
                                                                            ),
                                                                            Container(
                                                                              height: 236,
                                                                              width: 280,
                                                                              child: ListView.builder(
                                                                                shrinkWrap: true,
                                                                                itemCount: collection.playlists.length,
                                                                                itemBuilder: (BuildContext context, int playlistIndex) => ListTile(
                                                                                  title: Text(collection.playlists[playlistIndex].playlistName!, style: Theme.of(context).textTheme.headline4),
                                                                                  leading: Icon(
                                                                                    Icons.queue_music,
                                                                                    size: Theme.of(context).iconTheme.size,
                                                                                    color: Theme.of(context).iconTheme.color,
                                                                                  ),
                                                                                  onTap: () async {
                                                                                    await collection.playlistAddTrack(
                                                                                      collection.playlists[playlistIndex],
                                                                                      track,
                                                                                    );
                                                                                    Navigator.of(subContext).pop();
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      actions: [
                                                                        MaterialButton(
                                                                          textColor:
                                                                              Theme.of(context).primaryColor,
                                                                          onPressed:
                                                                              Navigator.of(subContext).pop,
                                                                          child:
                                                                              Text(language.CANCEL),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                              break;
                                                            case 3:
                                                              Playback.add(
                                                                [
                                                                  track,
                                                                ],
                                                              );
                                                              break;
                                                          }
                                                        },
                                                        icon: Icon(
                                                          FluentIcons
                                                              .more_vertical_20_regular,
                                                          color:
                                                              Theme.of(context)
                                                                  .iconTheme
                                                                  .color,
                                                          size: 20.0,
                                                        ),
                                                        tooltip:
                                                            language.OPTIONS,
                                                        itemBuilder: (_) =>
                                                            <PopupMenuEntry>[
                                                          PopupMenuItem(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            value: 0,
                                                            child: ListTile(
                                                              leading: Icon(
                                                                  FluentIcons
                                                                      .delete_16_regular),
                                                              title: Text(
                                                                language.DELETE,
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .headline4,
                                                              ),
                                                            ),
                                                          ),
                                                          PopupMenuItem(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            value: 1,
                                                            child: ListTile(
                                                              leading: Icon(
                                                                  FluentIcons
                                                                      .share_16_regular),
                                                              title: Text(
                                                                language.SHARE,
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .headline4,
                                                              ),
                                                            ),
                                                          ),
                                                          PopupMenuItem(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            value: 2,
                                                            child: ListTile(
                                                              leading: Icon(
                                                                  FluentIcons
                                                                      .list_16_regular),
                                                              title: Text(
                                                                language
                                                                    .ADD_TO_PLAYLIST,
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .headline4,
                                                              ),
                                                            ),
                                                          ),
                                                          PopupMenuItem(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            value: 3,
                                                            child: ListTile(
                                                              leading: Icon(
                                                                  FluentIcons
                                                                      .music_note_2_16_regular),
                                                              title: Text(
                                                                language
                                                                    .ADD_TO_NOW_PLAYING,
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .headline4,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : null,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension on Duration {
  String get label {
    int minutes = inSeconds ~/ 60;
    String seconds = inSeconds - (minutes * 60) > 9
        ? '${inSeconds - (minutes * 60)}'
        : '0${inSeconds - (minutes * 60)}';
    return '$minutes:$seconds';
  }
}
