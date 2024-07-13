# Project name

<!--- These are examples. See https://shields.io for others or to customize this set of shields. You might want to include dependencies, project status and licence info here --->
![GitHub repo size](https://img.shields.io/github/repo-size/dubey2k/list_manager)
![GitHub contributors](https://img.shields.io/github/contributors/dubey2k/list_manager)
![GitHub stars](https://img.shields.io/github/stars/dubey2k/list_manager?style=social)
![GitHub forks](https://img.shields.io/github/forks/dubey2k/list_manager?style=social)
![Twitter Follow](https://img.shields.io/twitter/follow/dubey2k?style=social)

A Flutter Package which help developers to add paging, filtering & searching efficiently, the package also works in combination of these operations altogether

## How to use

To use `list_manager`, follow these steps:

```yaml
dependencies:
  list_manager: ^latest_version
```

Model for data
```dart
class PostDataModel {
  PostDataModel({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
  });

  int userId;
  int id;
  String title;
  String body;
}
```

Define the controllers
```dart
late PagingController<PostDataModel> controller;
late FilterController<PostDataModel> filterController;
```

Configure Paging Controller
```dart
controller = PagingController(
      pagingHelper: PagingHelper.init(error: error, loader: loader()),
      loadData: {
        return Future.delayed(
            const Duration(seconds: 1),
            () {
                List<PostDataModel> list = [];
                int page = (helper?.page ?? 0);
                for (int i = 10 * (page); i < 10 * (page + 1); i++) {
                    var model = PostDataModel.fromMap(postData["data"][i]);  //postData is a json stored locally
                    list.add(model);
                    }
                controller.setPagingConfig(
                    helper?.copyWith(
                        hasNext: true,
                        loadNext: true,
                        page: (page + 1),
                        nextUrl: "nextUrl",
                    ) 
                    ?? PagingHelper.init()
                );
            return Success(data: list);
            },
        );
      },
    );
```

Configure Filter Controller
```dart
filterController = FilterController(
      loadFilters: loadFilters,
      pagingController: PagingController(
        pagingHelper: PagingHelper.init(error: filterError, loader: loader()),
        loadData: fetch,
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

// load filters and then pass appropriate data for filter components
Future<Result<List<FilterData>>> loadFilters() async {
    await Future.delayed(const Duration(seconds: 2));
    final list = [
      FDropdownData(
        title: "User",
        key: "user_id",
        onChange: () {},
        options: ["user1", "user2"],
      ),
      FDropdownData(
        title: "Project",
        key: "project_id",
        onChange: () {},
        options: ["project1", "project2"],
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
        options: ["Ascending", "Descending"],
      ),
      FRadioData(
        title: "Sort by Date",
        key: "sort_by_date",
        options: ["Ascending", "Descending"],
      ),
    ];
    return Success(data: list);
  }

Future<Result<List<PostDataModel>>> fetch(PagingHelper? helper) async {
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
```

Use the widget with configured filter and paging controllers
```dart
ListManager<PostDataModel>(
    itemBuilder: (BuildContext context, PostDataModel data, int index) {
        return Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
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
            "$error => Some Error Occured",
            style: const TextStyle(color: Colors.red),
          ),
        );
      },
    )
```

For using filters we can add components like this
```dart
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
  )
```

Now show bottomModalSheet for filter
```dart
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
```


## Contributing to `list_manager`
<!--- If your README is long or you have some specific process or steps you want contributors to follow, consider creating a separate CONTRIBUTING.md file--->
To contribute to `list_manager`, follow these steps:

1. Fork this repository.
2. Create a branch: `git checkout -b <branch_name>`.
3. Make your changes and commit them: `git commit -m '<commit_message>'`
4. Push to the original branch: `git push origin <project_name>/<location>`
5. Create the pull request.

Alternatively see the GitHub documentation on [creating a pull request](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request).