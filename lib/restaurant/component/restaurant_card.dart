import 'package:flutter/material.dart';
import 'package:flutter_token_login/common/const/color.dart';
import 'package:flutter_token_login/restaurant/model/restaurant_detail_model.dart';
import 'package:flutter_token_login/restaurant/model/restaurant_model.dart';

class RestaurantCard extends StatelessWidget {
  //restaurant banner img
  final Widget image;
  //restaurant name
  final String name;
  //hashtag
  final List<String> tags;
  // restaurant rating count
  final int ratingsCount;
  // delivery time
  final int deliveryTime;
  // delivery pay
  final int deliveryFee;
  // everage rating
  final double ratings;

  //detail page
  final bool isDetail;

  //상세내역
  final String? detail;

  const RestaurantCard({
    required this.image,
    required this.name,
    required this.tags,
    required this.ratingsCount,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.ratings,
    this.isDetail = false,
    this.detail,
    Key? key,
  }) : super(key: key);
  
  factory RestaurantCard.fromModel({
    required RestaurantModel model,
    bool isDetail = false,
}){
    return RestaurantCard(
      image: Image.network(
        model.thumbUrl,
        fit: BoxFit.cover,
      ),
      name: model.name,
      tags: model.tags,
      ratingsCount: model.ratingsCount,
      deliveryTime: model.deliveryTime,
      deliveryFee: model.deliveryFee,
      ratings: model.ratings,
      isDetail: isDetail,
      detail: model is RestaurantDetailModel ? model.detail : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if(isDetail)
          image,
        if(!isDetail)
        ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: image,
        ),
        const SizedBox(height: 16.0,),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isDetail ? 16.0 : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8.0,),
              Text(
                tags.join(' · '),
                style: TextStyle(
                  color: BODY_TEXT_COLOR,
                  fontSize: 14.0,
                ),
              ),
              const SizedBox(height: 8.0,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _IconText(
                    icon: Icons.star,
                    label: ratings.toString(),
                  ),
                  renderDot(),
                  _IconText(
                    icon: Icons.receipt,
                    label: ratingsCount.toString(),
                  ),
                  renderDot(),
                  _IconText(
                    icon: Icons.timelapse_outlined,
                    label: '$deliveryTime 분',
                  ),
                  renderDot(),
                  _IconText(
                    icon: Icons.monetization_on,
                    label: deliveryFee == 0 ? '무료': deliveryFee.toString(),
                  ),
                ],
              ),
              if(detail != null && isDetail)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(detail!),
                ),
            ],
          ),
        )
      ],
    );
  }

  Widget renderDot(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        ' · ',
        style: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}



class _IconText extends StatelessWidget {
  final IconData icon;
  final String label;


  const _IconText({
    required this.icon,
    required this.label,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: PRIMARY_COLOR,
          size: 14.0,
        ),
        const SizedBox(width: 8.0,),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ),
        )
      ],
    );
  }
}
