/// Estados simulados de carregamento das telas do protótipo (não há rede).
enum LoadState<Value> {
    case loading
    case loaded(Value)
    /// Falha de conexão ou do servidor.
    case failed
    /// Não há edição ativa no evento.
    case unavailable
}
