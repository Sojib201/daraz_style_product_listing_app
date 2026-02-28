import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../blocs/product/product_bloc.dart';
import '../repositories/api_repository.dart';
import '../widgets/product_sliver_grid.dart';
import '../widgets/shimmer_sliver_grid.dart';
import 'profile_screen.dart';


class TabDef {
  final String label;
  final String? category;
  const TabDef(this.label, [this.category]);
}

const tabs = [
  TabDef('All'),
  TabDef('Electronics', 'electronics'),
  TabDef("Men's Clothing", 'men\'s clothing'),
];

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({super.key});

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  late final List<ProductBloc> _blocs;

  @override
  void initState() {
    super.initState();

    final repo = context.read<ApiRepository>();
    _blocs = tabs.map((t) => ProductBloc(repo, category: t.category)).toList();

    _tabController = TabController(length: tabs.length, vsync: this)
      ..addListener(_onTabChanged);

    _blocs[0].add(const ProductFetchRequested());
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    for (final b in _blocs) {
      b.close();
    }
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    _blocs[_tabController.index].add(const ProductFetchRequested());
  }

  Future<void> _onRefresh() async {
    final idx = _tabController.index;
    final bloc = _blocs[idx];
    bloc.add(const ProductRefreshRequested());
    await bloc.stream.firstWhere((s) => s is ProductLoaded || s is ProductError,);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: const Color(0xFFFF6B00),
        displacement: 60,
        child: NestedScrollView(
          headerSliverBuilder: _buildHeaderSlivers,
          body: TabBarView(
            controller: _tabController,
            children: List.generate(
              tabs.length,
              (i) => _TabBody(bloc: _blocs[i]),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildHeaderSlivers(
      BuildContext context, bool innerBoxIsScrolled) {
    return [
      SliverAppBar(
        expandedHeight: 140.h,
        pinned: false,
        floating: false,
        snap: false,
        forceElevated: innerBoxIsScrolled,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        // flexibleSpace: FlexibleSpaceBar(
        //   collapseMode: CollapseMode.pin,
        //   background: _HeaderBanner(
        //     onProfileTap: () => Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (_) => const ProfileScreen()),
        //     ),
        //   ),
        // ),
        flexibleSpace: FlexibleSpaceBar(
          collapseMode: CollapseMode.pin,
          background: _HeaderBanner(
            onProfileTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            onSearchChanged: (value) {
              final currentIdx = _tabController.index;
              _blocs[currentIdx].add(ProductSearchChanged(value));
            },
          ),
        ),
      ),

      SliverPersistentHeader(
        pinned: true,
        delegate: _TabBarDelegate(
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: const Color(0xFFFF6B00),
            unselectedLabelColor: Colors.grey.shade600,
            indicatorColor: const Color(0xFFFF6B00),
            indicatorWeight: 2.5,
            labelStyle: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
            ),
            tabs: tabs.map((t) => Tab(text: t.label)).toList(),
          ),
        ),
      ),
    ];
  }
}


class _TabBody extends StatefulWidget {
  final ProductBloc bloc;
  const _TabBody({required this.bloc});

  @override
  State<_TabBody> createState() => _TabBodyState();
}

class _TabBodyState extends State<_TabBody>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<ProductBloc, ProductState>(
      bloc: widget.bloc,
      builder: (context, state) {

        return CustomScrollView(

          physics: const ClampingScrollPhysics(),
          slivers: [
            if (state is ProductInitial || state is ProductLoading)
              const ShimmerSliverGrid()
            else if (state is ProductLoaded)
              state.products.isEmpty
                  ? const _EmptySliver()
                  : ProductSliverGrid(products: state.products)
            else if (state is ProductError)
              _ErrorSliver(
                message: state.message,
                onRetry: () =>
                    widget.bloc.add(const ProductFetchRequested()),
              ),
          ],
        );
      },
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  const _TabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: overlapsContent
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate old) => _tabBar != old._tabBar;
}

class _HeaderBanner extends StatelessWidget {
  final VoidCallback onProfileTap;
  final ValueChanged<String> onSearchChanged;
  const _HeaderBanner({required this.onProfileTap,required this.onSearchChanged,});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF6B00), Color(0xFFFF9A3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 50.h, 16.w, 12.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              Text(
                'Daraz',
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
                  radius: 16.r,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person,
                      color: Colors.white, size: 18.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Container(
            height: 40.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6.r),
            ),
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey.shade400, size: 18.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: TextField(
                    onChanged: onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search in Daraz',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13.sp,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                // Expanded(
                //   child: TextField(
                //     onChanged: (value) {
                //       context
                //           .read<ProductBloc>()
                //           .add(ProductSearchChanged(value));
                //     },
                //     decoration: InputDecoration(
                //       hintText: 'Search in Daraz',
                //       hintStyle: TextStyle(
                //             color: Colors.grey.shade400,
                //             fontSize: 13.sp,
                //           ),
                //       border: InputBorder.none,
                //       isDense: true,
                //     ),
                //   ),
                // ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: Colors.white, size: 22.sp),
    );
  }
}


class _EmptySliver extends StatelessWidget {
  const _EmptySliver();

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Text('No products found.',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
      ),
    );
  }
}

class _ErrorSliver extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorSliver({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded,
                  size: 56.sp, color: Colors.grey.shade400),
              SizedBox(height: 16.h),
              Text(
                'Failed to load products',
                style: TextStyle(
                    fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 20.h),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF6B00),
                  side: const BorderSide(color: Color(0xFFFF6B00)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
