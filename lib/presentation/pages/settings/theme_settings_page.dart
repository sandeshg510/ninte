import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/presentation/theme/app_theme.dart';
import 'package:ninte/presentation/theme/app_theme_data.dart';
import 'package:ninte/presentation/theme/theme_cubit.dart';
import 'package:ninte/presentation/widgets/gradient_button.dart';
import 'package:ninte/presentation/routes/page_transitions.dart';
import 'package:ninte/presentation/widgets/custom_text_field.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> with SingleTickerProviderStateMixin {
  bool _showLightThemes = false;
  late PageController _pageController;
  late AnimationController _previewController;
  late Animation<double> _previewScale;

  final Map<String, List<ThemeType>> darkThemeCategories = {
    'Elegant Dark': [
      ThemeType.midnight,
      ThemeType.eclipse,
      ThemeType.obsidian,
    ],
    'Nature Inspired': [
      ThemeType.aurora,
      ThemeType.forest,
      ThemeType.ocean,
    ],
    'Vibrant Dark': [
      ThemeType.sunset,
      ThemeType.ruby,
      ThemeType.neon,
    ],
    'Mystic': [
      ThemeType.cosmic,
      ThemeType.amethyst,
      ThemeType.lavender,
    ],
  };

  final Map<String, List<ThemeType>> lightThemeCategories = {
    'Clean & Modern': [
      ThemeType.pearl,
      ThemeType.porcelain,
      ThemeType.crystal,
    ],
    'Warm & Cozy': [
      ThemeType.vanilla,
      ThemeType.champagne,
      ThemeType.cotton,
    ],
    'Fresh & Bright': [
      ThemeType.glacier,
      ThemeType.mint,
      ThemeType.moonlight,
    ],
    'Soft & Elegant': [
      ThemeType.rose,
      ThemeType.cotton,
      ThemeType.crystal,
    ],
  };

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _previewController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _previewScale = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _previewController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _previewController.dispose();
    super.dispose();
  }

  void _switchThemeMode(bool showLight) {
    setState(() => _showLightThemes = showLight);
    _pageController.animateToPage(
      showLight ? 1 : 0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppColors.withTheme(
      builder: (context, theme) => Scaffold(
        backgroundColor: theme.background,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: theme.surface,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Personalize Your Theme',
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(
                      painter: ThemeBackgroundPainter(
                        accent: theme.accent,
                        accentLight: theme.accentLight,
                        accentSecondary: theme.accentSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                color: theme.textPrimary,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            _showLightThemes 
                                ? 'Light Themes'
                                : 'Dark Themes',
                            key: ValueKey(_showLightThemes),
                            style: TextStyle(
                              color: theme.accent,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildThemeModeSwitch(theme),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _showLightThemes 
                            ? 'Swipe right for dark themes'
                            : 'Swipe left for light themes',
                        key: ValueKey(_showLightThemes),
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _showLightThemes = index == 1);
            },
            children: [
              _buildThemeList(darkThemeCategories, theme),
              _buildThemeList(lightThemeCategories, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeList(Map<String, List<ThemeType>> categories, AppThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories.keys.elementAt(index);
        final themes = categories[category]!;
        
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: TextStyle(
                  color: theme.accent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: themes.length,
                itemBuilder: (context, index) {
                  final type = themes[index];
                  return BlocBuilder<ThemeCubit, ThemeState>(
                    builder: (context, state) {
                      return _buildThemeCard(
                        context,
                        type,
                        type == state.type,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeModeSwitch(AppThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.surfaceLight.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModeSwitchButton(
            icon: Icons.dark_mode_rounded,
            label: 'Dark',
            isSelected: !_showLightThemes,
            theme: theme,
            onTap: () {
              setState(() => _showLightThemes = false);
              _pageController.animateToPage(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
          _buildModeSwitchButton(
            icon: Icons.light_mode_rounded,
            label: 'Light',
            isSelected: _showLightThemes,
            theme: theme,
            onTap: () {
              setState(() => _showLightThemes = true);
              _pageController.animateToPage(
                1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModeSwitchButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required AppThemeData theme,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? theme.accent.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? theme.accent : theme.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? theme.accent : theme.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(
    BuildContext context,
    ThemeType type,
    bool isSelected,
  ) {
    return AppColors.withTheme(
      builder: (context, theme) {
        final themeData = AppTheme.themes[type]!;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: themeData.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? themeData.accent : themeData.surfaceLight.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: themeData.accent.withOpacity(isSelected ? 0.2 : 0),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showThemePreview(context, type, themeData),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildThemePreview(themeData),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                themeData.name,
                                style: TextStyle(
                                  color: themeData.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: themeData.tags.take(2).map((tag) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: themeData.accent.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      tag.name.toUpperCase(),
                                      style: TextStyle(
                                        color: themeData.accent,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: themeData.accent.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: themeData.accent,
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
      },
    );
  }

  Widget _buildThemePreview(AppThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mock Status Bar
          Container(
            height: 20,
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.only(bottom: 8),
          ),
          // Mock Button
          Container(
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.accent, theme.accentLight],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          // Mock Card
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: theme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: theme.accent,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 8,
                        width: 60,
                        decoration: BoxDecoration(
                          color: theme.textPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 6,
                        width: 40,
                        decoration: BoxDecoration(
                          color: theme.textSecondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorDot(Color color) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  void _showThemePreview(
    BuildContext context,
    ThemeType type,
    AppThemeData themeData,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ThemePreviewModal(
        type: type,
        themeData: themeData,
      ),
    );
  }

  // Add ripple effect when theme changes
  Widget _buildRippleEffect(AppThemeData theme) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                theme.accent.withOpacity(0.2 * (1 - value)),
                theme.accent.withOpacity(0.0),
              ],
              radius: value * 2,
            ),
          ),
        );
      },
    );
  }

  // Add theme change animation
  void _applyTheme(BuildContext context, ThemeType type) {
    // Apply theme with a subtle fade
    context.read<ThemeCubit>().changeTheme(type);
    
    // Navigate back with fade transition
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/home',
      (route) => false,
    );
  }
}

// Add new stateful widget for the modal to handle animation state
class _ThemePreviewModal extends StatefulWidget {
  final ThemeType type;
  final AppThemeData themeData;

  const _ThemePreviewModal({
    required this.type,
    required this.themeData,
  });

  @override
  State<_ThemePreviewModal> createState() => _ThemePreviewModalState();
}

class _ThemePreviewModalState extends State<_ThemePreviewModal> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _applyTheme() async {
    setState(() => _isApplying = true);
    _controller.forward();

    // Add haptic feedback
    HapticFeedback.mediumImpact();

    // Apply theme with animation
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (!mounted) return;
    
    // Apply theme
    context.read<ThemeCubit>().changeTheme(widget.type);
    
    // Navigate back to home
    Navigator.pop(context);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: widget.themeData.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: widget.themeData.textSecondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.themeData.name,
                    style: TextStyle(
                      color: widget.themeData.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Theme Preview Components
                  _buildPreviewSection(
                    'Colors',
                    widget.themeData,
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildColorPreview('Accent', widget.themeData.accent),
                        _buildColorPreview('Light', widget.themeData.accentLight),
                        _buildColorPreview('Secondary', widget.themeData.accentSecondary),
                        _buildColorPreview('Background', widget.themeData.background),
                        _buildColorPreview('Surface', widget.themeData.surface),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildPreviewSection(
                    'Typography',
                    widget.themeData,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Primary Text',
                          style: TextStyle(
                            color: widget.themeData.textPrimary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Secondary Text',
                          style: TextStyle(
                            color: widget.themeData.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tertiary Text',
                          style: TextStyle(
                            color: widget.themeData.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildPreviewSection(
                    'Components',
                    widget.themeData,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: widget.themeData.surface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: widget.themeData.accent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.star_rounded,
                                  color: widget.themeData.accent,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sample Card',
                                      style: TextStyle(
                                        color: widget.themeData.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Preview of card component',
                                      style: TextStyle(
                                        color: widget.themeData.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [widget.themeData.accent, widget.themeData.accentLight],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Gradient Button',
                            style: TextStyle(
                              color: widget.themeData.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: _isApplying ? null : () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: widget.themeData.textSecondary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AnimatedBuilder(
                            animation: _scaleAnimation,
                            builder: (context, child) => Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: widget.themeData.accent.withOpacity(0.3),
                                      blurRadius: _isApplying ? 16 : 0,
                                      spreadRadius: _isApplying ? 2 : 0,
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _isApplying ? null : _applyTheme,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: widget.themeData.accent,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isApplying
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              widget.themeData.textPrimary,
                                            ),
                                          ),
                                        )
                                      : Text(
                                          'Apply Theme',
                                          style: TextStyle(
                                            color: widget.themeData.textPrimary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildPreviewSection(
  String title,
  AppThemeData themeData, {
  required Widget child,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          color: themeData.accent,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 16),
      child,
    ],
  );
}

Widget _buildColorPreview(String label, Color color) {
  return Column(
    children: [
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
        ),
      ),
    ],
  );
}

Widget _buildAppPreview(AppThemeData themeData) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'App Preview',
        style: TextStyle(
          color: themeData.accent,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 16),
      // Custom Text Field Preview
      CustomTextField(
        controller: TextEditingController(),
        label: 'Sample Input',
      ),
      const SizedBox(height: 16),
      // Gradient Button Preview
      GradientButton(
        text: 'Sample Button',
        onPressed: () {},
      ),
      const SizedBox(height: 16),
      // Card Preview with our app's style
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeData.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: themeData.surfaceLight.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: themeData.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.star_rounded,
                color: themeData.accent,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sample Card',
                    style: TextStyle(
                      color: themeData.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Preview with app style',
                    style: TextStyle(
                      color: themeData.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildFloatingCircle(Color color, double size) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withOpacity(0.2),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.1),
          blurRadius: 8,
          spreadRadius: 2,
        ),
      ],
    ),
  );
}

// Custom painter for the background pattern
class ThemeBackgroundPainter extends CustomPainter {
  final Color accent;
  final Color accentLight;
  final Color accentSecondary;

  ThemeBackgroundPainter({
    required this.accent,
    required this.accentLight,
    required this.accentSecondary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw geometric patterns
    final path = Path();
    
    // Draw diagonal lines
    for (var i = 0; i < size.width + size.height; i += 40) {
      paint.color = accent.withOpacity(0.1);
      path.moveTo(i.toDouble(), 0);
      path.lineTo(0, i.toDouble());
      canvas.drawPath(path, paint);
      path.reset();
    }

    // Draw circles
    paint.style = PaintingStyle.fill;
    for (var i = 0; i < size.width; i += 60) {
      for (var j = 0; j < size.height; j += 60) {
        paint.color = accentLight.withOpacity(0.05);
        canvas.drawCircle(Offset(i.toDouble(), j.toDouble()), 4, paint);
      }
    }

    // Draw curved lines
    paint.style = PaintingStyle.stroke;
    paint.color = accentSecondary.withOpacity(0.1);
    final curve = Path()
      ..moveTo(0, size.height * 0.4)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.2,
        size.width,
        size.height * 0.4,
      );
    canvas.drawPath(curve, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 