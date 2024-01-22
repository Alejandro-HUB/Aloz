// ignore_for_file: file_names, unused_element
import 'package:flutter/material.dart';
import 'package:projectcrm/Helpers/Constants/Styling.dart';

class IconHelper {
  static const List<String> iconNames = [
    'home',
    'settings',
    'notifications',
    'phone',
    'email',
    'person',
    'account_balance',
    'work',
    'date_range',
    'message',
    'location_on',
    'attach_file',
    'cloud_upload',
    'cloud_download',
    'photo_camera',
    'photo_library',
    'check',
    'close',
    'search',
    'edit',
    'delete',
    'star',
    'favorite',
    'bookmark',
    'share',
    'arrow_back',
    'arrow_forward',
    'play_arrow',
    'pause',
    'stop',
    'add',
    'info',
    'code',
    'payment',
    'list',
    'alarm',
    'assignment',
    'build',
    'contact_mail',
    'dns',
    'event',
    'group',
    'history',
    'info_outline',
    'lock',
    'mail_outline',
    'notifications_active',
    'people',
    'query_builder',
    'radio_button_checked',
    'wifi',
    'bluetooth',
    'gps_fixed',
    'brightness_medium',
    'account_circle',
    'vpn_lock',
    'rowing',
    'emoji_people',
    'sports_esports',
    'extension',
    'fireplace',
    'headphones',
    'brush',
    'attach_money',
    'bathtub',
    'local_dining',
    'mood',
    'power',
    'calendar_month'
    // Add more icon names as needed
  ];
}

extension IconsExtension on IconData {
  static Widget getIconPreview(String iconName) {
    final iconData = IconsExtension.getIconData(iconName);
    return Icon(
      iconData,
      size: 24,
      color: Styling.primaryColor,
    );
  }

  static IconData getIconData(String iconName) {
    switch (iconName) {
      case 'home':
        return Icons.home;
      case 'settings':
        return Icons.settings;
      case 'notifications':
        return Icons.notifications;
      case 'phone':
        return Icons.phone;
      case 'email':
        return Icons.email;
      case 'person':
        return Icons.person;
      case 'account_balance':
        return Icons.account_balance;
      case 'work':
        return Icons.work;
      case 'date_range':
        return Icons.date_range;
      case 'message':
        return Icons.message;
      case 'location_on':
        return Icons.location_on;
      case 'attach_file':
        return Icons.attach_file;
      case 'cloud_upload':
        return Icons.cloud_upload;
      case 'cloud_download':
        return Icons.cloud_download;
      case 'photo_camera':
        return Icons.photo_camera;
      case 'photo_library':
        return Icons.photo_library;
      case 'check':
        return Icons.check;
      case 'close':
        return Icons.close;
      case 'search':
        return Icons.search;
      case 'edit':
        return Icons.edit;
      case 'delete':
        return Icons.delete;
      case 'star':
        return Icons.star;
      case 'favorite':
        return Icons.favorite;
      case 'bookmark':
        return Icons.bookmark;
      case 'share':
        return Icons.share;
      case 'arrow_back':
        return Icons.arrow_back;
      case 'arrow_forward':
        return Icons.arrow_forward;
      case 'play_arrow':
        return Icons.play_arrow;
      case 'pause':
        return Icons.pause;
      case 'stop':
        return Icons.stop;
      case 'add':
        return Icons.add;
      case 'info':
        return Icons.info;
      case 'code':
        return Icons.code;
      case 'payment':
        return Icons.payment;
      case 'list':
        return Icons.list;
      case 'alarm':
        return Icons.alarm;
      case 'assignment':
        return Icons.assignment;
      case 'build':
        return Icons.build;
      case 'contact_mail':
        return Icons.contact_mail;
      case 'dns':
        return Icons.dns;
      case 'event':
        return Icons.event;
      case 'group':
        return Icons.group;
      case 'history':
        return Icons.history;
      case 'info_outline':
        return Icons.info_outline;
      case 'lock':
        return Icons.lock;
      case 'mail_outline':
        return Icons.mail_outline;
      case 'notifications_active':
        return Icons.notifications_active;
      case 'people':
        return Icons.people;
      case 'query_builder':
        return Icons.query_builder;
      case 'radio_button_checked':
        return Icons.radio_button_checked;
      case 'wifi':
        return Icons.wifi;
      case 'bluetooth':
        return Icons.bluetooth;
      case 'gps_fixed':
        return Icons.gps_fixed;
      case 'brightness_medium':
        return Icons.brightness_medium;
      case 'account_circle':
        return Icons.account_circle;
      case 'vpn_lock':
        return Icons.vpn_lock;
      case 'rowing':
        return Icons.rowing;
      case 'emoji_people':
        return Icons.emoji_people;
      case 'sports_esports':
        return Icons.sports_esports;
      case 'extension':
        return Icons.extension;
      case 'fireplace':
        return Icons.fireplace;
      case 'headphones':
        return Icons.headphones;
      case 'brush':
        return Icons.brush;
      case 'attach_money':
        return Icons.attach_money;
      case 'bathtub':
        return Icons.bathtub;
      case 'local_dining':
        return Icons.local_dining;
      case 'mood':
        return Icons.mood;
      case 'power':
        return Icons.power;
      case 'calendar_month':
        return Icons.calendar_month;
      // Add more cases as needed
      default:
        return Icons.error;
    }
  }
}
