import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const WhisperingForestGame());
}

enum GameScreen {
  intro,
  menu,
  chapter1,
  chapter2,
  chapter3,
  outro,
  credits,
}

class WhisperingForestGame extends StatelessWidget {
  const WhisperingForestGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Whispers in the Hollow',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF07110D),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5AE4A8),
          brightness: Brightness.dark,
        ),
      ),
      home: const GameHome(),
    );
  }
}

class GameHome extends StatefulWidget {
  const GameHome({super.key});

  @override
  State<GameHome> createState() => _GameHomeState();
}

class _GameHomeState extends State<GameHome> {
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();

  GameScreen _screen = GameScreen.intro;
  int _chapterIndex = 0;
  final Map<int, Set<String>> _discovered = {0: {}, 1: {}, 2: {}};
  bool _ambienceOn = true;
  bool _voiceOn = true;

  final List<Map<String, dynamic>> chapters = [
    {
      'title': 'Chapter 1',
      'subtitle': 'The Whispering Trail',
      'text':
          'The forest opens like a throat. Every leaf whispers your name, and the trail behind the chapel is still wet with rain. Something is moving beneath the roots, waiting for you to look away.',
      'ending':
          'The lantern burns blue for a moment, and in the fog you hear a single sentence: “The Hollow remembers.”',
      'items': [
        {
          'name': 'Lantern by the stump',
          'detail':
              'A storm-bent lantern glows beneath a split tree. The flame is warm, but the handle is wet with a strange black mist.',
        },
        {
          'name': 'Footprints in the moss',
          'detail':
              'The prints are too fresh to be old, but they stop at the edge of a ravine where no one should have walked.',
        },
        {
          'name': 'Whispering oak',
          'detail':
              'The bark hums with a low voice. It repeats one line over and over: “Do not follow the light without a name.”',
        },
        {
          'name': 'Broken sign',
          'detail':
              'Half of the sign remains, scratched into the wood: “Hollow Road — no return.”',
        },
      ],
    },
    {
      'title': 'Chapter 2',
      'subtitle': 'The Abandoned Cabin',
      'text':
          'You find a cabin hidden beneath the pines, the windows fogged with dust and breath. Across the floor lies a chair facing the door, as if someone heard you coming before you arrived.',
      'ending':
          'Inside the wall, beneath a portrait of a smiling family, you discover the name of the last survivor: Mara Voss.',
      'items': [
        {
          'name': 'Fallen portrait',
          'detail':
              'A framed photo lies smashed on the floor. Someone scratched the faces out with a nail, leaving only a single eye.',
        },
        {
          'name': 'Jacket on the chair',
          'detail':
              'The coat still smells of pine smoke and rain. The pocket contains a silver compass that spins toward the forest heart.',
        },
        {
          'name': 'Ritual circle',
          'detail':
              'Candles have melted into a strange ring. At the center sits a small stone engraved with an eye and a broken moon.',
        },
        {
          'name': 'Hidden journal',
          'detail':
              'The pages warn: “When the woods are quiet, listen for the second footsteps. They are not yours.”',
        },
      ],
    },
    {
      'title': 'Chapter 3',
      'subtitle': 'The Shrine of Echoes',
      'text':
          'The path narrows to a stone shrine buried beneath roots and fog. The air tastes like iron, and the trees lean in as if they are listening to your heartbeat.',
      'ending':
          'You lift the final relic and hear the forest answer. Somewhere behind the shrine, a door opens in the dark and the story begins again.',
      'items': [
        {
          'name': 'Stone altar',
          'detail':
              'The altar is carved with faces, all turned toward the same point in the mist. A voice whispers from below the stone.',
        },
        {
          'name': 'Echoing bell',
          'detail':
              'Its clapper is rusted, but it rings once when touched. The sound arrives from inside the earth, not from the air.',
        },
        {
          'name': 'Moving fog',
          'detail':
              'The mist forms a human shape and then slips away. A pair of footsteps follows you for a second before vanishing.',
        },
        {
          'name': 'Sacred relic',
          'detail':
              'A smooth silver charm pulses gently in the palm. It is warm, as though it has been waiting for your hand.',
        },
      ],
    },
  ];

