import 'package:json_annotation/json_annotation.dart';

part 'cursor_pagination_model.g.dart';

// abstract - instance로 만들지 못하게 할거다
abstract class CursorPaginationBase {}

class CursorPaginationError extends CursorPaginationBase {
  final String message;

  CursorPaginationError({
    required this.message,
  });
}

class CursorPaginationLoading extends CursorPaginationBase {}

@JsonSerializable(
  // jsonSerializable을 생성할때 genericArgument를 고려한 코드를 생성할 수 있다
  genericArgumentFactories: true,
)

// 아무것도 없는 CursorPaginationBase를 extends 해야하는 이유
// CursorPagination을 CursorPaginationBase의 타입인지 테스트 했을 때 CursorPaginationBase의 타입이라고 확인되는게 중요하다
// CursorPagination은 데이터가 응답이 와서 잘 있을때의 상태
class CursorPagination<T> extends CursorPaginationBase {
  final CursorPaginationMeta meta;
  final List<T> data;

  CursorPagination({
    required this.meta,
    required this.data,
  });

  CursorPagination copyWith({
    CursorPaginationMeta? meta,
    List<T>? data,
  }) {
    return CursorPagination(
      meta: meta ?? this.meta,
      data: data ?? this.data,
    );
  }

  // List의 타입이 정해지지 않고 넘어오고있기 때문에 어떻게 json으로부터 instance로 변환할지 알 수 없기 때문에 외부에서 알려줘야함
  factory CursorPagination.fromJson(
          Map<String, dynamic> json, T Function(Object? json) fromJsonT) =>
      _$CursorPaginationFromJson(json, fromJsonT);
}

@JsonSerializable()
class CursorPaginationMeta {
  final int count;
  final bool hasMore;

  CursorPaginationMeta({
    required this.count,
    required this.hasMore,
  });

  CursorPaginationMeta copyWith({
    int? count,
    bool? hasMore,
  }) {
    return CursorPaginationMeta(
      count: count ?? this.count,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  factory CursorPaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$CursorPaginationMetaFromJson(json);
}

// 새로고침 시
// meta, data가 있다는 가정 하에 refetch한다는 개념이기 때문에 extend CursorPagination
class CursorPaginationRefetching<T> extends CursorPagination<T> {
  CursorPaginationRefetching({
    required super.meta,
    required super.data,
  });
}

// 리스트의 맨 아래로 내려서 추가 데이터 요청하는 중
class CursorPaginationFetchingMore<T> extends CursorPagination<T> {
  CursorPaginationFetchingMore({
    required super.meta,
    required super.data,
  });
}
