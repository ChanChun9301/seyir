// ignore: unnecessary_import
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seyir/pages/logist/filter_logist_list.dart';
import '/pages/controls/address_control.dart';
import '/utils/constants.dart';
import '/widgets/circulateContainer.dart';
import '../../component/navbar.dart';
import 'filter_list.dart';

class AddressList extends StatefulWidget {
  final String? name;

  const AddressList({
    Key? key,
    required this.name,
  }) : super(key: key);
  @override
  State<AddressList> createState() => _CarAddressListState();
}

class _CarAddressListState extends State<AddressList>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddressControl());
    controller.fetchAddressItems();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            elevation: 10,
            centerTitle: true,
            title: const Text(
              'Salgylar',
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  letterSpacing: 2,
                  fontFamily: "Bricolage",
                  fontSize: 20,
                  color: Colors.white),
            ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.arrow_outward_outlined),
                color: Colors.white,
                iconSize: 20,
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(
                    Icons.sort_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
            shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(30))),
          )),
      drawer: const NavBar(),
      body: SafeArea(
          child: ListView(children: [
        GetX<AddressControl>(
            init: AddressControl(),
            builder: (controller) {
              if (controller.addressItems.isEmpty) {
                return const CircularContainerMain();
              }
              return ListView.builder(
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  shrinkWrap: true,
                  padding:
                      EdgeInsets.symmetric(horizontal: width(context) / 30),
                  itemCount: controller.addressItems.length,
                  itemBuilder: (context, index) {
                    final address = controller.addressItems[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ListTile(
                          title: Text(address.title,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Bricolage',
                                fontSize: 12,
                              )),
                          onTap: () {
                            if (widget.name == 'logist') {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: ((context) => LogistFilter(
                                            pageName: 'logist',
                                            name: address.title,
                                            url: 'address',
                                          ))));
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: ((context) => Filter(
                                            pageName: widget.name,
                                            name: address.title,
                                            url: 'address',
                                          ))));
                            }
                          },
                        ),
                        const Divider(
                          height: 2,
                          color: Colors.grey,
                        ),
                      ],
                    );
                  });
            })
      ])),
    );
  }
}
