import 'package:hive/hive.dart';

class CategoryModel {
  CategoryModel({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
    this.isDefault = false,
  });

  final String id;
  final String name;
  final int iconCodePoint;
  final int colorValue;
  final bool isDefault;
}

class CategoryModelAdapter extends TypeAdapter<CategoryModel> {
  @override
  final int typeId = 1;

  @override
  CategoryModel read(BinaryReader reader) {
    return CategoryModel(
      id: reader.readString(),
      name: reader.readString(),
      iconCodePoint: reader.readInt(),
      colorValue: reader.readInt(),
      isDefault: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, CategoryModel obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.name)
      ..writeInt(obj.iconCodePoint)
      ..writeInt(obj.colorValue)
      ..writeBool(obj.isDefault);
  }
}
