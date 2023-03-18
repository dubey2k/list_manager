import 'package:flutter/material.dart';
import 'package:list_manager/list_manager.dart';

class PagingHelper {
  static PagingHelper init({Widget? loader, WidgetCallback? error}) =>
      PagingHelper(
        page: 1,
        loader: loader ?? const Center(child: CircularProgressIndicator()),
        error: error,
      );

  PagingHelper(
      {this.hasNext = false,
      this.loadNext = false,
      this.nextUrl,
      this.page = 1,
      this.error,
      this.totalPages,
      this.loader = const Center(child: CircularProgressIndicator())});

  PagingHelper copyWith({
    bool? hasNext,
    bool? loadNext,
    String? nextUrl,
    int? page,
    int? totalPages,
    WidgetCallback? error,
    Widget? loader,
  }) =>
      PagingHelper(
        hasNext: hasNext ?? this.hasNext,
        loadNext: loadNext ?? this.loadNext,
        nextUrl: nextUrl ?? this.nextUrl,
        page: page ?? this.page,
        totalPages: totalPages ?? this.totalPages,
        error: error ?? this.error,
        loader: loader ?? this.loader,
      );
  bool? hasNext;
  bool? loadNext;
  String? nextUrl;
  int? page;
  int? totalPages;
  WidgetCallback? error;
  Widget loader;
}
