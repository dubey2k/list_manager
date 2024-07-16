import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:list_manager/APIResponse/Result.dart';
import 'package:list_manager/Components/FilterView.dart';
import 'package:list_manager/Provider/ListProvider.dart';
import 'package:list_manager/utils/FilterUtils/FilterData.dart';
import 'package:list_manager/utils/PagingUtils/PagingController.dart';
import 'package:list_manager/utils/PagingUtils/PagingHelper.dart';

typedef FetchFilters = Future<Result<List<FilterData>>> Function();
typedef ApplyFilter<T> = Future<Result<List<T>>> Function(
    {Map<String, dynamic>? selFilters, String? query, PagingHelper? helper});

enum FilterStatus {
  FILTER_IDLE,
  FILTER_LOADING,
  FILTER_ERROR,
  FILTER_LOADED,
}

class FilterController<T> extends ChangeNotifier {
  FilterController({
    required this.applyFilter,
    required this.loadFilters,
    this.filterQuery,
    this.pagingController,
  });

  final ApplyFilter<T> applyFilter;
  final FetchFilters? loadFilters;
  final PagingController<T>? pagingController;
  Map<String, dynamic>? filterQuery;
  List<T>? listData;
  List<FilterData> filterItems = [];
  FilterStatus filterStatus = FilterStatus.FILTER_IDLE;
  ListStatus listStatus = ListStatus.IDLE;
  String searchQuery = "";
  String error = "";
  bool filterChanged = false;

  void setPagingConfig(PagingHelper? helper) {
    if (pagingController != null) {
      pagingController?.pagingHelper = helper;
      notifyListeners();
    }
  }

  Future startLoadingFilters() async {
    if (filterItems.isNotEmpty) {
      filterStatus = FilterStatus.FILTER_LOADED;
      return;
    }
    if (loadFilters != null) {
      filterStatus = FilterStatus.FILTER_LOADING;
      var res = await loadFilters?.call();
      res?.maybeMap(
        success: (value) {
          filterStatus = FilterStatus.FILTER_LOADED;
          filterItems = value.data;
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

  void setStatus(FilterStatus status) {
    filterStatus = status;
    notifyListeners();
  }

  void applyFilters({String? query}) async {
    if (query != null && query != searchQuery) {
      searchQuery = query;
      if (query.length > 2 || query.isEmpty) {
        await exeFilters();
      }
    } else if (filterChanged &&
        filterQuery != null &&
        (filterQuery?.isNotEmpty ?? false)) {
      filterChanged = false;
      await exeFilters();
    }
  }

  exeFilters() async {
    listStatus = ListStatus.LOADING;
    notifyListeners();
    Result<List<T>> res = await applyFilter(
      selFilters: filterQuery,
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

  void setFilterQuery(String key, dynamic value) {
    filterChanged = true;

    if (filterQuery == null) {
      filterQuery = {key: value};
      return;
    }

    filterQuery![key] = value;
  }

  void clearFilter() {
    searchQuery = "";
    listData?.clear();
    filterItems.forEach((ele) {
      switch (ele.runtimeType) {
        case FDropdownData:
          {
            final item = ele as FDropdownData;
            item.value = null;
            break;
          }
        case FCheckboxData:
          {
            final item = ele as FCheckboxData;
            item.states = List.filled(item.options.length, false);
            break;
          }
        case FRadioData:
          {
            final item = ele as FRadioData;
            item.selected = null;
            break;
          }
        case FDateData:
          {
            final item = ele as FDateData;
            item.selStart = null;
            item.selEnd = null;
            break;
          }
        case FSliderData:
          {
            final item = ele as FSliderData;
            item.selLabels = null;
            item.selValues = null;
            break;
          }
      }
    });
    filterStatus = FilterStatus.FILTER_IDLE;
    listStatus = ListStatus.IDLE;
    pagingController?.clearPaging();
    filterQuery = null;
    notifyListeners();
  }
}
