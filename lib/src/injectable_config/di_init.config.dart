// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dotenv/dotenv.dart' as _i5;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:logger/logger.dart' as _i6;

import '../app/app.dart' as _i23;
import '../app/controller/link_controller.dart' as _i22;
import '../app/integration/environment_resolver.dart' as _i7;
import '../app/integration/impl/debug_server_info_retriever_impl.dart' as _i19;
import '../app/integration/impl/environment_resolver_impl.dart' as _i8;
import '../app/integration/impl/link_alias_generator_impl.dart' as _i16;
import '../app/integration/impl/link_url_hash_generator_impl.dart' as _i10;
import '../app/integration/impl/prod_server_info_retriever_impl.dart' as _i12;
import '../app/integration/impl/telegram_bot_operator_impl.dart' as _i18;
import '../app/integration/link_alias_generator.dart' as _i15;
import '../app/integration/link_url_hash_generator.dart' as _i9;
import '../app/integration/server_info_retriever.dart' as _i11;
import '../app/integration/sha_256_encryptor.dart' as _i3;
import '../app/integration/telegram_bot_operator.dart' as _i17;
import '../app/repository/impl/link_repository_impl.dart' as _i14;
import '../app/repository/link_repository.dart' as _i13;
import '../app/service/impl/link_service_impl.dart' as _i21;
import '../app/service/link_service.dart' as _i20;
import 'register_module.dart' as _i4;

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
    gh.factory<_i3.Sha256Encryptor>(() => _i3.Sha256Encryptor());
    gh.singleton<_i4.PrismaClientFactory>(() => _i4.PrismaClientFactory());
    gh.singleton<_i4.Utf8CodecFactory>(() => _i4.Utf8CodecFactory());
    gh.singleton<_i5.DotEnv>(() => registerModule.dotEnv);
    gh.singleton<_i6.Logger>(() => registerModule.logger);
    gh.singleton<_i7.EnvironmentResolver>(
        () => _i8.EnvironmentResolverImpl(gh<_i5.DotEnv>()));
    gh.singleton<_i9.LinkUrlHashGenerator>(() => _i10.LinkUrlHashGeneratorImpl(
          gh<_i4.Utf8CodecFactory>(),
          gh<_i3.Sha256Encryptor>(),
        ));
    gh.singleton<_i11.ServerInfoRetriever>(
      () => _i12.ProdServerInfoRetrieverImpl(),
      registerFor: {_prod},
    );
    gh.singleton<_i13.LinkRepository>(
        () => _i14.LinkRepositoryImpl(gh<_i4.PrismaClientFactory>()));
    gh.singleton<_i15.LinkAliasGenerator>(() => _i16.LinkAliasGeneratorImpl(
          gh<_i4.Utf8CodecFactory>(),
          gh<_i3.Sha256Encryptor>(),
        ));
    gh.singleton<_i17.TelegramBotOperator>(
        () => _i18.TelegramBotOperatorImpl.init(
              gh<_i7.EnvironmentResolver>(),
              gh<_i6.Logger>(),
            ));
    gh.singleton<_i11.ServerInfoRetriever>(
      () => _i19.DebugServerInfoRetrieverImpl(),
      registerFor: {_debug},
    );
    gh.singleton<_i20.LinkService>(() => _i21.LinkServiceImpl(
          gh<_i11.ServerInfoRetriever>(),
          gh<_i13.LinkRepository>(),
          gh<_i15.LinkAliasGenerator>(),
          gh<_i9.LinkUrlHashGenerator>(),
        ));
    gh.singleton<_i22.LinkController>(
        () => _i22.LinkController(gh<_i20.LinkService>()));
    await gh.singletonAsync<_i23.LinkTailorApp>(
      () => _i23.LinkTailorApp.init(
        gh<_i11.ServerInfoRetriever>(),
        gh<_i17.TelegramBotOperator>(),
        gh<_i7.EnvironmentResolver>(),
        gh<_i6.Logger>(),
        gh<_i22.LinkController>(),
      ),
      preResolve: true,
    );
    return this;
  }
}

class _$RegisterModule extends _i4.RegisterModule {}
