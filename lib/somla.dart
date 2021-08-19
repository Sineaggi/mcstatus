import 'package:dartmc/dartmc.dart';

class Somla {
  static Future<PingResponse> getStatus(
      {String address = 'gatsbycrafts.mc.gg'}) async {
    final server = await MinecraftServer.lookup(address);
    return await server.status();
  }
}
