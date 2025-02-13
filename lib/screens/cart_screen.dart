import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_cart_app/database/db_helper.dart';
import 'package:shopping_cart_app/model/cart_model.dart';
import 'package:shopping_cart_app/provider/cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  DBHelper? dbHelper = DBHelper();
  List<bool> tapped = [];
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('My Shopping Cart'),
        actions: [
          Badge(
            badgeContent: Consumer<CartProvider>(
              builder: (context, value, child) {
                return Text(
                  value.getCounter().toString(),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
            position: const BadgePosition(start: 30, bottom: 30),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.shopping_cart),
            ),
          ),
          const SizedBox(
            width: 20.0,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: cart.getData(),
              builder:
                  (BuildContext context, AsyncSnapshot<List<Cart>> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text(
                      'Your Cart is Empty',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18.0),
                    ));
                  } else {
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return Card(
                            color: Colors.blueGrey.shade200,
                            elevation: 5.0,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Image(
                                    height: 80,
                                    width: 80,
                                    image: AssetImage(
                                        snapshot.data![index].image.toString()),
                                  ),
                                  SizedBox(
                                    width: 130,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 5.0,
                                        ),
                                        RichText(
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          text: TextSpan(
                                              text: 'Name: ',
                                              style: TextStyle(
                                                  color:
                                                      Colors.blueGrey.shade800,
                                                  fontSize: 16.0),
                                              children: [
                                                TextSpan(
                                                    text:
                                                        '${snapshot.data![index].productName.toString()}\n',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ]),
                                        ),
                                        RichText(
                                          maxLines: 1,
                                          text: TextSpan(
                                              text: 'Unit: ',
                                              style: TextStyle(
                                                  color:
                                                      Colors.blueGrey.shade800,
                                                  fontSize: 16.0),
                                              children: [
                                                TextSpan(
                                                    text:
                                                        '${snapshot.data![index].unitTag.toString()}\n',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ]),
                                        ),
                                        RichText(
                                          maxLines: 1,
                                          text: TextSpan(
                                              text: 'Price: ' r"$",
                                              style: TextStyle(
                                                  color:
                                                      Colors.blueGrey.shade800,
                                                  fontSize: 16.0),
                                              children: [
                                                TextSpan(
                                                    text:
                                                        '${snapshot.data![index].productPrice.toString()}\n',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ]),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PlusMinusButtons(
                                    addQuantity: () {
                                      cart.addQuantity(
                                          snapshot.data![index].quantity!);
                                      dbHelper!
                                          .updateQuantity(Cart(
                                              id: index,
                                              productId: index.toString(),
                                              productName: snapshot
                                                  .data![index].productName,
                                              initialPrice: snapshot
                                                  .data![index].initialPrice,
                                              productPrice: snapshot
                                                  .data![index].productPrice,
                                              quantity: snapshot
                                                  .data![index].quantity,
                                              unitTag:
                                                  snapshot.data![index].unitTag,
                                              image:
                                                  snapshot.data![index].image))
                                          .then((value) => cart.addTotalPrice(
                                              double.parse(snapshot
                                                  .data![index].productPrice
                                                  .toString())));
                                    },
                                    deleteQuantity: () {
                                      cart.deleteQuantity(
                                          snapshot.data![index].quantity!);
                                      cart.removeTotalPrice(double.parse(
                                          snapshot.data![index].productPrice
                                              .toString()));
                                    },
                                    text: cart
                                        .getQuantity(
                                            snapshot.data![index].quantity!)
                                        .toString(),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        dbHelper!.deleteCartItem(
                                            snapshot.data![index].id!);
                                        cart.removeCounter();
                                        cart.removeTotalPrice(double.parse(
                                            snapshot.data![index].productPrice
                                                .toString()));
                                      },
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red.shade800,
                                      )),
                                ],
                              ),
                            ),
                          );
                        });
                  }
                }
                return const Center(
                    child: Text(
                  'Your Cart is Empty',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                ));
              },
            ),
          ),
          Consumer<CartProvider>(
            builder: (BuildContext context, value, Widget? child) {
              return Column(
                children: [
                  ReusableWidget(
                      title: 'Sub-Total',
                      value: r'$' + value.getTotalPrice().toStringAsFixed(2)),
                ],
              );
            },
          )
        ],
      ),
      bottomNavigationBar: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment Successful'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        child: Container(
          color: Colors.yellow.shade600,
          alignment: Alignment.center,
          height: 50.0,
          child: const Text(
            'Proceed to Pay',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class PlusMinusButtons extends StatelessWidget {
  final VoidCallback deleteQuantity;
  final VoidCallback addQuantity;
  final String text;
  const PlusMinusButtons(
      {Key? key,
      required this.addQuantity,
      required this.deleteQuantity,
      required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(onPressed: deleteQuantity, icon: const Icon(Icons.remove)),
        Text(text),
        IconButton(onPressed: addQuantity, icon: const Icon(Icons.add)),
      ],
    );
  }
}

class ReusableWidget extends StatelessWidget {
  final String title, value;
  const ReusableWidget({Key? key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.subtitle1,
          ),
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.subtitle2,
          ),
        ],
      ),
    );
  }
}
