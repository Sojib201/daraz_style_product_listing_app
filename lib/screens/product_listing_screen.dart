// lib/screens/product_listing_screen.dart
//
// ═══════════════════════════════════════════════════════════════════════════
// ARCHITECTURE README
// ═══════════════════════════════════════════════════════════════════════════
//
// 1. HOW HORIZONTAL SWIPE IS IMPLEMENTED
//    ─────────────────────────────────────
//    A PageView (physics: NeverScrollableScrollPhysics) is placed inside the
//    SliverFillRemaining. Tab switching is driven ONLY by TabController
//    (either via tap or by calling animateToPage() after detecting a
//    horizontal swipe via a GestureDetector that wraps the PageView area).
//
//    Why not use PageView's built-in swipe? Because PageView and the outer
//    NestedScrollView fight over vertical drag gestures — a small diagonal
//    swipe can hijack the vertical scroll. By disabling PageView's own scroll
//    physics and routing swipes through a thin GestureDetector we get:
//      • Precise horizontal-only swipe detection (DX > DY threshold).
//      • Zero interaction with the vertical scrollable.
//
// 2. WHO OWNS THE VERTICAL SCROLL AND WHY
//    ─────────────────────────────────────
//    NestedScrollView owns the SINGLE vertical ScrollController for the
//    entire screen. The collapsible header (SliverAppBar) lives in
//    headerSliverBuilder, and the sticky TabBar is also in a SliverPersistentHeader
//    inside that builder.
//
//    Each tab's body is a non-scrollable Column (a GridView with
//    physics: NeverScrollableScrollPhysics and a fixed shrinkWrap).
//    The NestedScrollView drives ALL vertical motion from a single viewport.
//
//    Trade-off: shrinkWrap + NeverScrollableScrollPhysics on large grids is
//    slightly less memory-efficient than a lazy SliverGrid, but it avoids
//    the "dual scrollable" problem completely and is totally jitter-free.
//    For a production app with 100+ items, switch to SliverGrid inside a
//    CustomScrollView and use NestedScrollView's innerScrollController.
//
// 3. TRADE-OFFS / LIMITATIONS
//    ─────────────────────────
//    • shrinkWrap renders all children at once → fine for ~20 products, not
//      for very long lists. Mitigation: paginate or use SliverGrid.
//    • Pull-to-refresh uses a RefreshIndicator that wraps the NestedScrollView.
//      Because the scroll is owned by NestedScrollView, PTR works from any
//      tab regardless of which category is active.
//    • Tab scroll position is preserved because we never rebuild the PageView
//      children; IndexedStack semantics are emulated by always keeping all
//      pages alive with AutomaticKeepAliveClientMixin.
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/product/product_bloc.dart';
import '../repositories/api_repository.dart';
import '../widgets/product_grid.dart';
import '../widgets/shimmer_grid.dart';
import 'profile_screen.dart';

// Tab definition – extend this list to add more tabs.
const _tabs = [
  _TabDef(label: 'All', category: null),
  _TabDef(label: 'Electronics', category: 'electronics'),
  _TabDef(label: "Jewellery", category: "jewelery"),
];

