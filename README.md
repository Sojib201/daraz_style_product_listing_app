sdk: 3.41.0

1. How Horizontal Swipe Is Implemented

TabBarView handles horizontal swipes internally using PageScrollPhysics.

PageScrollPhysics only claims a drag gesture when:

horizontal_displacement > vertical_displacement

at the start of the gesture. This is Flutter's built-in gesture disambiguation — no custom GestureDetector or threshold math is needed.

A single TabController is shared between TabBar and TabBarView:

Tap a tab label → TabController.animateTo(i) → TabBarView animates

Swipe TabBarView → TabController.index updates → TabBar indicator moves

Both directions are handled by the same TabController, which acts as the single source of truth.


2. Who Owns the Vertical Scroll?

NestedScrollView is the single owner of vertical scrolling.

It manages two scroll positions:

Outer position → drives SliverAppBar collapse/expand

Inner position → per-tab CustomScrollView (product list)

Each tab's CustomScrollView does not set its own ScrollController.

NestedScrollView assigns and manages controllers for each inner scrollable via PrimaryScrollController.

This ensures one unified vertical scroll for the entire screen.

Why not PageView?

A raw PageView inside NestedScrollView.body breaks inner scroll coordination because PageView intercepts scroll notifications before NestedScrollView can process them.

TabBarView internally uses PageView but wraps it in coordination logic that works correctly with NestedScrollView.


3. Trade-offs / Limitations
   Issue	Detail
   Overscroll glow	Appears on inner CustomScrollView, not outer. Known Flutter NestedScrollView behavior. Use BouncingScrollPhysics for iOS feel.
   Shared outer offset	Header collapse state is shared across tabs. Intentional — matches real app UX.
   Floating SliverAppBar	floating: true + snap: true has a known bug with NestedScrollView. Using pinned: false, floating: false avoids it.
   No true per-tab header	If per-tab independent header state is needed, a more complex approach is required (separate CustomScrollView with SliverAppBar per tab).