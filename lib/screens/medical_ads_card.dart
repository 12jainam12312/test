import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MedicalAdsCard extends StatelessWidget {
  const MedicalAdsCard({super.key});

  final List<Map<String, dynamic>> _medicalAds = const [
    {
      'title': 'Apollo Pharmacy',
      'subtitle': 'Up to 25% off on medicines',
      'description': 'Fast delivery • Genuine medicines',
      'discount': '25% OFF',
      'image': 'assets/apollo_logo.png', // Add this asset
      'color': Color(0xFF00A651),
      'url': 'https://www.apollopharmacy.in/',
    },
    {
      'title': 'Netmeds',
      'subtitle': 'Free home delivery',
      'description': 'Order medicines online',
      'discount': 'FREE DELIVERY',
      'image': 'assets/netmeds_logo.png', // Add this asset
      'color': Color(0xFF00B4D8),
      'url': 'https://www.netmeds.com/',
    },
    {
      'title': '1mg',
      'subtitle': 'Health checkups from ₹99',
      'description': 'Lab tests at your doorstep',
      'discount': 'FROM ₹99',
      'image': 'assets/1mg_logo.png', // Add this asset
      'color': Color(0xFFFF6B35),
      'url': 'https://www.1mg.com/',
    },
  ];

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _medicalAds.length,
        itemBuilder: (context, index) {
          final ad = _medicalAds[index];
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ad['color'].withOpacity(0.1),
                  ad['color'].withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ad['color'].withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: ad['color'].withOpacity(0.1),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _launchURL(ad['url']),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: ad['color'].withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.local_pharmacy,
                              color: ad['color'],
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ad['title'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  ad['subtitle'],
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: ad['color'],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              ad['discount'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        ad['description'],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            'Shop Now',
                            style: TextStyle(
                              color: ad['color'],
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: ad['color'],
                            size: 16,
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
      ),
    );
  }
}