import 'package:flutter/material.dart';
import 'package:lacakind_frontend/styles/color.styles.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(hintText: "Search by Serial Number"),
            ),
            SizedBox(height: 12),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: neutral300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Checkbox(value: true, onChanged: (value) {}),
                                SizedBox(width: 8),
                                Text("Select all"),
                              ],
                            ),
                          ),
                          Expanded(child: Text("Serial Number")),
                          Expanded(child: Text("Model")),
                          Expanded(child: Text("Status")),
                          Expanded(child: Text("Location")),
                          Expanded(child: Text("Client")),
                          Expanded(child: Text("Contracts")),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    Expanded(
                      child: ListView.separated(
                        itemBuilder: (context, index) {
                          return Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: neutral300),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Checkbox(
                                    value: true,
                                    onChanged: (value) {},
                                  ),
                                ),
                                Expanded(child: Text("SN3123123")),
                                Expanded(child: Text("CyberTruck")),
                                Expanded(child: Text("Status")),
                                Expanded(child: Text("Location")),
                                Expanded(child: Text("Client")),
                                Expanded(child: Text("Contracts")),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 10),
                        itemCount: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
