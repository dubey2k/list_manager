import 'package:example/PostDataModel.dart';
import 'package:example/postData.dart';
import 'package:flutter/material.dart';
import 'package:list_manager/APIResponse/Result.dart';
import 'package:list_manager/Components/FilterView.dart';
import 'package:list_manager/SearchWidget.dart';
import 'package:list_manager/list_manager.dart';
import 'package:list_manager/utils/FilterUtils/FilterController.dart';
import 'package:list_manager/utils/FilterUtils/FilterData.dart';
import 'package:list_manager/utils/PagingUtils/PagingController.dart';
import 'package:list_manager/utils/PagingUtils/PagingHelper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late PagingController<PostDataModel> controller;
  late FilterController<PostDataModel> filterController;

  @override
  void initState() {
    super.initState();
    controller = PagingController(
      pagingHelper: PagingHelper.init(error: error, loader: loader()),
      loadData: fetch,
    );
    filterController = FilterController(
      loadFilters: loadFilters,
      pagingController: PagingController(
        pagingHelper: PagingHelper.init(error: filterError, loader: loader()),
        loadData: fetch2,
      ),
      applyFilter: ({selFilters, query, helper}) async {
        return Future.delayed(
          const Duration(seconds: 1),
          () {
            List<PostDataModel> list = [];
            int page = (helper?.page ?? 0);
            for (int i = 10 * (page); i < 10 * (page + 1); i++) {
              var model = PostDataModel.fromMap(filterData["data"][i]);
              list.add(model);
            }
            if (page == 2) {
              return const Failure(reason: "Custom Error Filter wala");
            }
            filterController.pagingController?.setPagingConfig(
              helper?.copyWith(
                    hasNext: true,
                    loadNext: true,
                    page: (page + 1),
                    nextUrl: "nextUrl",
                  ) ??
                  PagingHelper.init(),
            );
            return Success(data: list);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                      child: SearchWidget(
                    filterController: filterController,
                    inputBorder: const OutlineInputBorder(),
                  )),
                  IconButton(
                    icon: const Icon(Icons.filter_alt),
                    onPressed: () async {
                      showFilterBottomSheet();
                    },
                  ),
                ],
              ),
              Expanded(
                child: ListManager<PostDataModel>(
                  itemBuilder:
                      (BuildContext context, PostDataModel data, int index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.symmetric(
                          vertical: 30, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text("${data.id}. ${data.title}"),
                    );
                  },
                  pagingController: controller,
                  filterController: filterController,
                  loader: const Center(
                    child: Text(
                      "Loading",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  error: (context, error) {
                    return Center(
                      child: Text(
                        "$error => at Page 1 itself",
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Result<List<PostDataModel>>> fetch(PagingHelper? helper) async {
    return Future.delayed(
      const Duration(seconds: 1),
      () {
        List<PostDataModel> list = [];
        int page = (helper?.page ?? 0);
        for (int i = 10 * (page); i < 10 * (page + 1); i++) {
          var model = PostDataModel.fromMap(postData["data"][i]);
          list.add(model);
        }
        // if (page == 2) return const Failure(reason: "Custom Error");
        controller.setPagingConfig(
          helper?.copyWith(
                hasNext: true,
                loadNext: true,
                page: (page + 1),
                nextUrl: "nextUrl",
              ) ??
              PagingHelper.init(),
        );
        return Success(data: list);
      },
    );
  }

  Future<Result<List<PostDataModel>>> fetch2(PagingHelper? helper) async {
    return Future.delayed(
      const Duration(seconds: 1),
      () {
        List<PostDataModel> list = [];
        int page = (helper?.page ?? 0);
        for (int i = 10 * (page); i < 10 * (page + 1); i++) {
          var model = PostDataModel.fromMap(filterData["data"][i]);
          list.add(model);
        }
        filterController.setPagingConfig(
          helper?.copyWith(
                hasNext: true,
                loadNext: true,
                page: (page + 1),
                nextUrl: "nextUrl",
              ) ??
              PagingHelper.init(),
        );
        return Success(data: list);
      },
    );
  }

  void showFilterBottomSheet() async {
    filterController.startLoadingFilters();
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      showDragHandle: true,
      scrollControlDisabledMaxHeightRatio: 0.8,
      builder: (context) {
        return FilterComponent(
          title: "Filters",
          controller: filterController,
        );
      },
    );
  }

  Widget loader() {
    return const Center(
      child: Text(
        "Loading",
        style: TextStyle(
          color: Colors.blue,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget error(context, error) {
    return Center(
      child: Text(
        error,
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget filterError(context, error) {
    return Center(
      child: Text(
        "filter: $error",
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    filterController.dispose();
  }

  Future<Result<List<FilterData>>> loadFilters() async {
    // await Future.delayed(const Duration(seconds: 2));
    final list = [
      FDropdownData(
          title: "User",
          key: "user_id",
          onChange: () {},
          showSearchBox: true, //enable search box
          isFilterOnline: true, // enable searchData function for searching
          options: [
            FilterOptionData(id: "user_id_1", name: "user 1"),
            FilterOptionData(id: "user_id_2", name: "user 2"),
          ],
          searchData: (query) async {
            await Future.delayed(const Duration(seconds: 2));
            return [
              FilterOptionData(id: "user_id_3", name: "user 3"),
              FilterOptionData(id: "user_id_4", name: "user 4"),
            ];
          }),
      FDropdownData(
        title: "Project",
        key: "project_id",
        onChange: () {},
        options: [
          FilterOptionData(id: "project_id_1", name: "project 1"),
          FilterOptionData(id: "project_id_2", name: "project 2"),
        ],
      ),
      FSliderData(
        title: "Amount Range",
        minKey: "amount_less_than",
        maxKey: "amount_greater_than",
        labels: const RangeLabels("0", "20000"),
        values: const RangeValues(0, 20000),
        min: 0,
        max: 100000,
      ),
      FDateData(
        title: "Date",
        startDateKey: "start_date",
        endDateKey: "end_date",
        start: DateTime.now(),
        end: DateTime.now().add(const Duration(days: 34)),
      ),
      FRadioData(
        title: "Sort by Amount",
        key: "sort_by_amount",
        options: [
          FilterOptionData(id: "ASC", name: "Ascending"),
          FilterOptionData(id: "DESC", name: "Descending"),
        ],
      ),
      FRadioData(
        title: "Sort by Date",
        key: "sort_by_date",
        options: [
          FilterOptionData(id: "ASC", name: "Ascending"),
          FilterOptionData(id: "DESC", name: "Descending"),
        ],
      ),
    ];
    return Success(data: list);
  }
}
