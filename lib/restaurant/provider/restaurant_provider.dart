import 'package:delivery_app/common/model/cursor_pagination_model.dart';
import 'package:delivery_app/common/model/pagination_params.dart';
import 'package:delivery_app/restaurant/model/restaurant_model.dart';
import 'package:delivery_app/restaurant/repository/restaurant_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final restaurantDetailProvider =
    Provider.family<RestaurantModel?, String>((ref, id) {
  final state = ref.watch(restaurantProvider);

  if (state is! CursorPagination) {
    return null;
  }

  return state.data.firstWhere((element) => element.id == id);
});

final restaurantProvider =
    StateNotifierProvider<RestaurantStateNotifier, CursorPaginationBase>((ref) {
  final RestaurantRepository repository =
      ref.watch(restaurantRepositoryProvider);

  return RestaurantStateNotifier(repository: repository);
});

class RestaurantStateNotifier extends StateNotifier<CursorPaginationBase> {
  final RestaurantRepository repository;

  RestaurantStateNotifier({required this.repository})
      : super(CursorPaginationLoading()) {
    paginate();
  }

  Future<void> paginate({
    int fetchCount = 20,
    bool fetchMore = false,
    bool forceRefetch = false,
  }) async {
    try {
      if (state is CursorPagination && !forceRefetch) {
        final pState = state as CursorPagination;

        if (!pState.meta.hasMore) {
          return;
        }
      }

      final isLoading = state is CursorPaginationLoading;
      final isRefetching = state is CursorPaginationRefetching;
      final isFetchingMore = state is CursorPaginationFetchingMore;

      if (fetchMore && (isLoading || isRefetching || isFetchingMore)) {
        return;
      }

      // PaginationParams 생성
      PaginationParams paginationParams = PaginationParams(
        count: fetchCount,
      );

      // fetchMore 상태
      // fetchMore 상태는, 무조건 데이터를 가지고 있는 상태라고 보면됨.
      if (fetchMore) {
        final pState = state as CursorPagination;

        state =
            CursorPaginationFetchingMore(meta: pState.meta, data: pState.data);

        paginationParams =
            paginationParams.copyWith(after: pState.data.last.id);
      } else {
        //처음부터 데이터를 가져올 때
        if (state is CursorPagination && !forceRefetch) {
          //데이터가 이미 존재하는 상황임. 근데 사용자가 전체 새로고침을 실행한 상황
          final pState = state as CursorPagination;
          state =
              CursorPaginationRefetching(meta: pState.meta, data: pState.data);
        } else {
          //여기는 그냥 해당 페이지에 최초 진입한 상황임
          state = CursorPaginationLoading();
        }
      }

      final resp =
          await repository.paginate(paginationParams: paginationParams);

      if (state is CursorPaginationFetchingMore) {
        final pState = state as CursorPaginationFetchingMore;

        state = resp.copyWith(data: [...pState.data, ...resp.data]);
      } else {
        state = resp;
      }
    } catch (e) {
      state = CursorPaginationError(message: '데이터를 가져오지 못했습니다.');
    }
  }

  void getDetail({
    required String id,
  }) async {
    if (state is! CursorPagination) {
      await paginate();
    }

    // state가 CursorPagination이 아닐 때 리턴
    if (state is! CursorPagination) {
      return;
    }

    final pState = state as CursorPagination;

    //현상태에서 state의 타입을 살펴보자면 CursorPagination<RestaurantModel> { meta: CursorPaginationMeta, data: List<RestaurantModel> }
    //형태로 타입이 정해져있는 상태임.
    //RestaurantDetail 모델이, Restaurant 모델을 상속받고 있기 때문에, 다형성에 의해서 data 필드에 들어갈 수 있게됨
    //그래서, 현재 존재하는 state의 data 리스트 중에, id 값이 파라미터로 받은 id값과 같은 친구만
    //RestaurantModel 에서 RestaurantDetailModel로 바꿔주는 작업이 아래의 copyWith 작업임
    final resp = await repository.getRestaurantDetail(id: id);

    state = pState.copyWith(
      data: pState.data
          .map<RestaurantModel>(
            (e) => e.id == id ? resp : e,
          )
          .toList(),
    );
  }
}
