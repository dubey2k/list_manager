import 'package:flutter/material.dart';
import 'package:list_manager/Provider/ListProvider.dart';
import 'package:list_manager/list_manager.dart';
import 'package:list_manager/utils/FilterUtils/FilterController.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class ListWidget<T> extends StatefulWidget {
  const ListWidget({
    Key? key,
    required this.itemBuilder,
    this.separatorBuilder,
    this.error,
    this.noData,
    required this.loader,
  }) : super(key: key);
  final ItemCallback<T> itemBuilder;
  final ItemCallback<T>? separatorBuilder;
  final WidgetCallback? error;
  final Widget? noData;
  final Widget loader;

  @override
  State<ListWidget<T>> createState() => _ListWidgetState<T>();
}

class _ListWidgetState<T> extends State<ListWidget<T>> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(keepScrollOffset: true);
    var list = context.read<ListProvider<T>>();
    if (list.helper != null) {
      _scrollController.addListener(() {
        if (_scrollController.position.maxScrollExtent ==
            _scrollController.position.pixels) {
          var pagHelper = list.helper;
          if (list.status != ListStatus.LOADING &&
              pagHelper?.hasNext == true &&
              pagHelper?.loadNext == true) {
            list.loadData();
          }
        }
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      list.loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Selector<ListProvider<T>, Tuple2<ListStatus, ListType>>(
      selector: (context, val) => Tuple2(val.status, val.listType),
      builder: (context, val, child) {
        var pro = context.read<ListProvider<T>>();
        switch (val.item1) {
          case ListStatus.IDLE:
            return const Center(child: CircularProgressIndicator());
          case ListStatus.LOADING:
            return pro.listData == null
                ? widget.loader
                : buildList(pro.listData!, addLoader: 1);
          case ListStatus.EMPTY:
            return const Text("Empty Data");
          case ListStatus.ERROR:
            return pro.listData == null
                ? widget.error?.call(context, pro.error ?? "") ??
                    Center(child: Text(pro.error ?? ""))
                : buildList(pro.listData!, addError: 1);
          case ListStatus.LOADED:
            return buildList(pro.listData!);
          default:
            return const SizedBox();
        }
      },
    );
  }

  buildList(List<T> list, {int addLoader = -1, int addError = -1}) {
    int length = list.length;
    if (addLoader == 1) length++;
    if (addError == 1) length++;

    Widget listWid = ListView.separated(
      controller: _scrollController,
      itemCount: length,
      itemBuilder: (context, index) {
        if (addLoader == 1 && index == length - 1) {
          var pro = context.read<ListProvider<T>>();
          return pro.pagingController?.pagingHelper?.loader ??
              const Center(child: CircularProgressIndicator());
        }
        if (addError == 1 && index == length - 1) {
          var pro = context.read<ListProvider<T>>();
          String error = pro.error ?? "";
          return pro.pagingController?.pagingHelper?.error
                  ?.call(context, error) ??
              Center(child: Text(error));
        }
        return widget.itemBuilder(context, list.elementAt(index), index);
      },
      separatorBuilder: (context, index) {
        if (widget.separatorBuilder == null) {
          return const SizedBox();
        } else {
          return widget.separatorBuilder!.call(context, list[index], index);
        }
      },
    );
    return length == 0 ? widget.noData ?? listWid : listWid;
  }
}
