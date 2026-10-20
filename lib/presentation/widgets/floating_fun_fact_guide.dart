import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/storage_service.dart';
import '../../data/data_sources/fun_facts_data.dart';

/// Represents the visual & behavioral state of the floating mascot guide.
enum MascotGuideState {
  /// Shown automatically when the app opens (`mascot_cat_idle_clean.png` + time-of-day welcome bubble).
  /// Auto-retracts into [peeking] after a few seconds or when dismissed.
  greeting,

  /// Discreetly peeking from the right edge (`mascot_cat_peeking_clean.png`) with no bubble.
  peeking,

  /// Active fun-fact state (`mascot_cat_tapping_clean.png` + spotlight veil + fun fact chat bubble).
  speaking,
}

/// Interactive Floating Character Guide featuring the cute white cat mascot.
/// Behavior:
/// - **Greeting State (`MascotGuideState.greeting`)**: Uses `mascot_cat_idle_clean.png` when the app opens,
///   dimming the background with a thin dark veil and displaying a warm time-of-day Korean greeting bubble.
///   Remains open until manually closed by the user (tapping the veil, the 'X' button, or "Let's Study!"),
///   or transitioned into a fun fact by tapping "Fun Fact".
/// - **Peeking State (`MascotGuideState.peeking`)**: Uses `mascot_cat_peeking_clean.png` with no text bubble,
///   peeking discreetly from the right edge of the screen.
/// - **Speaking / Tapping State (`MascotGuideState.speaking`)**: Uses `mascot_cat_tapping_clean.png` every 5 minutes
///   (or whenever the user taps the peeking cat), dimming the background with a thin dark spotlight veil and opening
///   the speech bubble with a Korean fun fact.
class FloatingFunFactGuide extends StatefulWidget {
  final StorageService storageService;
  final Duration promptInterval;
  final bool showInitialGreeting;

  const FloatingFunFactGuide({
    super.key,
    required this.storageService,
    this.promptInterval = const Duration(minutes: 5),
    this.showInitialGreeting = true,
  });

  @override
  State<FloatingFunFactGuide> createState() => FloatingFunFactGuideState();
}

