import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_iptv_client/model/channel.dart';
import 'package:flutter_iptv_client/provider/channel_provider.dart';
import 'package:provider/provider.dart';

import '../page/video_page.dart';

class ChannelListTile extends StatelessWidget {
  const ChannelListTile({
    super.key,
    required this.item,
  });

  final Channel item;

  @override
  Widget build(BuildContext context) {
    final isFavorite = item.isFavorite;
    final url = item.url;
    final gradient = url == null? [Colors.grey, Colors.grey]:[Theme.of(context).colorScheme.primary,Theme.of(context).colorScheme.tertiary];
    return InkWell(
      onTap: () {
        if (url != null) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => VideoPage(url: url)));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          gradient: LinearGradient(colors: gradient, begin: Alignment.topCenter, end: Alignment.bottomCenter)
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 40, top: 20, left: 10, right: 10),
              child: CachedNetworkImage(
                width: double.infinity,
                height: double.infinity,
                imageUrl: item.logo ?? '',
                errorWidget: (_, __, ___) =>
                const Icon(
                  Icons.error,
                  size: 24,
                ),
              ),
            ),
            Align(
              alignment: Alignment(0, 0.9),
              child: Text(item.name, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
            ),
            Align(
              alignment: Alignment(0.9, -0.9),
              child: InkWell(
                onTap: () {
                  context.read<ChannelProvider>().setFavorite(item.id, !isFavorite);
                },
                child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      isFavorite ? Icons.star : Icons.star_border,
                      color: Theme.of(context).colorScheme.onSecondary,
                      size: 24,
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }
}
