// lib/presentation/database_screen/database_screen.dart
import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_drop_down.dart';
import '../../model/camera_user_detected.dart';
import 'package:sriram_s_application3/Services/api_service.dart';

class DatabaseScreen extends StatefulWidget {
  DatabaseScreen({Key? key}) : super(key: key);

  @override
  _DatabaseScreenState createState() => _DatabaseScreenState();
}

class _DatabaseScreenState extends State<DatabaseScreen> {
  final ApiService apiService = ApiService();
  final dropdownItemList = List<String>.generate(31, (index) => (index + 1).toString());
  final dropdownItemList1 = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];
  final dropdownItemList2 = List<String>.generate(100, (index) => (2024 + index).toString());
  String selectedDate = "1";
  String selectedMonth = "April";
  String selectedYear = "2023";
  List<Result> detectedFaces = [];

  @override
  void initState() {
    super.initState();
    fetchDetectedFaces();
  }

  Future<void> fetchDetectedFaces() async {
    final monthIndex = dropdownItemList1.indexOf(selectedMonth) + 1;
    final faces = await apiService.getDetectedFaces(
      date: selectedDate,
      month: monthIndex.toString(),
      year: selectedYear,
    );
    setState(() {
      detectedFaces = faces.results ?? [];
    });
  }

  void _renameFace(Result face) async {
    final TextEditingController controller = TextEditingController(text: face.name ?? "");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Rename Face"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "Enter new name"),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String newName = controller.text.trim();
              if (newName.isNotEmpty) {
                final updated = await apiService.renameFace(face.id!, newName);
                if (updated) {
                  fetchDetectedFaces();
                }
              }
              Navigator.of(context).pop();
            },
            child: Text("Save"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            SizedBox(height: 39.v),
            _buildRowDatabase(context),
            SizedBox(height: 22.v),
            _buildDateSelection(),
            SizedBox(height: 24.v),
            _buildDetectedFacesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRowDatabase(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 29.h, right: 24.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4.v),
            child: Text(
              "Database",
              style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white),
            ),
          ),
          IconButton(
            onPressed: () {
              onTapBtnIconButton(context);
            },
            icon: Icon(Icons.notifications_none, color: Colors.white, size: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelection() {
    return Padding(
      padding: EdgeInsets.only(left: 29.h, right: 17.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomDropDown(
            width: 70.h,
            hintStyle: TextStyle(fontSize: 13, color: Colors.black),
            textStyle: TextStyle(fontSize: 14, color: Colors.black),
            contentPadding: EdgeInsets.only(left: 15.h, top: 7.5.h, bottom: 7.5.h),
            items: dropdownItemList,
            hintText: selectedDate,
            onChanged: (value) {
              setState(() {
                selectedDate = value;
                fetchDetectedFaces();
              });
            },
          ),
          SizedBox(width: 9.h),
          CustomDropDown(
            width: 140.h,
            hintStyle: TextStyle(fontSize: 13, color: Colors.black),
            textStyle: TextStyle(fontSize: 14, color: Colors.black),
            contentPadding: EdgeInsets.only(left: 10.h, top: 7.5.h, bottom: 7.5.h),
            items: dropdownItemList1,
            hintText: selectedMonth,
            onChanged: (value) {
              setState(() {
                selectedMonth = value;
                fetchDetectedFaces();
              });
            },
          ),
          SizedBox(width: 9.h),
          CustomDropDown(
            width: 95.h,
            hintStyle: TextStyle(fontSize: 13, color: Colors.black),
            textStyle: TextStyle(fontSize: 14, color: Colors.white),
            contentPadding: EdgeInsets.only(left: 15.h, top: 7.5.h, bottom: 7.5.h),
            items: dropdownItemList2,
            hintText: selectedYear,
            onChanged: (value) {
              setState(() {
                selectedYear = value;
                fetchDetectedFaces();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetectedFacesList() {
    return Expanded(
      child: detectedFaces.isEmpty
          ? Center(child: Text("No detected faces", style: TextStyle(color: Colors.white)))
          : ListView.builder(
        itemCount: detectedFaces.length,
        itemBuilder: (context, index) {
          final face = detectedFaces[index];
          return ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 8.v),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(face.embedding ?? ''),
              radius: 30.h,
            ),
            title: Text(
              face.name ?? "Unknown ${face.id}",
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              face.createdAt ?? "",
              style: TextStyle(color: Colors.grey),
            ),
            trailing: IconButton(
              icon: Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                _renameFace(face);
              },
            ),
            tileColor: face.name != null ? Colors.grey[850] : Colors.red[900],
          );
        },
      ),
    );
  }

  void onTapBtnIconButton(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.notificationsScreen);
  }
}
