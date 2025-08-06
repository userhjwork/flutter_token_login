import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_token_login/common/model/cursor_pagination_model.dart';
import 'package:flutter_token_login/restaurant/component/restaurant_card.dart';
import 'package:flutter_token_login/restaurant/provider/restaurant_provider.dart';
import 'package:flutter_token_login/restaurant/view/restaurant_detail_screen.dart';

class RestaurantScreen extends ConsumerStatefulWidget {
  const RestaurantScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends ConsumerState<RestaurantScreen> {
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();

    controller.addListener(scrollListener);
  }

  void scrollListener() {
    // 현재 위치가 최대 길이보다 조금 덜 되는 위치까지 왔다면
    // 새로운 데이터를 추가 요청

    // 현재 위치(controller.offset)가 최대 길이(maxScrollExtent) - 300px보다 클 때
    if (controller.offset > controller.position.maxScrollExtent - 300) {
      // controller.position.maxScrollExtent > controller에서 스트롤 가능한 최대 길이까지 간 지점
      print('checkpoint');

      ref.read(restaurantProvider.notifier).paginate(
            fetchMore: true,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(restaurantProvider);

    // is는 타입 비교
    // 맨 초기 진입 로딩일 때
    if (data is CursorPaginationLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    // error
    if (data is CursorPaginationError) {
      return Center(
        child: Text(data.message),
      );
    }

    // CursorPagination
    // CursorPaginationRefetching
    // CursorPaginationFetchingMore

    final cp = data as CursorPagination;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.separated(
          controller: controller,
          itemCount: cp.data.length + 1,
          itemBuilder: (_, index) {
            if (index == cp.data.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Center(
                  child: data is CursorPaginationFetchingMore
                      ? CircularProgressIndicator()
                      : Text('마지막 데이터에옹ㅜ'),
                ),
              );
            }

            final pItem = cp.data[index];

            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RestaurantDetailScreen(
                      id: pItem.id,
                    ),
                  ),
                );
              },
              child: RestaurantCard.fromModel(
                model: pItem,
              ),
            );
          },
          separatorBuilder: (_, index) {
            return SizedBox(
              height: 16.0,
            );
          }),
    );
  }
}
