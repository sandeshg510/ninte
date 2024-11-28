import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ninte/presentation/theme/app_colors.dart';

class PersonalSupportPage extends StatefulWidget {
  const PersonalSupportPage({super.key});

  @override
  State<PersonalSupportPage> createState() => _PersonalSupportPageState();
}

class _PersonalSupportPageState extends State<PersonalSupportPage> {
  final _formKey = GlobalKey<FormState>();
  final _issueController = TextEditingController();
  final _contactController = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return AppColors.withTheme(
      builder: (context, theme) => Container(
        decoration: BoxDecoration(
          color: theme.background,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Text(
                'Personal Support',
                style: TextStyle(color: theme.textPrimary),
              ),
              leading: IconButton(
                icon: Icon(Icons.close, color: theme.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Share Your Concerns',
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This is a safe space. Your message will be handled with complete confidentiality.',
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _issueController,
                      maxLines: 5,
                      style: TextStyle(color: theme.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'What\'s on your mind?',
                        hintText: 'Share your thoughts, problems, or concerns...',
                        alignLabelWithHint: true,
                        fillColor: theme.surface,
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please share your thoughts';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contactController,
                      style: TextStyle(color: theme.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'How can we reach you? (Optional)',
                        hintText: 'Email or phone number',
                        fillColor: theme.surface,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
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
                                  padding: const EdgeInsets.all(16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Submit'),
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

  @override
  void dispose() {
    _issueController.dispose();
    _contactController.dispose();
    super.dispose();
  }
} 