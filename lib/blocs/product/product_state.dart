part of 'product_bloc.dart';

abstract class ProductState extends Equatable {
  const ProductState();
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

// class ProductLoaded extends ProductState {
//   final List<Product> products;
//   const ProductLoaded({required this.products});
//   @override
//   List<Object?> get props => [products];
// }

class ProductLoaded extends ProductState {
  final List<Product> products;
  final String searchQuery;

  const ProductLoaded({
    required this.products,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [products, searchQuery];
}

class ProductError extends ProductState {
  final String message;
  const ProductError(this.message);
  @override
  List<Object?> get props => [message];
}
