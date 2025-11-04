import 'package:ecommerce_app/data/models/chat_message_model.dart';
import 'package:ecommerce_app/data/models/product.dart';
import 'package:ecommerce_app/data/repositories/category_repository.dart';
import 'package:ecommerce_app/data/repositories/product_repository.dart';
import 'package:ecommerce_app/viewmodels/chatbot_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keeps the state alive when switching tabs
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChatbot();
    });

    // ✅ Listen to keyboard changes and auto-scroll
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _scrollToBottom();
        });
      }
    });
  }

  Future<void> _initializeChatbot() async {
    final viewModel = context.read<ChatbotViewModel>();

    // ✅ Get user ID
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';

    try {
      // ✅ Get products from ProductRepository
      final productRepo = context.read<ProductRepository>();
      final products = await productRepo.fetchAllProducts(limit: 100);

      // ✅ Get categories from CategoryRepository
      final categoryRepo = context.read<CategoryRepository>();
      final categories = await categoryRepo.fetchAllCategories();

      // Convert products to Map format
      final productsJson = products
          .map(
            (p) => {
              'id': p.id.toString(),
              'title': p.title,
              'price': p.price,
              'category': p.category,
              'rating': {'rate': p.rating ?? 0.0},
              'description': p.description,
              'brand': p.brand,
            },
          )
          .toList();

      // Extract category names
      final categoryNames = categories.map((c) => c.name).toList();

      // ✅ Initialize with both products AND categories
      await viewModel.initialize(
        userId,
        productsJson,
        categories: categoryNames, // ✅ Pass categories here
      );
    } catch (e) {
      print('Error initializing chatbot: $e');
      // Initialize with empty data if error
      await viewModel.initialize(userId, []);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ✅ FIXED: Better scroll handling for keyboard
  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        if (animated) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      }
    });
  }

  void _handleSendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    context.read<ChatbotViewModel>().sendMessage(text);
    _messageController.clear();

    // ✅ Scroll immediately and again after delay
    _scrollToBottom(animated: false);
    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollToBottom();
    });
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showClearChatDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.darkCardColor
            : AppColors.surfaceColor,
        title: Text(
          'Clear Chat History',
          style: TextStyle(
            color: isDark ? AppColors.primaryColor : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to clear all chat messages? This action cannot be undone.',
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<ChatbotViewModel>().clearChat();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.errorColor),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Must call this with AutomaticKeepAliveClientMixin

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackgroundColor
          : AppColors.backgroundColor,
      appBar: _buildAppBar(isDark),
      resizeToAvoidBottomInset: true,
      body: Consumer<ChatbotViewModel>(
        builder: (context, viewModel, child) {
          // ✅ FIX: Only auto-scroll if messages exist
          if (viewModel.messages.isNotEmpty && !viewModel.isLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollToBottom();
              }
            });
          }

          if (viewModel.isLoading) {
            return _buildLoadingState(isDark);
          }

          return Column(
            children: [
              // Messages List
              Expanded(
                child: viewModel.messages.isEmpty
                    ? _buildEmptyState(isDark)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 16,
                          bottom: 16,
                        ),
                        // ✅ FIX: Safe itemCount
                        itemCount: viewModel.messages.length,
                        itemBuilder: (context, index) {
                          // ✅ FIX: Safe index access
                          if (index >= viewModel.messages.length) {
                            return SizedBox.shrink();
                          }
                          return _buildMessageBubble(
                            viewModel.messages[index],
                            isDark,
                          );
                        },
                      ),
              ),

              // Typing Indicator
              if (viewModel.isTyping) _buildTypingIndicator(isDark),

              // Input Field
              _buildMessageInput(isDark),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark
          ? AppColors.darkSurfaceColor
          : AppColors.surfaceColor,
      automaticallyImplyLeading: false,
      elevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Shopping Assistant',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Powered by Gemini AI',
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.textTertiary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.delete_outline,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          onPressed: () => _showClearChatDialog(isDark),
          tooltip: 'Clear chat history',
        ),
      ],
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryColor),
          const SizedBox(height: 16),
          Text(
            'Initializing AI Assistant...',
            style: TextStyle(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Start Shopping with AI',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask me anything! I can recommend products, help you find deals, and answer shopping questions.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            _buildSuggestedQuestions(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedQuestions(bool isDark) {
    final suggestions = [
      {'icon': '🎁', 'text': 'Suggest gift ideas'},
      {'icon': '💰', 'text': 'Show me deals under \$50'},
      {'icon': '⭐', 'text': 'Top rated electronics'},
      {'icon': '👕', 'text': 'Fashion recommendations'},
      {'icon': '📱', 'text': 'Latest smartphones'},
      {'icon': '🔍', 'text': 'Help me find a product'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: suggestions.map((suggestion) {
        return InkWell(
          onTap: () {
            _messageController.text = suggestion['text']!;
            _handleSendMessage();
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardColor : AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? AppColors.darkBorderColor
                    : AppColors.borderColor,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(suggestion['icon']!, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  suggestion['text']!,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel message, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? AppColors.primaryColor
                        : (isDark
                              ? AppColors.darkCardColor
                              : AppColors.surfaceColor),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                      bottomRight: Radius.circular(message.isUser ? 4 : 16),
                    ),
                    border: !message.isUser
                        ? Border.all(
                            color: isDark
                                ? AppColors.darkBorderColor
                                : AppColors.borderColor,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (message.isUser
                                    ? AppColors.primaryColor
                                    : Colors.black)
                                .withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: TextStyle(
                          color: message.isUser
                              ? Colors.white
                              : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary),
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          color: message.isUser
                              ? Colors.white70
                              : (isDark
                                    ? AppColors.darkTextTertiary
                                    : AppColors.textTertiary),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                // Show product recommendations if available
                if (message.recommendedProductIds != null &&
                    message.recommendedProductIds!.isNotEmpty)
                  _buildProductRecommendations(
                    message.recommendedProductIds!,
                    isDark,
                  ),
              ],
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.accentColor,
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ],
        ],
      ),
    );
  }

  // ✅ FIXED: Product recommendations with proper height
  Widget _buildProductRecommendations(List<String> productIds, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 16,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Recommended Products',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 240, // ✅ FIXED: Increased height for better display
            child: FutureBuilder<List<Product>>(
              future: _fetchProductsByIds(productIds),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No products found',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return _buildProductCard(snapshot.data![index], isDark);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Product>> _fetchProductsByIds(List<String> productIds) async {
    try {
      if (productIds.isEmpty) {
        return [];
      }

      final productRepo = context.read<ProductRepository>();
      final allProducts = await productRepo.fetchAllProducts(limit: 100);

      // ✅ ADDED: Filter with null safety
      return allProducts.where((p) {
        final productId = p.id?.toString();
        return productId != null && productIds.contains(productId);
      }).toList();
    } catch (e) {
      debugPrint('❌ Error fetching products: $e');
      return []; // Return empty list instead of crashing
    }
  }

  // ✅ FIXED: Better product card with proper image sizing
  Widget _buildProductCard(Product product, bool isDark) {
    return GestureDetector(
      onTap: () {
        // ✅ Navigate to product detail screen
        // TODO: Update with your actual route
        // Navigator.pushNamed(context, '/product-detail', arguments: product);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Opening: ${product.title}')));
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCardColor : AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorderColor : AppColors.borderColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ FIXED: Product Image with proper sizing
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Container(
                height: 135, // ✅ FIXED: Proper height
                width: double.infinity,
                color: isDark
                    ? AppColors.darkInputFillColor
                    : AppColors.inputFillColor,
                child: CachedNetworkImage(
                  imageUrl: product.thumbnail ?? '',
                  fit: BoxFit.cover, // ✅ FIXED: Cover for better display
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                      strokeWidth: 2,
                    ),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 40,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
            ),

            // Product Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Rating (if available)
                    if (product.rating != null)
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${product.rating}',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 4),

                    // Price
                    Text(
                      '\$${product.price?.toStringAsFixed(2) ?? '0.00'}',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardColor : AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? AppColors.darkBorderColor
                    : AppColors.borderColor,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (index) => Padding(
                  padding: EdgeInsets.only(left: index > 0 ? 4 : 0),
                  child: _buildTypingDot(index, isDark),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index, bool isDark) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        final delay = index * 0.2;
        final animValue = (value - delay).clamp(0.0, 1.0);
        return Opacity(
          opacity: 0.3 + (0.7 * animValue),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  // ✅ FIXED: Input field with proper keyboard handling
  Widget _buildMessageInput(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceColor : AppColors.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadowColor : AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(
                  maxHeight: 120, // Limit max height for multiline
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkInputFillColor
                      : AppColors.inputFillColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkInputBorderColor
                        : AppColors.inputBorderColor,
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Ask me anything...',
                    hintStyle: TextStyle(
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.textTertiary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                    fontSize: 15,
                  ),
                  maxLines: 4,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleSendMessage(),
                  onChanged: (text) {
                    // Auto-scroll when typing multiline
                    if (text.contains('\n')) {
                      _scrollToBottom(animated: false);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _handleSendMessage,
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
