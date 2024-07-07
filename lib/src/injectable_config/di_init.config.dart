// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dotenv/dotenv.dart' as _i4;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:logger/logger.dart' as _i5;

import '../app/app.dart' as _i16;
import '../app/integration/environment_resolver.dart' as _i8;
import '../app/integration/impl/debug_server_info_retriever_impl.dart' as _i14;
import '../app/integration/impl/environment_resolver_impl.dart' as _i9;
import '../app/integration/impl/link_alias_generator_impl.dart' as _i7;
import '../app/integration/impl/prod_server_info_retriever_impl.dart' as _i11;
import '../app/integration/link_alias_generator.dart' as _i6;
import '../app/integration/server_info_retriever.dart' as _i10;
import '../app/repository/impl/link_repository_impl.dart' as _i13;
import '../app/repository/link_repository.dart' as _i12;
import '../app/service/impl/link_service_impl.dart' as _i15;
import 'register_module.dart' as _i3;

const String _prod = 'prod';
const String _debug = 'debug';

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i1.GetIt> init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    gh.singleton<_i3.PrismaClientFactory>(() => _i3.PrismaClientFactory());
    gh.singleton<_i4.DotEnv>(() => registerModule.dotEnv);
    gh.singleton<_i5.Logger>(() => registerModule.logger);
    gh.singleton<_i6.LinkAliasGenerator>(() => _i7.LinkAliasGeneratorImpl());
    gh.singleton<_i8.EnvironmentResolver>(
        () => _i9.EnvironmentResolverImpl(gh<_i4.DotEnv>()));
    gh.singleton<_i10.ServerInfoRetriever>(
      () => _i11.ProdServerInfoRetrieverImpl(),
      registerFor: {_prod},
    );
    gh.singleton<_i12.LinkRepository>(
        () => _i13.LinkRepositoryImpl(gh<_i3.PrismaClientFactory>()));
    gh.singleton<_i10.ServerInfoRetriever>(
      () => _i14.DebugServerInfoRetrieverImpl(),
      registerFor: {_debug},
    );
    gh.singleton<_i15.LinkServiceImpl>(() => _i15.LinkServiceImpl(
          gh<_i10.ServerInfoRetriever>(),
          gh<_i12.LinkRepository>(),
          gh<_i6.LinkAliasGenerator>(),
        ));
    await gh.singletonAsync<_i16.LinkTailorApp>(
      () => _i16.LinkTailorApp.init(
        gh<_i10.ServerInfoRetriever>(),
        gh<_i8.EnvironmentResolver>(),
        gh<_i5.Logger>(),
      ),
      preResolve: true,
    );
    return this;
  }
}

class _$RegisterModule extends _i3.RegisterModule {}
