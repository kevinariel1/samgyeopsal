import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/app_providers.dart';

class HangulCharacterGuide {
  final String hangul;
  final String romanization;
  final String name;
  final String sound;
  final String category;

  const HangulCharacterGuide({
    required this.hangul,
    required this.romanization,
    required this.name,
    required this.sound,
    required this.category,
  });
}

class HangulGuideScreen extends ConsumerStatefulWidget {
  const HangulGuideScreen({super.key});

  @override
  ConsumerState<HangulGuideScreen> createState() => _HangulGuideScreenState();
}

class _HangulGuideScreenState extends ConsumerState<HangulGuideScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const List<HangulCharacterGuide> basicConsonants = [
    HangulCharacterGuide(hangul: 'ㄱ', romanization: 'g / k', name: 'Giyeok (기역)', sound: '그', category: 'Basic Consonant'),
    HangulCharacterGuide(hangul: 'ㄴ', romanization: 'n', name: 'Nieun (니은)', sound: '느', category: 'Basic Consonant'),
    HangulCharacterGuide(hangul: 'ㄷ', romanization: 'd / t', name: 'Digeut (디귿)', sound: '드', category: 'Basic Consonant'),
    HangulCharacterGuide(hangul: 'ㄹ', romanization: 'r / l', name: 'Rieul (리을)', sound: '르', category: 'Basic Consonant'),
    HangulCharacterGuide(hangul: 'ㅁ', romanization: 'm', name: 'Mieum (미음)', sound: '므', category: 'Basic Consonant'),
    HangulCharacterGuide(hangul: 'ㅂ', romanization: 'b / p', name: 'Bieup (비읍)', sound: '브', category: 'Basic Consonant'),
    HangulCharacterGuide(hangul: 'ㅅ', romanization: 's', name: 'Siot (시옷)', sound: '스', category: 'Basic Consonant'),
    HangulCharacterGuide(hangul: 'ㅇ', romanization: 'silent / ng', name: 'Ieung (이응)', sound: '응', category: 'Basic Consonant'),
    HangulCharacterGuide(hangul: 'ㅈ', romanization: 'j', name: 'Jieut (지읒)', sound: '즈', category: 'Basic Consonant'),
    HangulCharacterGuide(hangul: 'ㅊ', romanization: 'ch', name: 'Chieut (치읓)', sound: '츠', category: 'Basic Consonant'),
    HangulCharacterGuide(hangul: 'ㅋ', romanization: 'k', name: 'Kieuk (키읔)', sound: '크', category: 'Basic Consonant'),
    HangulCharacterGuide(hangul: 'ㅌ', romanization: 't', name: 'Tieut (티읕)', sound: '트', category: 'Basic Consonant'),
    HangulCharacterGuide(hangul: 'ㅍ', romanization: 'p', name: 'Pieup (피vp)', sound: '프', category: 'Basic Consonant'),
    HangulCharacterGuide(hangul: 'ㅎ', romanization: 'h', name: 'Hieut (히읗)', sound: '흐', category: 'Basic Consonant'),
  ];

  static const List<HangulCharacterGuide> doubleConsonants = [
    HangulCharacterGuide(hangul: 'ㄲ', romanization: 'kk', name: 'Ssang-giyeok (쌍기역)', sound: '끄', category: 'Double Consonant'),
    HangulCharacterGuide(hangul: 'ㄸ', romanization: 'tt', name: 'Ssang-digeut (쌍디귿)', sound: '뜨', category: 'Double Consonant'),
    HangulCharacterGuide(hangul: 'ㅃ', romanization: 'pp', name: 'Ssang-bieup (쌍비읍)', sound: '쁘', category: 'Double Consonant'),
    HangulCharacterGuide(hangul: 'ㅆ', romanization: 'ss', name: 'Ssang-siot (쌍시옷)', sound: '쓰', category: 'Double Consonant'),
    HangulCharacterGuide(hangul: 'ㅉ', romanization: 'jj', name: 'Ssang-jieut (쌍지읒)', sound: '쯔', category: 'Double Consonant'),
  ];

  static const List<HangulCharacterGuide> basicVowels = [
    HangulCharacterGuide(hangul: 'ㅏ', romanization: 'a', name: 'Ah', sound: '아', category: 'Basic Vowel'),
    HangulCharacterGuide(hangul: 'ㅑ', romanization: 'ya', name: 'Yah', sound: '야', category: 'Basic Vowel'),
    HangulCharacterGuide(hangul: 'ㅓ', romanization: 'eo', name: 'Uh', sound: '어', category: 'Basic Vowel'),
    HangulCharacterGuide(hangul: 'ㅕ', romanization: 'yeo', name: 'Yeo', sound: '여', category: 'Basic Vowel'),
    HangulCharacterGuide(hangul: 'ㅗ', romanization: 'o', name: 'Oh', sound: '오', category: 'Basic Vowel'),
    HangulCharacterGuide(hangul: 'ㅛ', romanization: 'yo', name: 'Yoh', sound: '요', category: 'Basic Vowel'),
    HangulCharacterGuide(hangul: 'ㅜ', romanization: 'u', name: 'Oo', sound: '우', category: 'Basic Vowel'),
    HangulCharacterGuide(hangul: 'ㅠ', romanization: 'yu', name: 'Yoo', sound: '유', category: 'Basic Vowel'),
    HangulCharacterGuide(hangul: 'ㅡ', romanization: 'eu', name: 'Eu', sound: '으', category: 'Basic Vowel'),
    HangulCharacterGuide(hangul: 'ㅣ', romanization: 'i', name: 'Ee', sound: '이', category: 'Basic Vowel'),
  ];

  static const List<HangulCharacterGuide> compoundVowels = [
    HangulCharacterGuide(hangul: 'ㅐ', romanization: 'ae', name: 'Ae (eh)', sound: '애', category: 'Compound Vowel'),
    HangulCharacterGuide(hangul: 'ㅒ', romanization: 'yae', name: 'Yae', sound: '얘', category: 'Compound Vowel'),
    HangulCharacterGuide(hangul: 'ㅔ', romanization: 'e', name: 'Eh', sound: '에', category: 'Compound Vowel'),
    HangulCharacterGuide(hangul: 'ㅖ', romanization: 'ye', name: 'Yeh', sound: '예', category: 'Compound Vowel'),
    HangulCharacterGuide(hangul: 'ㅘ', romanization: 'wa', name: 'Wa', sound: '와', category: 'Compound Vowel'),
    HangulCharacterGuide(hangul: 'ㅙ', romanization: 'wae', name: 'Wae', sound: '왜', category: 'Compound Vowel'),
    HangulCharacterGuide(hangul: 'ㅚ', romanization: 'oe (we)', name: 'Oe / We', sound: '외', category: 'Compound Vowel'),
    HangulCharacterGuide(hangul: 'ㅝ', romanization: 'wo', name: 'Wo', sound: '워', category: 'Compound Vowel'),
    HangulCharacterGuide(hangul: 'ㅞ', romanization: 'we', name: 'We', sound: '웨', category: 'Compound Vowel'),
    HangulCharacterGuide(hangul: 'ㅟ', romanization: 'wi', name: 'Wi (Wee)', sound: '위', category: 'Compound Vowel'),
    HangulCharacterGuide(hangul: 'ㅢ', romanization: 'ui', name: 'Ui', sound: '의', category: 'Compound Vowel'),
  ];

  static const List<String> matrixConsonants = [
    'ㄱ', 'ㄴ', 'ㄷ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅅ', 'ㅇ', 'ㅈ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ'
  ];
  static const List<String> matrixVowels = ['ㅏ', 'ㅑ', 'ㅓ', 'ㅕ', 'ㅗ', 'ㅛ', 'ㅜ', 'ㅠ', 'ㅡ', 'ㅣ'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _speak(String text) {
    ref.read(audioServiceProvider).speakKorean(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hangul Alphabet Guide'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: theme.hintColor,
          tabs: const [
            Tab(icon: Icon(Icons.border_all_rounded), text: 'Consonants (19)'),
            Tab(icon: Icon(Icons.text_fields_rounded), text: 'Vowels (21)'),
            Tab(icon: Icon(Icons.grid_on_rounded), text: 'Syllables Matrix'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConsonantsTab(theme),
          _buildVowelsTab(theme),
          _buildMatrixTab(theme),
        ],
      ),
    );
  }

  Widget _buildConsonantsTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader(
          title: 'Basic Consonants (14)',
          subtitle: 'The primary building blocks of Korean',
          count: '14',
          color: AppColors.primary,
        ),
        const SizedBox(height: 12),
        _buildCharacterGrid(basicConsonants, theme),
        const SizedBox(height: 28),
        _buildSectionHeader(
          title: 'Double Consonants (5)',
          subtitle: 'Tense, twin letters with crisp pronunciation',
          count: '5',
          color: AppColors.secondary,
        ),
        const SizedBox(height: 12),
        _buildCharacterGrid(doubleConsonants, theme),
      ],
    );
  }

  Widget _buildVowelsTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader(
          title: 'Basic Vowels (10)',
          subtitle: 'The foundation: Sky (•), Earth (ㅡ), and Person (ㅣ)',
          count: '10',
          color: AppColors.primary,
        ),
        const SizedBox(height: 12),
        _buildCharacterGrid(basicVowels, theme),
        const SizedBox(height: 28),
        _buildSectionHeader(
          title: 'Compound Vowels (11)',
          subtitle: 'Glides and combinations with Y, W, and E sounds',
          count: '11',
          color: AppColors.accentPurple,
        ),
        const SizedBox(height: 12),
        _buildCharacterGrid(compoundVowels, theme),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required String count,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCharacterGrid(List<HangulCharacterGuide> items, ThemeData theme) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.88,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildCharacterTile(item, theme);
      },
    );
  }

  Widget _buildCharacterTile(HangulCharacterGuide item, ThemeData theme) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _speak(item.sound),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.lightCardBorder, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              item.hangul,
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                item.romanization,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.secondary,
                ),
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                item.name,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: theme.hintColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatrixTab(ThemeData theme) {
    // Generate syllables combining matrixConsonants and matrixVowels:
    // Unicode formula: 0xAC00 + (consonantIndex * 21 * 28) + (vowelIndex * 28)
    const int baseUnicode = 0xAC00;
    const List<int> vowelIndices = [0, 2, 4, 6, 8, 12, 13, 17, 18, 20]; // ㅏ, ㅑ, ㅓ, ㅕ, ㅗ, ㅛ, ㅜ, ㅠ, ㅡ, ㅣ

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: AppColors.primaryContainer.withOpacity(0.4),
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tap any syllable block to hear it pronounced! Scroll horizontally or vertically.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16),
              child: Table(
                defaultColumnWidth: const FixedColumnWidth(54),
                border: TableBorder.all(
                  color: theme.dividerColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                children: [
                  // Header Row with vowels
                  TableRow(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                    ),
                    children: [
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            'C / V',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      ...matrixVowels.map(
                        (v) => Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              v,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Matrix rows for each consonant
                  for (int cIdx = 0; cIdx < matrixConsonants.length; cIdx++)
                    TableRow(
                      children: [
                        // Row header (Consonant)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              matrixConsonants[cIdx],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ),
                        // Syllable cells
                        for (int vIdx = 0; vIdx < matrixVowels.length; vIdx++) ...[
                          Builder(
                            builder: (context) {
                              final int unicode = baseUnicode +
                                  (cIdx * 21 * 28) +
                                  (vowelIndices[vIdx] * 28);
                              final String syllable = String.fromCharCode(unicode);

                              return InkWell(
                                onTap: () => _speak(syllable),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  alignment: Alignment.center,
                                  child: Text(
                                    syllable,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
