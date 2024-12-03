class GCFService {
  Future<String> checkProximity(double latitude, double longitude) async {
    // Simula um tempo de resposta
    await Future.delayed(const Duration(seconds: 1));
    // Retorna uma mensagem simulada
    return "Bem vindo à PUC Minas unidade fictícia!";
  }
}
