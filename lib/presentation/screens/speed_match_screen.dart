import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/app_providers.dart';

class MatchPairItem {
  final String hangul;
  final String romanization;
  final String sound;

  const MatchPairItem({
    required this.hangul,
    required this.romanization,
    required this.sound,
  });
}

class SpeedMatchScreen extends ConsumerStatefulWidget {
  const SpeedMatchScreen({super.key});

  @override
  ConsumerState<SpeedMatchScreen> createState() => _SpeedMatchScreenState();
}

class _SpeedMatchScreenState extends ConsumerState<SpeedMatchScreen> {
  static const List<MatchPairItem> fullPool = [
    MatchPairItem(hangul: 'ㄱ', romanization: 'g / k', sound: '그'),
    MatchPairItem(hangul: 'ㄴ', romanization: 'n', sound: '느'),
    MatchPairItem(hangul: 'ㄷ', romanization: 'd / t', sound: '드'),
    MatchPairItem(hangul: 'ㄹ', romanization: 'r / l', sound: '르'),
    MatchPairItem(hangul: 'ㅁ', romanization: 'm', sound: '므'),
    MatchPairItem(hangul: 'ㅂ', romanization: 'b / p', sound: '브'),
    MatchPairItem(hangul: 'ㅅ', romanization: 's', sound: '스'),
    MatchPairItem(hangul: 'ㅇ', romanization: 'ng / 0', sound: '응'),
    MatchPairItem(hangul: 'ㅈ', romanization: 'j', sound: '즈'),
    MatchPairItem(hangul: 'ㅎ', romanization: 'h', sound: '흐'),
    MatchPairItem(hangul: 'ㅏ', romanization: 'a', sound: '아'),
    MatchPairItem(hangul: 'ㅓ', romanization: 'eo', sound: '어'),
    MatchPairItem(hangul: 'ㅗ', romanization: 'o', sound: '오'),
    MatchPairItem(hangul: 'ㅜ', romanization: 'u', sound: '우'),
    MatchPairItem(hangul: '가', romanization: 'ga', sound: '가'),
    MatchPairItem(hangul: '나', romanization: 'na', sound: '나'),
    MatchPairItem(hangul: '물', romanization: 'mul (Water)', sound: '물'),
    MatchPairItem(hangul: '밥', romanization: 'bap (Rice)', sound: '밥'),
  ];

  late List<MatchPairItem> _leftHangul;
  late List<MatchPairItem> _rightRoman;
  final Set<String> _matchedHangul = {};
  String? _selectedHangul;
  String? _selectedRomanHangulKey;
  bool _hasErrorFlash = false;
  int _moves = 0;

  @override
  void initState() {
    super.initState();
    _startNewRound();
  }

  void _startNewRound() {
    final rng = Random();
    final shuffled = List<MatchPairItem>.from(fullPool)..shuffle(rng);
    final selected = shuffled.take(6).toList();

    setState(() {
      _leftHangul = List<MatchPairItem>.from(selected)..shuffle(rng);
      _rightRoman = List<MatchPairItem>.from(selected)..shuffle(rng);
      _matchedHangul.clear();
      _selectedHangul = null;
      _selectedRomanHangulKey = null;
      _hasErrorFlash = false;
      _moves = 0;
    });
  }

  void _onSelectLeft(MatchPairItem item) {
    if (_matchedHangul.contains(item.hangul)) return;
    ref.read(audioServiceProvider).speakKorean(item.sound);

    setState(() {
      _selectedHangul = item.hangul;
      _hasErrorFlash = false;
    });
    _checkMatch();
  }

  void _onSelectRight(MatchPairItem item) {
    if (_matchedHangul.contains(item.hangul)) return;
    setState(() {
      _selectedRomanHangulKey = item.hangul;
      _hasErrorFlash = false;
    });
    _checkMatch();
  }

  void _checkMatch() {
    if (_selectedHangul == null || _selectedRomanHangulKey == null) return;
    _moves++;

    if (_selectedHangul == _selectedRomanHangulKey) {
      final isClearingMove = _matchedHangul.length + 1 == _leftHangul.length;
      setState(() {
        _matchedHangul.add(_selectedHangul!);
        _selectedHangul = null;
        _selectedRomanHangulKey = null;
      });
      if (isClearingMove) {
        ref.read(progressProvider.notifier).awardPracticeXp(
              15,
              badgeId: 'badge_speed_matcher',
            );
      }
    } else {
      setState(() {
        _hasErrorFlash = true;
        _selectedHangul = null;
        _selectedRomanHangulKey = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allCleared = _matchedHangul.length == _leftHangul.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Speed Match'),
        actions: [
          IconButton(
            tooltip: 'New Board',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _startNewRound,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Matched: ${_matchedHangul.length} / ${_leftHangul.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'Moves: $_moves',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            if (_hasErrorFlash) ...[
              const SizedBox(height: 8),
              const Text(
                'Not a match! Try another pair',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (allCleared)
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.success, width: 2),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox.shrink(),
                        const SizedBox(height: 12),
                        const Text(
                          'Board Cleared!',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        Text('You matched all 6 pairs in $_moves moves!'),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _startNewRound,
                          icon: const Icon(Icons.replay_rounded),
                          label: const Text('Play Another Round'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: Row(
                  children: [
                    // Left column: Hangul characters
                    Expanded(
                      child: ListView.separated(
                        itemCount: _leftHangul.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, idx) {
                          final item = _leftHangul[idx];
                          final isMatched = _matchedHangul.contains(item.hangul);
                          final isSelected = _selectedHangul == item.hangul;

                          return InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: isMatched ? null : () => _onSelectLeft(item),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 64,
                              decoration: BoxDecoration(
                                color: isMatched
                                    ? AppColors.success.withOpacity(0.12)
                                    : (isSelected
                                        ? AppColors.primary
                                        : theme.cardTheme.color),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isMatched
                                      ? AppColors.success
                                      : (isSelected
                                          ? AppColors.primary
                                          : AppColors.lightCardBorder),
                                  width: 2,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                item.hangul,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: isMatched
                                      ? AppColors.success
                                      : (isSelected ? Colors.white : AppColors.primary),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Right column: Romanization / Meaning
                    Expanded(
                      child: ListView.separated(
                        itemCount: _rightRoman.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, idx) {
                          final item = _rightRoman[idx];
                          final isMatched = _matchedHangul.contains(item.hangul);
                          final isSelected = _selectedRomanHangulKey == item.hangul;

                          return InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: isMatched ? null : () => _onSelectRight(item),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 64,
                              decoration: BoxDecoration(
                                color: isMatched
                                    ? AppColors.success.withOpacity(0.12)
                                    : (isSelected
                                        ? AppColors.secondary
                                        : theme.cardTheme.color),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isMatched
                                      ? AppColors.success
                                      : (isSelected
                                          ? AppColors.secondary
                                          : AppColors.lightCardBorder),
                                  width: 2,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                item.romanization,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: isMatched
                                      ? AppColors.success
                                      : (isSelected ? Colors.white : AppColors.secondary),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
