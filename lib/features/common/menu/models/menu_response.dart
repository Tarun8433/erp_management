class MenuResponse {
  final bool? status;
  final String? message;
  final List<MenuComponent>? data;

  MenuResponse({this.status, this.message, this.data});

  factory MenuResponse.fromJson(Map<String, dynamic> json) {
    return MenuResponse(
      status: json['status'] is bool
          ? json['status']
          : (json['status'] == 'success' || json['status'] == 'true'),
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List)
                .map((e) => MenuComponent.fromJson(e))
                .toList()
          : null,
    );
  }
}

class MenuComponent {
  final int? menuID;
  final String? menuName;
  final String? route;
  final String? icon;
  final List<MenuComponent>? subMenu;

  MenuComponent({
    this.menuID,
    this.menuName,
    this.route,
    this.icon,
    this.subMenu,
  });

  factory MenuComponent.fromJson(Map<String, dynamic> json) {
    return MenuComponent(
      menuID: json['menuID'],
      menuName: json['menuName'],
      route: json['route'],
      icon: json['icon'],
      subMenu: json['subMenu'] != null
          ? (json['subMenu'] as List)
                .map((e) => MenuComponent.fromJson(e))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menuID': menuID,
      'menuName': menuName,
      'route': route,
      'icon': icon,
      'subMenu': subMenu?.map((e) => e.toJson()).toList(),
    };
  }
}
