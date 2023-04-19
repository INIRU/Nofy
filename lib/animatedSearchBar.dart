import 'package:flutter/material.dart';
import 'package:bssidtest3333/main.dart';

class AnimatedSearchBar extends StatefulWidget {
  @override
  AnimatedSearchBarState createState() => AnimatedSearchBarState();
}

class AnimatedSearchBarState extends State<AnimatedSearchBar> {
  bool _folded = true;
  static final filter = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return  AnimatedContainer(
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 7),
      duration: Duration(milliseconds: 100),
      width: _folded ? 56 : size.width - 55,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_folded ? 32 : 12),
        color: Colors.white,
        boxShadow: kElevationToShadow[6],
      ),
      child: Row(
        children: [
          Expanded(child: Container(
            padding: EdgeInsets.only(left: 16),
            child: !_folded ? TextField(decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none),
              onChanged: (value){
              setState(() {
                MyHomePageState().ItemListBuilder();

              });
              },
              controller: filter,
            )
                :null,
          ),
          ),
          AnimatedContainer(duration: Duration(milliseconds: 100),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(_folded ? 32 : 12),
                    topRight: Radius.circular(_folded ? 32 : 12),
                    bottomLeft: Radius.circular(_folded ? 32 : 12),
                    bottomRight: Radius.circular(_folded ? 32 : 12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Icon(_folded ? Icons.search: Icons.close, color: Colors.grey,
                    ),
                  ),
                  onTap: () {
                    setState((){
                      _folded = !_folded;
                      filter.text = '';
                    });
                  },
                ),
              )
          )
        ],
      ),
    );
  }
}

