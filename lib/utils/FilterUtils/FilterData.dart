import 'dart:convert';

FilterData filJsonModelFromJson(String str) =>
    FilterData.fromJson(json.decode(str));

String filJsonModelToJson(FilterData data) => json.encode(data.toJson());

class FilterData {
  FilterData({
    required this.filterKey,
    required this.subFilterOptions,
    this.name,
  }) {
    name ??= filterKey;
  }
  String filterKey;
  String? name;
  List<FilterOptionModel> subFilterOptions;
  List<int> selected = [];
  List<String> selValue = [];

  factory FilterData.fromJson(Map<String, dynamic> json) => FilterData(
        filterKey: json["filterKey"] ?? "",
        subFilterOptions: json["subFilterOptions"] != null &&
                json["subFilterOptions"].isNotEmpty
            ? List<FilterOptionModel>.from(json["subFilterOptions"]
                .map((x) => FilterOptionModel.fromJson(x)))
            : [],
      );
  Map<String, dynamic> toJson() => {
        "filterKey": filterKey,
        "subFilterOptions":
            List<dynamic>.from(subFilterOptions.map((x) => x.toJson())),
      };
}

class FilterOptionModel {
  FilterOptionModel({
    this.id,
    required this.name,
  });

  String? id;
  String name;

  factory FilterOptionModel.fromJson(Map<String, dynamic> json) =>
      FilterOptionModel(
        id: json["id"]?.toString(),
        name: json["name"]?.toString() ?? "Error",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
