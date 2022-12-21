library list_manager;

import 'package:flutter/material.dart';
import 'package:list_manager/APIResponse/Result.dart';
import 'package:list_manager/Components/ListWidget.dart';
import 'package:list_manager/Provider/ListProvider.dart';
import 'package:list_manager/utils/FilterUtils/FilterController.dart';
import 'package:list_manager/utils/PagingUtils/PagingController.dart';
import 'package:list_manager/utils/PagingUtils/PagingHelper.dart';
import 'package:list_manager/utils/SearchUtils/SearchController.dart';
import 'package:provider/provider.dart';

typedef ItemCallback<T> = Widget Function(
    BuildContext context, T data, int index);
typedef FetchData<T> = Future<Result<List<T>>> Function(PagingHelper? helper);

typedef WidgetCallback = Widget Function(BuildContext context, String error);

class ListManager<T> extends StatelessWidget {
  const ListManager({
    Key? key,
    required this.itemBuilder,
    this.separatorBuilder,
    this.pagingController,
    this.filterController,
    this.searchController,
    this.error,
    this.loader = const Center(child: CircularProgressIndicator()),
  }) : super(key: key);
  final ItemCallback<T> itemBuilder;
  final ItemCallback<T>? separatorBuilder;
  final PagingController<T>? pagingController;

  final FilterController<T>? filterController;

  final SearchController<T>? searchController;

  /// Error Callback for page 1
  final WidgetCallback? error;

  /// Loader widget for page 1
  final Widget loader;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ListProvider<T>>(
      create: (_) => ListProvider<T>(
        pagingController: pagingController,
        filterController: filterController,
        searchController: searchController,
      ),
      child: Builder(
        builder: (context) {
          return ListWidget<T>(
            itemBuilder: itemBuilder,
            separatorBuilder: separatorBuilder,
            error: error,
            loader: loader,
          );
        },
      ),
    );
  }
}
