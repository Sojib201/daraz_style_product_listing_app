// lib/blocs/product/product_state.dart

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

class ProductLoaded extends ProductState {
  final List<Product> products;
  final String? category;

  const ProductLoaded({required this.products, this.category});

  @override
  List<Object?> get props => [products, category];
}

class ProductError extends ProductState {
  final String message;
  final String? category;

  const ProductError(this.message, {this.category});

  @override
  List<Object?> get props => [message, category];
}
