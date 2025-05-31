import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ReelsPage extends StatefulWidget {
  @override
  _ReelsPageState createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  List<String> videoUrls = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVideoUrls();
  }

  Future<void> _fetchVideoUrls() async {
    try {
      // Reference to the 'reels' folder in Firebase Storage
      final ListResult result = await storage.ref('reels').listAll();

      // Get all video URLs
      List<String> urls = [];
      for (var item in result.items) {
        String url = await item.getDownloadURL();
        urls.add(url);
      }

      setState(() {
        videoUrls = urls;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching video URLs: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reels"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : InfiniteReels(videoUrls: videoUrls),
    );
  }
}

class InfiniteReels extends StatefulWidget {
  final List<String> videoUrls;

  InfiniteReels({required this.videoUrls});

  @override
  _InfiniteReelsState createState() => _InfiniteReelsState();
}

class _InfiniteReelsState extends State<InfiniteReels> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextVideo() {
    _pageController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: widget.videoUrls.length,
      onPageChanged: (index) {
        setState(() {
          _currentPage = index % widget.videoUrls.length; // Simulate infinite scrolling
        });
      },
      itemBuilder: (context, index) {
        int actualIndex = index % widget.videoUrls.length; // Wrap around using modulo
        return FullScreenVideoPlayer(
          key: ValueKey(actualIndex), // Ensure proper widget recreation
          videoUrl: widget.videoUrls[actualIndex],
          onVideoFinished: _goToNextVideo,
        );
      },
    );
  }
}

class FullScreenVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final VoidCallback onVideoFinished;

  FullScreenVideoPlayer({
    required Key key,
    required this.videoUrl,
    required this.onVideoFinished,
  }) : super(key: key);

  @override
  _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {}); // Trigger rebuild after initialization
        _controller.setLooping(false); // Disable looping
        _controller.play(); // Auto-play the video
      }).catchError((error) {
        print("Error initializing video player: $error");
      });

    // Listen for video completion
    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration &&
          !_controller.value.isPlaying) {
        widget.onVideoFinished(); // Trigger next video
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    setState(() {
      if (isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      isPlaying = !isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlayback,
      child: SizedBox.expand(
        child: _controller.value.isInitialized
            ? AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        )
            : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Loading video..."),
            ],
          ),
        ),
      ),
    );
  }
}