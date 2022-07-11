import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
import 'package:ruangkeluarga/global/global.dart';

import '../../../model/cobrand_program_content_model.dart';

class FeedController extends GetxController {
  late List<ContentModel> listContent;
  late List<ContentModel> listSearchContent;
  late List<CoBrandModel> listCoBrand;
  late List<ProgramModel> listProgram;
  late List<ProgramModel> listSearchProgram;
  late List<ContentModel> listProgramContent;

  //-1 itu All, 0~... itu tergantung index pada list cobrand
  int selectedCoBrand = -1;
  String selectedCoBrandEmail = '';

  final api = MediaRepository();
  Future<bool>? fGetListContent, fGetListCoBrand, fGetListProgram,
      fGetListProgramContent;
  String jenisArtikel = 'artikel';
  String lastUpdated = DateTime.now().toIso8601String();
  final ScrollController scrollController = new ScrollController();
  int offset = 0;
  final limit = 5;
  bool isThereMore = true;
  bool isWaiting = false;
  bool isProgramThereMore = true;
  bool isProgramWaiting = false;
  //bool stillSearching = false;
  String search = '';

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    fGetListContent = getContents();
    fGetListProgram = getPrograms();
    fGetListCoBrand = getCoBrand();
    fGetListProgramContent= getProgramContents();
  }

  void _scrollListener() {
    // print("Ini anu: ${scrollController.position.extentAfter}");
    if (jenisArtikel == 'artikel') {
      if (scrollController.position.extentAfter < 100 &&
          isThereMore &&
          !isWaiting) {
        isWaiting = true;
        offset = offset + limit;
        fGetListContent = getContents();
      }
    } else {
      if (scrollController.position.extentAfter < 100 &&
          isProgramThereMore &&
          !isProgramWaiting) {
        isProgramWaiting = true;
        offset = offset + limit;
        fGetListProgram = getPrograms();
      }
    }
  }

  Future<bool> getContents({bool refresh = false, String cobrand = ''}) async {
    if (refresh == true) {
      lastUpdated = DateTime.now().toIso8601String();
      offset = 0;
      isThereMore = true;
    }
    if (cobrand == 'all')
      selectedCoBrandEmail = '';
    else if (cobrand != '') selectedCoBrandEmail = cobrand;
    final res = await api.fetchCoBrandContents(lastUpdated, limit, offset,
        key: search, email: selectedCoBrandEmail);
    if (res.statusCode == 200) {
      // print('print res fetchCoBrandContents ${res.body}');
      final json = jsonDecode(res.body);
      if (json['resultCode'] == "OK") {
        List contents = json['contents'];
        if (offset == 0)
          listContent = contents.map((e) => ContentModel.fromJson(e)).toList();
        else
          listContent += contents.map((e) => ContentModel.fromJson(e)).toList();
        listSearchContent = listContent;
        update();
        if (contents.length < 5) {
          isThereMore = false;
        }
        isWaiting = false;
        return true;
      }
    }
    print("Ini error contentnya: $res");
    listContent = [];
    return false;
  }

  Future<bool> getProgramContents({bool refresh = false,
    String programId = ''}) async {
    if (refresh == true) {
      lastUpdated = DateTime.now().toIso8601String();
      offset = 0;
      isThereMore = true;
    }
    final res = await api.fetchProgramContents(programId, limit, offset);
    if (res.statusCode == 200) {
      // print('print res fetchCoBrandContents ${res.body}');
      final json = jsonDecode(res.body);
      if (json['resultCode'] == "OK") {
        List contents = json['contents'];
        if (offset == 0)
          listProgramContent = contents.map((e) => ContentModel.fromJson(e)).toList();
        else
          listProgramContent += contents.map((e) => ContentModel.fromJson(e)).toList();
        listProgramContent.sort((b, a) => a.nomerUrutTahapan!.compareTo(a.nomerUrutTahapan!));
        update();
        if (contents.length < 5) {
          isThereMore = false;
        }
        isWaiting = false;
        return true;
      }
    }
    print("Ini error isi programnya: $res");
    listProgramContent = [];
    return false;
  }

  Future<bool> getPrograms({bool refresh = false, String cobrand = '',
    String}) async {
    if (refresh == true) {
      lastUpdated = DateTime.now().toIso8601String();
      offset = 0;
      isProgramThereMore = true;
    }
    if (cobrand == 'all')
      selectedCoBrandEmail = '';
    else if (cobrand != '') selectedCoBrandEmail = cobrand;
    final res = await api.fetchCoBrandPrograms(lastUpdated, limit, offset,
        key: search, email: selectedCoBrandEmail);
    if (res.statusCode == 200) {
      // print('print res fetchCoBrandContents ${res.body}');
      final json = jsonDecode(res.body);
      if (json['resultCode'] == "OK") {
        List programs = json['programs'];
        if (offset == 0)
          listProgram = programs.map((e) => ProgramModel.fromJson(e)).toList();
        else
          listProgram += programs.map((e) => ProgramModel.fromJson(e)).toList();

        listSearchProgram = listProgram;
        update();
        if (programs.length < 5) {
          isProgramThereMore = false;
        }
        isProgramWaiting = false;
        return true;
      }
    }
    print("Ini error Programnya: $res");
    listProgram = [];
    return false;
  }

  Future<bool> getCoBrand() async {
    final res2 = await api.fetchCoBrand();
    if (res2.statusCode == 200) {
      // print('Print res fetchCoBrand: ${res2.body}');
      final json = jsonDecode(res2.body);
      if (json['resultCode'] == "OK") {
        List cobrands = json['cobrands'];
        listCoBrand = cobrands.map((e) => CoBrandModel.fromJson(e)).toList();
        update();
        return true;
      }
    }
    print('Error fetchCoBrand: $res2');
    return false;
  }

  void setSearchData(String text) {
    print("Text: $text");
    offset = 0;
    isThereMore = true;
    search = text;
    // Timer(Duration(milliseconds: 800), () {
    //   //stillSearching = true;
    // });
    // //stillSearching = false;
    getContents();
  }

  void setSearchProgramData(String text) {
    print("Text: $text");
    offset = 0;
    isProgramThereMore = true;
    search = text;
    // Timer(Duration(milliseconds: 800), () {
    //   //stillSearching = true;
    // });
    // //stillSearching = false;
    getPrograms();
  }

}
