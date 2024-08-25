import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:the_movie_data_base/locator.dart';
import 'package:the_movie_data_base/router.dart';

import '../../services/services.dart';
import '../ui.dart';

class MovieDetailsScreen extends StatefulWidget {
  const MovieDetailsScreen({
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
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> with SingleTickerProviderStateMixin {
  late bool isAdd;
  late TabController _tabController;
  List<CastMemberDto> movieCastList = [];
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _tabController = TabController(length: 3, vsync: this);
    getMovieCastList();
    fetchWatchlist();
  }

  String formatRuntime(int minutes) {
    final int hours = minutes ~/ 60;
    final int mins = minutes % 60;
    return '${hours}h ${mins}m';
  }

  getMovieCastList() async {
    movieCastList = await locate<RestService>().getMovieCastList(id: widget.id);
    setState(() {});
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

  List<Widget> buildCastCrewCardList(List<CastMemberDto> list, int maxCount) {
    return list.take(maxCount).map((member) {
      return Container(
        width: 80,
        margin: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            CachedNetworkImage(
              imageUrl: member.profilePath != null
                  ? '${locate<LocatorConfig>().tmdbImagePath}${member.profilePath}'
                  : 'https://ui-avatars.com/api/?background=random&name=${member.name}',
              imageBuilder: (context, imageProvider) => Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            const SizedBox(height: 5),
            Text(
              member.name ?? '',
              style: Theme.of(context).textTheme.labelLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> buildProductionCardList(List<MovieProductionCompanyDto> list, int maxCount) {
    return list.take(maxCount).map((company) {
      return Container(
        width: 80,
        margin: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            CachedNetworkImage(
              imageUrl: company.logoPath != null
                  ? '${locate<LocatorConfig>().tmdbImagePath}${company.logoPath}'
                  : 'https://ui-avatars.com/api/?background=random&name=${company.name}',
              imageBuilder: (context, imageProvider) => Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            const SizedBox(height: 5),
            Text(
              company.name ?? '',
              style: Theme.of(context).textTheme.labelLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }).toList();
  }

  List<CastMemberDto> filterByDepartment(String department) {
    return movieCastList.where((member) => member.knownForDepartment == department).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<CastMemberDto> castList = filterByDepartment('Acting');
    List<CastMemberDto> writerList = filterByDepartment('Writing');
    List<CastMemberDto> directorList = filterByDepartment('Directing');

    Widget buildHorizontalCastCrewListView(List<CastMemberDto> list, int maxCount) {
      return SizedBox(
        height: 180, // Set a fixed height for the horizontal scroll view
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: buildCastCrewCardList(list, maxCount)),
        ),
      );
    }

    Widget buildHorizontalProductionListView(List<MovieProductionCompanyDto> list, int maxCount) {
      return SizedBox(
        height: 180, // Set a fixed height for the horizontal scroll view
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: buildProductionCardList(list, maxCount)),
        ),
      );
    }

    List<int> watchlist = Provider.of<List<int>>(context);
    isAdd = watchlist.contains(widget.id);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 330,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(widget.imageUri.isNotEmpty
                        ? widget.imageUri
                        : 'https://ui-avatars.com/api/?background=random&name=${widget.title}'),
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
                top: 16,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Positioned(
                top: 16,
                left: 4,
                right: 4,
                child: Column(
                  children: [
                    SizedBox(
                      height: 300,
                      width: 300,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: CachedNetworkImage(
                          imageUrl: widget.imageUri.isNotEmpty
                              ? widget.imageUri
                              : 'https://ui-avatars.com/api/?background=random&name=${widget.title}', // Provide a valid fallback URL
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.5),
              border: Border.all(color: Colors.transparent),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (widget.genresList != null && widget.genresList!.isNotEmpty)
                        ...(widget.genresList?.take(3).map((genre) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 5.0),
                                child: Text(
                                  '${genre.name} |',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              );
                            }).toList() ??
                            []),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Text(
                          widget.releaseYear.length >= 4 ? widget.releaseYear.substring(0, 4) : widget.releaseYear,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Text(
                          widget.language,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      if (widget.isAdult)
                        Container(
                          margin: const EdgeInsets.only(right: 5),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Text(
                            '18+',
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: const Color(0xFFFF0000).withOpacity(0.5),
                                ),
                          ),
                        ),
                      Container(
                        margin: const EdgeInsets.only(right: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Text(
                          formatRuntime(widget.runtime),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Row(
                        children: [
                          for (var i = 0; i < 5; i++)
                            BorderedStar(
                              iconData: i < (widget.rating / 2).floor()
                                  ? Icons.star
                                  : (i < (widget.rating / 2) ? Icons.star_half : Icons.star_border),
                              fillColor: Colors.orangeAccent,
                            ),
                          const SizedBox(width: 4), // Adjust spacing between stars and rating text if needed
                          Text(
                            widget.rating.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              widget.overview,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          const SizedBox(height: 10),
          CustomButton(
              onPressed: () => handleAddToWatchlist(context),
              padding: 40,
              height: 40,
              text: isAdd ? 'Added to Watchlist' : 'Add to Watchlist',
              icon: isAdd
                  ? const Icon(Icons.bookmark, color: Colors.white, size: 18)
                  : const Icon(Icons.bookmark_add_outlined, color: Colors.white, size: 18)),
          const SizedBox(height: 15),
          TabBar(
            controller: _tabController,
            tabs:  [
              Tab(
                  child: Text(
                'Cast',
                style: Theme.of(context).textTheme.titleSmall,
              )),
              Tab(
                  child: Text(
                'Writers',
                style: Theme.of(context).textTheme.titleSmall,
              )),
              Tab(
                  child: Text(
                'Directors',
                style: Theme.of(context).textTheme.titleSmall,
              )),
            ],
          ),
          SizedBox(
            height: 150,
            child: TabBarView(
              controller: _tabController,
              children: [
                buildHorizontalCastCrewListView(castList, 7),
                buildHorizontalCastCrewListView(writerList, 3),
                buildHorizontalCastCrewListView(directorList, 3),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              'Production',
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
          ),
          const Divider(
            color: Colors.deepPurple,
            thickness: 2,
            endIndent: 265,
          ),
          buildHorizontalProductionListView(widget.productionCompanies ?? [], 3),
        ],
      ),
    );
  }
}

class BorderedStar extends StatelessWidget {
  final IconData iconData;
  final Color fillColor;
  final double size;

  const BorderedStar({super.key, required this.iconData, required this.fillColor, this.size = 18.0});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.star_border,
          color: Colors.black,
          size: size,
        ),
        Icon(
          iconData,
          color: fillColor,
          size: size * 0.9,
        ),
      ],
    );
  }
}
