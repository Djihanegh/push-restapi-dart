// import 'package:better_player/better_player.dart';
import 'package:clipboard/clipboard.dart';
import 'package:example/__lib.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:push_restapi_dart/push_restapi_dart.dart';
import 'package:video_player/video_player.dart';

class LiveSpaceRoom extends ConsumerStatefulWidget {
  final SpaceDTO space;

  LiveSpaceRoom({required this.space});

  @override
  ConsumerState<LiveSpaceRoom> createState() => _LiveSpaceRoomState();
}

class _LiveSpaceRoomState extends ConsumerState<LiveSpaceRoom> {
  VideoPlayerController? _controller;
  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(PushSpaceProvider);
    final SpaceDTO data = widget.space;
    final liveSpaceData = vm.liveSpaceData;
    final host = liveSpaceData.host;
    final speakers = liveSpaceData.speakers;
    return Scaffold(
      appBar: AppBar(
        title: Text('Space'),
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  SizedBox(height: 12),
                  DataView(
                    label: 'Space Name:',
                    value: data.spaceName,
                  ),
                  SizedBox(height: 12),
                  DataView(
                    label: 'Space Id:',
                    value: data.spaceId,
                  ),
                  SizedBox(height: 12),
                  DataView(
                    label: 'Space Description:',
                    value: data.spaceDescription ?? '',
                  ),
                  SizedBox(height: 12),
                  DataView(label: 'Space Creator', value: data.spaceCreator),
                  SizedBox(height: 24),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: InkWell(
                      onTap: () {
                        FlutterClipboard.copy(data.spaceId).then((value) {
                          showMyDialog(
                              context: context,
                              title: 'Space ',
                              message: 'Space Id copied successfully');
                        });
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.purple),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.copy,
                              size: 14,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Copy space id',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Divider(),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration:
                        BoxDecoration(color: Colors.yellow.withOpacity(.3)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Host'),
                        SizedBox(height: 8),
                        if (host.address == '') Text('Host hasnt joined the space yet'),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${host.address}',
                              ),
                            ),
                            SizedBox(width: 24),
                            Container(
                              decoration: BoxDecoration(shape: BoxShape.circle),
                              child: Icon(
                                host.audio == true ? Icons.mic : Icons.mic_off,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration:
                        BoxDecoration(color: Colors.pinkAccent.withOpacity(.3)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Speakers'),
                        SizedBox(height: 8),
                        if (speakers.isEmpty) Text('There are no speakers in the space currently'),
                        ...speakers.map(
                          (e) => Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${e.address}',
                                  ),
                                ),
                                SizedBox(width: 24),
                                Container(
                                  decoration:
                                      BoxDecoration(shape: BoxShape.circle),
                                  child: Icon(
                                    e.audio == true
                                        ? Icons.mic
                                        : Icons.mic_off,
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Consumer(
              builder: (context, ref, child) {
                final vm = ref.watch(PushSpaceProvider);
                // _setPlaybackUrl(vm.spacePlaybackUrl);

                if (vm.spacePlaybackUrl != null) {
                  if (_controller == null) {
                    _controller = VideoPlayerController.networkUrl(
                      Uri.parse(vm.spacePlaybackUrl!),
                      formatHint: VideoFormat.hls,
                      videoPlayerOptions:
                          VideoPlayerOptions(allowBackgroundPlayback: true),
                    )..initialize().then((_) {
                        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
                        setState(() {});
                      });
                    return SizedBox.shrink();
                  }

                  return Column(
                    children: [
                      SizedBox(
                        height: 100,
                        child: _controller!.value.isInitialized
                            ? AspectRatio(
                                aspectRatio: _controller!.value.aspectRatio,
                                child: VideoPlayer(_controller!),
                              )
                            : SizedBox.shrink(),
                      ),
                      MaterialButton(
                        padding: EdgeInsets.all(16),
                        color: Colors.white,
                        shape: CircleBorder(),
                        child: Icon(
                          Icons.play_arrow,
                          size: 32,
                        ),
                        onPressed: () {
                          _controller!.play();
                        },
                      ),
                    ],
                  );
                }
                return SizedBox.shrink();
              },
            ),
            if (vm.isSpeakerConnected)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    children: [
                      MaterialButton(
                        color: Colors.purple,
                        shape: CircleBorder(),
                        child: Icon(
                          Icons.people,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                      Text('Participants')
                    ],
                  ),
                  SizedBox(width: 16),
                  Consumer(builder: (context, ref, child) {
                    final vm = ref.watch(PushSpaceProvider);
                    bool isSpeaker = vm.isSpeakerConnected;

                    if (isSpeaker) {
                      bool isMicOn = vm.isMicOn;
                      return Column(
                        children: [
                          MaterialButton(
                            padding: EdgeInsets.all(16),
                            color: Colors.white,
                            shape: CircleBorder(),
                            child: Icon(
                              isMicOn ? Icons.mic : Icons.mic_off,
                              size: 32,
                            ),
                            onPressed:
                                ref.read(PushSpaceProvider.notifier).toggleMic,
                          ),
                          Text('Mic')
                        ],
                      );
                    }

                    return SizedBox.shrink();
                  }),
                  SizedBox(width: 16),
                  Column(
                    children: [
                      MaterialButton(
                        color: Colors.red,
                        shape: CircleBorder(),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          showLoadingDialog(context);
                          await vm.leave().then((value) {
                            showMyDialog(
                              context: context,
                              title: 'Space',
                              message: 'Leave space success',
                              onClose: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                            );
                          });
                        },
                      ),
                      Text('Leave')
                    ],
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}

class DataView extends StatelessWidget {
  const DataView({
    super.key,
    required this.label,
    required this.value,
    this.color,
  });
  final Color? color;
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 10,
              color: color ?? Colors.grey[700]),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: color,
          ),
        ),
      ],
    );
  }
}
