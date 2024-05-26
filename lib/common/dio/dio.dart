import 'package:delivery_app/common/const/data.dart';
import 'package:delivery_app/common/secure_storage/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  final storage = ref.watch(secureStorageProvider);

  dio.interceptors.add(
    CustomInterceptor(storage: storage),
  );

  return dio;
});

class CustomInterceptor extends Interceptor {
  final FlutterSecureStorage storage;

  CustomInterceptor({required this.storage});

  //요청을 보낼 때 (요청 보내기 전임 리턴이 되야 요청이 보내 지는 것)
  //요청이 보내질 때마다, 만약에 요청의 Header에 accessToken : true 라는 값이 있다면
  //실제 토큰을 가져 와서 (from storage) authorization: bearer $token 으로 Headers 값을 변경 해준다.
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    print('[REQ] [${options.method}] ${options.uri}');

    if (options.headers['accessToken'] == 'true') {
      options.headers.remove('accessToken'); //기존의 헤더를 삭제 해줌

      final token = await storage.read(key: ACCESS_TOKEN_KEY);

      //새로운 헤더를 추가함
      options.headers.addAll({
        'authorization': 'Bearer $token',
      });
    }

    if (options.headers['refreshToken'] == 'true') {
      options.headers.remove('refreshToken'); //기존의 헤더를 삭제해줌

      final token = await storage.read(key: REFRESH_TOKEN_KEY);

      //새로운 헤더를 추가함
      options.headers.addAll({'authorization': 'Bearer $token'});
    }

    //요청이 보내지는 시점
    return super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    //401 에러 (토큰 만료, 잘못된 토큰)
    print('[ERR] [${err.requestOptions.method}] ${err.requestOptions.uri}');

    final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);

    //refreshToken이 없으면 에러 던짐
    //사실상 여기서는 다시 로그인하는 과정으로 가야되는것?
    if (refreshToken == null) {
      handler.reject(err);
      return;
    }

    //토큰관련 에러인지 체크함
    final isStatus401 = err.response?.statusCode == 401;
    //토큰을 재요청하는 에러인지 체크함
    final isPathRefresh = err.requestOptions.path == '/auth/token';

    //토큰관련 에러는 맞지만, 토큰을 재요청하는, 즉 로그인을 새로하는 에러는 아님(Refresh token은 살아있다는 말임)
    //이 말은 새로운 AccessToken을 발급받아야 된다 라는 말임
    if (isStatus401 && !isPathRefresh) {
      final dio = Dio();

      try {
        //Access 토큰을 재요청해서 발급받음
        final resp = await dio.post('http://$ip/auth/token',
            options: Options(headers: {
              'authorization': 'Bearer $refreshToken',
            }));
        final accessToken = resp.data['accessToken'];

        //에러가 났었던, 원래 Request 요청을 가지고옴
        final options = err.requestOptions;

        //토큰 변경
        options.headers.addAll({'authorization': 'Bearer $refreshToken'});

        //새로 발급받았으니 다시 저장
        await storage.write(key: ACCESS_TOKEN_KEY, value: accessToken);

        //아까 에러가 났었던 요청에(err.requestOptions로 가져온 위치) 다시 요청 보내기
        final response = await dio.fetch(options);

        //에러가 나지 않았던것 마냥 진행시켜버림
        return handler.resolve(response);
      } on DioException catch (e) {
        //Access Token 발급 과정에서 에러가 발생함
        return handler.reject(e);
      }
    }

    return handler.reject(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
        '[RESP] [${response.requestOptions.method}] ${response.requestOptions.uri}');

    return super.onResponse(response, handler);
  }
}
