import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'shopping_list_provider.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ShoppingListProvider()),
        ChangeNotifierProvider(
            create: (context) => ThemeProvider(themeData: ThemeData.light())),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cart Companion',
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: ShoppingListScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    ShoppingListScreen(),
    MembershipCardScreen(),
    SettingsScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cart Companion')),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Shopping List'),
          BottomNavigationBarItem(
              icon: Icon(Icons.credit_card), label: 'Membership Cards'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class ShoppingListScreen extends StatefulWidget {
  @override
  _ShoppingListScreenState createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  List<Item> _shoppingList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart Companion'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddItemScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.manage_search),
            onPressed: () {
              // Manage items logic
            },
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              _shareList(context);
            },
          ),
        ],
      ),
      body: Consumer<ShoppingListProvider>(
        builder: (context, shoppingListProvider, child) {
          return ListView.builder(
            itemCount: shoppingListProvider.items.length,
            itemBuilder: (context, index) {
              final item = shoppingListProvider.items[index];
              return Card(
                child: ListTile(
                  title: Text(item.name),
                  subtitle: Text('Quantity: ${item.quantity}'),
                  onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemDetailScreen(item: item),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: Icon(Icons.check),
                  onPressed: () {
                    shoppingListProvider.removeItem(index);
                  },
                ),
              ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Shopping List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_membership),
            label: 'Membership Cards',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ShoppingListScreen()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MembershipCardScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsScreen()),
            );
          }
        },
      ),
    );
  }

  void _shareList(BuildContext context) async {
    // Replace this URL with the actual Instagram or Facebook URL you want to share
    String url = 'https://www.instagram.com';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to open the link')),
      );
    }
  }

  Future<void> _showEditItemDialog(int index) async {
    String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _itemNameController =
            TextEditingController(text: _shoppingList[index].name);

        return AlertDialog(
          title: Text('Edit Item'),
          content: TextField(
            controller: _itemNameController,
            decoration: InputDecoration(labelText: 'Item Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(_itemNameController.text);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        Provider.of<ShoppingListProvider>(context, listen: false)
            .updateItemName(index, result);
      });
    }
  }
}

class AddItemScreen extends StatefulWidget {
  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Item'),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          TextField(
            controller: _itemNameController,
            decoration: InputDecoration(labelText: 'Item Name'),
          ),
          TextField(
            controller: _quantityController,
            decoration: InputDecoration(labelText: 'Quantity'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _brandController,
            decoration: InputDecoration(labelText: 'Brand'),
          ),
          TextField(
            controller: _typeController,
            decoration: InputDecoration(labelText: 'Type'),
          ),
          ElevatedButton(
            onPressed: () {
              final newItem = Item(
                name: _itemNameController.text,
                quantity: int.parse(_quantityController.text),
                brand: _brandController.text,
                type: _typeController.text,
                purchased: false,
              );
              Provider.of<ShoppingListProvider>(context, listen: false)
                  .addItem(newItem);
              Navigator.pop(context);
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class ItemDetailScreen extends StatelessWidget {
  final Item item;

  ItemDetailScreen({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${item.name}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Quantity: ${item.quantity}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Brand: ${item.brand}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Type: ${item.type}', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

class MembershipCardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Membership Cards'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Image.asset(
                'assets/images/tesco_card.png'), // Replace with actual image file name
            title: Text('Tesco Card'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Tesco Card Barcode'),
                    content: Image.asset(
                        'assets/images/tesco_barcode.png'), // Replace with actual image file name
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          ListTile(
            leading: Image.asset(
                'assets/images/waitrose_card.png'), // Replace with actual image file name
            title: Text('Waitrose Card'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Waitrose Card Barcode'),
                    content: Image.asset(
                        'assets/images/waitrose_barcode.png'), // Replace with actual image file name
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          // Add more cards here
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // logic for adding a new membership card
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    _isDarkModeEnabled = themeProvider.themeData.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Dark Mode'),
            value: _isDarkModeEnabled,
            onChanged: (bool value) {
              setState(() {
                _isDarkModeEnabled = value;
                themeProvider.setThemeData(
                  _isDarkModeEnabled ? ThemeData.dark() : ThemeData.light(),
                );
              });
            },
          ),
        ],
      ),
    );
  }
}
