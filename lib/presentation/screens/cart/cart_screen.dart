import 'package:ecommerce_app/core/providers/cart_provider.dart';
import 'package:ecommerce_app/presentation/screens/product/product_detail_screen.dart';
import 'package:ecommerce_app/presentation/widgets/just_for_you_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/cart_item.dart';
import '../../../data/repositories/product_repository.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late final ProductRepository _productRepo;
  final _scroll = ScrollController();
  bool _firstBlockShown = false;
  bool _jfyReady = false;
  bool _postFrameChecked = false;

  @override
  void initState() {
    super.initState();
    _productRepo = context.read<ProductRepository>();
    _scroll.addListener(_maybeStartLazyJustForYou);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        try {
          await context.read<CartProvider>().initializeCart();
          setState(() {
            _firstBlockShown = true; // Force the flag once cart is loaded
          });
        } catch (e) {
          print('Cart initialization error: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to load cart: $e'),
                backgroundColor: AppColors.errorColor,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _maybeStartLazyJustForYou() {
    if (_firstBlockShown && !_jfyReady) {
      final offset = _scroll.position.pixels;
      final vp = _scroll.position.viewportDimension;

      // Trigger Just For You section when scrolled 40% of viewport
      if (offset > vp * 0.40) {
        setState(() => _jfyReady = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackgroundColor
          : AppColors.backgroundColor,
      appBar: _buildAppBar(isDark),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          if (!_postFrameChecked && !cartProvider.isLoading) {
            _postFrameChecked = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _jfyReady = true; // Force the Just For You section readiness
              });
            });
          }

          if (cartProvider.isLoading) return _buildLoadingState(isDark);
          return _buildCartContentWithJFY(cartProvider, isDark);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    final modalRoute = ModalRoute.of(context);
    final isModal = modalRoute?.canPop ?? false;

    return AppBar(
      backgroundColor: isDark
          ? AppColors.darkSurfaceColor
          : AppColors.surfaceColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: isModal
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.primaryColor,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      title: Consumer<CartProvider>(
        builder: (_, cartProvider, __) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Cart',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            if (cartProvider.itemCount > 0)
              Text(
                '${cartProvider.itemCount} ${cartProvider.itemCount == 1 ? 'item' : 'items'}',
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
      actions: [
        Consumer<CartProvider>(
          builder: (_, cartProvider, __) {
            if (cartProvider.cartItems.isEmpty) return const SizedBox.shrink();
            return TextButton.icon(
              onPressed: () => _showClearCartDialog(cartProvider),
              icon: Icon(
                Icons.delete_sweep_rounded,
                size: 18,
                color: AppColors.errorColor,
              ),
              label: Text(
                'Clear All',
                style: TextStyle(
                  color: AppColors.errorColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primaryColor,
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            'Loading your cart...',
            style: TextStyle(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateWithJFY(bool isDark) {
    return CustomScrollView(
      controller: _scroll,
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.primaryColor.withOpacity(0.1)
                          : AppColors.primaryColor.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: AppColors.primaryColor.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Your Cart is Empty',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Looks like you haven\'t added\nanything to your cart yet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).maybePop();
                    },
                    icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                    label: const Text('Start Shopping'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_firstBlockShown && _jfyReady)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: JustForYouSection(
                productRepository: _productRepo,
                title: 'Just For You',
                onProductTap: (product) {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: product),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCartContentWithJFY(CartProvider cartProvider, bool isDark) {
    return CustomScrollView(
      controller: _scroll,
      slivers: [
        // Cart Items List - Only visible when cart has items
        if (cartProvider.cartItems.isNotEmpty) ...[
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((_, index) {
                final item = cartProvider.cartItems[index];
                return _buildCartItemCard(item, cartProvider, isDark);
              }, childCount: cartProvider.cartItems.length),
            ),
          ),
        ],

        // Cart Summary - Only shown when there are items in the cart
        if (cartProvider.cartItems.isNotEmpty)
          SliverToBoxAdapter(child: _buildCartSummary(cartProvider, isDark)),

        // Just For You Section - Only shown after Cart Summary when there are items
        if (cartProvider.cartItems.isNotEmpty && _firstBlockShown && _jfyReady)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: JustForYouSection(
                productRepository: _productRepo,
                title: 'Just For You',
                onProductTap: (product) {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: product),
                    ),
                  );
                },
              ),
            ),
          ),

        // Just For You Section and Empty Cart Message - Only shown when cart is empty
        if (cartProvider.cartItems.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  // Empty Cart Message
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.primaryColor.withOpacity(0.1)
                                  : AppColors.primaryColor.withOpacity(0.05),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.shopping_cart_outlined,
                              size: 80,
                              color: AppColors.primaryColor.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Your Cart is Empty',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Looks like you haven\'t added\nanything to your cart yet',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).maybePop();
                            },
                            icon: const Icon(
                              Icons.shopping_bag_outlined,
                              size: 20,
                            ),
                            label: const Text('Start Shopping'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Just For You Section (Only shown when cart is empty)
                  if (_firstBlockShown && _jfyReady)
                    JustForYouSection(
                      productRepository: _productRepo,
                      title: 'Just For You',
                      onProductTap: (product) {
                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailScreen(product: product),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCartItemCard(
    CartItem item,
    CartProvider cartProvider,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardColor : AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkBorderColor
                      : AppColors.borderColor.withOpacity(0.3),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item.thumbnail,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 90,
                    height: 90,
                    color: isDark
                        ? AppColors.darkInputFillColor
                        : Colors.grey[100],
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          Icons.delete_outline_rounded, // Remove Icon
                          size: 20,
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.textTertiary,
                        ),
                        onPressed: () => _removeItem(cartProvider, item),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Brand & Category
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.primaryColor.withOpacity(0.1)
                          : AppColors.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${item.brand} • ${item.category}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Price Row - Apply Discount
                  Row(
                    children: [
                      if (item.discountPercentage != null) ...[
                        Text(
                          '\$${item.discountedPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\$${item.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.textTertiary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.errorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${item.discountPercentage!.toStringAsFixed(0)}% OFF',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.errorColor,
                            ),
                          ),
                        ),
                      ] else
                        Text(
                          '\$${item.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Quantity Controls
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkInputFillColor
                              : AppColors.inputFillColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorderColor
                                : AppColors.borderColor,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildQuantityButton(
                              icon: Icons.remove_rounded,
                              onPressed: () => _updateQuantity(
                                cartProvider,
                                item,
                                item.quantity - 1,
                              ),
                              isDark: isDark,
                            ),
                            Container(
                              constraints: const BoxConstraints(minWidth: 36),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                '${item.quantity}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            _buildQuantityButton(
                              icon: Icons.add_rounded,
                              onPressed: () => _updateQuantity(
                                cartProvider,
                                item,
                                item.quantity + 1,
                              ),
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Total: \$${item.totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 18,
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildCartSummary(CartProvider cartProvider, bool isDark) {
    final deliveryFee = cartProvider.calculateDeliveryFee();
    final finalTotal = cartProvider.getFinalTotal();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceColor : AppColors.surfaceColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Summary Rows
              _buildSummaryRow(
                'Subtotal',
                '\$${cartProvider.cartSubtotal.toStringAsFixed(2)}',
                isDark: isDark,
              ),
              if (cartProvider.cartDiscount > 0) ...[
                const SizedBox(height: 8),
                _buildSummaryRow(
                  'Discount',
                  '-\$${cartProvider.cartDiscount.toStringAsFixed(2)}',
                  isDark: isDark,
                  color: AppColors.successColor,
                ),
              ],
              const SizedBox(height: 8),
              _buildSummaryRow(
                'Delivery',
                deliveryFee == 0
                    ? 'FREE'
                    : '\$${deliveryFee.toStringAsFixed(2)}',
                isDark: isDark,
                color: deliveryFee == 0 ? AppColors.successColor : null,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Divider(
                  color: isDark
                      ? AppColors.darkDividerColor
                      : AppColors.dividerColor,
                  thickness: 1,
                ),
              ),

              // Total Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '\$${finalTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Checkout Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _proceedToCheckout(cartProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_outline_rounded, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Proceed to Checkout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    required bool isDark,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color:
                color ??
                (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  void _updateQuantity(
    CartProvider cartProvider,
    CartItem item,
    int newQuantity,
  ) async {
    if (newQuantity <= 0) {
      _removeItem(cartProvider, item);
    } else {
      try {
        await cartProvider.updateQuantity(item.productId, newQuantity);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update quantity: $e'),
              backgroundColor: AppColors.errorColor,
            ),
          );
        }
      }
    }
  }

  void _removeItem(CartProvider cartProvider, CartItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.darkCardColor
            : AppColors.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Remove Item?',
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Remove ${item.title} from your cart?',
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await cartProvider.removeFromCart(item.productId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${item.title} removed from cart'),
                      backgroundColor: AppColors.successColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to remove item: $e'),
                      backgroundColor: AppColors.errorColor,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(CartProvider cartProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.darkCardColor
            : AppColors.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Clear Cart?',
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to remove all items from your cart?',
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await cartProvider.clearCart();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Cart cleared successfully'),
                      backgroundColor: AppColors.successColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to clear cart: $e'),
                      backgroundColor: AppColors.errorColor,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _proceedToCheckout(CartProvider cartProvider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Proceeding to checkout with ${cartProvider.itemCount} items',
        ),
        backgroundColor: AppColors.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
