// Dart & Flutter Core
export 'dart:async';
export 'dart:convert';

export 'package:flutter/foundation.dart';
export 'package:flutter/material.dart';
export 'package:flutter/services.dart';

// Foundation packages used across all layers
export 'package:connectivity_plus/connectivity_plus.dart';
export 'package:dartz/dartz.dart' hide State;
export 'package:dio/dio.dart';
export 'package:equatable/equatable.dart';
export 'package:get_it/get_it.dart';
export 'package:hive/hive.dart';
export 'package:hive_flutter/hive_flutter.dart';
export 'package:intl/intl.dart' hide TextDirection;

// Core
export 'package:axis_assessment/core/error/exceptions.dart';
export 'package:axis_assessment/core/error/failures.dart';
export 'package:axis_assessment/core/network/dio_client.dart';
export 'package:axis_assessment/core/network/network_info.dart';
export 'package:axis_assessment/core/theme/app_colors.dart';
export 'package:axis_assessment/core/theme/app_spacing.dart';
export 'package:axis_assessment/core/theme/app_theme.dart';
export 'package:axis_assessment/core/theme/app_typography.dart';
export 'package:axis_assessment/core/utils/logging.dart';
