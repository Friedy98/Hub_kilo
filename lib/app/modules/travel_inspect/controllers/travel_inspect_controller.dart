import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../common/ui.dart';
import '../../../../main.dart';
import '../../../models/option_model.dart';
import 'package:http/http.dart' as http;

import '../../../repositories/upload_repository.dart';
import '../../global_widgets/packet_image_field_widget.dart';
import '../../userBookings/controllers/bookings_controller.dart';

class TravelInspectController extends GetxController {
  final currentSlide = 0.obs;
  final quantity = 1.obs;
  final dimension = 1.obs;
  final description = ''.obs;
  final travelCard = {}.obs;
  final imageUrl = "".obs;
  final bookingStep = 0.obs;
  final elevation = 0.obs;
  final name = "".obs;
  final email = "".obs;
  final phone = "".obs;
  final address = "".obs;
  final selectUser = false.obs;
  var receiverId = 0.obs;
  final buttonPressed = false.obs;
  var url = ''.obs;
  var selectedIndex = 0.obs;
  var currentIndex = 0.obs;
  var status = ''.obs;
  var accept = false.obs;
  var reject = false.obs;
  var selected = false.obs;
  var users =[].obs;
  var travelBookings = [].obs;
  var list = [];
  var listAir =[];
  var listRoad =[];
  var resetusers =[].obs;
  var transferBooking = false.obs;
  var transferBookingId = ''.obs;

  var visible = true.obs;

  UploadRepository _uploadRepository;
  TravelInspectController() {
    _uploadRepository = new UploadRepository();
    Get.lazyPut<BookingsController>(
          () => BookingsController(),
    );

  }

  @override
  void onInit() async {
    transferBooking = Get.find<BookingsController>().transferBooking;
    print("transfer "+transferBooking.toString());
    transferBookingId =Get.find<BookingsController>().bookingIdForTransfer;
    var arguments = Get.arguments as Map<String, dynamic>;
    travelCard.value = arguments['travelCard'];


    listAir = await getAirBookingsOnTravel(travelCard['id']);
    listRoad = await getRoadBookingsOnTravel(travelCard['id']);

    travelCard['travel_type'] == "Air"?
    list = listAir
        :travelCard['travel_type'] == "Sea"?list =[]
    : list = listRoad;

    travelBookings.value = list;
    if(travelCard['travel_type'].toLowerCase() == "air"){
      imageUrl.value = "https://images.unsplash.com/photo-1570710891163-6d3b5c47248b?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NHx8Y2FyZ28lMjBwbGFuZXxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=900&q=60";
    }else if(travelCard['travel_type'].toLowerCase() == "sea"){
      imageUrl.value = "https://media.istockphoto.com/id/591986620/fr/photo/porte-conteneurs-de-fret-générique-en-mer.jpg?b=1&s=170667a&w=0&k=20&c=gZmtr0Gv5JuonEeGmXDfss_yg0eQKNedwEzJHI-OCE8=";
    }else{
      imageUrl.value = "https://media.istockphoto.com/id/859916128/photo/truck-driving-on-the-asphalt-road-in-rural-landscape-at-sunset-with-dark-clouds.jpg?s=612x612&w=0&k=20&c=tGF2NgJP_Y_vVtp4RWvFbRUexfDeq5Qrkjc4YQlUdKc=";
    }
    await getAllUsers();
    super.onInit();
  }

  @override
  void onReady() async {
    await refreshEService();
    super.onReady();
  }

  Future refreshEService() async {
    onInit();
  }

