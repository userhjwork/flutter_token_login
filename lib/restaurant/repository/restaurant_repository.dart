import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_token_login/common/dio/dio.dart';
import 'package:flutter_token_login/common/model/cursor_pagination_model.dart';
import 'package:flutter_token_login/common/model/pagination_params.dart';
import 'package:flutter_token_login/restaurant/model/restaurant_detail_model.dart';
import 'package:flutter_token_login/restaurant/model/restaurant_model.dart';
import 'package:retrofit/retrofit.dart';

import '../../common/const/data.dart';

part 'restaurant_repository.g.dart';

final restaurantRepositoryProvider = Provider<RestaurantRepository>((ref) {
  final dio = ref.watch(dioProvider);

  final repository =
      RestaurantRepository(dio, baseUrl: 'http://$ip/restaurant');

  return repository;
});

@RestApi()
abstract class RestaurantRepository {
  // repository의 class는 항상 abstract로 선언해야한다.  abstract인스턴스화 할 수 없음
  // http://$ip/restaurant < baseUrl
  factory RestaurantRepository(Dio dio, {String baseUrl}) =
      _RestaurantRepository;

  // http://$ip/restaurant/
  @GET('/')
  @Headers({'accessToken': 'true'})
  Future<CursorPagination<RestaurantModel>> paginate({
    @Queries() PaginationParams? paginationParams = const PaginationParams(), // paginationParams에 해당되는 class들이 바로 쿼리값으로 변경됨
  });

  // http://$ip/restaurant/:id/
  @GET('/{id}')
  @Headers({'accessToken': 'true'})
  Future<RestaurantDetailModel> getRestaurantDetail({
    @Path() required String id,
  }); //외부에서 오는 요청이기 때문에 반드시 future을 넣어야함
}
