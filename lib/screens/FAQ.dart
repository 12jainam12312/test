import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/animated_card.dart';
import '../widgets/animated_button.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});


  @override
  Widget build(BuildContext context) {
    final l10n=AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    
  final faqs = [
  {'question': l10n.faqQ1, 'answer': l10n.faqA1},
  {'question': l10n.faqQ2, 'answer': l10n.faqA2},
  {'question': l10n.faqQ3, 'answer': l10n.faqA3},
  {'question': l10n.faqQ4, 'answer': l10n.faqA4},
  ];
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: themeProvider.textColor),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                children: [
                  Text(
                    l10n.faqTitle,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.faqSubtitle,
                    style: TextStyle(fontSize: 16, color: themeProvider.secondaryTextColor),
                  ),
                  const SizedBox(height: 28),
                  ...faqs.map((faq) => _buildFAQCard(faq, themeProvider)).toList(),
                  const SizedBox(height: 100),
                ],
              ),
            ),

            // Sticky Bottom Buttons
            Container(
              color: themeProvider.backgroundColor,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: AnimatedButton(
                      text: l10n.readAllFAQ,
                      onPressed: () {
                        // Read all FAQ action
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AnimatedButton(
                      text: l10n.contactUs,
                      onPressed: () {
                        // Contact action
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

  Widget _buildFAQCard(Map<String, String> faq, ThemeProvider themeProvider) {
    return AnimatedCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            faq['question']!,
            style: TextStyle(
              color: themeProvider.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            faq['answer']!,
            style: TextStyle(
              color: themeProvider.secondaryTextColor,
              fontSize: 15,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
