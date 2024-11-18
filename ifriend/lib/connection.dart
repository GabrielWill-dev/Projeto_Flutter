import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

void main(List<String> arguments) async{
final conn = await MySqlConnection.connect(ConnectionSettings(
      host: '143.106.241.3',
      port: 3306,
      user: 'cl203156',
      db: 'cl203156',
      password: 'cl*27042003'
      )
      );

      print(await conn.query('select * from tbusuarios'));


}