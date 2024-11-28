import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ninte/presentation/theme/app_colors.dart';

class PersonalSupportPage extends StatefulWidget {
  const PersonalSupportPage({super.key});

  @override
  State<PersonalSupportPage> createState() => _PersonalSupportPageState();
}

class _PersonalSupportPageState extends State<PersonalSupportPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _issueController = TextEditingController();
  final _contactController = TextEditingController();
  bool _isSubmitting = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _issueController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppColors.withTheme(
      builder: (context, theme) => Scaffold(
        backgroundColor: theme.background,
        appBar: AppBar(
          backgroundColor: theme.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Personal Support',
            style: TextStyle(color: theme.textPrimary),
          ),
        ),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section with Animation
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -0.1),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.easeOut,
                      )),
                      child: FadeTransition(
                        opacity: _animationController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Share Your Concerns',
                              style: TextStyle(
                                color: theme.textPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'This is a safe space. Your message will be handled with complete confidentiality.',
                              style: TextStyle(
                                color: theme.textSecondary,
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Form Fields with Animation
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.easeOut,
                      )),
                      child: FadeTransition(
                        opacity: _animationController,
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: theme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.surfaceLight.withOpacity(0.1),
                                ),
                              ),
                              child: TextFormField(
                                controller: _issueController,
                                maxLines: 5,
                                style: TextStyle(color: theme.textPrimary),
                                decoration: InputDecoration(
                                  labelText: 'What\'s on your mind?',
                                  hintText: 'Share your thoughts, problems, or concerns...',
                                  alignLabelWithHint: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Please share your thoughts';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              decoration: BoxDecoration(
                                color: theme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.surfaceLight.withOpacity(0.1),
                                ),
                              ),
                              child: TextFormField(
                                controller: _contactController,
                                style: TextStyle(color: theme.textPrimary),
                                decoration: InputDecoration(
                                  labelText: 'How can we reach you? (Optional)',
                                  hintText: 'Email or phone number',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button with Animation
                    ScaleTransition(
                      scale: CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.easeOut,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _isSubmitting
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: theme.accent,
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: _submitIssue,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.accent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Submit',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitIssue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    try {
      // TODO: Implement submission to backend
      await Future.delayed(const Duration(seconds: 2)); // Simulate network request

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for sharing. We\'ll look into this.'),
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
} 