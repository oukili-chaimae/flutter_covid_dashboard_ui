import 'package:flutter/material.dart';
import 'package:flutter_covid_dashboard_ui/screens/intances.dart';
import 'package:flutter_covid_dashboard_ui/screens/qr_code.dart';
import 'package:flutter_covid_dashboard_ui/screens/scan_page.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DetailsScreen extends StatefulWidget {
  final MyQrCode qrCode;
  final Function callback;
  const DetailsScreen({Key? key, required this.qrCode, required this.callback})
      : super(key: key);

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  String dropdownValue = "PCR";
  bool isSwitched = false;
  DateTime currentDate = DateTime.now();
  String? errorOthers;
  TextEditingController otherController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Details"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextButton(
              onPressed: () {
                DatePicker.showDatePicker(context,
                    showTitleActions: true,
                    onChanged: (date) {}, onConfirm: (date) {
                  setState(() {
                    currentDate = date;
                  });
                }, currentTime: DateTime.now(), locale: LocaleType.fr);
              },
              child: Text(
                formatDate(currentDate),
                style: const TextStyle(color: Colors.blue),
              )),
          Container(
            child: widget.qrCode.type != 'qrCode'
                ? Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: ListTile(
                      leading: Text(widget.qrCode.type.toString()),
                      title: Text(widget.qrCode.content.toString()),
                    ),
                  )
                : QrImage(
                    data: widget.qrCode.content.toString(),
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
            child: DropdownButton<String>(
              value: dropdownValue,
              isExpanded: true,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              underline: Container(
                height: 3,
                color: Theme.of(context).primaryColor,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                });
              },
              items: <String>['PCR', 'Pass Covid', 'Autorisation', 'Autre']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          dropdownValue == 'Autre'
              ? Padding(
                  padding:
                      const EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
                  child: TextField(
                    decoration: InputDecoration(errorText: errorOthers),
                    controller: otherController,
                  ),
                )
              : const SizedBox(
                  width: 0.0,
                ),
          dropdownValue == 'PCR'
              ? Padding(
                  padding:
                      const EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
                  child: Row(
                    children: [
                      const Text("Covid positive"),
                      Switch(
                        value: isSwitched,
                        onChanged: (value) {
                          setState(() {
                            isSwitched = value;
                          });
                        },
                        activeTrackColor: Colors.lightGreenAccent,
                        activeColor: Colors.green,
                      ),
                    ],
                  ),
                )
              : const SizedBox(
                  width: 0.0,
                ),
          ElevatedButton(
              onPressed: () {
                if (dropdownValue == 'Autre') {
                  if (otherController.value.text.toString().isEmpty) {
                    setState(() {
                      errorOthers = "Vous devez choisir un type!";
                    });
                    return;
                  }
                  errorOthers = null;
                  widget.qrCode.type = otherController.value.text.toString();
                } else {
                  widget.qrCode.type = dropdownValue;
                }
                widget.qrCode.pcr = isSwitched;
                widget.qrCode.date = currentDate;
                myData.box.put(widget.qrCode);
                widget.callback(widget.qrCode);
              },
              child: const Text("Validate"))
        ],
      ),
    );
  }
}
