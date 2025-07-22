import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/ayurvedic_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../widgets/animated_card.dart';
import '../widgets/animated_button.dart';
import '../widgets/auth_input_field.dart';

class AyurvedicSolutionsScreen extends StatefulWidget {
  const AyurvedicSolutionsScreen({super.key});

  @override
  State<AyurvedicSolutionsScreen> createState() => _AyurvedicSolutionsScreenState();
}

class _AyurvedicSolutionsScreenState extends State<AyurvedicSolutionsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final searchController = TextEditingController();
  List<AyurvedicSolution> approvedSolutions = [];
  List<AyurvedicSolution> userSolutions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    
    try {
      final approved = await AyurvedicService.getApprovedSolutions();
      final user = AuthService().currentUser;
      List<AyurvedicSolution> userSubmissions = [];
      
      if (user != null) {
        userSubmissions = await AyurvedicService.getUserSolutions(user.uid);
      }
      
      setState(() {
        approvedSolutions = approved;
        userSolutions = userSubmissions;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar('Error loading solutions: $e');
    }
  }

  Future<void> _searchSolutions(String query) async {
    if (query.isEmpty) {
      _loadData();
      return;
    }

    try {
      final results = await AyurvedicService.searchSolutions(query);
      setState(() {
        approvedSolutions = results;
      });
    } catch (e) {
      _showSnackBar('Error searching: $e');
    }
  }

  void _showSubmitDialog() {
    final problemController = TextEditingController();
    final solutionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Provider.of<ThemeProvider>(context).cardColor,
        title: Text(
          'Submit Ayurvedic Solution',
          style: TextStyle(color: Provider.of<ThemeProvider>(context).primaryColor),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: problemController,
                decoration: InputDecoration(
                  labelText: 'Health Problem',
                  hintText: 'e.g., Headache, Indigestion',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: solutionController,
                decoration: InputDecoration(
                  labelText: 'Ayurvedic Solution',
                  hintText: 'Describe the remedy in detail',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (problemController.text.trim().isEmpty || 
                  solutionController.text.trim().isEmpty) {
                _showSnackBar('Please fill in all fields');
                return;
              }

              try {
                final user = AuthService().currentUser;
                if (user == null) throw Exception('User not authenticated');

                await AyurvedicService.submitSolution(
                  problem: problemController.text.trim(),
                  solution: solutionController.text.trim(),
                  submittedBy: user.uid,
                );

                Navigator.pop(context);
                _showSnackBar('Solution submitted for review!');
                _loadData();
              } catch (e) {
                _showSnackBar('Error submitting solution: $e');
              }
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.surfaceColor,
        title: Text(
          'Ayurvedic Solutions',
          style: TextStyle(color: themeProvider.primaryColor),
        ),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: themeProvider.primaryColor,
          unselectedLabelColor: themeProvider.secondaryTextColor,
          indicatorColor: themeProvider.primaryColor,
          tabs: [
            Tab(text: 'Browse'),
            Tab(text: 'Submit'),
            Tab(text: 'My Solutions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBrowseTab(themeProvider),
          _buildSubmitTab(themeProvider),
          _buildMySubmissionsTab(themeProvider),
        ],
      ),
    );
  }

  Widget _buildBrowseTab(ThemeProvider themeProvider) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search solutions...',
              prefixIcon: Icon(Icons.search, color: themeProvider.primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: themeProvider.primaryColor),
              ),
            ),
            onChanged: _searchSolutions,
          ),
        ),

        // Solutions List
        Expanded(
          child: isLoading
              ? Center(child: CircularProgressIndicator(color: themeProvider.primaryColor))
              : approvedSolutions.isEmpty
                  ? Center(
                      child: Text(
                        'No solutions found',
                        style: TextStyle(color: themeProvider.secondaryTextColor),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: approvedSolutions.length,
                      itemBuilder: (context, index) {
                        final solution = approvedSolutions[index];
                        return _buildSolutionCard(solution, themeProvider);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildSubmitTab(ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          AnimatedCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: themeProvider.primaryColor,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Share Your Knowledge',
                  style: TextStyle(
                    color: themeProvider.textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Help others by sharing effective Ayurvedic solutions. Your submissions will be reviewed by our experts.',
                  style: TextStyle(
                    color: themeProvider.secondaryTextColor,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                AnimatedButton(
                  text: 'Submit Solution',
                  icon: Icons.add,
                  onPressed: _showSubmitDialog,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Guidelines
          AnimatedCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Submission Guidelines',
                  style: TextStyle(
                    color: themeProvider.primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildGuideline('Be specific about the health problem', themeProvider),
                _buildGuideline('Provide detailed preparation instructions', themeProvider),
                _buildGuideline('Include any precautions or contraindications', themeProvider),
                _buildGuideline('Only submit traditional Ayurvedic remedies', themeProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMySubmissionsTab(ThemeProvider themeProvider) {
    return isLoading
        ? Center(child: CircularProgressIndicator(color: themeProvider.primaryColor))
        : userSolutions.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.description_outlined,
                      color: themeProvider.secondaryTextColor,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No submissions yet',
                      style: TextStyle(
                        color: themeProvider.secondaryTextColor,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Share your first Ayurvedic solution!',
                      style: TextStyle(
                        color: themeProvider.secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: userSolutions.length,
                itemBuilder: (context, index) {
                  final solution = userSolutions[index];
                  return _buildUserSolutionCard(solution, themeProvider);
                },
              );
  }

  Widget _buildSolutionCard(AyurvedicSolution solution, ThemeProvider themeProvider) {
    return AnimatedCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            solution.problem,
            style: TextStyle(
              color: themeProvider.primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            solution.solution,
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.verified,
                color: Colors.green,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Verified Solution',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(solution.approvedAt ?? solution.submittedAt),
                style: TextStyle(
                  color: themeProvider.secondaryTextColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserSolutionCard(AyurvedicSolution solution, ThemeProvider themeProvider) {
    return AnimatedCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  solution.problem,
                  style: TextStyle(
                    color: themeProvider.primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildStatusChip(solution, themeProvider),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            solution.solution,
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 14,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            'Submitted: ${_formatDate(solution.submittedAt)}',
            style: TextStyle(
              color: themeProvider.secondaryTextColor,
              fontSize: 12,
            ),
          ),
          if (solution.rejectionReason != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Reason: ${solution.rejectionReason}',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(AyurvedicSolution solution, ThemeProvider themeProvider) {
    Color color;
    String text;
    IconData icon;

    if (solution.isApproved) {
      color = Colors.green;
      text = 'Approved';
      icon = Icons.check_circle;
    } else if (solution.rejectionReason != null) {
      color = Colors.red;
      text = 'Rejected';
      icon = Icons.cancel;
    } else {
      color = Colors.orange;
      text = 'Pending';
      icon = Icons.hourglass_empty;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideline(String text, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check,
            color: themeProvider.primaryColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: themeProvider.textColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}