class FloatingFunFactGuideState extends State<FloatingFunFactGuide>
    with SingleTickerProviderStateMixin {
  static const String _kStorageKeyDisabled = 'guide_fun_facts_disabled_v1';
  static const String _kStorageKeyShownFacts = 'guide_fun_facts_shown_ids_v1';

  static const String _kMascotGreetingIdleAssetPath =
      'assets/images/mascot_cat_idle_clean.png';
  static const String _kMascotPeekingAssetPath =
      'assets/images/mascot_cat_peeking_clean.png';
  static const String _kMascotTappingAssetPath =
      'assets/images/mascot_cat_tapping_clean.png';

  late final AnimationController _hopController;
  late final Animation<double> _hopAnimation;
  Timer? _periodicTimer;

  late bool _isDisabled;
  late MascotGuideState _guideState;
  late int _currentIndex;
  late List<int> _deckOrder;

  bool get _isExpanded =>
      _guideState == MascotGuideState.greeting ||
      _guideState == MascotGuideState.speaking;

  @override
  void initState() {
    super.initState();
    _isDisabled = widget.storageService.getBool(_kStorageKeyDisabled) ?? false;
    _initRotationDeck();

    _guideState = (!widget.showInitialGreeting || _isDisabled)
        ? MascotGuideState.peeking
        : MascotGuideState.greeting;

    _hopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    _hopAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 0.0), weight: 50),
    ]).animate(
      CurvedAnimation(parent: _hopController, curve: Curves.easeOutCubic),
    );

    if (!_isDisabled) {
      if (_guideState == MascotGuideState.greeting) {
        _hopController.forward(from: 0.0);
      }
      _startPeriodicTimer();
    }
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    _hopController.dispose();
    super.dispose();
  }

  void _startPeriodicTimer() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer(widget.promptInterval, () {
      if (!mounted || _isDisabled) return;
      if (_guideState == MascotGuideState.peeking) {
        _advanceFactIndex();
        setState(() {
          _guideState = MascotGuideState.speaking;
        });
        _hopController.forward(from: 0.0);
      }
      _startPeriodicTimer();
    });
  }

  void _initRotationDeck() {
    final shownList =
        (widget.storageService.getString(_kStorageKeyShownFacts) ?? '')
            .split(',')
            .where((s) => s.isNotEmpty)
            .toSet();

    final all = FunFactsData.facts;
    final unshownIndices = <int>[];
    final shownIndices = <int>[];

    for (int i = 0; i < all.length; i++) {
      if (shownList.contains(all[i].id)) {
        shownIndices.add(i);
      } else {
        unshownIndices.add(i);
      }
    }

    if (unshownIndices.isEmpty) {
      _deckOrder = List.generate(all.length, (i) => i)..shuffle();
      widget.storageService.setString(_kStorageKeyShownFacts, '');
    } else {
      unshownIndices.shuffle();
      _deckOrder = [...unshownIndices, ...shownIndices];
    }

    _currentIndex = _deckOrder.isNotEmpty ? _deckOrder.first : 0;
    _markCurrentAsShown();
  }

  void _markCurrentAsShown() {
    final currentId = FunFactsData.facts[_currentIndex].id;
    final shownList =
        (widget.storageService.getString(_kStorageKeyShownFacts) ?? '')
            .split(',')
            .where((s) => s.isNotEmpty)
            .toSet();
    shownList.add(currentId);
    widget.storageService.setString(_kStorageKeyShownFacts, shownList.join(','));
  }

  void _advanceFactIndex() {
    final currentPos = _deckOrder.indexOf(_currentIndex);
    if (currentPos >= 0 && currentPos + 1 < _deckOrder.length) {
      _currentIndex = _deckOrder[currentPos + 1];
    } else {
      _deckOrder = List.generate(FunFactsData.facts.length, (i) => i)..shuffle();
      _currentIndex = _deckOrder.first;
      widget.storageService.setString(_kStorageKeyShownFacts, '');
    }
    _markCurrentAsShown();
  }

  /// Public method to cycle to the next fact and show the speaking bubble
  void nextFact() {
    if (!mounted || _isDisabled) return;
    setState(() {
      _advanceFactIndex();
      _guideState = MascotGuideState.speaking;
    });
    _hopController.forward(from: 0.0);
    _startPeriodicTimer();
  }

  /// Transitions directly from the greeting state to showing a fun fact
  void _showFunFactFromGreeting() {
    if (!mounted || _isDisabled) return;
    setState(() {
      _guideState = MascotGuideState.speaking;
    });
    _hopController.forward(from: 0.0);
    _startPeriodicTimer();
  }

  /// Called when tapping the cat sprite
  void _onTapCat() {
    if (_isExpanded) {
      _closeBubble();
    } else {
      setState(() {
        _guideState = MascotGuideState.speaking;
      });
      _hopController.forward(from: 0.0);
      _startPeriodicTimer();
    }
  }

  /// Closes the speech bubble, fades out the dark veil, and slides the cat back to peeking mode
  void _closeBubble() {
    setState(() {
      _guideState = MascotGuideState.peeking;
    });
    _startPeriodicTimer();
  }

  void _disableForever() {
    _periodicTimer?.cancel();
    setState(() {
      _isDisabled = true;
      _guideState = MascotGuideState.peeking;
    });
    widget.storageService.setBool(_kStorageKeyDisabled, true);
  }

  /// Returns time-of-day Korean greeting details
  ({String badge, String korean, String romanization, String message})
      _getTimeOfDayGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return (
        badge: 'GOOD MORNING ☀️',
        korean: '좋은 아침이에요! (Jo-eun a-chim-i-e-yo!)',
        romanization: 'Good morning!',
        message:
            'Ready to start your day with a few fun Korean syllables? 화이팅! (Hwaiting!)',
      );
    } else if (hour >= 12 && hour < 18) {
      return (
        badge: 'GOOD AFTERNOON 🌤️',
        korean: '안녕하세요! 좋은 오후예요!',
        romanization: 'An-nyeong-ha-se-yo! Good afternoon!',
        message:
            'Keep up your awesome study streak today! Tap me anytime you want a Korean fun fact.',
      );
    } else {
      return (
        badge: 'GOOD EVENING 🌙',
        korean: '오늘도 수고했어요! (O-neul-do su-go-haess-eo-yo!)',
        romanization: 'Great job today! Good evening!',
        message:
            'A quick evening review is the best way to remember Hangul! Let\'s learn together!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisabled) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fact = FunFactsData.facts[_currentIndex];
    final bool showSpotlightVeil = _isExpanded;

    return Positioned.fill(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Thin Dark Spotlight Veil when the character is speaking or greeting (_isExpanded)
          // Tapping anywhere on this veil closes the speech bubble and retracts the cat.
          IgnorePointer(
            ignoring: !showSpotlightVeil,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _closeBubble,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOut,
                color: showSpotlightVeil
                    ? Colors.black.withOpacity(isDark ? 0.62 : 0.48)
                    : Colors.transparent,
              ),
            ),
          ),

          // 2. Character + Speech Bubble Layer
          // - Greeting: mascot_cat_idle_clean.png (right: 12) + Greeting Bubble
          // - Peeking: mascot_cat_peeking_clean.png (right: -6) + No Bubble
          // - Speaking: mascot_cat_tapping_clean.png (right: 12) + Fun Fact Bubble
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            bottom: 12,
            right: _isExpanded ? 12 : -6,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_guideState == MascotGuideState.greeting)
                  _buildGreetingChatBubble(theme, isDark)
                else if (_guideState == MascotGuideState.speaking)
                  _buildExpandedChatBubble(theme, isDark, fact),
                _buildCharacterSprite(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Greeting speech bubble shown at app launch with `mascot_cat_idle_clean.png`
  Widget _buildGreetingChatBubble(ThemeData theme, bool isDark) {
    final bubbleBg = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    const borderColor = AppColors.primary;
    final greeting = _getTimeOfDayGreeting();

    return Padding(
      padding: const EdgeInsets.only(right: 4, bottom: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 305,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bubbleBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(8),
              ),
              border: Border.all(color: borderColor, width: 2.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'WELCOME • ${greeting.badge}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: 20,
                      tooltip: 'Close greeting',
                      icon: const Icon(Icons.close_rounded),
                      onPressed: _closeBubble,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    greeting.korean,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  greeting.message,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.38,
                    color: isDark
                        ? Colors.white.withOpacity(0.95)
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: TextButton(
                        onPressed: _closeBubble,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(40, 24),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Let\'s Study!',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _showFunFactFromGreeting,
                      icon: const Icon(Icons.auto_awesome_rounded, size: 14),
                      label: const Text(
                        'Fun Fact',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        minimumSize: const Size(76, 34),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 42),
            child: CustomPaint(
              size: const Size(20, 13),
              painter: _BubbleTailPainter(
                fillColor: bubbleBg,
                borderColor: borderColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Expanded chat bubble popup coming from the cat character during `MascotGuideState.speaking`
  Widget _buildExpandedChatBubble(ThemeData theme, bool isDark, FunFact fact) {
    final bubbleBg = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final borderColor = AppColors.accentPurple;

    return Padding(
      padding: const EdgeInsets.only(right: 4, bottom: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 315,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: bubbleBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(8),
              ),
              border: Border.all(color: borderColor, width: 2.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bubble Top Bar with Close 'X' button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentPurple.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'DID YOU KNOW? • ${fact.category}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.accentPurple,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: 20,
                      tooltip: 'Close',
                      icon: const Icon(Icons.close_rounded),
                      onPressed: _closeBubble,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Optional Korean Word badge
                if (fact.korean != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      fact.korean!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                // Fun Fact Speech Content
                Text(
                  '"${fact.fact}"',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                    color: isDark
                        ? Colors.white.withOpacity(0.95)
                        : Colors.black87,
                  ),
                ),
                if (fact.detail != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    fact.detail!,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                // Bubble Footer Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: TextButton(
                        onPressed: _disableForever,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(40, 24),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Don\'t show again',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: nextFact,
                      icon: const Icon(Icons.auto_awesome_rounded, size: 14),
                      label: const Text(
                        'Next Fact',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        minimumSize: const Size(76, 34),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Speech Bubble Pointer Tail aimed directly at the cat character below
          Padding(
            padding: const EdgeInsets.only(right: 42),
            child: CustomPaint(
              size: const Size(20, 13),
              painter: _BubbleTailPainter(
                fillColor: bubbleBg,
                borderColor: borderColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Standalone Cute White Cat Sprite:
  /// - `MascotGuideState.greeting`: Uses `mascot_cat_idle_clean.png` (greeting the user at launch).
  /// - `MascotGuideState.peeking`: Uses `mascot_cat_peeking_clean.png` (peeking from right screen edge).
  /// - `MascotGuideState.speaking`: Uses `mascot_cat_tapping_clean.png` (sharing a fun fact).
  Widget _buildCharacterSprite() {
    final double spriteWidth = _isExpanded ? 132 : 112;
    final double spriteHeight = _isExpanded ? 104 : 92;

    final String activeAsset = switch (_guideState) {
      MascotGuideState.greeting => _kMascotGreetingIdleAssetPath,
      MascotGuideState.peeking => _kMascotPeekingAssetPath,
      MascotGuideState.speaking => _kMascotTappingAssetPath,
    };

    return Semantics(
      button: true,
      label: _isExpanded
          ? 'Close cat guide'
          : 'Tap peeking cat for a Korean fun fact',
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _onTapCat,
        child: AnimatedBuilder(
          animation: _hopAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _hopAnimation.value),
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            width: spriteWidth,
            height: spriteHeight,
            child: Transform.scale(
              scale: _isExpanded ? 1.7 : 1.35,
              alignment:
                  _isExpanded ? Alignment.center : Alignment.centerRight,
              child: Image.asset(
                activeAsset,
                fit: BoxFit.contain,
                alignment:
                    _isExpanded ? Alignment.center : Alignment.centerRight,
                errorBuilder: (_, _, _) => const Center(
                  child: Text('🐱', style: TextStyle(fontSize: 48)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Draws the comic speech-bubble tail seamlessly connecting the chat bubble to the character below
class _BubbleTailPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;

  _BubbleTailPainter({
    required this.fillColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Fill triangle overlapping 1.5px into the bubble above so the top seam is invisible
    final fillPath = Path()
      ..moveTo(0, -1.5)
      ..lineTo(size.width, -1.5)
      ..lineTo(size.width * 0.65, size.height)
      ..close();

    // Stroke only the two outer V edges of the tail
    final strokePath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.65, size.height)
      ..lineTo(size.width, 0);

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(strokePath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _BubbleTailPainter oldDelegate) =>
      oldDelegate.fillColor != fillColor ||
      oldDelegate.borderColor != borderColor;
}
