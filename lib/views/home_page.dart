// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:shivathuli/models/category_model.dart';
import 'package:shivathuli/models/group_model.dart';
import 'package:shivathuli/models/singer_model.dart';
import 'package:shivathuli/services/api_service.dart';
import 'package:shivathuli/views/song_list_page.dart';
import 'package:shivathuli/widgets/speech_item.dart';
import 'package:shivathuli/widgets/thitrumuraikal_item.dart';
import 'package:shivathuli/widgets/mini_player_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- Mini player state (simulate for demo) ---
  bool _isPlayerVisible = true; // Set true to show mini player
  bool _isPlaying = true; // Simulate playing/paused
  double _playerProgress = 0.3;
  Duration _playerCurrent = const Duration(minutes: 1, seconds: 22);
  Duration _playerTotal = const Duration(minutes: 5, seconds: 11);
  String _playerTitle = "THIRUVASAGAM";
  String _playerSubtitle = "Manikkavacakar";
  // --- Dynamic data for demonstration (would come from API in a real app) ---
  List<Map<String, String>> speechData = [];
  List<Map<String, String>> thitrumuraikalData = [];

  // --- Static UI labels and configurations ---
  final List<Map<String, dynamic>> filterChips = [
    {
      "icon": Icons.favorite_border,
      "label": "Favorites",
      "action": () => print("Favorites tapped"),
    },
    {
      "icon": Icons.history,
      "label": "Recent",
      "action": () => print("Recent tapped"),
    },
    {
      "icon": Icons.remove_red_eye_outlined,
      "label": "Most Viewed",
      "action": () => print("Most Viewed tapped"),
    },
  ];

  final List<Map<String, String>> bookCategories = [
    {"text": "திருவாசகம்", "route": "/thiruvasagam"},
    {"text": "வழிபாடு", "route": "/vazhipadu"},
    {"text": "பன்னிரு திருமுறை", "route": "/panniru_thirumurai"},
    {"text": "விண்ணப்பம்", "route": "/vinnappam"},
  ];

  final ApiService apiService = ApiService();

  List<Category> categories = [];
  List<Singer> singers = [];
  List<Group> groups = [];

  @override
  void initState() {
    super.initState();
    _loadGroups();
    _loadCategories(); // Fetch categories here
    _loadSingers();
  }

  Future<void> _loadSingers() async {
    try {
      final result = await apiService.fetchSingers();
      setState(() {
        singers = result;
      });
    } catch (e) {
      print("Error loading singers: $e");
    }
  }

  Future<void> _loadCategories() async {
    try {
      final result = await apiService.fetchCategories();
      setState(() {
        categories = result;
      });
    } catch (e) {
      print("Failed to fetch categories: $e");
    }
  }

  Future<void> _loadGroups() async {
    try {
      final result = await apiService.fetchGroups();
      setState(() {
        groups = result;
      });
    } catch (e) {
      print("Failed to fetch groups: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access the defined text theme from the app's theme
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(
                textTheme,
              ), // Pass textTheme to search bar for hint style
              const SizedBox(height: 10),
              _buildFilterChips(textTheme), // Pass textTheme to filter chips
              const SizedBox(height: 10),
              _buildCategoryList(), // Pass textTheme to category buttons
              const SizedBox(height: 10),
              _buildSectionHeader(context, "Speeches", () {
                // TODO: Navigate to Speeches list screen
                print("View all Speeches");
              }, textTheme), // Pass textTheme to section header
              const SizedBox(height: 10),
              _buildSpeechesList(), // Uses its own internal textTheme access
              const SizedBox(height: 10),
              _buildSectionHeader(context, "Thitrumuraikal", () {
                // TODO: Navigate to Thitrumuraikal list screen
                print("View all Thitrumuraikal");
              }, textTheme), // Pass textTheme to section header
              const SizedBox(height: 15),
              _buildThitrumuraikalList(), // Uses its own internal textTheme access
              const SizedBox(height: 120),
            ],
          ),
        ),
        if (_isPlayerVisible)
          Positioned(
            left: 0,
            right: 0,
            bottom: -10,
            child: MiniPlayerController(
              isPlaying: _isPlaying,
              title: _playerTitle,
              subtitle: _playerSubtitle,
              progress: _playerProgress,
              current: _playerCurrent,
              total: _playerTotal,
              onPlayPause: () {
                setState(() {
                  _isPlaying = !_isPlaying;
                });
              },
              onTap: () {
                // TODO: Navigate to full player page
              },
            ),
          ),
      ],
    );
  }

  // --- Search Bar Widget ---
  Widget _buildSearchBar(TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search", // Static UI text
                  border: InputBorder.none,
                  icon: const Icon(Icons.search, color: Colors.grey),
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ), // Style for hint text
                ),
                style: textTheme.bodyMedium, // Style for input text
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            //  padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.grey),
              onPressed: () {
                // TODO: Handle notification tap
                print("Notification tapped");
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Filter Chips Section ---
  Widget _buildFilterChips(TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: filterChips
            .map(
              (chip) => _buildFilterChip(
                chip["icon"] as IconData,
                chip["label"] as String, // Static UI text
                chip["action"] as VoidCallback,
                textTheme,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildFilterChip(
    IconData icon,
    String label,
    VoidCallback onPressed,
    TextTheme textTheme,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[700]),
            const SizedBox(width: 5),
            Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Book Categories Section (Updated) ---
  // After _buildBookCategories()
  Widget _buildCategoryList() {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SongListPage(
                    groupId: group.id,
                    collectionTitle: group.name,
                  ),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 16.0 : 8.0,
                right: index == groups.length - 1 ? 16.0 : 8.0,
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      group.image,
                      height: 90,
                      width: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 90,
                    child: Text(
                      group.name,
                      style: const TextStyle(fontSize: 13),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryButton(
    String text,
    IconData icon,
    VoidCallback onPressed,
    TextTheme textTheme,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.deepOrange,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      icon: Icon(icon, size: 20),
      label: Text(
        text,
        style: textTheme.labelLarge, // Use the themed labelLarge style
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // --- Section Header Widget (e.g., "Speeches", "Thitrumuraikal") ---
  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    VoidCallback onTap,
    TextTheme textTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title, // Static UI text
            style: textTheme
                .titleLarge, // Use the themed titleLarge style for section headers
          ),
          InkWell(
            onTap: onTap,
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Speeches List Section ---
  Widget _buildSpeechesList() {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: singers.length,
        itemBuilder: (context, index) {
          final singer = singers[index];
          return Padding(
            padding: EdgeInsets.only(
              left: 16.0,
              right: index == singers.length - 1 ? 16.0 : 0,
            ),
            child: SpeechItem(
              imageUrl: singer.image,
              title: singer.name,
              onTap: () {
                print("Singer ${singer.name} tapped");
                // TODO: Navigate to singer detail or songs list
              },
            ),
          );
        },
      ),
    );
  }

  // --- Thitrumuraikal List Section ---
  Widget _buildThitrumuraikalList() {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SongListPage(
                    categoryId: category.id,
                    collectionTitle: category.name,
                  ),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 16.0 : 8.0,
                right: index == categories.length - 1 ? 16.0 : 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      category.image,
                      height: 90,
                      width: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 90,
                    child: Text(
                      category.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
