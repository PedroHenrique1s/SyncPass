// Enum para gerenciar os tipos de senha de forma segura
enum PasswordType { login, card, generic }

// Mapa para os textos que aparecerão no dropdown (se precisar em outro lugar)
const Map<PasswordType, String> passwordTypeLabels = {
  PasswordType.login: 'Login de Site/App',
  PasswordType.card: 'Cartão de Crédito',
  PasswordType.generic: 'Senha Genérica / Nota',
};