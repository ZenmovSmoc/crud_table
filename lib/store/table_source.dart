import 'package:crud_table/model/data_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DataSource<T extends DataModel> extends DataTableSource {
  DataSource(this.data);

  final List<T> data;

  int _selectedCount = 0;

  DateTime lastUpdateTime = DateTime.now();

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);

    final DataModel item = data[index];
    print(item);
    return DataRow.byIndex(
      index: index,
      cells: createDataCell(item),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => _selectedCount;

  List<DataCell> createDataCell(DataModel item) {
    List<DataCell> cells = [];
    final params = item.getDisplayParamsList();
    final map = item.toMap();

    params.forEach(
      (element, type) {
        // if (type == GeoPoint) {
        //   cells.add(
        //     _geoPointDataCell(map[element]),
        //   );
        // } else
        if (type == DateTime) {
          cells.add(
            _dateTimeCell(map[element]),
          );
          // } else if (type == ReservationsStatus) {
          //   cells.add(
          //     _reservationStatusCell(item, element),
          //   );
          // }
        } else if (type == Image) {
          cells.add(
            _imageCell(map[element]),
          );
        } else {
          cells.add(
            _defaultDataCell(map[element]),
          );
        }
      },
    );

    // add edit and delete button
    // if (editable) {
    //   cells.insert(
    //     0,
    //     DataCell(
    //       IconButton(
    //         icon: const Icon(Icons.edit),
    //         onPressed: () {
    //           editHandler(item);
    //         },
    //       ),
    //     ),
    //   );

    //   cells.add(
    //     DataCell(
    //       IconButton(
    //         icon: const Icon(Icons.delete),
    //         onPressed: () {
    //           deleteHandler(item);
    //         },
    //       ),
    //     ),
    //   );
    // }

    // ToDo: 更新時に
    if (lastUpdateTime == null) {
      cells.insert(
        0,
        DataCell(
          Text(''),
        ),
      );
    } else if (map['createdAt'] != null &&
        lastUpdateTime.isBefore(map['createdAt'])) {
      cells.insert(
        0,
        DataCell(
          Container(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: Text(
                'New Data',
                style: TextStyle(color: Colors.white),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.deepOrange,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    } else if (map['updatedAt'] != null &&
        lastUpdateTime.isBefore(map['updatedAt'])) {
      cells.insert(
        0,
        DataCell(
          Container(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: Text(
                'Latest Update',
                style: TextStyle(color: Colors.white),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.deepOrange,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    } else {
      cells.insert(
        0,
        DataCell(
          Text(''),
        ),
      );
    }

    return cells;
  }

  // DataCell _geoPointDataCell(GeoPoint data) {
  //   return DataCell(
  //     IconButton(
  //       icon: const Icon(Icons.location_on),
  //       onPressed: () {
  //         mapButtonHandler(data);
  //       },
  //     ),
  //   );
  // }

  DataCell _dateTimeCell(DateTime? data) {
    final formatter = DateFormat('yyyy-MM-dd HH:mm');
    return data != null
        ? DataCell(
            Text('${formatter.format(data)}'),
          )
        : const DataCell(Text(''));
  }

  // DataCell _reservationStatusCell(DataModel item, String key) {
  //   final data = item.toMap();

  //   if (data[key] == 4 && data['planLaundryOutAt'] == null) {
  //     return DataCell(
  //       Center(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(getReservationStatusString(data[key]) ?? ''),
  //             RaisedButton(
  //               child: const Text('Laundry done'),
  //               onPressed: () {
  //                 statusChangedHandler(
  //                   item,
  //                   DateTime.now(),
  //                 );
  //               },
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   } else if (data[key] == 4 && data['planLaundryOutAt'] != null) {
  //     return DataCell(
  //       Center(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(getReservationStatusString(data[key]) ?? ''),
  //             RaisedButton(
  //               child: const Text('Re open'),
  //               onPressed: () {
  //                 item.setParameter('planLaundryOutAt', null);
  //                 statusChangedHandler(item, null);
  //               },
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }
  //   return DataCell(
  //     Text(getReservationStatusString(data[key]) ?? ''),
  //   );
  // }

  DataCell _imageCell(String data) {
    return DataCell(
      Container(
        height: 90,
        width: 90,
        // child: Image(
        //   fit: BoxFit.contain,
        //   imageUrl: data ?? "",
        //   errorWidget: (context, url, error) {
        //     return const Icon(Icons.broken_image);
        //   },
        // ),
      ),
    );
  }

  DataCell _defaultDataCell(dynamic data) {
    return DataCell(
      Text('${data ?? ''}'),
    );
  }
}
