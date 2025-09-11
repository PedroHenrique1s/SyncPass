bool isValidCPF(String cpf) {
  cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');

  if (cpf.length != 11) return false;

  // Elimina CPFs com todos os dígitos iguais
  if (RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) return false;

  // Valida dígito 1
  int sum = 0;
  for (int i = 0; i < 9; i++) {
    sum += int.parse(cpf[i]) * (10 - i);
  }
  int firstDigit = (sum * 10) % 11;
  if (firstDigit == 10) firstDigit = 0;
  if (firstDigit != int.parse(cpf[9])) return false;

  // Valida dígito 2
  sum = 0;
  for (int i = 0; i < 10; i++) {
    sum += int.parse(cpf[i]) * (11 - i);
  }
  int secondDigit = (sum * 10) % 11;
  if (secondDigit == 10) secondDigit = 0;
  if (secondDigit != int.parse(cpf[10])) return false;

  return true;
}
