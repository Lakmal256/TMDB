import 'package:flutter/material.dart';

class MovieCard extends StatelessWidget {
  const MovieCard({
    super.key,
    required this.imageUri,
    required this.title,
    required this.language,
    required this.releaseYear,
    required this.isAdult,
    required this.rating,
  });
  final String imageUri;
  final String title;
  final String releaseYear;
  final String language;
  final bool isAdult;
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 2,
            child: SizedBox(
              height: 250,
              width: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: FadeInImage.assetNetwork(placeholder: 'assets/gif/loading.gif', image: imageUri,fit: BoxFit.fill,),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: SizedBox(
              width: 180,
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              children: [
                Text(
                  releaseYear.length >= 4 ? releaseYear.substring(0, 4) : releaseYear,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(width: 5),
                Text(
                  language,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(width: 5),
                if (isAdult)
                  Text(
                    "18+",
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: const Color(0xFFFF0000).withOpacity(0.5),
                        ),
                  ),
                const SizedBox(width: 5),
                const Icon(Icons.star_border_purple500, size: 16, color: Colors.orangeAccent),
                Text(
                  rating.toStringAsFixed(2),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
