import 'package:flutter/material.dart';
import '../../models/kanban_model.dart';

// ===== SHARED CONTAINER WIDGET =====
class SharedKanbanContainer extends StatelessWidget {
  final String headerText;
  final Widget content;
  final bool expandContent;

  const SharedKanbanContainer({
    super.key,
    required this.headerText,
    required this.content,
    this.expandContent = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: expandContent ? MainAxisSize.max : MainAxisSize.min,
        children: [
          // Shared Header
          Container(
            height: 45,
            decoration: BoxDecoration(
              color: Colors.lightBlue[100],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            alignment: Alignment.center,
            child: Text(
              headerText,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          // Content
          expandContent
              ? Expanded(child: content)
              : content,
        ],
      ),
    );
  }
}

// ===== หน้า 1: ปรับชื่อฟิลด์ตามโครงสร้างใหม่ =====
class KanbanFirstPage extends StatelessWidget {
  final KanbanModel kanbanData;

  const KanbanFirstPage({super.key, required this.kanbanData});

  // ปรับปรุงฟังก์ชันการจัดการรูปภาพ
  Widget _buildImageWidget(String? filename, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Color? fallbackColor,
    String fallbackText = '',
    double fallbackIconSize = 24,
  }) {
    // ถ้าไม่มีรูป ให้แสดง fallback
    if (filename == null || filename.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: fallbackColor ?? Colors.grey[200],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.image_not_supported,
                size: fallbackIconSize,
                color: Colors.grey[400],
              ),
              if (fallbackText.isNotEmpty) ...[
                SizedBox(height: fallbackIconSize > 20 ? 8 : 4),
                Text(
                  fallbackText,
                  style: TextStyle(
                    fontSize: fallbackIconSize > 20 ? 12 : 8,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      );
    }

    // พยายามแสดงรูป
    String imagePath = filename;
    if (!filename.contains('/')) {
      imagePath = 'assets/images/$filename';
    }

    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // Debug print เพื่อดูว่ารูปไหนโหลดไม่ได้
        print('ไม่สามารถโหลดรูป: $imagePath');
        print('Error: $error');

        return Container(
          width: width,
          height: height,
          color: fallbackColor ?? Colors.grey[200],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.broken_image,
                  size: fallbackIconSize,
                  color: Colors.grey[400],
                ),
                if (fallbackText.isNotEmpty) ...[
                  SizedBox(height: fallbackIconSize > 20 ? 8 : 4),
                  Text(
                    fallbackText,
                    style: TextStyle(
                      fontSize: fallbackIconSize > 20 ? 12 : 8,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper function to safely get string values
  String _safeString(String? value, [String fallback = '']) {
    return value ?? fallback;
  }

  @override
  Widget build(BuildContext context) {
    return SharedKanbanContainer(
      headerText: _safeString(kanbanData.partCode, 'N/A'),
      expandContent: false,
      content: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Table - 4x2 grid
              Table(
                border: TableBorder.symmetric(
                  inside: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(1),
                },
                children: [
                  // Row 1: Reinforcement | Cover
                  TableRow(children: [
                    _buildCell(_safeString(kanbanData.reinforcement), label: "Reinforcement"),
                    _buildCell(_safeString(kanbanData.cover), label: "Cover"),
                  ]),
                  // Row 2: DiffAssy | Size (Name + Picture)
                  TableRow(children: [
                    _buildCell(_safeString(kanbanData.diffAssy), label: "DiffAssy"),
                    _buildSizeCell(
                        _safeString(kanbanData.sizeName),
                        imagePath: kanbanData.sizePicture,
                        label: "Size"
                    ),
                  ]),
                  // Row 3: LH Part | RH Part (with pictures)
                  TableRow(children: [
                    _buildPartImageCell(
                        "LH",
                        _safeString(kanbanData.lhPart),
                        kanbanData.lhPartPicture,
                        Colors.pink[100]!,
                        label: "LH Part"
                    ),
                    _buildPartImageCell(
                        "RH",
                        _safeString(kanbanData.rhPart),
                        kanbanData.rhPartPicture,
                        Colors.yellow[100]!,
                        label: "RH Part"
                    ),
                  ]),
                  // Row 4: Shaft | Axles
                  TableRow(children: [
                    _buildCell(_safeString(kanbanData.shaft), label: "Shaft"),
                    _buildCell(_safeString(kanbanData.axles), label: "Axles"),
                  ]),
                ],
              ),

              // Brake Name header
              Container(
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1)),
                ),
                child: Text(
                  _safeString(kanbanData.brakeName),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),

              // Brake Picture - ใช้ฟังก์ชันใหม่
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1)),
                ),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Builder(
                    builder: (context) => GestureDetector(
                      onTap: () => _showBrakeImageDialog(context),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: _buildImageWidget(
                            kanbanData.brakePicture,
                            width: double.infinity,
                            height: double.infinity,
                            fallbackColor: Colors.white,
                            fallbackText: _safeString(kanbanData.brakeName),
                            fallbackIconSize: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Painting section
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.lightBlue[100],
                  border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1)),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Painting (${_safeString(kanbanData.painting)})",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Models section (bottom)
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.lightBlue[50],
                  border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1)),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(3)),
                ),
                alignment: Alignment.center,
                child: Text(
                  _safeString(kanbanData.models),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Cell สำหรับข้อความธรรมดา
  Widget _buildCell(String text, {String? label}) {
    return Container(
      height: 40,
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  // Cell สำหรับ Size (text + picture) - ปรับปรุงแล้ว
  Widget _buildSizeCell(String text, {String? imagePath, String? label}) {
    return Container(
      height: 40,
      color: Colors.white,
      child: Row(
        children: [
          // Left half - Size Name
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Right half - Size Picture
          Expanded(
            flex: 1,
            child: Builder(
              builder: (context) => GestureDetector(
                onTap: () => _showImageDialog(context, text, "Size Detail", imagePath),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: Colors.grey[300]!, width: 0.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: _buildImageWidget(
                      imagePath,
                      width: double.infinity,
                      height: double.infinity,
                      fallbackColor: Colors.grey[200],
                      fallbackIconSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Cell สำหรับ LH/RH Part with pictures - ปรับปรุงแล้ว
  Widget _buildPartImageCell(String side, String partText, String? imagePath, Color fallbackColor, {String? label}) {
    return Container(
      height: 65,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Builder(
          builder: (context) => GestureDetector(
            onTap: () => _showImageDialog(context, side, partText, imagePath),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: Colors.grey[400]!, width: 0.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Stack(
                  children: [
                    // Background image
                    Positioned.fill(
                      child: _buildImageWidget(
                        imagePath,
                        width: double.infinity,
                        height: double.infinity,
                        fallbackColor: fallbackColor,
                        fallbackText: side,
                        fallbackIconSize: 24,
                      ),
                    ),
                    // Text overlay - แสดงเฉพาะเมื่อมีรูป
                    if (imagePath != null && imagePath.isNotEmpty)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                          ),
                          child: Text(
                            partText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context, String title, String subtitle, String? imagePath) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ImageViewerDialog(
          title: title,
          subtitle: subtitle,
          imagePath: imagePath,
        );
      },
    );
  }

  void _showBrakeImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => ImageViewerDialog(
        title: _safeString(kanbanData.brakeName),
        subtitle: "Brake Component",
        imagePath: kanbanData.brakePicture,
      ),
    );
  }
}

// ===== หน้า 2: ปรับใหม่ให้ text, picture, partcode อยู่เสมอกัน =====
// ===== หน้า 2: ปรับ layout ให้รูปแสดงแนวนอนและใช้พื้นที่เต็มที่ =====
class KanbanSecondPage extends StatelessWidget {
  final KanbanModel kanbanData;

  const KanbanSecondPage({super.key, required this.kanbanData});

  // ปรับปรุงฟังก์ชันการจัดการรูปภาพ
  Widget _buildImageWidget(String? filename, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Color? fallbackColor,
    String fallbackText = '',
    double fallbackIconSize = 24,
  }) {
    // ถ้าไม่มีรูป ให้แสดง fallback
    if (filename == null || filename.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: fallbackColor ?? Colors.grey[200],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.image_not_supported,
                size: fallbackIconSize,
                color: Colors.grey[400],
              ),
              if (fallbackText.isNotEmpty) ...[
                SizedBox(height: fallbackIconSize > 20 ? 8 : 4),
                Text(
                  fallbackText,
                  style: TextStyle(
                    fontSize: fallbackIconSize > 20 ? 12 : 8,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      );
    }

    // พยายามแสดงรูป
    String imagePath = filename;
    if (!filename.contains('/')) {
      imagePath = 'assets/images/$filename';
    }

    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // Debug print เพื่อดูว่ารูปไหนโหลดไม่ได้
        print('ไม่สามารถโหลดรูป: $imagePath');
        print('Error: $error');

        return Container(
          width: width,
          height: height,
          color: fallbackColor ?? Colors.grey[200],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.broken_image,
                  size: fallbackIconSize,
                  color: Colors.grey[400],
                ),
                if (fallbackText.isNotEmpty) ...[
                  SizedBox(height: fallbackIconSize > 20 ? 8 : 4),
                  Text(
                    fallbackText,
                    style: TextStyle(
                      fontSize: fallbackIconSize > 20 ? 12 : 8,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper function to safely get string values
  String _safeString(String? value, [String fallback = '']) {
    return value ?? fallback;
  }

  @override
  Widget build(BuildContext context) {
    final projectInfo = kanbanData.projectInfo;

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Text บนสุด - Project Details (ลดความสูง)
          Container(
            height: 60, // ลดความสูงจาก 80 เป็น 60
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.lightBlue[100],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            child: Center(
              child: Text(
                _safeString(projectInfo?.leafSpecs).isNotEmpty
                    ? _safeString(projectInfo?.leafSpecs)
                    : '${_safeString(kanbanData.partCode)} Leaf ${_safeString(kanbanData.shaft)} -${_safeString(kanbanData.sizeName)} H/D ( ${_safeString(kanbanData.axles)} )',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // 2. Picture ตรงกลาง - ขยายให้ใช้พื้นที่เต็มที่
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    // Main Image - เอาการหมุนออก
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () => _showImageDialog(context),
                        child: _buildImageWidget( // เอา Transform.rotate ออก
                          kanbanData.brakePicture,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.contain,
                          fallbackColor: Colors.grey[200],
                          fallbackText: "Project Diagram",
                          fallbackIconSize: 48,
                        ),
                      ),
                    ),
                    // Watermark/Label at corner
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Tap to view',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. PartCode ล่างสุด (ลดความสูง)
          Container(
            height: 60, // ลดความสูงจาก 80 เป็น 60
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.lightBlue[50],
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            child: Center(
              child: Text(
                _safeString(kanbanData.partCode),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => ImageViewerDialog(
        title: _safeString(kanbanData.partCode),
        subtitle: "Project Diagram",
        imagePath: kanbanData.brakePicture,
        rotateImage: false, // เปลี่ยนเป็น false เพื่อไม่ให้หมุนรูปใน dialog
      ),
    );
  }
}

// ===== Image Viewer Dialog - ปรับปรุงเพิ่มการหมุนรูป =====
class ImageViewerDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imagePath;
  final bool rotateImage;

  const ImageViewerDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    this.rotateImage = false, // ค่า default คือ false
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          Center(
            child: rotateImage
                ? Transform.rotate(
              angle: -1.5708, // -90 degrees
              child: _buildDialogContent(),
            )
                : _buildDialogContent(),
          ),
          // Title overlay
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Close button
          Positioned(
            top: 40,
            right: 20,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                padding: const EdgeInsets.all(12),
              ),
            ),
          ),
          // Tap to close
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              behavior: HitTestBehavior.translucent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogContent() {
    // ถ้าไม่มีรูป ให้แสดง placeholder
    if (imagePath == null || imagePath!.isEmpty) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.image_not_supported, size: 80, color: Colors.white54),
              const SizedBox(height: 16),
              const Text(
                "ไม่มีรูปภาพ",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    // พยายามแสดงรูป
    String fullPath = imagePath!;
    if (!imagePath!.contains('/')) {
      fullPath = 'assets/images/$imagePath';
    }

    return Image.asset(
      fullPath,
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (ctx, error, stackTrace) {
        print('ไม่สามารถโหลดรูปใน Dialog: $fullPath');
        print('Error: $error');

        return Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.broken_image, size: 80, color: Colors.white54),
                const SizedBox(height: 16),
                const Text(
                  "ไม่พบรูปภาพ",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  fullPath.split('/').last,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ===== Image Viewer Dialog - ปรับปรุงแล้ว =====
