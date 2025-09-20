// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

import '../../features/llm/data/repositories/llm_repository_impl.dart' as _i377;
import '../../features/llm/domain/repositories/llm_repository.dart' as _i791;
import '../../features/llm/presentation/blocs/voice_command/voice_command_bloc.dart'
    as _i975;
import '../blocs/authentication/authentication_bloc.dart' as _i598;
import '../blocs/location/location_bloc.dart' as _i729;
import '../services/llm_service.dart' as _i450;
import '../services/location_service.dart' as _i669;
import '../services/voice_service.dart' as _i950;
import 'injection.dart' as _i464;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i454.SupabaseClient>(() => registerModule.supabaseClient);
    gh.lazySingleton<_i669.LocationService>(() => _i669.LocationServiceImpl());
    gh.lazySingleton<_i950.VoiceService>(() => _i950.VoiceServiceImpl());
    gh.lazySingleton<_i791.LLMRepository>(
      () => _i377.LLMRepositoryImpl(supabaseClient: gh<_i454.SupabaseClient>()),
    );
    gh.factory<_i729.LocationBloc>(
      () => _i729.LocationBloc(locationService: gh<_i669.LocationService>()),
    );
    gh.lazySingleton<_i450.LLMService>(
      () => _i450.LLMServiceImpl(supabaseClient: gh<_i454.SupabaseClient>()),
    );
    gh.factory<_i598.AuthenticationBloc>(
      () =>
          _i598.AuthenticationBloc(supabaseClient: gh<_i454.SupabaseClient>()),
    );
    gh.factory<_i975.VoiceCommandBloc>(
      () => _i975.VoiceCommandBloc(llmRepository: gh<_i791.LLMRepository>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i464.RegisterModule {}
