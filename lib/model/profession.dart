import 'package:cloud_firestore/cloud_firestore.dart';

class Profession {
  String? departmentName;
  List<dynamic>? designations;

  Profession();

  Map<String, dynamic> toJson() => {
    'departmentName': departmentName,
    'designations': designations,
  };

  Profession.fromSnapshot(snapshot)
      : departmentName = snapshot.data()['departmentName'],
        designations = snapshot.data()['designations'];

  static List<dynamic> convertObjectToList(Object? object) {
    if (object == null) {
      return []; // return an empty list if the object is null
    } else if (object is List<dynamic>) {
      return object; // if it's already a List<dynamic>, return as is
    } else {
      throw FormatException('Object cannot be converted to List<dynamic>');
    }
  }
  @override
  String toString() {
    return departmentName??"";
  }

  @override
  bool filter(String query) {
    String dName = departmentName?.toLowerCase()??"";
    return dName.contains(query.toLowerCase());
  }
}

