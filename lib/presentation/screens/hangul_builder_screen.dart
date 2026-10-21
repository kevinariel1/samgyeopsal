import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/app_providers.dart';

class JamoChoice {
  final String jamo;
  final String romanization;
  final int unicodeIndex;

  const JamoChoice({
    required this.jamo,
    required this.romanization,
    required this.unicodeIndex,
  });
}

class SyllableChallenge {
  final String targetSyllable;
  final String romanization;
  final String meaningHint;
  final int chosungIdx;
  final int jungsungIdx;
  final int jongsungIdx;

  const SyllableChallenge({
    required this.targetSyllable,
    required this.romanization,
    required this.meaningHint,
    required this.chosungIdx,
    required this.jungsungIdx,
    required this.jongsungIdx,
  });
}

class HangulBuilderScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const HangulBuilderScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  ConsumerState<HangulBuilderScreen> createState() => _HangulBuilderScreenState();
}

class _HangulBuilderScreenState extends ConsumerState<HangulBuilderScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Sandbox selections (index into chosungList, jungsungList, jongsungList)
  int _selectedChosungListIdx = 0; // ㄱ
  int _selectedJungsungListIdx = 0; // ㅏ
  int _selectedJongsungListIdx = 0; // None

  // Challenge Mode state
  int _challengeIdx = 0;
  int _challengeChosungListIdx = 7; // ㅇ
  int _challengeJungsungListIdx = 0; // ㅏ
  int _challengeJongsungListIdx = 0; // None
  bool _challengeSolved = false;
  String? _challengeFeedback;
  int _score = 0;

  // Standard Unicode Hangul Jamo tables
  // 0xAC00 + (chosungUnicodeIdx * 21 * 28) + (jungsungUnicodeIdx * 28) + jongsungUnicodeIdx
  static const List<JamoChoice> chosungList = [
    JamoChoice(jamo: 'ㄱ', romanization: 'g/k', unicodeIndex: 0),
    JamoChoice(jamo: 'ㄴ', romanization: 'n', unicodeIndex: 2),
    JamoChoice(jamo: 'ㄷ', romanization: 'd/t', unicodeIndex: 3),
    JamoChoice(jamo: 'ㄹ', romanization: 'r/l', unicodeIndex: 5),
    JamoChoice(jamo: 'ㅁ', romanization: 'm', unicodeIndex: 6),
    JamoChoice(jamo: 'ㅂ', romanization: 'b/p', unicodeIndex: 7),
    JamoChoice(jamo: 'ㅅ', romanization: 's', unicodeIndex: 9),
    JamoChoice(jamo: 'ㅇ', romanization: 'silent', unicodeIndex: 11),
    JamoChoice(jamo: 'ㅈ', romanization: 'j', unicodeIndex: 12),
    JamoChoice(jamo: 'ㅊ', romanization: 'ch', unicodeIndex: 14),
    JamoChoice(jamo: 'ㅋ', romanization: 'k', unicodeIndex: 15),
    JamoChoice(jamo: 'ㅌ', romanization: 't', unicodeIndex: 16),
    JamoChoice(jamo: 'ㅍ', romanization: 'p', unicodeIndex: 17),
    JamoChoice(jamo: 'ㅎ', romanization: 'h', unicodeIndex: 18),
    JamoChoice(jamo: 'ㄲ', romanization: 'kk', unicodeIndex: 1),
    JamoChoice(jamo: 'ㄸ', romanization: 'tt', unicodeIndex: 4),
    JamoChoice(jamo: 'ㅃ', romanization: 'pp', unicodeIndex: 8),
    JamoChoice(jamo: 'ㅆ', romanization: 'ss', unicodeIndex: 10),
    JamoChoice(jamo: 'ㅉ', romanization: 'jj', unicodeIndex: 13),
  ];

  static const List<JamoChoice> jungsungList = [
    JamoChoice(jamo: 'ㅏ', romanization: 'a', unicodeIndex: 0),
    JamoChoice(jamo: 'ㅓ', romanization: 'eo', unicodeIndex: 4),
    JamoChoice(jamo: 'ㅗ', romanization: 'o', unicodeIndex: 8),
    JamoChoice(jamo: 'ㅜ', romanization: 'u', unicodeIndex: 13),
    JamoChoice(jamo: 'ㅡ', romanization: 'eu', unicodeIndex: 18),
    JamoChoice(jamo: 'ㅣ', romanization: 'i', unicodeIndex: 20),
    JamoChoice(jamo: 'ㅑ', romanization: 'ya', unicodeIndex: 2),
    JamoChoice(jamo: 'ㅕ', romanization: 'yeo', unicodeIndex: 6),
    JamoChoice(jamo: 'ㅛ', romanization: 'yo', unicodeIndex: 12),
    JamoChoice(jamo: 'ㅠ', romanization: 'yu', unicodeIndex: 17),
    JamoChoice(jamo: 'ㅐ', romanization: 'ae', unicodeIndex: 1),
    JamoChoice(jamo: 'ㅔ', romanization: 'e', unicodeIndex: 5),
    JamoChoice(jamo: 'ㅘ', romanization: 'wa', unicodeIndex: 9),
    JamoChoice(jamo: 'ㅝ', romanization: 'wo', unicodeIndex: 14),
    JamoChoice(jamo: 'ㅟ', romanization: 'wi', unicodeIndex: 16),
    JamoChoice(jamo: 'ㅢ', romanization: 'ui', unicodeIndex: 19),
  ];

  static const List<JamoChoice> jongsungList = [
    JamoChoice(jamo: 'None', romanization: '-', unicodeIndex: 0),
    JamoChoice(jamo: 'ㄱ', romanization: '-k', unicodeIndex: 1),
    JamoChoice(jamo: 'ㄴ', romanization: '-n', unicodeIndex: 4),
    JamoChoice(jamo: 'ㄷ', romanization: '-t', unicodeIndex: 7),
    JamoChoice(jamo: 'ㄹ', romanization: '-l', unicodeIndex: 8),
    JamoChoice(jamo: 'ㅁ', romanization: '-m', unicodeIndex: 16),
    JamoChoice(jamo: 'ㅂ', romanization: '-p', unicodeIndex: 17),
    JamoChoice(jamo: 'ㅅ', romanization: '-t', unicodeIndex: 19),
    JamoChoice(jamo: 'ㅇ', romanization: '-ng', unicodeIndex: 21),
  ];

  static const Map<String, String> knownWords = {
    '가': 'Go! / Edge (가다 = To go)',
    '나': 'I / Me (Casual)',
    '다': 'All / Everything',
    '차': 'Tea  or Car',
    '코': 'Nose',
    '이': 'Tooth  or Number 2',
    '오': 'Number 5',
    '아이': 'Child',
    '개': 'Dog',
    '네': 'Yes! (Polite)',
    '와': 'Wow!',
    '위': 'Up / Above ⬆',
    '물': 'Water',
    '밥': 'Cooked Rice / Meal',
    '산': 'Mountain',
    '빵': 'Bread',
    '공': 'Ball  or Zero',
    '곰': 'Bear  (Like Baby Bear!)',
    '집': 'House / Home',
    '별': 'Star',
    '달': 'Moon',
    '밤': 'Night  or Chestnut',
    '눈': 'Eye  or Snow',
    '손': 'Hand',
    '발': 'Foot',
    '말': 'Horse  or Speech/Words',
    '불': 'Fire  or Light',
    '문': 'Door',
    '강': 'River',
    '방': 'Room',
  };

  static const List<SyllableChallenge> challenges = [
    SyllableChallenge(
      targetSyllable: '가',
      romanization: 'ga',
      meaningHint: 'Means "Go!" (ㄱ + ㅏ)',
      chosungIdx: 0,
      jungsungIdx: 0,
      jongsungIdx: 0,
    ),
    SyllableChallenge(
      targetSyllable: '나',
      romanization: 'na',
      meaningHint: 'Means "I / Me" (ㄴ + ㅏ)',
      chosungIdx: 1,
      jungsungIdx: 0,
      jongsungIdx: 0,
    ),
    SyllableChallenge(
      targetSyllable: '코',
      romanization: 'ko',
      meaningHint: 'Means "Nose"',
      chosungIdx: 10,
      jungsungIdx: 2,
      jongsungIdx: 0,
    ),
    SyllableChallenge(
      targetSyllable: '물',
      romanization: 'mul',
      meaningHint: 'Means "Water"  (Uses Batchim ㄹ!)',
      chosungIdx: 4,
      jungsungIdx: 3,
      jongsungIdx: 4,
    ),
    SyllableChallenge(
      targetSyllable: '밥',
      romanization: 'bap',
      meaningHint: 'Means "Cooked Rice"  (Uses Batchim ㅂ!)',
      chosungIdx: 5,
      jungsungIdx: 0,
      jongsungIdx: 6,
    ),
    SyllableChallenge(
      targetSyllable: '산',
      romanization: 'san',
      meaningHint: 'Means "Mountain"  (Uses Batchim ㄴ!)',
      chosungIdx: 6,
      jungsungIdx: 0,
      jongsungIdx: 2,
    ),
    SyllableChallenge(
      targetSyllable: '곰',
      romanization: 'gom',
      meaningHint: 'Means "Bear"  (ㄱ + ㅗ + ㅁ)',
      chosungIdx: 0,
      jungsungIdx: 2,
      jongsungIdx: 5,
    ),
    SyllableChallenge(
      targetSyllable: '빵',
      romanization: 'ppang',
      meaningHint: 'Means "Bread"  (Twin ㅃ + ㅏ + ㅇ)',
      chosungIdx: 16,
      jungsungIdx: 0,
      jongsungIdx: 8,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _composeSyllable(int cListIdx, int vListIdx, int bListIdx) {
    final c = chosungList[cListIdx].unicodeIndex;
    final v = jungsungList[vListIdx].unicodeIndex;
    final b = jongsungList[bListIdx].unicodeIndex;
    final code = 0xAC00 + (c * 21 * 28) + (v * 28) + b;
    return String.fromCharCode(code);
  }

  String _composeRomanization(int cListIdx, int vListIdx, int bListIdx) {
    final cRom = chosungList[cListIdx].romanization == 'silent'
        ? ''
        : chosungList[cListIdx].romanization.split('/').first;
    final vRom = jungsungList[vListIdx].romanization;
    final bRom = jongsungList[bListIdx].unicodeIndex == 0
        ? ''
        : jongsungList[bListIdx].romanization.replaceAll('-', '');
    return '$cRom$vRom$bRom';
  }

  void _speak(String text) {
    ref.read(audioServiceProvider).speakKorean(text);
  }

  void _checkChallenge() {
    final currentChallenge = challenges[_challengeIdx];
    final builtSyllable = _composeSyllable(
      _challengeChosungListIdx,
      _challengeJungsungListIdx,
      _challengeJongsungListIdx,
    );

    if (builtSyllable == currentChallenge.targetSyllable) {
      if (!_challengeSolved) {
        ref.read(progressProvider.notifier).awardPracticeXp(
              10,
              badgeId: 'badge_syllable_architect',
            );
      }
      setState(() {
        if (!_challengeSolved) {
          _score += 10;
        }
        _challengeSolved = true;
        _challengeFeedback =
            'Awesome! You built "${currentChallenge.targetSyllable}" (${currentChallenge.romanization})! (+10 XP)';
      });
      _speak(builtSyllable);
    } else {
      setState(() {
        _challengeFeedback =
            'You built "$builtSyllable", but we need "${currentChallenge.targetSyllable}"! Check your blocks';
      });
      _speak(builtSyllable);
    }
  }

  void _nextChallenge() {
    setState(() {
      _challengeIdx = (_challengeIdx + 1) % challenges.length;
      _challengeSolved = false;
      _challengeFeedback = null;
    });
    _speak(challenges[_challengeIdx].targetSyllable);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Build the Hangul'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: theme.hintColor,
          tabs: const [
            Tab(icon: Icon(Icons.extension_rounded), text: 'Syllable Workshop'),
            Tab(icon: Icon(Icons.flag_rounded), text: 'Puzzle Challenge'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWorkshopTab(theme),
          _buildChallengeTab(theme),
        ],
      ),
    );
  }

  Widget _buildWorkshopTab(ThemeData theme) {
    final syllable = _composeSyllable(
      _selectedChosungListIdx,
      _selectedJungsungListIdx,
      _selectedJongsungListIdx,
    );
    final romanization = _composeRomanization(
      _selectedChosungListIdx,
      _selectedJungsungListIdx,
      _selectedJongsungListIdx,
    );
    final cJamo = chosungList[_selectedChosungListIdx].jamo;
    final vJamo = jungsungList[_selectedJungsungListIdx].jamo;
    final bJamo = jongsungList[_selectedJongsungListIdx].jamo;
    final wordMeaning = knownWords[syllable];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Assembly Display Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.primaryContainer, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                // Formula equation row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFormulaChip(cJamo, '1. Consonant', AppColors.primary),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Text('+', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    _buildFormulaChip(vJamo, '2. Vowel', AppColors.secondary),
                    if (bJamo != 'None') ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text('+', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      _buildFormulaChip(bJamo, '3. Batchim', AppColors.accentPurple),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                // Giant Snapped Syllable
                GestureDetector(
                  onTap: () => _speak(syllable),
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 2),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          syllable,
                          style: const TextStyle(
                            fontSize: 76,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                            height: 1.0,
                          ),
                        ),
                        const Positioned(
                          bottom: 8,
                          right: 8,
                          child: Icon(
                            Icons.volume_up_rounded,
                            color: AppColors.secondary,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Sounds like: "$romanization"',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.secondary,
                  ),
                ),
                if (wordMeaning != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.accentYellow.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome_rounded, color: AppColors.starGold, size: 18),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Real Word: $wordMeaning',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildPickerSection(
            title: '1. Pick Initial Consonant (초성)',
            choices: chosungList,
            selectedIndex: _selectedChosungListIdx,
            activeColor: AppColors.primary,
            onSelect: (idx) {
              setState(() => _selectedChosungListIdx = idx);
              _speak(_composeSyllable(
                idx,
                _selectedJungsungListIdx,
                _selectedJongsungListIdx,
              ));
            },
          ),
          const SizedBox(height: 20),
          _buildPickerSection(
            title: '2. Pick Vowel (중성)',
            choices: jungsungList,
            selectedIndex: _selectedJungsungListIdx,
            activeColor: AppColors.secondary,
            onSelect: (idx) {
              setState(() => _selectedJungsungListIdx = idx);
              _speak(_composeSyllable(
                _selectedChosungListIdx,
                idx,
                _selectedJongsungListIdx,
              ));
            },
          ),
          const SizedBox(height: 20),
          _buildPickerSection(
            title: '3. Pick Bottom Batchim (종성 - Optional)',
            choices: jongsungList,
            selectedIndex: _selectedJongsungListIdx,
            activeColor: AppColors.accentPurple,
            onSelect: (idx) {
              setState(() => _selectedJongsungListIdx = idx);
              _speak(_composeSyllable(
                _selectedChosungListIdx,
                _selectedJungsungListIdx,
                idx,
              ));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeTab(ThemeData theme) {
    final challenge = challenges[_challengeIdx];
    final currentBuilt = _composeSyllable(
      _challengeChosungListIdx,
      _challengeJungsungListIdx,
      _challengeJongsungListIdx,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Challenge Prompt Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.secondaryContainer, width: 2),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Puzzle ${_challengeIdx + 1} of ${challenges.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.secondary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentYellow.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_score pts',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Build the block for "${challenge.romanization.toUpperCase()}"!',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  challenge.meaningHint,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _speak(challenge.targetSyllable),
                      icon: const Icon(Icons.volume_up_rounded),
                      label: const Text('Listen to Target'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        currentBuilt,
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_challengeFeedback != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (_challengeSolved ? AppColors.success : AppColors.error).withOpacity(0.14),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _challengeSolved ? AppColors.success : AppColors.error,
                ),
              ),
              child: Text(
                _challengeFeedback!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _challengeSolved ? AppColors.success : AppColors.error,
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          _buildPickerSection(
            title: '1. Initial Consonant',
            choices: chosungList,
            selectedIndex: _challengeChosungListIdx,
            activeColor: AppColors.primary,
            onSelect: (idx) => setState(() => _challengeChosungListIdx = idx),
          ),
          const SizedBox(height: 16),
          _buildPickerSection(
            title: '2. Vowel',
            choices: jungsungList,
            selectedIndex: _challengeJungsungListIdx,
            activeColor: AppColors.secondary,
            onSelect: (idx) => setState(() => _challengeJungsungListIdx = idx),
          ),
          const SizedBox(height: 16),
          _buildPickerSection(
            title: '3. Bottom Batchim',
            choices: jongsungList,
            selectedIndex: _challengeJongsungListIdx,
            activeColor: AppColors.accentPurple,
            onSelect: (idx) => setState(() => _challengeJongsungListIdx = idx),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _checkChallenge,
                  icon: const Icon(Icons.check_circle_rounded),
                  label: const Text('Snap & Check!'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (_challengeSolved) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _nextChallenge,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('Next Puzzle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormulaChip(String jamo, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text(
            jamo,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerSection({
    required String title,
    required List<JamoChoice> choices,
    required int selectedIndex,
    required Color activeColor,
    required ValueChanged<int> onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(choices.length, (idx) {
            final item = choices[idx];
            final isSelected = idx == selectedIndex;
            return InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => onSelect(idx),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? activeColor : activeColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? activeColor : activeColor.withOpacity(0.25),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.jamo,
                      style: TextStyle(
                        fontSize: item.jamo == 'None' ? 13 : 18,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? Colors.white : activeColor,
                      ),
                    ),
                    Text(
                      item.romanization,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white70 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
