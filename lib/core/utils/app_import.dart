// =============================================================================
// Dart & Flutter Core
// =============================================================================
export 'dart:async';
export 'dart:convert';
export 'package:flutter/foundation.dart';
export 'package:flutter/material.dart';
export 'package:flutter/services.dart';

// =============================================================================
// Third-Party Packages
// =============================================================================
export 'package:connectivity_plus/connectivity_plus.dart';
export 'package:dartz/dartz.dart' hide State;
export 'package:dio/dio.dart';
export 'package:equatable/equatable.dart';
export 'package:fl_chart/fl_chart.dart';
export 'package:flutter_bloc/flutter_bloc.dart';
export 'package:get_it/get_it.dart';
export 'package:go_router/go_router.dart';
export 'package:hive/hive.dart';
export 'package:hive_flutter/hive_flutter.dart';
export 'package:intl/intl.dart' hide TextDirection;
export 'package:shimmer/shimmer.dart';

// =============================================================================
// Core - Dependency Injection & Network
// =============================================================================
export 'package:axis_assessment/core/di/injection_container.dart';
export 'package:axis_assessment/core/network/dio_client.dart';
export 'package:axis_assessment/core/network/network_info.dart';

// =============================================================================
// Core - Errors & Exceptions
// =============================================================================
export 'package:axis_assessment/core/error/exceptions.dart';
export 'package:axis_assessment/core/error/failures.dart';

// =============================================================================
// Core - Routing
// =============================================================================
export 'package:axis_assessment/core/router/app_router.dart';

// =============================================================================
// Core - Theme & Styling
// =============================================================================
export 'package:axis_assessment/core/theme/app_colors.dart';
export 'package:axis_assessment/core/theme/app_spacing.dart';
export 'package:axis_assessment/core/theme/app_theme.dart';
export 'package:axis_assessment/core/theme/app_typography.dart';
export 'package:axis_assessment/core/theme/cubit/theme_cubit.dart';
export 'package:axis_assessment/core/theme/cubit/theme_state.dart';

// =============================================================================
// Core - Utilities
// =============================================================================
export 'package:axis_assessment/core/utils/logging.dart';

// =============================================================================
// Core - Shared Widgets
// =============================================================================
export 'package:axis_assessment/core/widgets/app_button.dart';
export 'package:axis_assessment/core/widgets/app_card.dart';
export 'package:axis_assessment/core/widgets/app_dropdown.dart';
export 'package:axis_assessment/core/widgets/app_text_field.dart';
export 'package:axis_assessment/core/widgets/error_view.dart';
export 'package:axis_assessment/core/widgets/loading_view.dart';
export 'package:axis_assessment/core/widgets/theme_toggle_button.dart';

// =============================================================================
// Features - Exchange - Domain
// =============================================================================
export 'package:axis_assessment/features/exchange/domain/entities/currency_rate.dart';
export 'package:axis_assessment/features/exchange/domain/entities/historical_point.dart';
export 'package:axis_assessment/features/exchange/domain/entities/supported_currency.dart';
export 'package:axis_assessment/features/exchange/domain/repositories/exchange_repository.dart';
export 'package:axis_assessment/features/exchange/domain/usecases/get_historical_rates.dart';
export 'package:axis_assessment/features/exchange/domain/usecases/get_latest_rates_with_change.dart';

// =============================================================================
// Features - Exchange - Data
// =============================================================================
export 'package:axis_assessment/features/exchange/data/datasources/exchange_local_data_source.dart';
export 'package:axis_assessment/features/exchange/data/datasources/exchange_remote_data_source.dart';
export 'package:axis_assessment/features/exchange/data/models/currency_rate_model.dart';
export 'package:axis_assessment/features/exchange/data/models/historical_point_model.dart';
export 'package:axis_assessment/features/exchange/data/repositories/exchange_repository_impl.dart';

// =============================================================================
// Features - Exchange - Presentation
// =============================================================================
export 'package:axis_assessment/features/exchange/presentation/cubit/currency_detail/currency_detail_cubit.dart';
export 'package:axis_assessment/features/exchange/presentation/cubit/currency_detail/currency_detail_state.dart';
export 'package:axis_assessment/features/exchange/presentation/cubit/rates_list/rates_list_cubit.dart';
export 'package:axis_assessment/features/exchange/presentation/cubit/rates_list/rates_list_state.dart';
export 'package:axis_assessment/features/exchange/presentation/pages/currency_detail_page.dart';
export 'package:axis_assessment/features/exchange/presentation/pages/rates_list_page.dart';
export 'package:axis_assessment/features/exchange/presentation/widgets/currency_rate_tile.dart';
export 'package:axis_assessment/features/exchange/presentation/widgets/history_chart_shimmer.dart';
export 'package:axis_assessment/features/exchange/presentation/widgets/history_line_chart.dart';
export 'package:axis_assessment/features/exchange/presentation/widgets/offline_banner.dart';
export 'package:axis_assessment/features/exchange/presentation/widgets/rate_change_badge.dart';

// =============================================================================
// Application Root
// =============================================================================
export 'package:axis_assessment/app.dart';
