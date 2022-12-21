import 'dart:async';

import 'package:flutter/material.dart';
import 'package:list_manager/Provider/ListProvider.dart';
import 'package:list_manager/utils/FilterUtils/FilterController.dart';

import '../../APIResponse/Result.dart';

enum SearchStatus { INIT, LOADING, LOADED, ERROR }

typedef ApplySearch<T> = Future<Result<List<T>>> Function(
    {required String query});

class SearchController<T> extends ChangeNotifier {
  FilterController<T>? filterController;
  List<T>? listData;
  Timer? debouceCall;
  ApplySearch<T> searchCall;
  SearchStatus searchStatus = SearchStatus.INIT;
  FilterStatus filterStatus = FilterStatus.FILTER_IDLE;
  ListStatus listStatus = ListStatus.IDLE;

  String error = "";

  SearchController({
    this.filterController,
    required this.searchCall,
  });

  void search(String query) {
    if (debouceCall != null) debouceCall?.cancel();
    debouceCall = Timer(
      const Duration(seconds: 1),
      () async {
        var res = await searchCall(query: query);
        res.maybeMap(
          success: (value) {
            searchStatus = SearchStatus.LOADED;
            listData = value.data;
          },
          failure: (value) {
            searchStatus = SearchStatus.ERROR;
            error = value.reason;
          },
          orElse: () {
            searchStatus = SearchStatus.ERROR;
            error = "Unknown Error";
          },
        );
      },
    );
  }

  Future<Result<List<T>>> loadMore() async {
    if (filterController != null &&
        filterController?.pagingController == null) {
      return const Failure(reason: "No Paging Setup for Filter");
    }
    var res = await filterController?.pagingController!.loadListData();
    return res!.maybeMap(
      success: (value) {
        listStatus = ListStatus.LOADED;
        listData = value.data;
        return Success(data: listData!);
      },
      failure: (value) {
        listStatus = ListStatus.ERROR;
        error = value.reason;
        return value;
      },
      orElse: () {
        listStatus = ListStatus.ERROR;
        error = "Unknown Error";
        return const Failure(reason: "Unknown Error");
      },
    );
  }
}
