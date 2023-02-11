import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('shopping_box');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  List<Map<String, dynamic>> _items = [];

  final _shoppingBox = Hive.box('shopping_box');

  @override
  void initState() {
    super.initState();
    _refrshItems();
  }

  void _refrshItems() {
    final data = _shoppingBox.keys.map((Key) {
      final item = _shoppingBox.get(Key);
      return {"key": Key, "name": item["name"], "Age": item["Age"]};
    }).toList();

    setState(() {
      _items = data.reversed.toList();
      print(_items.length);
    });
  }

  Future<void> _createItem(Map<String, dynamic> newItem) async {
    await _shoppingBox.add(newItem);
    _refrshItems();

    print("amount data is ${_shoppingBox.length}");
  }

  Future<void> _updateItem(Map<String, dynamic> Item, int itemkey) async {
    await _shoppingBox.put(itemkey, Item);
    _refrshItems();
  }

  Future<void> _deleteItem(int itemkey) async {
    await _shoppingBox.delete(itemkey);
    _refrshItems();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('An item has been deleted')));
  }

  void _showfoam(BuildContext ctx, int? itemkey) async {
    if (itemkey != null) {
      final existingItem =
          _items.firstWhere((element) => element["key"] == itemkey);
      _nameController.text = existingItem["name"];
      _ageController.text = existingItem["Age"];
    }
    showModalBottomSheet(
        context: ctx,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(hintText: 'Name'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'Age'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (itemkey == null) {
                          _createItem({
                            "name": _nameController.text,
                            "Age": _ageController.text
                          });
                        }

                        if (itemkey != null) {
                          _updateItem({
                            'name': _nameController.text.trim(),
                            'Age': _ageController.text.trim()
                          }, itemkey);
                        }

                        _nameController.text = '';
                        _ageController.text = '';

                        Navigator.of(context).pop();
                      },
                      child: Text((itemkey == null) ? 'Çreate New' : 'Update')),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hive'),
      ),

      body: ListView.builder(
          itemCount: _items.length,
          itemBuilder: (_, index) {
            final currentItem = _items[index];
            return Card(
              color: Colors.orangeAccent,
              margin: const EdgeInsets.all(10),
              elevation: 3,
              child: ListTile(
                title: Text(currentItem['name']),
                subtitle: Text(currentItem['Age'].toString()),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () => _showfoam(context, currentItem['key']),
                        icon: const Icon(Icons.edit)),
                    IconButton(
                        onPressed: () => _deleteItem( currentItem['key']),
                        icon: const Icon(Icons.delete))
                  ],
                ),
              ),
            );
          }),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showfoam(context, null),
        tooltip: 'Add new',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
