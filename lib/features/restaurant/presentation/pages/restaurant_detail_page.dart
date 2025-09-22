import 'package:flutter/material.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/entities/dish.dart';
import '../widgets/dish_card.dart';

class RestaurantDetailPage extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailPage({
    Key? key,
    required this.restaurant,
  }) : super(key: key);

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Dish> _dishes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMenu();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMenu() async {
    // TODO: Load menu from repository
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
      // Mock data for now
      _dishes = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.restaurant.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ],
                ),
              ),
              background: widget.restaurant.bannerUrl != null
                  ? Image.network(
                      widget.restaurant.bannerUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Theme.of(context).primaryColor.withOpacity(0.8),
                                Theme.of(context).primaryColor,
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.restaurant,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(0.8),
                            Theme.of(context).primaryColor,
                          ],
                        ),
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restaurant Info
                  Text(
                    widget.restaurant.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  
                  // Quick Info Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoChip(
                        Icons.star,
                        '${widget.restaurant.averageRating.toStringAsFixed(1)}',
                        '${widget.restaurant.reviewCount} reviews',
                        Colors.amber,
                      ),
                      _buildInfoChip(
                        Icons.access_time,
                        '${widget.restaurant.averagePreparationTime} min',
                        'Prep time',
                        Colors.blue,
                      ),
                      _buildInfoChip(
                        Icons.delivery_dining,
                        '${widget.restaurant.deliveryFee.toStringAsFixed(0)} FCFA',
                        'Delivery',
                        Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Minimum Order
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Minimum order: ${widget.restaurant.minimumOrder.toStringAsFixed(0)} FCFA',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Methods
                  Wrap(
                    spacing: 8,
                    children: widget.restaurant.acceptedPayments.map((payment) {
                      IconData icon;
                      String label;
                      switch (payment) {
                        case PaymentMethod.cash:
                          icon = Icons.money;
                          label = 'Cash';
                          break;
                        case PaymentMethod.mobileMoney:
                          icon = Icons.phone_android;
                          label = 'Mobile Money';
                          break;
                        case PaymentMethod.card:
                          icon = Icons.credit_card;
                          label = 'Card';
                          break;
                        case PaymentMethod.wallet:
                          icon = Icons.account_balance_wallet;
                          label = 'Wallet';
                          break;
                      }
                      return Chip(
                        avatar: Icon(icon, size: 18),
                        label: Text(label),
                        backgroundColor: Colors.grey[100],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Menu'),
                  Tab(text: 'Reviews'),
                  Tab(text: 'Info'),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Menu Tab
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _dishes.isEmpty
                        ? const Center(
                            child: Text('No dishes available'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _dishes.length,
                            itemBuilder: (context, index) {
                              final dish = _dishes[index];
                              return DishCard(
                                dish: dish,
                                onAdd: () {
                                  // TODO: Add to cart
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Added to cart'),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                // Reviews Tab
                const Center(
                  child: Text('Reviews will be displayed here'),
                ),
                // Info Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoSection(
                        'Opening Hours',
                        Icons.schedule,
                        Column(
                          children: widget.restaurant.openingHours.entries
                              .map((entry) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    entry.key.substring(0, 1).toUpperCase() +
                                        entry.key.substring(1),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${entry.value.opening} - ${entry.value.closing}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildInfoSection(
                        'Location',
                        Icons.location_on,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.restaurant.location.address != null)
                              Text(widget.restaurant.location.address!),
                            if (widget.restaurant.location.city != null)
                              Text(
                                widget.restaurant.location.city!,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildInfoSection(
                        'Certifications',
                        Icons.verified,
                        Wrap(
                          spacing: 8,
                          children: widget.restaurant.certifications
                              .map((cert) => Chip(
                                    label: Text(cert),
                                    backgroundColor: Colors.green[50],
                                    labelStyle: TextStyle(
                                      color: Colors.green[700],
                                    ),
                                  ))
                              .toList(),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to cart
        },
        icon: const Icon(Icons.shopping_cart),
        label: const Text('View Cart'),
      ),
    );
  }

  Widget _buildInfoChip(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, IconData icon, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}