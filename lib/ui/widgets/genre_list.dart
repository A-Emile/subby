import 'package:flutter/material.dart';

import '../../models/genre.dart';
import '../../utils/subsonic.dart';

class GenreList extends StatelessWidget {
  const GenreList({super.key, required this.onGenreSelected});

  final ValueChanged<String> onGenreSelected;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Genre>>(
      future: SubsonicAPI.getGenres(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint(snapshot.error.toString());
          return const Center(
            child: Text('Nothing found.'),
          );
        } else if (snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: GridView.builder(
              padding: const EdgeInsets.only(top: 20),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisExtent: 100,
                childAspectRatio: 1,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                final genre = snapshot.data![index];
                return OutlinedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  onPressed: () => onGenreSelected(genre.name),
                  child: Text(
                    genre.name,
                    maxLines: 2,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                );
              },
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
