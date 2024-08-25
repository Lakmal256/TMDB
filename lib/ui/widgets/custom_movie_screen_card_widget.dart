import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:the_movie_data_base/locator.dart';
import 'package:the_movie_data_base/router.dart';

import '../../services/services.dart';
import '../ui.dart';

class MovieScreenCard extends StatefulWidget {
  const MovieScreenCard(
      {super.key,
      required this.movieId,
      required this.imageUri,
      required this.title,
      required this.language,
      required this.releaseYear,
      required this.isAdult,
      required this.rating,
      required this.genresList,
      required this.runtime,
      required this.overview,
      required this.productionCompanies,
      required this.onTap});

  final int movieId;
  final String imageUri;
  final String title;
  final String releaseYear;
  final String language;
  final bool isAdult;
  final double rating;
  final List<MovieGenresDto> genresList;
  final int runtime;
  final String overview;
  final List<MovieProductionCompanyDto>? productionCompanies;
  final VoidCallback onTap;

  @override
  State<MovieScreenCard> createState() => _MovieScreenCardState();
}

class _MovieScreenCardState extends State<MovieScreenCard> {
  late bool isAdd;
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    fetchWatchlist();
  }

  String formatRuntime(int minutes) {
    final int hours = minutes ~/ 60;
    final int mins = minutes % 60;
    return '${hours}h ${mins}m';
  }

  Future<void> fetchWatchlist() async {
    if (user != null) {
      bool isInWatchlist = await locate<RestService>()
          .checkIfMovieInWatchlist(userId: user!.uid, movieId: widget.movieId);

      if (mounted) {
        setState(() {
          isAdd = isInWatchlist;
        });
      }
    }
  }

  Future<void> handleAddToWatchlist(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      if (isAdd) {
        await locate<RestService>()
            .removeFromWatchlist(userId: user.uid, movieId: widget.movieId);
      } else {
        await locate<RestService>().addToWatchlist(
          userId: user.uid,
          movieId: widget.movieId,
          title: widget.title,
          imageUri: widget.imageUri,
          releaseYear: widget.releaseYear,
          language: widget.language,
          isAdult: widget.isAdult,
          rating: widget.rating,
          genresList: widget.genresList,
          runtime: widget.runtime,
          overview: widget.overview,
          productionCompanies: widget.productionCompanies,
        );
      }

      if (mounted) {
        setState(() {
          isAdd = !isAdd;
        });
      }
    } else {
      bool? ok = await showConfirmationDialog(
        context,
        title: "Sign In?",
        content: "Please sign in to add movies to your watchlist.",
      );

      if (ok != null && ok) {
        if (context.mounted) {
          context.push(AppRoutes.auth);
        }
      }
    }
  }

  @override
  void dispose() {
    // If there are any ongoing asynchronous operations,
    // consider adding cleanup code here.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<int> watchlist = Provider.of<List<int>>(context);
    isAdd = watchlist.contains(widget.movieId);
    // isAdd = isInWatchlist;

    return InkWell(
      onTap: widget.onTap,
      child: LimitedBox(
        maxHeight: 240,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 230,
                width: 140,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15.0),
                    topLeft: Radius.circular(15.0),
                  ),
                ),
                child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15.0),
                      topLeft: Radius.circular(15.0),
                    ),
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/gif/loading.gif',
                      image: widget.imageUri.isNotEmpty
                          ? widget.imageUri
                          : 'https://ui-avatars.com/api/?background=random&name=${widget.title}',
                      fit: BoxFit.fill,
                    )),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      if (widget.genresList.isNotEmpty)
                        Wrap(
                          runSpacing: 5.0,
                          children: widget.genresList.take(4).map((genre) {
                            return Container(
                              margin: const EdgeInsets.only(right: 5),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Text(
                                genre.name ?? ' ',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          widget.title,
                          style: widget.title.length > 10
                              ? Theme.of(context).textTheme.titleMedium!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  )
                              : Theme.of(context).textTheme.titleLarge!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Row(
                          children: [
                            Text(
                              widget.releaseYear.length >= 4 ? widget.releaseYear.substring(0, 4) : widget.releaseYear,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '|',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              widget.language,
                              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                    fontWeight: FontWeight.normal,
                                  ),
                            ),
                            const SizedBox(width: 5),
                            if (widget.isAdult) ...[
                              Text(
                                '|',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "18+",
                                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                      color: const Color(0xFFFF0000).withOpacity(0.5),
                                    ),
                              ),
                            ]
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          formatRuntime(widget.runtime),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.star_border_purple500, size: 24, color: Colors.orangeAccent),
                          Text(
                            widget.rating.toStringAsFixed(2),
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const Expanded(
                        child: SizedBox.shrink(),
                      ),
                      CustomButton(
                          onPressed: () => handleAddToWatchlist(context),
                          padding: 20,
                          height: 25,
                          text: isAdd ? 'Added to Watchlist' : 'Add to Watchlist',
                          icon: isAdd
                              ? const Icon(Icons.bookmark, color: Colors.white, size: 20)
                              : const Icon(Icons.bookmark_add_outlined, color: Colors.white, size: 20)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
