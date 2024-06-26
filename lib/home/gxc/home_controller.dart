import 'package:countertop_drawer/feat_canvas/widgets/custom_rect.dart';
import 'package:countertop_drawer/utils/app_strings.dart';
import 'package:get/get.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:dxf/dxf.dart';

class HomeController extends GetxController {
  var selectedOption = AppString.newKitchenCounterTop.obs;
  var rectangles = <CustomRect>[].obs;

  // Method to handle selection of an option
  void selectOption(String option) {
    if (option.toLowerCase() == AppString.exportToDXFFile.toLowerCase()) {
      exportToDXF(
          rectangles); // Export to DXF if the selected option is to export
      return;
    }
    selectedOption.value = option; // Update the selected option
  }

  // Method to export rectangles to a DXF file
  void exportToDXF(List<CustomRect> rectangles) async {
    var docDir = await getApplicationDocumentsDirectory();
    var path = join(docDir.path, 'drawing.dxf');
    var dxf = await DXF.create(path);

    // Add rectangles as poly lines to the DXF document
    for (var rect in rectangles) {
      var entity = AcDbPolyline(
        dxf.nextHandle,
        vertices: [
          [rect.left, rect.top],
          [rect.left + rect.width, rect.top],
          [rect.left + rect.width, rect.top + rect.height],
          [rect.left, rect.top + rect.height],
          [rect.left, rect.top],
        ],
      );
      dxf.addEntities(entity);
    }

    await dxf.save(); // Save the DXF document

    // Prepare and send an email with the DXF file attached
    Email email = Email(
      body: AppString.pleaseFindTheDXFFileAttahed,
      subject: AppString.dxfFile,
      recipients: ['test@gmail.com'],
      attachmentPaths: [path],
      isHTML: false,
    );

    await FlutterEmailSender.send(email); // Send the email
  }
}
