import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:the_movie_data_base/router.dart';

import '../../locator.dart';
import '../../services/services.dart';
import '../ui.dart';

class MovieDetailsCard extends StatefulWidget {
  const MovieDetailsCard({
    super.key,
    required this.id,
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
  });

  final int id;
  final String imageUri;
  final String title;
  final String releaseYear;
  final String language;
  final bool isAdult;
  final double rating;
  final List<MovieGenresDto>? genresList;
  final int runtime;
  final String overview;
  final List<MovieProductionCompanyDto>? productionCompanies;

  @override
  State<MovieDetailsCard> createState() => _MovieDetailsCardState();
}

class _MovieDetailsCardState extends State<MovieDetailsCard> {
  late bool isAdd;
  User? user;

  String formatRuntime(int minutes) {
    final int hours = minutes ~/ 60;
    final int mins = minutes % 60;
    return '${hours}h ${mins}m';
  }

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    fetchWatchlist();
  }

  fetchWatchlist() async {
    if (user != null) {
      isAdd = await locate<RestService>().checkIfMovieInWatchlist(userId: user!.uid, movieId: widget.id);
    }
  }

  Future<void> handleAddToWatchlist(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      if (isAdd) {
        await locate<RestService>().removeFromWatchlist(userId: user.uid, movieId: widget.id);
      } else {
        await locate<RestService>().addToWatchlist(
          userId: user.uid,
          movieId: widget.id,
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
      setState(() {
        isAdd = !isAdd;
      });
    } else {
      bool? ok = await showConfirmationDialog(context, title: "Sign In?", content: "Please sign in to add movies to your watchlist.");

      if (ok != null && ok) {
        if (context.mounted) {
          context.push(AppRoutes.auth);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<int> watchlist = Provider.of<List<int>>(context);
    isAdd = watchlist.contains(widget.id);
    // isAdd = isInWatchlist;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              height: 355,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(widget.imageUri),
                  fit: BoxFit.fill,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 4,
              right: 4,
              child: Column(
                children: [
                  SizedBox(
                    height: 250,
                    width: 250,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: CachedNetworkImage(
                        imageUrl: widget.imageUri,
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.5),
                      borderRadius:
                          const BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
                      border: Border.all(color: Colors.transparent),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            widget.title,
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: const Color(0xFFFFFFFF),
                                  fontWeight: FontWeight.bold,
                                ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              widget.releaseYear.length >= 4 ? widget.releaseYear.substring(0, 4) : widget.releaseYear,
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: const Color(0xFFFFFFFF),
                                    fontWeight: FontWeight.normal,
                                  ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '|',
                              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.normal,
                                  ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              widget.language,
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: const Color(0xFFFFFFFF),
                                    fontWeight: FontWeight.normal,
                                  ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '|',
                              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.normal,
                                  ),
                            ),
                            if (widget.isAdult)
                              Text(
                                "18+",
                                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                      color: const Color(0xFFFF0000).withOpacity(0.5),
                                      fontWeight: FontWeight.normal,
                                    ),
                              ),
                            if (widget.isAdult) const SizedBox(width: 5),
                            if (widget.isAdult)
                              Text(
                                '|',
                                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.normal,
                                    ),
                              ),
                            const Icon(Icons.star_border_purple500, size: 18, color: Colors.orangeAccent),
                            Text(
                              widget.rating.toStringAsFixed(2),
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: const Color(0xFFFFFFFF),
                                    fontWeight: FontWeight.normal,
                                  ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '|',
                              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.normal,
                                  ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              formatRuntime(widget.runtime),
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: const Color(0xFFFFFFFF),
                                    fontWeight: FontWeight.normal,
                                  ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            if (widget.genresList != null && widget.genresList!.isNotEmpty)
                              ...(widget.genresList?.take(3).map((genre) {
                                    return Container(
                                      margin: const EdgeInsets.only(right: 5),
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child: Text(
                                        genre.name ?? ' ',
                                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                              color: Colors.white,
                                            ),
                                      ),
                                    );
                                  }).toList() ??
                                  []),
                            SizedBox(
                              width: 160,
                              child: CustomButton(
                                  onPressed: () => handleAddToWatchlist(context),
                                  padding: 0,
                                  height: 25,
                                  text: isAdd ? 'Added to Watchlist' : 'Add to Watchlist',
                                  icon: isAdd
                                      ? const Icon(Icons.bookmark, color: Colors.white, size: 18)
                                      : const Icon(Icons.bookmark_add_outlined, color: Colors.white, size: 18)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
