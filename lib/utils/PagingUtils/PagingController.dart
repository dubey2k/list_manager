import 'package:flutter/material.dart';
import 'package:list_manager/APIResponse/Result.dart';
import 'package:list_manager/Provider/ListProvider.dart';
import 'package:list_manager/list_manager.dart';
import 'package:list_manager/utils/PagingUtils/PagingHelper.dart';

class PagingController<T> extends ChangeNotifier {
  PagingController({this.pagingHelper, required this.loadData});
  PagingHelper? pagingHelper;
  ListStatus status = ListStatus.IDLE;
  List<T>? listData;
  String error = "";
  FetchData<T> loadData;

  void setPagingConfig(PagingHelper? helper) {
    pagingHelper = helper;
    notifyListeners();
  }

  Future<Result<List<T>>> loadListData() async {
    status = ListStatus.LOADING;
    Result<List<T>> res = await loadData(pagingHelper);
    return res.maybeMap(
      success: (value) {
        status = ListStatus.LOADED;
        listData == null ? listData = value.data : listData?.addAll(value.data);
        return Success(data: listData!);
      },
      failure: (value) {
        status = ListStatus.ERROR;
        error = value.reason;
        return value;
      },
      orElse: () {
        status = ListStatus.ERROR;
        return const Failure(reason: "Unknown Error");
      },
    );
  }

  void clearPaging() {
    listData?.clear();
    if (pagingHelper != null) {
      pagingHelper = PagingHelper.init(
        loader: pagingHelper?.loader,
        error: pagingHelper?.error,
      );
    }
    status = ListStatus.IDLE;
  }
}
