part of 'product_bloc.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object?> get props => [];
}

class ProductFetchRequested extends ProductEvent {
  const ProductFetchRequested();
}

class ProductRefreshRequested extends ProductEvent {
  const ProductRefreshRequested();
}

class ProductSearchChanged extends ProductEvent {
  final String query;
  const ProductSearchChanged(this.query);
  @override
  List<Object?> get props => [query];
}
