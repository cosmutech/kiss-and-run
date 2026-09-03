import 'package:flutter/material.dart';
import '../../data/shop_catalog.dart';
import '../../systems/save_manager.dart';
import '../../rendering/character_painter.dart';

class CustomizeScreen extends StatefulWidget {
  const CustomizeScreen({super.key});

  @override
  State<CustomizeScreen> createState() => _CustomizeScreenState();
}

class _CustomizeScreenState extends State<CustomizeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _coins = 0;
  List<String> _unlocked = [];
  Map<String, dynamic> _equipped = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _coins = SaveManager.getHeartCoins();
      _unlocked = SaveManager.getUnlockedItems();
      _equipped = SaveManager.getEquippedCustoms();
    });
  }

  Future<void> _buyItem(ShopItem item) async {
    if (_coins < item.price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough Heart Coins! Keep kissing & escaping! ❤️'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final success = await SaveManager.spendHeartCoins(item.price);
    if (success) {
      await SaveManager.unlockItem(item.id);
      await _equipItem(item);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unlocked ${item.name}! ✨'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _equipItem(ShopItem item) async {
    setState(() {
      switch (item.category) {
        case 'gender':
          _equipped['gender'] = item.value;
          break;
        case 'hair':
          _equipped['hair'] = item.value;
          break;
        case 'shirt':
          // Index of shirt
          final idx = ShopCatalog.items.where((i) => i.category == 'shirt').toList().indexOf(item);
          _equipped['shirt'] = idx;
          break;
        case 'pants':
          final idx = ShopCatalog.items.where((i) => i.category == 'pants').toList().indexOf(item);
          _equipped['pants'] = idx;
          break;
        case 'accessory':
          _equipped['accessory'] = item.value;
          break;
      }
    });
    await SaveManager.saveEquippedCustoms(_equipped);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'DRESSING ROOM',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.pinkAccent),
                ),
                child: Row(
                  children: [
                    const Text('💰 ', style: TextStyle(fontSize: 14)),
                    Text(
                      '$_coins',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Character Mannequin Preview
          Container(
            height: 180,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                colors: [Color(0xFF334155), Color(0xFF1E293B)],
                radius: 0.9,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white12),
            ),
            child: Center(
              child: CustomPaint(
                size: const Size(120, 150),
                painter: _AvatarPreviewPainter(
                  equipped: _equipped,
                ),
              ),
            ),
          ),

          // 2. Category Tabs
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Colors.pinkAccent,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.pinkAccent,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'CHARACTERS'),
              Tab(text: 'HAIR'),
              Tab(text: 'SHIRTS'),
              Tab(text: 'PANTS'),
              Tab(text: 'ACCESSORIES'),
            ],
          ),

          // 3. Items Catalog Grid
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCatalogList('gender'),
                _buildCatalogList('hair'),
                _buildCatalogList('shirt'),
                _buildCatalogList('pants'),
                _buildCatalogList('accessory'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogList(String category) {
    final items = ShopCatalog.items.where((i) => i.category == category).toList();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.15,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isUnlocked = _unlocked.contains(item.id);
        final isEquipped = _isEquipped(item);

        return Container(
          decoration: BoxDecoration(
            color: isEquipped
                ? const Color(0xFF1E293B)
                : const Color(0xFF1A2234),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isEquipped
                  ? Colors.pinkAccent
                  : isUnlocked
                      ? Colors.white24
                      : Colors.white10,
              width: isEquipped ? 2.5 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item.iconEmoji, style: const TextStyle(fontSize: 34)),
              const SizedBox(height: 6),
              Text(
                item.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (isEquipped) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'EQUIPPED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ] else if (isUnlocked) ...[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white12,
                    minimumSize: const Size(70, 26),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  onPressed: () => _equipItem(item),
                  child: const Text('EQUIP', style: TextStyle(color: Colors.white, fontSize: 11)),
                ),
              ] else ...[
                ElevatedButton.icon(
                  icon: const Text('💰', style: TextStyle(fontSize: 12)),
                  label: Text(
                    '${item.price}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(70, 26),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  onPressed: () => _buyItem(item),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  bool _isEquipped(ShopItem item) {
    switch (item.category) {
      case 'gender':
        return _equipped['gender'] == item.value;
      case 'hair':
        return _equipped['hair'] == item.value;
      case 'shirt':
        final idx = ShopCatalog.items.where((i) => i.category == 'shirt').toList().indexOf(item);
        return _equipped['shirt'] == idx;
      case 'pants':
        final idx = ShopCatalog.items.where((i) => i.category == 'pants').toList().indexOf(item);
        return _equipped['pants'] == idx;
      case 'accessory':
        return _equipped['accessory'] == item.value;
      default:
        return false;
    }
  }
}

class _AvatarPreviewPainter extends CustomPainter {
  final Map<String, dynamic> equipped;

  _AvatarPreviewPainter({required this.equipped});

  @override
  void paint(Canvas canvas, Size size) {
    final hairStyle = equipped['hair'] ?? 0;
    final shirtIdx = equipped['shirt'] ?? 0;
    final pantsIdx = equipped['pants'] ?? 0;
    final accIdx = equipped['accessory'] ?? 0;

    final shirtColors = [
      const Color(0xFFFF4081),
      const Color(0xFF00E5FF),
      const Color(0xFF76FF03),
      const Color(0xFF212121),
      const Color(0xFFFFD700),
    ];
    final pantsColors = [
      const Color(0xFF1976D2),
      const Color(0xFF263238),
      const Color(0xFFD7CCC8),
    ];

    CharacterPainter.drawCharacter(
      canvas: canvas,
      x: size.width / 2,
      y: size.height / 2 + 15,
      facingDirection: 1.0,
      skinTone: const Color(0xFFFFDFC4),
      hairColor: const Color(0xFF424242),
      hairStyle: hairStyle,
      shirtColor: shirtColors[shirtIdx.clamp(0, shirtColors.length - 1)],
      pantsColor: pantsColors[pantsIdx.clamp(0, pantsColors.length - 1)],
      accessoryIndex: accIdx,
      isKissing: false,
      isSlapped: false,
      isLove: false,
      isAngry: false,
      isMoving: false,
      animTime: 0,
      scale: 1.6,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
