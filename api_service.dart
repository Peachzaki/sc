import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/kanban_model.dart';
import '../utils/constants.dart';

class ApiService {
  Future<KanbanModel> fetchKanbanData(String productCode) async {
    try {
      final response = await http.get(
        Uri.parse('${Constants.apiBaseUrl}/ekanban/$productCode'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return KanbanModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock data for demo
      return getMockData(productCode);
    }
  }

  KanbanModel getMockData(String code) {
    if (code.contains('AUS') || code == 'AKV') {
      return KanbanModel(
        partCode: 'PartCode',
        partNo: '42100-05100',
        diffAssy: 'DiffAssy',
        lhPart: 'ซ้มพ RH',
        rhPart: 'สิ้นท้อง RH แถบสีเขียว',
        cover: 'Cover',
        // arm: 'L/D',  // ลบบรรทัดนี้ออกเพราะไม่มีในโมเดล
        sizeName: 'Size"', // เปลี่ยนจาก Size เป็น sizeName
        reinforcement: 'Reinforcement',
        brakeName: 'BrakeName', // เปลี่ยนจาก brake เป็น brakeName
        shaft: 'Shaft',
        painting: 'Painting',
        models: 'Models', // เปลี่ยนจาก model เป็น models
        axles: 'Axles', // เปลี่ยนจาก axle เป็น axles
        projectInfo: ProjectInfo(
          projectCode: '482D',
          projectName: 'Project 482D',
          brktCount: '7 Pcs',
          leafSpecs: 'c374d60e-b229-4d6a-b3fe-02789908575a',
          discType: 'Disc',
        ),
      );
    } else {
      return KanbanModel(
        partCode: 'PartCode',
        partNo: '42100-05110',
        diffAssy: 'DiffAssy',
        lhPart: 'ซ้มพ RH',
        lhPartPicture: 'placeholder.jpg',
        rhPart: 'สิ้นท้อง RH แถบสีเขียว',
        rhPartPicture: 'placeholder.jpg',
        cover: 'Cover',
        // arm: 'L/D',  // ลบบรรทัดนี้ออกเพราะไม่มีในโมเดล
        sizeName: 'Size"', // เปลี่ยนจาก size เป็น sizeName
        sizePicture: 'placeholder.jpg',
        reinforcement: 'Reinforcement',
        brakeName: 'BrakeName', // เปลี่ยนจาก brake เป็น brakeName
        shaft: 'Shaft',
        brakePicture: 'placeholder.jpg',
        painting: 'Painting',
        models: 'Models', // เปลี่ยนจาก model เป็น models
        axles: 'Axles', // เปลี่ยนจาก axle เป็ axles
        projectInfo: ProjectInfo(
          projectCode: '482D',
          projectName: 'Project 482D',
          brktCount: '7 Pcs',
          leafSpecs: 'c374d60e-b229-4d6a-b3fe-02789908575ac374d60e-b229-4d6a-b3fe-02789908575ac374d60e-b229-4d6a-b3fe-02789908575a',
          discType: 'Disc',
        ),
      );
    }
  }
}