  final List<String> credits = [
    'Lead Game Design — Maria Atta',
    'Narrative Director — The Hollow Team',
    'Environment Art — Night Forest Studios',
    'Audio Production — Whisper Echo Lab',
    'Programming — Flutter + Dart',
    'Special Thanks — The Players Who Followed the Light',
  ];

  @override
  void dispose() {
    _tts.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (!_voiceOn || text.isEmpty) return;
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.9);
    await _tts.setVolume(1.0);
    await _tts.speak(text);
  }

  Future<void> _toggleAmbience() async {
    if (!_ambienceOn) {
      await _audioPlayer.stop();
      setState(() => _ambienceOn = false);
      return;
    }

    setState(() => _ambienceOn = true);

    try {
      await _audioPlayer.play(
        const UrlSource(
          'https://cdn.pixabay.com/download/audio/2022/03/15/audio_7bfb112f4f.mp3?filename=dark-ambient-forest-185951.mp3',
        ),
      );
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (_) {
      // Silent fallback for offline or blocked media access.
    }
  }

  void _startGame() {
    _chapterIndex = 0;
    _screen = GameScreen.chapter1;
    _speak('A new game begins. The forest watches.');
    _toggleAmbience();
    setState(() {});
  }

  void _discoverItem(String itemName) {
    final set = _discovered[_chapterIndex] ?? <String>{};
    if (set.contains(itemName)) return;

    set.add(itemName);
    final chapter = chapters[_chapterIndex];
    final item = (chapter['items'] as List).firstWhere(
      (entry) => entry['name'] == itemName,
      orElse: () => {'detail': 'The darkness grows thicker around you.'},
    );

    _speak(item['detail']);
    setState(() {});
  }

  void _advanceStory() {
    if (_chapterIndex < chapters.length - 1) {
      _chapterIndex += 1;
      _screen = _screenForChapter(_chapterIndex);
      _speak('Chapter ${_chapterIndex + 1} begins.');
      setState(() {});
      return;
    }

    _screen = GameScreen.outro;
    _speak('The story ends. But the forest is still awake.');
    setState(() {});
  }

  GameScreen _screenForChapter(int index) {
    switch (index) {
      case 0:
        return GameScreen.chapter1;
      case 1:
        return GameScreen.chapter2;
      case 2:
        return GameScreen.chapter3;
      default:
        return GameScreen.outro;
    }
  }

  bool _chapterComplete() {
    final currentItems = chapters[_chapterIndex]['items'] as List<Map<String, dynamic>>;
    final found = _discovered[_chapterIndex] ?? <String>{};
    return found.length >= currentItems.length;
  }

  Widget _buildIntroScreen() {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF04140F), Color(0xFF0B1F1A), Color(0xFF0A0A14)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 80,
              left: 40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF3BB98C).withOpacity(0.16),
                ),
              ),
            ),
            Positioned(
              bottom: 120,
              right: 60,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF7B2D40).withOpacity(0.18),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'WHISPERS',
                      style: GoogleFonts.cinzel(
                        fontSize: 34,
                        letterSpacing: 5,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'IN THE HOLLOW',
                      style: GoogleFonts.cinzel(
                        fontSize: 18,
                        letterSpacing: 8,
                        color: const Color(0xFFB9E7D5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(18),
                        color: Colors.black.withOpacity(0.18),
                      ),
                      child: Text(
                        'A survival story in the dark forest',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          letterSpacing: 1.2,
                          color: const Color(0xFFDDE9E3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 44),
                    SizedBox(
                      width: 220,
                      child: ElevatedButton(
                        onPressed: _startGame,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(54),
                          backgroundColor: const Color(0xFF48DDA7),
                          foregroundColor: const Color(0xFF052415),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          'Start New Game',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuScreen() {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Forest Access',
                  style: GoogleFonts.cinzel(
                    fontSize: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      backgroundColor: const Color(0xFF2D5245),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Resume the Story'),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: SwitchListTile(
                        title: const Text('Ambience'),
                        value: _ambienceOn,
                        onChanged: (_) => _toggleAmbience(),
                      ),
                    ),
                    Expanded(
                      child: SwitchListTile(
                        title: const Text('Voice'),
                        value: _voiceOn,
                        onChanged: (value) {
                          setState(() => _voiceOn = value);
                          if (!value) {
                            _tts.stop();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChapterScreen() {
    final chapter = chapters[_chapterIndex];
    final items = chapter['items'] as List<Map<String, dynamic>>;
    final discovered = _discovered[_chapterIndex] ?? <String>{};

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF05170F), Color(0xFF102E1E), Color(0xFF0D1620)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        chapter['title'],
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF9DEFC8),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${discovered.length}/${items.length}',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  chapter['subtitle'],
                  style: GoogleFonts.cinzel(
                    fontSize: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chapter['text'],
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            height: 1.7,
                            color: const Color(0xFFE6F6F1),
                          ),
                        ),
                        const SizedBox(height: 22),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.25,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final isDiscovered = discovered.contains(item['name']);

                            return GestureDetector(
                              onTap: () => _discoverItem(item['name']),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isDiscovered
                                        ? const Color(0xFF49E0A7)
                                        : Colors.white.withOpacity(0.18),
                                  ),
                                  color: isDiscovered
                                      ? const Color(0xFF15342A)
                                      : Colors.black.withOpacity(0.12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isDiscovered ? 'Discovered' : 'Look closer',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: isDiscovered
                                            ? const Color(0xFF9DEFC8)
                                            : Colors.white60,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item['name'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      isDiscovered ? item['detail'] : 'Tap to investigate',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _chapterComplete() ? _advanceStory : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: const Color(0xFF4FDBA5),
                      foregroundColor: const Color(0xFF062710),
                    ),
                    child: Text(
                      _chapterIndex < chapters.length - 1
                          ? 'Continue to Next Chapter'
                          : 'Reveal the Final Outro',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
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

  Widget _buildOutroScreen() {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B101B), Color(0xFF1A161D), Color(0xFF0A0C12)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'The Forest Is Still Listening',
                  style: GoogleFonts.cinzel(
                    fontSize: 30,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'The shrine has opened. The path is ending. But the woods remember your name, and the next chapter is waiting behind the fog.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: const Color(0xFFE9EDF3),
                    height: 1.8,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 220,
                  child: ElevatedButton(
                    onPressed: () {
                      _screen = GameScreen.credits;
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: const Color(0xFF7B6EEB),
                    ),
                    child: const Text('View Credits'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreditsScreen() {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 30),
          child: Column(
            children: [
              Text(
                'Developers',
                style: GoogleFonts.cinzel(
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  itemCount: credits.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Text(
                        credits[index],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _screen = GameScreen.intro;
                    _chapterIndex = 0;
                    _discovered.clear();
                    _discovered[0] = {};
                    _discovered[1] = {};
                    _discovered[2] = {};
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: const Color(0xFF49D7A8),
                    foregroundColor: const Color(0xFF041D15),
                  ),
                  child: const Text('Play Again'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_screen) {
      case GameScreen.intro:
        return _buildIntroScreen();
      case GameScreen.menu:
        return _buildMenuScreen();
      case GameScreen.chapter1:
      case GameScreen.chapter2:
      case GameScreen.chapter3:
        return _buildChapterScreen();
      case GameScreen.outro:
        return _buildOutroScreen();
      case GameScreen.credits:
        return _buildCreditsScreen();
    }
  }
}

class _ForestButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _ForestButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

/*
  Game Overview:
  - Intro sequence with dark cinematic mood and button start
  - Chapter progression with clickable clue discoverables
  - Character narration and creepy atmosphere
  - End section with final suspense and developer credits
*/

