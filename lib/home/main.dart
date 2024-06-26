import 'package:countertop_drawer/feat_canvas/canvas_widget.dart'; // Custom canvas widget
import 'package:countertop_drawer/home/gxc/home_controller.dart'; // Controller for the home page
import 'package:countertop_drawer/utils/app_strings.dart'; // App strings for localization
import 'package:flutter/material.dart'; // Flutter material design package
import 'package:get/get.dart'; // GetX package for state management

void main() {
  runApp(const MyApp()); // Main entry point of the app
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppString.appName, // Setting the app title
      theme: ThemeData(
        primarySwatch: Colors.blue, // Setting the primary theme color
      ),
      home: HomePage(), // Setting the home page of the app
    );
  }
}

class HomePage extends StatelessWidget {
  final HomeController homeController = Get.put(
      HomeController()); // Instantiating and injecting the HomeController

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppString.appName), // App bar title
        actions: [
          PopupMenuButton<String>(
            onSelected: (option) => homeController
                .selectOption(option), // Handling menu option selection
            itemBuilder: (BuildContext context) {
              return {
                AppString.newKitchenCounterTop,
                AppString.newIsland,
                AppString.exportToDXFFile
              }.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice), // Displaying menu options
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Obx(() => CanvasWidget(
            selectedOption: homeController.selectedOption
                .value, // Binding selected option from controller
            rectangles:
                homeController.rectangles, // Binding rectangles from controller
          )),
    );
  }
}
