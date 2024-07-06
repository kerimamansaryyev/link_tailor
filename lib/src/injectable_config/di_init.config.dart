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

import '../app/app.dart' as _i13;
import '../app/integration/environment_resolver.dart' as _i6;
import '../app/integration/impl/debug_server_info_retriever_impl.dart' as _i12;
import '../app/integration/impl/environment_resolver_impl.dart' as _i7;
import '../app/integration/impl/prod_server_info_retriever_impl.dart' as _i9;
import '../app/integration/server_info_retriever.dart' as _i8;
import '../app/repository/impl/link_repository_impl.dart' as _i11;
import '../app/repository/link_repository.dart' as _i10;
import '../app/service/impl/link_service_impl.dart' as _i14;
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
    gh.singleton<_i6.EnvironmentResolver>(
        () => _i7.EnvironmentResolverImpl(gh<_i4.DotEnv>()));
    gh.singleton<_i8.ServerInfoRetriever>(
      () => _i9.ProdServerInfoRetrieverImpl(),
      registerFor: {_prod},
    );
    gh.singleton<_i10.LinkRepository>(
        () => _i11.LinkRepositoryImpl(gh<_i3.PrismaClientFactory>()));
    gh.singleton<_i8.ServerInfoRetriever>(
      () => _i12.DebugServerInfoRetrieverImpl(),
      registerFor: {_debug},
    );
    await gh.singletonAsync<_i13.LinkTailorApp>(
      () => _i13.LinkTailorApp.init(
        gh<_i8.ServerInfoRetriever>(),
        gh<_i6.EnvironmentResolver>(),
        gh<_i5.Logger>(),
      ),
      preResolve: true,
    );
    gh.singleton<_i14.LinkServiceImpl>(() => _i14.LinkServiceImpl(
          serverInfoRetriever: gh<_i8.ServerInfoRetriever>(),
          linkRepository: gh<_i10.LinkRepository>(),
        ));
    return this;
  }
}

class _$RegisterModule extends _i3.RegisterModule {}
