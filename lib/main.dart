import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    home: Add_to_cart_screen(),
  ));
}


class Add_to_cart_screen extends StatefulWidget {
  @override
  _Add_to_cart_screenState createState() => _Add_to_cart_screenState();
}

class _Add_to_cart_screenState extends State<Add_to_cart_screen> {
  List products_list = [];

  @override
  void initState() {
    super.initState();
    Load_json_file();
    Total_prize();
    Load_quantitiy_saved();
  }


  Future<void> Load_json_file() async {
    final String response =
        await rootBundle.rootBundle.loadString('assets/json_data.json');
    final Map<String, dynamic> jsonData = json.decode(response);

    setState(() {
      products_list = jsonData['data'];
    });

    //  print(products); // Print the entire list of products
  }

  double total_Price = 0;

  void Total_prize() {
    total_Price = 0;
    for (var product in products_list) {
      total_Price += product['price'] * product['qty'];
    }
    setState(() {
      //   print("calculation=$total_Price");
    });
  }

  void Update_quantity(int index, int newQty) async {
    final product = products_list[index];
    if (newQty >= 1 && newQty <= product['maxQty']) {
      setState(() {
        product['qty'] = newQty;
      });
      Total_prize();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('product_${product['productID']}_qty', newQty);
    } else {
      final message = newQty < 1
          ? "At least 1 quantity is required"
          : "maximum quantity reached";

      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> Load_quantitiy_saved() async {
    SharedPreferences quantitiy = await SharedPreferences.getInstance();
    for (var product in products_list) {
      int saved_quantity =
          quantitiy.getInt('product_${product['productID']}_qty') ??
              product['qty'];
      product['qty'] = saved_quantity;
    }
    Total_prize();
  }


  @override
  Widget build(BuildContext context) {
    double screenhight = MediaQuery.of(context).size.height;
    double screenwidth = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.white70,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            'Review Cart',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
          leading: const Icon(
            Icons.arrow_back_ios,
            color: Colors.blue,
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Account section
            ///
            Container(
              // height: 50,
              height: screenhight * 0.05,
              width: double.infinity,
              color: const Color(0xFFC1E1C1),
              child: const Row(
                children: [
                  SizedBox(width: 10),
                  Text("Balance In your Wallet",
                      style: TextStyle(fontSize: 16, color: Colors.green)),
                  SizedBox(width: 90),
                  Icon(Icons.account_balance_wallet, color: Colors.green),
                  SizedBox(width: 5),
                  Text("Rs 5386",
                      style: TextStyle(fontSize: 16, color: Colors.green)),
                  SizedBox(
                    width: 13,
                  ),
                  Icon(Icons.info, color: Colors.orange)
                ],
              ),
            ),

            SizedBox(height: screenhight * 0.035),

            /// product Listt
            Expanded(
              child: ListView.builder(
                itemCount: products_list.length,
                itemBuilder: (context, index) {
                  final product = products_list[index];

                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      height: screenhight * 0.18,
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Product Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.network(
                              product['image'],
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: screenwidth * 0.04),

                          // Product Name and Price
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['productName'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.blue,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    SizedBox(width: screenwidth * 0.02),
                                    Image.asset(
                                      "assets/veg_icon.png",
                                      height: 18,
                                    ),
                                    SizedBox(width: screenwidth * 0.02),
                                    const Text("Litres",
                                        style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                                SizedBox(height: screenhight * 0.02),
                                Row(
                                  children: [
                                    const Text('₹',
                                        style: TextStyle(
                                            color: Colors.blue, fontSize: 25)),
                                    Text('${product['price']}',
                                        style: const TextStyle(
                                            color: Colors.blue, fontSize: 22)),
                                  ],
                                ),
                              ],
                            ),
                          ),


                          Column(
                            children: [
                              const SizedBox(height: 40),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Update_quantity(index, product['qty'] - 1);
                                    },
                                    child: Container(
                                      height: 30,
                                      width: 30,
                                      child: Image.asset('assets/minus.png'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text('${product['qty']}',
                                      style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: (product['qty'] < product['maxQty'])
                                        ? () {
                                            Update_quantity(
                                                index, product['qty'] + 1);
                                          }
                                        : () {
                                            Fluttertoast.showToast(
                                              msg: "maximum quantity reached",
                                              toastLength: Toast.LENGTH_LONG,
                                              gravity: ToastGravity.BOTTOM,
                                              backgroundColor: Colors.black,
                                              textColor: Colors.white,
                                              fontSize: 16.0,
                                            );
                                          },
                                    child: Opacity(
                                      opacity:
                                          (product['qty'] < product['maxQty'])
                                              ? 1.0
                                              : 0.5,
                                      child: Container(
                                        height: 30,
                                        width: 30,
                                        child: Image.asset('assets/plus.png'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const Column(
                            children: [
                              Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Icon(Icons.remove_circle, color: Colors.red),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            /// order deatils section
            const Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                "Order Details",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),

            SizedBox(
              height: screenhight * 0.005,
            ),

            Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const SizedBox(width: 10),
                        const Text("Item Total",
                            style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue)),
                        SizedBox(
                          width: screenwidth * 0.3,
                        ),
                        const Text('₹ ',
                            style:
                                TextStyle(color: Colors.green, fontSize: 21)),
                        Text(total_Price.toString(),
                            style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue)),
                        SizedBox(width: screenwidth * 0.015),
                        Text((total_Price + 400).toString(),
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                decoration: TextDecoration.lineThrough)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const SizedBox(width: 10),
                        const Text("Delivery Charges",
                            style: TextStyle(fontSize: 15, color: Colors.grey)),
                        SizedBox(
                          width: screenwidth * 0.5,
                        ),
                        const Text("Free",
                            style:
                                TextStyle(fontSize: 18, color: Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const SizedBox(width: 10),
                        const Text("Total Items",
                            style: TextStyle(fontSize: 15, color: Colors.grey)),
                        SizedBox(
                          width: screenwidth * 0.6,
                        ),
                        const Text("2",
                            style:
                                TextStyle(fontSize: 18, color: Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Divider(),
                    Row(
                      children: [
                        const SizedBox(width: 10),
                        const Text("To Pay",
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue)),
                        SizedBox(
                          width: screenwidth * 0.5,
                        ),
                        const Text('₹ ',
                            style:
                                TextStyle(color: Colors.green, fontSize: 23)),
                        Text(total_Price.toString(),
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue)),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ),

            SizedBox(height: screenhight * 0.06),

            /// checkout button

            Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () {
                  Fluttertoast.showToast(
                    msg: "Checkout Button Clicked",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8)),
                  height: screenhight * 0.06,
                  width: double.infinity,
                  child: const Center(
                    child: Text(
                      "CHECKOUT",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: screenhight * 0.012),
          ],
        ));
  }
}
