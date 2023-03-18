import 'package:flutter/material.dart';
import 'package:list_manager/utils/FilterUtils/FilterController.dart';
import 'package:list_manager/utils/PagingUtils/PagingController.dart';
import '../utils/PagingUtils/PagingHelper.dart';

enum ListStatus { IDLE, LOADING, EMPTY, ERROR, LOADED }

enum ListType { PAGING, FILTERING }

class ListProvider<T> extends ChangeNotifier {
  List<T>? listData;
  ListStatus status = ListStatus.IDLE;
  String? error;
  PagingController<T>? pagingController;
  FilterController<T>? filterController;
  PagingHelper? helper;
  ListType listType = ListType.PAGING;
  final Widget? noData;

  ListProvider({
    this.pagingController,
    this.filterController,
    this.noData,
  }) {
    helper = pagingController?.pagingHelper;
    pagingController?.addListener(() {
      setListType(ListType.PAGING);
      notifyListeners();
    });
    filterController?.addListener(() {
      if (filterController!.searchQuery.isEmpty) {
        setListType(ListType.PAGING);
      }
      if (filterController?.filterStatus == FilterStatus.FILTER_IDLE &&
          filterController?.listStatus == ListStatus.IDLE) {
        setListType(ListType.PAGING);
      } else if (
          // filterController?.filterStatus == FilterStatus.FILTER_LOADED &&
          filterController?.listStatus != ListStatus.IDLE) {
        setListType(ListType.FILTERING);
      }
      notifyListeners();
    });
  }

  Future loadData({bool afterClear = false}) async {
    status = ListStatus.LOADING;
    notifyListeners();

    switch (listType) {
      case ListType.PAGING:
        await pagingController?.loadListData();
        setListType(ListType.PAGING);
        break;
      case ListType.FILTERING:
        await filterController?.loadMore();
        setListType(ListType.FILTERING);
        break;
    }
    notifyListeners();
  }

  // Future refresh(FetchData<T> fetchCallback) async {
  //   //reseting paging controller
  //   pagingController?.pagingHelper =
  //       pagingController?.pagingHelper?.copyWith(page: 1);
  //   //reseting filter's paging controller
  //   filterController?.pagingController?.pagingHelper =
  //       filterController?.pagingController?.pagingHelper?.copyWith(page: 1);
  //   listData?.clear();
  //   await loadData(fetchCallback, afterClear: true);
  // }

  void setListType(ListType type) {
    listType = type;
    switch (type) {
      case ListType.PAGING:
        helper = pagingController?.pagingHelper;
        listData = pagingController?.listData;
        error = pagingController?.error;
        status = pagingController?.status ?? ListStatus.ERROR;
        break;
      case ListType.FILTERING:
        helper = filterController?.pagingController?.pagingHelper;
        listData = filterController?.listData ?? [];
        error = filterController?.error;
        status = filterController?.listStatus ?? ListStatus.ERROR;
        break;
    }
    notifyListeners();
  }
}
