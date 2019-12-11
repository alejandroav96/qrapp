import 'package:flutter/material.dart';
import 'package:qrapp/models/data.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class DetailScreen extends StatelessWidget {
  final List<Data> data;
  final String title;
  final bool animate = true;

  static List<charts.Series<Data, String>> _createSampleData(data, title) {
    return [
      new charts.Series<Data, String>(
        id: title,
        //colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (Data sales, _) => sales.getId(),
        measureFn: (Data sales, _) => sales.getCount(),
        data: data,
      )
    ];
  }

  // In the constructor, require a Data.
  DetailScreen({Key key, @required this.data, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SizedBox(
            width: 450.0,
            height: 300.0,
            child: new charts.PieChart(
              _createSampleData(data, title),
              animate: animate,
              behaviors: [
                new charts.DatumLegend(
                  position: charts.BehaviorPosition.end,
                  horizontalFirst: false,
                  cellPadding: new EdgeInsets.only(right: 4.0, bottom: 4.0),
                  showMeasures: true,
                  legendDefaultMeasure: charts.LegendDefaultMeasure.firstValue,
                  measureFormatter: (num value) {
                    return value == null ? '-' : '${value}';
                  },
                ),
              ],
            )),
      ),
    );
  }
}