class _TabDef {
  final String label;
  final String? category;
  const _TabDef({required this.label, required this.category});
}

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({super.key});

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final PageController _pageController;

  // One bloc per tab – created once, disposed with the screen.
  late final List<ProductBloc> _blocs;

  // Tracks which tab's refresh is in progress (for pull-to-refresh).
  int _activeTab = 0;

  // Horizontal swipe detection state
  double _swipeDx = 0;
  double _swipeDy = 0;
  bool _isHorizontalSwipe = false;
  static const double _swipeThreshold = 12.0;

  @override
  void initState() {
    super.initState();
    final repo = context.read<ApiRepository>();
    _blocs = List.generate(
      _tabs.length,
      (_) => ProductBloc(repo),
    );

    _tabController = TabController(length: _tabs.length, vsync: this)
      ..addListener(_onTabChanged);

    _pageController = PageController();

    // Kick off the first tab fetch immediately.
    _fetchTab(0);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _pageController.dispose();
    for (final b in _blocs) {
      b.close();
    }
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final idx = _tabController.index;
    if (idx == _activeTab) return;
    setState(() => _activeTab = idx);
    _fetchTab(idx);
    _pageController.animateToPage(
      idx,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _fetchTab(int idx) {
    _blocs[idx].add(ProductFetchRequested(category: _tabs[idx].category));
  }

  Future<void> _onRefresh() async {
    final idx = _activeTab;
    final completer = ValueNotifier<bool>(false);
    _blocs[idx].add(ProductRefreshRequested(category: _tabs[idx].category));
    // Wait until bloc emits loaded/error.
    await Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      return _blocs[idx].state is! ProductLoaded &&
          _blocs[idx].state is! ProductError;
    });
  }

  // ── Gesture handling ───────────────────────────────────────────────────────
  //
  // We wrap the PageView in a GestureDetector to intercept horizontal swipes.
  // On drag start we sample DX vs DY to decide ownership.
  // If horizontal: we drive the TabController directly.
  // If vertical:   we do nothing → NestedScrollView handles it.

  void _onPanStart(DragStartDetails d) {
    _swipeDx = 0;
    _swipeDy = 0;
    _isHorizontalSwipe = false;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    _swipeDx += d.delta.dx.abs();
    _swipeDy += d.delta.dy.abs();

    if (!_isHorizontalSwipe &&
        (_swipeDx > _swipeThreshold || _swipeDy > _swipeThreshold)) {
      _isHorizontalSwipe = _swipeDx > _swipeDy;
    }
  }

  void _onPanEnd(DragEndDetails d) {
    if (!_isHorizontalSwipe) return;
    final velocity = d.velocity.pixelsPerSecond.dx;
    if (velocity < -300 && _activeTab < _tabs.length - 1) {
      _tabController.animateTo(_activeTab + 1);
    } else if (velocity > 300 && _activeTab > 0) {
      _tabController.animateTo(_activeTab - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: RefreshIndicator(
        // PTR wraps the ENTIRE NestedScrollView so it works from any tab.
        onRefresh: _onRefresh,
        color: const Color(0xFFFF6B00),
        child: NestedScrollView(
          // NestedScrollView is the SINGLE owner of the vertical scroll axis.
          headerSliverBuilder: _buildHeader,
          body: _buildBody(),
        ),
      ),
    );
  }

  // ── Header (collapsible AppBar + sticky TabBar) ────────────────────────────

  List<Widget> _buildHeader(BuildContext context, bool innerBoxIsScrolled) {
    return [
      // Collapsible banner + search bar
      SliverAppBar(
        expandedHeight: 180.h,
        floating: false,
        pinned: false,
        snap: false,
        backgroundColor: const Color(0xFFFF6B00),
        elevation: 0,
        flexibleSpace: FlexibleSpaceBar(
          background: _BannerWithSearch(onProfileTap: _openProfile),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: _openProfile,
          ),
        ],
      ),

      // Sticky tab bar — stays pinned once the SliverAppBar collapses.
      SliverPersistentHeader(
        pinned: true,
        delegate: _StickyTabBarDelegate(
          TabBar(
            controller: _tabController,
            isScrollable: false,
            labelColor: const Color(0xFFFF6B00),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFFFF6B00),
            indicatorWeight: 3,
            labelStyle: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
            tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
          ),
        ),
      ),
    ];
  }

  // ── Body (PageView – NeverScrollableScrollPhysics) ─────────────────────────
  //
  // PageView physics are disabled. Horizontal navigation is handled exclusively
  // by the GestureDetector above + TabController, keeping vertical scroll clean.

  Widget _buildBody() {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      behavior: HitTestBehavior.translucent,
      child: PageView.builder(
        controller: _pageController,
        // CRITICAL: disable PageView's own scroll physics to prevent
        // gesture conflicts with the vertical NestedScrollView.
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _tabs.length,
        itemBuilder: (context, index) => _TabPage(
          bloc: _blocs[index],
          category: _tabs[index].category,
        ),
      ),
    );
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }
}

// ── Tab Page ──────────────────────────────────────────────────────────────────
//
// Each page is kept alive so switching tabs doesn't lose scroll state.
// Content is a non-scrollable GridView; the parent NestedScrollView drives
// all vertical scrolling.

class _TabPage extends StatefulWidget {
  final ProductBloc bloc;
  final String? category;

  const _TabPage({required this.bloc, required this.category});

  @override
  State<_TabPage> createState() => _TabPageState();
}

class _TabPageState extends State<_TabPage>
    with AutomaticKeepAliveClientMixin {
  // AutomaticKeepAliveClientMixin ensures the page isn't torn down when
  // the user swipes to an adjacent tab, preserving the rendered product list.
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // required by AutomaticKeepAliveClientMixin
    return BlocBuilder<ProductBloc, ProductState>(
      bloc: widget.bloc,
      builder: (context, state) {
        if (state is ProductLoading || state is ProductInitial) {
          return const ShimmerGrid();
        }
        if (state is ProductError) {
          return _ErrorView(message: state.message);
        }
        if (state is ProductLoaded) {
          if (state.products.isEmpty) {
            return const _EmptyView();
          }
          return ProductGrid(products: state.products);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ── SliverPersistentHeader delegate for sticky tab bar ────────────────────────

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  const _StickyTabBarDelegate(this.tabBar);

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
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) =>
      tabBar != oldDelegate.tabBar;
}

// ── Banner Widget ─────────────────────────────────────────────────────────────

class _BannerWithSearch extends StatelessWidget {
  final VoidCallback onProfileTap;

  const _BannerWithSearch({required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF6B00), Color(0xFFFF9500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 48.h, 16.w, 12.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Logo row
          Row(
            children: [
              Text(
                'daraz',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onProfileTap,
                child: CircleAvatar(
                  radius: 18.r,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 20.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Search bar
          Container(
            height: 44.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                SizedBox(width: 12.w),
                Icon(Icons.search, color: Colors.grey, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'Search products...',
                  style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error / Empty views ────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 64.sp, color: Colors.grey.shade400),
            SizedBox(height: 16.h),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                  fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No products found.',
        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
      ),
    );
  }
}
