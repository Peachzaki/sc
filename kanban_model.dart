class KanbanModel {
  final int? id;
  final String partNo;
  final String partCode;
  final String reinforcement;
  final String cover;
  final String? hosingAssyPartNo;
  final String diffAssy;
  final String sizeName;
  final String? sizePicture;
  final String lhPart;
  final String? lhPartPicture;
  final String rhPart;
  final String? rhPartPicture;
  final String shaft;
  final String axles;
  final String brakeName;
  final String? brakePicture;
  final String painting;
  final String models;
  final ProjectInfo? projectInfo;

  KanbanModel({
    this.id,
    required this.partNo,
    required this.partCode,
    required this.reinforcement,
    required this.cover,
    this.hosingAssyPartNo,
    required this.diffAssy,
    required this.sizeName,
    this.sizePicture,
    required this.lhPart,
    this.lhPartPicture,
    required this.rhPart,
    this.rhPartPicture,
    required this.shaft,
    required this.axles,
    required this.brakeName,
    this.brakePicture,
    required this.painting,
    required this.models,
    this.projectInfo,
  });

  factory KanbanModel.fromJson(Map<String, dynamic> json) {
    return KanbanModel(
      id: json['Id'],
      partNo: json['PartNo'] ?? '',
      partCode: json['PartCode'] ?? '',
      reinforcement: json['Reinforcement'] ?? '',
      cover: json['Cover'] ?? '',
      hosingAssyPartNo: json['HosingAssyPartNo'],
      diffAssy: json['DiffAssy'] ?? '',
      sizeName: json['SizeName'] ?? '',
      sizePicture: json['SizePicture'],
      lhPart: json['LHPart'] ?? '',
      lhPartPicture: json['LHPartPicture'],
      rhPart: json['RHPart'] ?? '',
      rhPartPicture: json['RHPartPicture'],
      shaft: json['Shaft'] ?? '',
      axles: json['Axles'] ?? '',
      brakeName: json['BrakeName'] ?? '',
      brakePicture: json['BrakePicture'],
      painting: json['Painting'] ?? '',
      models: json['Models'] ?? '',
      projectInfo: json['projectInfo'] != null
          ? ProjectInfo.fromJson(json['projectInfo'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'PartNo': partNo,
      'PartCode': partCode,
      'Reinforcement': reinforcement,
      'Cover': cover,
      'HosingAssyPartNo': hosingAssyPartNo,
      'DiffAssy': diffAssy,
      'SizeName': sizeName,
      'SizePicture': sizePicture,
      'LHPart': lhPart,
      'LHPartPicture': lhPartPicture,
      'RHPart': rhPart,
      'RHPartPicture': rhPartPicture,
      'Shaft': shaft,
      'Axles': axles,
      'BrakeName': brakeName,
      'BrakePicture': brakePicture,
      'Painting': painting,
      'Models': models,
      'projectInfo': projectInfo?.toJson(),
    };
  }
}

class ProjectInfo {
  final String projectCode;
  final String projectName;
  final String brktCount;
  final String leafSpecs;
  final String discType;

  ProjectInfo({
    required this.projectCode,
    required this.projectName,
    required this.brktCount,
    required this.leafSpecs,
    required this.discType,
  });

  factory ProjectInfo.fromJson(Map<String, dynamic> json) {
    return ProjectInfo(
      projectCode: json['projectCode'] ?? '482D',
      projectName: json['projectName'] ?? 'Project 482D',
      brktCount: json['brktCount'] ?? '7 Pcs',
      leafSpecs: json['leafSpecs'] ?? '4x4 -8.5" H/D',
      discType: json['discType'] ?? 'Disc',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectCode': projectCode,
      'projectName': projectName,
      'brktCount': brktCount,
      'leafSpecs': leafSpecs,
      'discType': discType,
    };
  }
}