import 'package:flutter_token_login/common/const/data.dart';
import 'package:flutter_token_login/common/utils/data_utils.dart';
import 'package:flutter_token_login/restaurant/model/restaurant_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'restaurant_detail_model.g.dart';

// "detail": "오늘 주문하면 배송비 3000원 할인!",

@JsonSerializable() // 코드
class RestaurantDetailModel extends RestaurantModel{ //설정파일
  final String detail;
  final List<RestaurantProductModel> products;

  RestaurantDetailModel({
    required super.id,
    required super.name,
    required super.thumbUrl,
    required super.tags,
    required super.priceRange,
    required super.ratings,
    required super.ratingsCount,
    required super.deliveryTime,
    required super.deliveryFee,
    required this.detail,
    required this.products,
  });

  factory RestaurantDetailModel.fromJson(Map<String, dynamic> json)
  => _$RestaurantDetailModelFromJson(json);
}

@JsonSerializable()
class RestaurantProductModel{
  final String id;
  final String name;
  @JsonKey(
    fromJson: DataUtils.pathToUrl,
  )
  final String imgUrl;
  final String detail;
  final int price;

  RestaurantProductModel({
    required this.id,
    required this.name,
    required this.imgUrl,
    required this.detail,
    required this.price,
  });

  factory RestaurantProductModel.fromJson(Map<String, dynamic> json)
  => _$RestaurantProductModelFromJson(json);
}