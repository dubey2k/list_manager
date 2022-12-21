import 'package:flutter/material.dart';
import 'package:list_manager/APIResponse/Result.dart';
import 'package:list_manager/Provider/ListProvider.dart';
import 'package:list_manager/list_manager.dart';
import 'package:list_manager/utils/FilterUtils/FilterData.dart';
import 'package:list_manager/utils/PagingUtils/PagingController.dart';
import 'package:list_manager/utils/PagingUtils/PagingHelper.dart';

typedef FetchFilters = Future<Result<List<FilterData>>> Function();
typedef ApplyFilter<T> = Future<Result<List<T>>> Function(
    {List<FilterData>? selFilters, String? query, PagingHelper? helper});

enum FilterStatus {
  FILTER_IDLE,
  FILTER_LOADING,
  FILTER_ERROR,
  FILTER_LOADED,
  FILTER_CHANGED,
}

enum SearchStatus {
  SEARCH_IDLE,
  SEARCH_QUERYING,
  SEARCH_LOADED,
}

class FilterController<T> extends ChangeNotifier {
  FilterController({
    this.filterData,
    required this.loadFilter,
    required this.applyFilter,
    this.pagingController,
  });
  List<FilterData>? filterData;
  final FetchFilters loadFilter;
  final ApplyFilter<T> applyFilter;
  List<T>? listData;
  final PagingController<T>? pagingController;
  FilterStatus filterStatus = FilterStatus.FILTER_IDLE;
  ListStatus listStatus = ListStatus.IDLE;
  SearchStatus searchStatus = SearchStatus.SEARCH_IDLE;
  String searchQuery = "";
  String error = "";

  Future loadFilters() async {
    if (filterData != null) {
      filterStatus = FilterStatus.FILTER_LOADED;
      filterData = filterData;
      return;
    }
    filterStatus = FilterStatus.FILTER_LOADING;
    var res = await loadFilter();
    res.maybeMap(
      success: (value) {
        filterStatus = FilterStatus.FILTER_LOADED;
        filterData = value.data;
      },
      failure: (value) {
        filterStatus = FilterStatus.FILTER_ERROR;
        error = value.reason;
      },
      orElse: () {
        filterStatus = FilterStatus.FILTER_ERROR;
        error = "Something went wrong";
      },
    );
    notifyListeners();
  }

  void setPagingConfig(PagingHelper? helper) {
    if (pagingController != null) {
      pagingController?.pagingHelper = helper;
      notifyListeners();
    }
  }

  void applyFilters({String? query}) async {
    listStatus = ListStatus.LOADING;
    if ((filterStatus == FilterStatus.FILTER_CHANGED &&
            filterData != null &&
            (filterData?.isNotEmpty ?? true)) ||
        (query != null && query.length > 3)) {
      searchQuery = query ?? "";
      notifyListeners();
      Result<List<T>> res = await applyFilter(
        selFilters: filterData,
        query: query,
        helper: pagingController?.pagingHelper,
      );
      res.maybeMap(
        success: (value) {
          listStatus = ListStatus.LOADED;
          listData == null
              ? listData = value.data
              : listData?.addAll(value.data);
          notifyListeners();
        },
        failure: (value) {
          listStatus = ListStatus.ERROR;
          error = value.reason;
          notifyListeners();
        },
        orElse: () {
          listStatus = ListStatus.ERROR;
          notifyListeners();
        },
      );
    } else if (query != null && query.isEmpty) {
      //
    } else {
      filterStatus = FilterStatus.FILTER_ERROR;
      error = "No Filter or Query passed";
    }
  }

  Future<Result<List<T>>> loadMore() async {
    if (pagingController == null) {
      return const Failure(reason: "No Paging Setup for Filter");
    }
    var res = await pagingController!.loadListData();
    return res.maybeMap(
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

  void setSubFilters(int selFilterIndex, List<int> val) {
    filterStatus = FilterStatus.FILTER_CHANGED;
    filterData![selFilterIndex].selected = val;
  }

  FilterData? getFilterOptions(int index) {
    if (filterData != null) {
      return filterData![index];
    } else {
      return null;
    }
  }

  FilterOptionModel? getSubFilterOptions(int selFilterIndex, int index) {
    if (filterData != null) {
      return filterData![selFilterIndex].subFilterOptions[index];
    } else {
      return null;
    }
  }

  void clearFilter() {
    listData?.clear();
    filterStatus = FilterStatus.FILTER_IDLE;
    listStatus = ListStatus.IDLE;
    pagingController?.clearPaging();
    filterData?.forEach(
      (element) {
        element.selected.clear();
      },
    );
    notifyListeners();
  }
}
