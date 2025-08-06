import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_token_login/common/model/cursor_pagination_model.dart';
import 'package:flutter_token_login/common/model/pagination_params.dart';
import 'package:flutter_token_login/restaurant/model/restaurant_model.dart';
import 'package:flutter_token_login/restaurant/repository/restaurant_repository.dart';

final restaurantDetailProvider =
    Provider.family<RestaurantModel?, String>((ref, id) {
  final state = ref.watch(restaurantProvider);

  if (state is! CursorPagination<RestaurantModel>) {
    return null;
  }

  return state.data.firstWhere((element) => element.id == id);
});

final restaurantProvider =
    StateNotifierProvider<RestaurantStateNotifier, CursorPaginationBase>(
  (ref) {
    final repository = ref.watch(restaurantRepositoryProvider);

    final notifier = RestaurantStateNotifier(repository: repository);

    return notifier;
  },
);

class RestaurantStateNotifier extends StateNotifier<CursorPaginationBase> {
  //CursorPagination의 상태를 그대로 들고있어야 다음 페이지를 불러 올 때 CursorPagination에 들어온 값을 가지고 남은 값이 더 있는지 판단하고 있으면 새로운 요청을 통해 다음 값을을 가져오게 요청을 추가 할 수 있다
  final RestaurantRepository repository;

  RestaurantStateNotifier({
    required this.repository,
  }) : super(CursorPaginationLoading()) {
    // super([]) 제일 처음에 일단 [] 아무 데이터도 없는 list를 반환한다
    // RestaurantStateNotifier가 생성이 되는 순간에 paginate(); 실행
    paginate();
  }

  Future<void> paginate({
    int fetchCount = 20,
    bool fetchMore =
        false, // 데이터를 추가로 더 가져올건지 true - 추가데이터 더 가져옴, false - 현재 삳태를 덮어씌움(새로고침)
    bool forceRefetch = false, // true - CursorPaginationLoading()
  }) async {
    try {
      // 5가지 가능성
      // state 상태
      // [상태가]
      // 1) CursorPagination - 정상적으로 데이터가 있는 상태
      // 2) CursorPaginationLoading - 데이터가 로딩중인 상태 (현재 캐시 없음)
      // 3) CursorPaginationError - 에러가 있는 상태
      // 4) CursorPaginationRefetching - 첫번째 페이지부터 다시 데이터를 가져올때
      // 5) CursorPaginationFetchMore - 추가 데이터를 paginate 해오라는 오청을 받았을 때

      // 바로 반환하는 상황
      // 1) hasMore = false (기존 상태에서 이미 다음 데이터가 없다는 값을 들고있다면) > 데이터를 가져온적이 있어야 hasMore의 값을 알 수 있다
      // 2) 로딩중 - fetchMore: true
      //    fetchMore가 아닐때 - 새로고침의 의도가 있을 수 있다(기존 요청이 중요하지가 않다)

      if (state is CursorPagination && !forceRefetch) {
        // 무조건 CursorPagination의 instance거나 extend하고 있는 경우일 것, hasMore을 가지고 있을 것
        final pState = state
            as CursorPagination; //1%라도 CursorPagination이 아닐 확률이 있는 경우에는 절대 사용 금지

        if (!pState.meta.hasMore) {
          // 현재 상태에서의 hasMore이 false라면 더이상 함수를 진행하지않고 반환한다
          return;
        }
      }

      final isLoading = state is CursorPaginationLoading;
      final isRefetching = state is CursorPaginationRefetching;
      final isFetchingMore = state is CursorPaginationFetchingMore;

      // 2) 로딩중 반환 상황
      if (fetchMore && (isLoading || isRefetching || isFetchingMore)) {
        return;
      }

      // PaginationParams 생성
      PaginationParams paginationParams = PaginationParams(
        count: fetchCount,
      );

      // fetchingMore
      // 데이터를 추가로 더 가져오는 상황
      if (fetchMore) {
        final pState = state
            as CursorPagination; // 데이터를 '추가'로 더 가져온다는 것은 이미 CursorPagination을 extend하고 있거나 CursorPagination의 instance인 상황

        state = CursorPaginationFetchingMore(
          meta: pState.meta,
          data: pState.data,
        );

        paginationParams = paginationParams.copyWith(
          after: pState.data.last.id,
        );
      }
      //데이터를 처음부터 가져오는 상황
      else {
        // 만약 데이터가 있는 상황이라면 기존데이터를 보존한채로 fetch(API 요청)를 진행
        if (state is CursorPagination && !forceRefetch) {
          final pState = state as CursorPagination;

          state = CursorPaginationRefetching(
            meta: pState.meta,
            data: pState.data,
          );
        }
        // 나머지 상황
        else {
          state = CursorPaginationLoading();
        }
      }

      final resp = await repository.paginate(
        paginationParams: paginationParams,
      ); // 가장 최근의 데이터 묶음

      //state가 CursorPaginationFetchingMore에 연관된(종속된) 상황일때 > 데이터를 추가할 상황일 때
      if (state is CursorPaginationFetchingMore) {
        final pState = state
            as CursorPaginationFetchingMore; // state 재정의  CursorPaginationFetchingMore는 기존에 부모가 가진 데이터를 상속받아서 가지고 있음

        // 부모에게 상속받은 기존 데이터에 새로운 데이터 추가
        state = resp.copyWith(
          data: [
            ...pState.data, //기존에 있던 데이터
            ...resp.data, //가장 최신의 새로운 데이터
          ],
        );
      } else {
        // 처음 가져오는 20개의 data 바로 뿌리기
        state = resp;
      }
    } catch (e) {
      state = CursorPaginationError(message: '데이터를 가져오지 못함');
    }
  }

  void getDetail({
    required String id,
  }) async {
    // 만약 아직 데이터가 없는 상태라면 >> state != CursorPagination
    if (state is! CursorPagination) {
      await this.paginate();
    }

    // 앞 if문을 거치고도 state가 CursorPagination이 아닐 때 그냥 return > 뭔가 서버에서 오류가 난 것
    if (state is! CursorPagination) {
      return;
    }

    final pState = state as CursorPagination;

    final resp = await repository.getRestaurantDetail(id: id);

    state = pState.copyWith(
      data: pState.data.map((e) => e.id == id ? resp : e,).toList(), //mapping 시 특정 e(element > id)가 getDetail에서 입력한 id값과 같은 경우 resp반환, 아닐 경우 기존 e(element > id)반환
    );
  }
}
