// intercept
// 요청, 응답, 에러를 가로채서 또 다른 무언가로 변환해서 반환할 수 있다
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_token_login/common/const/data.dart';
import 'package:flutter_token_login/common/secure_storage/secure_storage.dart';

final dioProvider = Provider<Dio>((ref) {
 final dio = Dio();
 
 final storage = ref.watch(secureStorageProvider);
 
 dio.interceptors.add(
   CustomInterceptor(
     storage: storage,
   ),
 );

 return dio;
});

class CustomInterceptor extends Interceptor{ //일반 Interceptor의 기능들을 모두 쓸 수 있게 부모요소로 첨부
  final FlutterSecureStorage storage;

  CustomInterceptor({
    required this.storage,
  });

  // 1)요청을 보낼 때
  // 요청이 보내질때마다
  //만약에 요청의 header에 accessToken: true라는 값이 있다면
  // (storage에서)실제 토큰을 가져와서 authorization: bearer $token으로
  // header를 변경한다
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    print('[REQ]' '[${options.method}] ${options.uri}');

    if(options.headers['accessToken'] == 'true'){

      //header에서 토큰 재발급을 확인하기위한 키 지우기
      options.headers.remove('accessToken');

      final token = await storage.read(key: ACCESS_TOKEN_KEY);

      //실제 토큰으로 대체하기
      options.headers.addAll({
        'authorization': 'Bearer $token',
      });
    }

    if(options.headers['refreshToken'] == 'true'){

      //header에서 토큰 재발급을 확인하기위한 키 지우기
      options.headers.remove('refreshToken');

      final token = await storage.read(key: REFRESH_TOKEN_KEY);

      //실제 토큰으로 대체하기
      options.headers.addAll({
        'authorization': 'Bearer $token',
      });
    }

    return super.onRequest(options, handler);
  }

  // 2)응답받을때
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('[RES]' '[${response.requestOptions.method}] ${response.requestOptions.uri}');

    return super.onResponse(response, handler);
  }

  // 3)에러 시
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    // 401 error (status code)
    // 토큰을 재발급 받는 시도를 하고 토큰이 재발급되면
    // 다시 새로운 토큰으로 요청을 한다.

    // err.requestOptions - 에러에 대한 모든 요청을 가져올 수 있다
    // err.requestOptions.method - 어떤 요청에서 error인지 알 수 있다
    print('[ERROR]' '[${err.requestOptions.method}] ${err.requestOptions.uri}');

    final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);

    // 만약 refreshToken 없을 시,
    // 당연히 에러를 던진다
    if(refreshToken == null){
      // 에러를 던질때는 handler.reject를 사용한다
      return handler.reject(err);
    }

    // err.response - 에러에 대한 모든 응답을 가져올 수 있다, 응답은 아예 없을 수도 있으니 null safety 적용
    // statusCode - 상태코드
    final isStatus401 = err.response?.statusCode == 401;
    // 요청의 경로가 토큰일 때 true를 반환 >> 에러가 난 요청이 토큰을 리프레시 하려다가 에러가 났음을 확인 >> refreshToken에 문제가 있음
    final isPathRefresh = err.requestOptions.path == '/auth/token';

    // token을 refresh하려는 의도가 아니였는데 401오류가 났을 때
    // refreshToken이 살아있다고 가정할 수 있기 때문에 가지고있는 refreshToken으로 accessToken 재발급 시도
    if(isStatus401 && !isPathRefresh){
      final dio = Dio();

      try{ // 안의 내용을 시도
        //refreshToken으로 accessToken 발급 시도
        final resp = await dio.post(
            'http://$ip/auth/token',
            options: Options(
                headers: {
                  'authorization': 'Bearer $refreshToken',
                }
            )
        );

        // 새로 발급받은 accessToken
        final accessToken = resp.data['accessToken'];

        // err.requestOptions는 에러가 발생한 모든 요청을 담고있음
        final options = err.requestOptions;

        // 토큰 변경하기
        options.headers.addAll({
          'authorization': 'Bearer $accessToken',
        });

        await storage.write(key: ACCESS_TOKEN_KEY, value:accessToken);

        // 요청 재전송
        // 토큰 변경 뒤 에러가 발생했던 요청을 다시 재전송
        // 오류 수정 후 새로 보내는 요청에 대한 응답
        final response = await dio.fetch(options);

        // 에러 없이 요청을 끝낼 때
        return handler.resolve(response);

      }on DioError catch(e){ // 시도한 내용에서 error반환 시 Dio안에서 난 오류만 잡을 때
        return handler.reject(e);
      }
    }

    return handler.reject(err);
  }
}