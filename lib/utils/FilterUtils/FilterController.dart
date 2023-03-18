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
}

class FilterController<T> extends ChangeNotifier {
  FilterController({
    required this.applyFilter,
    this.filterData,
    this.loadFilter,
    this.pagingController,
  });
  List<FilterData>? filterData;
  final FetchFilters? loadFilter;
  final ApplyFilter<T> applyFilter;
  List<T>? listData;
  final PagingController<T>? pagingController;
  FilterStatus filterStatus = FilterStatus.FILTER_IDLE;
  ListStatus listStatus = ListStatus.IDLE;
  String searchQuery = "";
  String error = "";
  bool noFilter = true;
  bool filterChanged = false;

  Future loadFilters() async {
    if (filterData != null) {
      filterStatus = FilterStatus.FILTER_LOADED;
      filterData = filterData;
      return;
    }
    if (loadFilter != null) {
      filterStatus = FilterStatus.FILTER_LOADING;
      var res = await loadFilter?.call();
      res?.maybeMap(
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
  }

  void setPagingConfig(PagingHelper? helper) {
    if (pagingController != null) {
      pagingController?.pagingHelper = helper;
      notifyListeners();
    }
  }

  void applyFilters({String? query}) async {
    if ((query == null || query == "") && noFilter) {
      clearFilter();
    } else if (query == searchQuery && !filterChanged) {
      filterStatus = FilterStatus.FILTER_ERROR;
      error = "No Filter or Query passed";
    } else if (query != searchQuery && query != null) {
      searchQuery = query;
      if (query.length > 2 || query.isEmpty) {
        await exeFilters();
      }
    } else if (filterChanged &&
        filterData != null &&
        (filterData?.isNotEmpty ?? false)) {
      filterChanged = false;
      await exeFilters();
    }
  }

  exeFilters() async {
    listStatus = ListStatus.LOADING;
    notifyListeners();
    Result<List<T>> res = await applyFilter(
      selFilters: filterData,
      query: searchQuery,
      helper: pagingController?.pagingHelper,
    );
    res.maybeMap(
      success: (value) {
        listStatus = ListStatus.LOADED;
        listData = value.data;
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
    filterChanged = true;
    filterData![selFilterIndex].selected = val;
    List<String> selValues = [];
    filterData![selFilterIndex].selected.forEach((element) {
      selValues.add(filterData![selFilterIndex].subFilterOptions[element].name);
    });
    filterData![selFilterIndex].selValue = selValues;
    bool temp = true;
    filterData?.forEach((element) {
      if (element.selected.isNotEmpty) {
        temp = false;
      }
    });
    noFilter = temp;
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
    searchQuery = "";
    listData?.clear();
    noFilter = true;
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
