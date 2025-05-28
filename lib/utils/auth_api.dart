// import 'dart:convert';

// import 'package:sowda_app/utils/constants.dart';
// import 'package:sowda_app/utils/models.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:http/http.dart' as http;

// Future<dynamic> userAuth(String phoneNumber)async {
//   Map body={
//     'phone_number':phoneNumber
//   };

//   var url=Uri.parse('$baseUrl/user/auth/login/');
//   var  res = await http.post(url,body:body);

//   if(res.statusCode==200){
//     Map json=jsonDecode(res.body);
//     String token = json['key'];
//     var box=await Hive.openBox(tokenBox);
//     box.put('token',token);
//     UserToken? user=await getUser(token);
//     return user;
//   }else{
//     return null;
//   }
// }

// Future<UserToken?> getUser(String token)async{
//   var url = Uri.parse('$baseUrl/user/auth/user/');
//   var res = await http.get(url,headers: {'Authorization':'Token $token'});

//   if(res.statusCode == 200){
//     var json = jsonDecode(res.body);
//     UserToken user= UserToken.fromJson(json);
//     user.token=token;
//     return user;
//   }else{
//     return null;
//   }
// }