  Future getAirBookingsOnTravel(int id)async{

    final box = GetStorage();
    var session_id = box.read("session_id");

    var headers = {
      'Cookie': 'frontend_lang=en_US; $session_id'
    };
    var request = http.Request('GET', Uri.parse('${Domain.serverPort}/air/current/user/travel/books/$id'));
    request.body = '''{\r\n  "jsonrpc": "2.0"\r\n}''';
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      print(data);
      return json.decode(data);
    }
    else {
      print(response.reasonPhrase);
    }
  }

  getRoadBookingsOnTravel(int id)async{
    final box = GetStorage();
    var session_id = box.read("session_id");
    var headers = {
      'Cookie': 'frontend_lang=en_US; '+session_id.toString()
    };
    var request = http.Request('GET', Uri.parse(Domain.serverPort+'/road/current/user/travel/books/2'));
    request.body = '''{\r\n  "jsonrpc": "2.0"\r\n}''';
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      print(data);
      return json.decode(data);
    }
    else {
      print(response.reasonPhrase);
    }

  }

  acceptAirBooking(int id)async{
    final box = GetStorage();
    var session_id = box.read('session_id');
    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'frontend_lang=en_US; '+session_id.toString()
    };
    var request = http.Request('PUT', Uri.parse(Domain.serverPort+'/air/accept/booking/$id'));
    request.body = json.encode({
      "jsonrpc": "2.0"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      if(json.decode(data)['result'] != null){
        Get.showSnackbar(Ui.SuccessSnackBar(message: "Booking accepted ".tr));
        Navigator.pop(Get.context);
      }else{
        Get.showSnackbar(Ui.ErrorSnackBar(message: "An error occured!".tr));
      }
    }
    else {
      print(response.reasonPhrase);
      Get.showSnackbar(Ui.ErrorSnackBar(message: "An error occured!".tr));
    }
  }

  rejectAirBooking(int id)async{
    final box = GetStorage();
    var session_id = box.read('session_id');
    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'frontend_lang=en_US; '+session_id.toString()
    };
    var request = http.Request('PUT', Uri.parse(Domain.serverPort+'/air/reject/booking/$id'));
    request.body = json.encode({
      "jsonrpc": "2.0"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      if(json.decode(data)['result'] != null){
        Get.showSnackbar(Ui.SuccessSnackBar(message: "Booking rejected ".tr));
        Navigator.pop(Get.context);
      }else{
        Get.showSnackbar(Ui.ErrorSnackBar(message: "An error occured!".tr));
      }
    }
    else {
      print(response.reasonPhrase);
      Get.showSnackbar(Ui.ErrorSnackBar(message: "An error occured!".tr));

    }
  }


  acceptRoadBooking(int id)async{
    final box = GetStorage();
    var session_id = box.read('session_id');
    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'frontend_lang=en_US; '+session_id.toString()
    };
    var request = http.Request('PUT', Uri.parse(Domain.serverPort+'/road/accept/booking/'+id.toString()));
    request.body = json.encode({
      "jsonrpc": "2.0"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      if(json.decode(data)['result'] != null){
        Get.showSnackbar(Ui.SuccessSnackBar(message: "Booking accepted ".tr));
        Navigator.pop(Get.context);
      }else{
        Get.showSnackbar(Ui.ErrorSnackBar(message: "An error occured!".tr));
      }
    }
    else {
      Get.showSnackbar(Ui.ErrorSnackBar(message: "An error occured!".tr));
    }

  }

  rejectRoadBooking(int id)async{
    final box = GetStorage();
    var session_id = box.read('session_id');
    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'frontend_lang=en_US; '+session_id.toString()
    };
    var request = http.Request('PUT', Uri.parse(Domain.serverPort+'/road/reject/booking/'+id.toString()));
    request.body = json.encode({
      "jsonrpc": "2.0"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      if(json.decode(data)['result'] != null){
        Get.showSnackbar(Ui.SuccessSnackBar(message: "Booking rejected ".tr));
        Navigator.pop(Get.context);
      }else{
        Get.showSnackbar(Ui.ErrorSnackBar(message: "An error occured!".tr));
      }
    }
    else {
      Get.showSnackbar(Ui.ErrorSnackBar(message: "An error occured!".tr));
    }

  }

  deleteAirTravel(int id)async{
    final box = GetStorage();
    var session_id = box.read("session_id");
    var headers = {
      'Cookie': 'frontend_lang=en_US; $session_id'
    };
    var request = http.Request('DELETE', Uri.parse('${Domain.serverPort}/air/api/travel/delete/$id'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      if(json.decode(data)['status'] == 200){
        Get.showSnackbar(Ui.SuccessSnackBar(message: "${json.decode(data)['message']}".tr));
        Navigator.pop(Get.context);
      }else{
        Get.showSnackbar(Ui.ErrorSnackBar(message: "An error occured!".tr));
      }
    }
    else {
      print(response.reasonPhrase);
    }
  }


  deleteRoadTravel(int id)async{
    final box = GetStorage();
    var session_id = box.read("session_id");
    var headers = {
      'Cookie': 'frontend_lang=en_US; $session_id'
    };
    var request = http.Request('DELETE', Uri.parse('${Domain.serverPort}/road/api/travel/delete/$id'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      if(json.decode(data)['status'] == 200){
        Get.showSnackbar(Ui.SuccessSnackBar(message: "${json.decode(data)['message']}".tr));
        Navigator.pop(Get.context);
      }else{
        Get.showSnackbar(Ui.ErrorSnackBar(message: "An error occured!".tr));
      }
    }
    else {
      print(response.reasonPhrase);
    }
  }


  Future getEService() async {

  }

  Future getReviews() async {

  }

  bookAirNow(int travelId)async{
    final box = GetStorage();
    var session_id = box.read('session_id');
    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'frontend_lang=en_US; $session_id'
    };
    var request = http.Request('POST', Uri.parse('${Domain.serverPort}/air/travel/booking/create'));
    if(selectUser.value) {
      print(true);
      print(receiverId.value.toString());
      request.body = json.encode({
        "jsonrpc": "2.0",
        "params": {
          "travel_id": travelId,
          "receiver_partner_id": receiverId.value,
          "type_of_luggage": description.value,
          "kilo_booked": quantity.value
        }
      });
    }else{
      request.body = json.encode({
        "jsonrpc": "2.0",
        "params": {
          "travel_id": travelId,
          "receiver_name": name.value,
          "receiver_email": email.value,
          "receiver_phone": phone.value,
          "receiver_address": address.value,
          "type_of_luggage": description.value,
          "kilo_booked": quantity.value
        }
      });
    }
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(
        "${name.value}, ${email.value}, ${phone.value} ${address.value} ${description.value} ${quantity.value}"
      );
      var data = await response.stream.bytesToString();
      print(data);
      if(json.decode(data)['result']['success'] != false){
        await setAirPacketImage(json.decode(data)["result"]["response"]["booking_id"]);
        Get.showSnackbar(Ui.SuccessSnackBar(message: "Book success ".tr));
        Navigator.pop(Get.context);
      }else{
        Get.showSnackbar(Ui.ErrorSnackBar(message: "An error occured!".tr));
      }
    }
    else {
      var data = await response.stream.bytesToString();
      print(data);
      Get.showSnackbar(Ui.ErrorSnackBar(message: "An error occured!".tr));
    }
  }


  bookRoadNow(int travelId)async{
    final box = GetStorage();
    var session_id = box.read('session_id');
    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'frontend_lang=en_US; '+session_id.toString()
    };
    var request = http.Request('POST', Uri.parse(Domain.serverPort+'/road/travel/booking/create'));
    if(selectUser.value) {
      request.body = json.encode({
        "jsonrpc": "2.0",
        "params": {
          "travel_id": travelId,
          "receiver_partner_id": receiverId.value,
          "luggage_dimension": dimension.value,
          "luggage_weight": quantity.value,
          "type_of_luggage": description.value
        }
      });
    }
    else{
      request.body = json.encode({
        "jsonrpc": "2.0",
        "params": {
          "travel_id": travelId,
          "receiver_name": name.value,
          "receiver_email": email.value,
          "receiver_phone": phone.value,
          "receiver_address": address.value,
          "luggage_dimension": dimension.value,
          "luggage_weight": quantity.value,
          "type_of_luggage": description.value
        }
      });
    }
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      print(data);
      if(json.decode(data)['result']['success'] != false){
        await setRoadPacketImage(json.decode(data)["result"]["response"]["booking_id"]);
        Get.showSnackbar(Ui.SuccessSnackBar(message: "Book success ".tr));
        Navigator.pop(Get.context);
      }else{
        Get.showSnackbar(Ui.ErrorSnackBar(message: "An error occured!".tr));
      }
    }
    else {
      Get.showSnackbar(Ui.ErrorSnackBar(message: "An error occured!".tr));
    }

  }


  transferNow(int travelId)async{
    print("Transfer booking Id: "+transferBookingId.value);
    print("Travel Id: "+travelId.toString());
    final box = GetStorage();
    var session_id = box.read('session_id');
    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'frontend_lang=en_US; '+session_id.toString()
    };
    var request = http.Request('PUT', Uri.parse(Domain.serverPort+'/air/current/user/transfer/booking/'+transferBookingId.value));
    request.body = json.encode({
      "jsonrpc": "2.0",
      "params": {
        "new_travel_id": travelId
      }
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      print(data);
      if(json.decode(data)['result'] != null){

        Get.showSnackbar(Ui.SuccessSnackBar(message: "Transfer success ".tr));
        Get.find<BookingsController>().transferBooking.value = false;
        Navigator.pop(Get.context);
      }else{
        Get.showSnackbar(Ui.ErrorSnackBar(message: "An error occured!".tr));

      }
    }
    else {
      print(response.reasonPhrase);
      Get.showSnackbar(Ui.ErrorSnackBar(message: "An error occured!".tr));
      Get.find<BookingsController>().transferBooking.value = false;
    }



  }

  getAllUsers()async{
    final box = GetStorage();
    var session_id = box.read('session_id');
    var headers = {
      'Content-Type': 'text/plain',
      'Cookie': 'frontend_lang=en_US; '+session_id.toString()
    };
    var request = http.Request('GET', Uri.parse(Domain.serverPort+'/hubkilo/all/partners'));
    request.body = '''{\r\n     "jsonrpc": "2.0"\r\n}''';
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = await response.stream.bytesToString();
      users.value= json.decode(data);
      resetusers.value= json.decode(data);
      print(users);
    }
    else {
      print(response.reasonPhrase);
    }

  }

  TextStyle getTitleTheme(Option option) {
    if (option.checked.value) {
      return Get.textTheme.bodyText2.merge(TextStyle(color: Get.theme.colorScheme.secondary));
    }
    return Get.textTheme.bodyText2;
  }

  TextStyle getSubTitleTheme(Option option) {
    if (option.checked.value) {
      return Get.textTheme.caption.merge(TextStyle(color: Get.theme.colorScheme.secondary));
    }
    return Get.textTheme.caption;
  }

  Color getColor(Option option) {
    if (option.checked.value) {
      return Get.theme.colorScheme.secondary.withOpacity(0.1);
    }
    return null;
  }

  void incrementQuantity() {
    quantity.value < 1000 ? quantity.value++ : null;
  }

  void decrementQuantity() {
    quantity.value > 1 ? quantity.value-- : null;
  }


  Future setAirPacketImage (bookingId)async{
    Get.lazyPut<PacketImageFieldController>(
          () => PacketImageFieldController(),
    );
    File imageFile = Get.find<PacketImageFieldController>().image.value;
    if (imageFile != null) {
      try {
        //await deleteUploaded();
        await _uploadRepository.airImagePacket(imageFile, bookingId);
      } catch (e) {
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }
    } else {
      Get.showSnackbar(Ui.ErrorSnackBar(message: "Please select an image file".tr));
    }
  }

  Future setRoadPacketImage (bookingId)async{
    Get.lazyPut<PacketImageFieldController>(
          () => PacketImageFieldController(),
    );
    File imageFile = Get.find<PacketImageFieldController>().image.value;
    if (imageFile != null) {
      try {
        //await deleteUploaded();
        await _uploadRepository.roadImagePacket(imageFile, bookingId);
      } catch (e) {
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }
    } else {
      Get.showSnackbar(Ui.ErrorSnackBar(message: "Please select an image file".tr));
    }
  }


}
