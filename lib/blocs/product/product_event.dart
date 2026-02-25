// lib/blocs/product/product_event.dart

part of 'product_bloc.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch products for a given tab category.
/// [category] == null means "All Products".
class ProductFetchRequested extends ProductEvent {
  final String? category;

  const ProductFetchRequested({this.category});

  @override
  List<Object?> get props => [category];
}

/// Pull-to-refresh: same as fetch but forces a reload.
class ProductRefreshRequested extends ProductEvent {
  final String? category;

  const ProductRefreshRequested({this.category});

  @override
  List<Object?> get props => [category];
}
