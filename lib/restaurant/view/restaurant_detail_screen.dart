import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_token_login/common/layout/default_layout.dart';
import 'package:flutter_token_login/restaurant/component/restaurant_card.dart';
import 'package:flutter_token_login/restaurant/model/restaurant_detail_model.dart';
import 'package:flutter_token_login/restaurant/model/restaurant_model.dart';
import 'package:flutter_token_login/restaurant/provider/restaurant_provider.dart';

class RestaurantDetailScreen extends ConsumerWidget {
  final String id;

  const RestaurantDetailScreen({
    required this.id,
    Key? key,
  }) : super(key: key);

  // Future<RestaurantDetailModel> getRestaurantDetail(WidgetRef ref) async {
  //   return ref.watch(restaurantRepositoryProvider).getRestaurantDetail(id: id);
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(restaurantDetailProvider(id));

    if (state == null) {
      return DefaultLayout(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return DefaultLayout(
      title: state.name,
      child: CustomScrollView(
        slivers: [
          renderTop(
            model: state,
          ),
          // renderLabel(),
          // renderProducts(
          // products: snapshot.data!.products,
          // ),
        ],
      ),
    );
  }


  SliverPadding renderProducts({
    required List<RestaurantProductModel> products,
  }) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final model = products[index];

            return Padding(
              padding: const EdgeInsets.only(top: 16.0),
              // child: ProductCard.fromModel(
              //   model: model,
              // ),
              child: Text(
                  'ddddd'
              ),
            );
          },
          childCount: products.length,
        ),
      ),
    );
  }

  SliverPadding renderLabel() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverToBoxAdapter(
        child: Text(
          'MENU',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }


  SliverToBoxAdapter renderTop({
    required RestaurantModel model,
  }) {
    return SliverToBoxAdapter(
      child: RestaurantCard.fromModel(
        model: model,
        isDetail: true,
      ),
    );
  }
}
