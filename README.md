# SyncPass 🔐

![Flutter](https://img.shields.io/badge/Framework-Flutter-02569B?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Language-Dart-0175C2?style=for-the-badge&logo=dart)
![Firebase](https://img.shields.io/badge/Backend-Firebase-FFCA28?style=for-the-badge&logo=firebase)

Um gerenciador de senhas móvel, seguro e sincronizado, construído com Flutter e Firebase. O SyncPass permite que os usuários armazenem e gerenciem suas credenciais, notas seguras e documentos com facilidade.

## ✨ Principais Funcionalidades

* **Autenticação Segura:** Login facilitado utilizando E-mail/Senha ou autenticação social com o **Google**.
* **Cofre de Senhas:** Armazene, visualize e gerencie suas senhas e nomes de usuário.
* **Dados Criptografados:** Todas as senhas e dados sensíveis são criptografados antes de serem salvos no banco de dados, garantindo sua privacidade.
* **Armazenamento de Anexos:** Faça upload e vincule imagens e documentos (como fotos de cartões ou documentos de identidade) de forma segura usando o **Firebase Storage**.
* **Sincronização em Tempo Real:** Seus dados são salvos e sincronizados instantaneamente com o **Firebase Database** (Firestore/Realtime Database).

## 📸 Screenshots (Telas)


| Tela de Login | Tela Principal (Cofre) |
| :---: | :---: |
| [![syncPassjpeg](https://github.com/user-attachments/assets/3cb78e97-995c-4c2c-997a-d112469fabee)] | [![telaINicialjpeg](https://github.com/user-attachments/assets/2ca830e6-7f0b-4684-80c2-55f371864dd6)] 

## 🚀 Tecnologias Utilizadas

Este projeto foi construído utilizando as seguintes tecnologias:

* **[Flutter](https://flutter.dev/)**: SDK de UI para criar aplicativos nativos compilados para dispositivos móveis, web e desktop a partir de um único código-base.
* **[Dart](https://dart.dev/)**: Linguagem de programação otimizada para clientes para aplicativos rápidos em qualquer plataforma.
* **[Firebase](https://firebase.google.com/)**: Plataforma de desenvolvimento de aplicativos do Google que ajuda a construir e escalar aplicativos.
    * **[Firebase Authentication](https://firebase.google.com/products/auth)**: Para gerenciamento de login com E-mail/Senha e Google.
    * **[Firebase Database (Firestore/Realtime)](https://firebase.google.com/products/database)**: Para armazenar os dados criptografados do usuário em tempo real.
    * **[Firebase Storage](https://firebase.google.com/products/storage)**: Para upload e armazenamento de imagens e documentos anexados.

## 🔧 Instalação e Execução

Para rodar este projeto localmente, siga os passos abaixo:

**1. Pré-requisitos:**

* Você precisa ter o [SDK do Flutter](https://flutter.dev/docs/get-started/install) instalado.
* Um editor de código (como VS Code ou Android Studio).

**2. Clone o Repositório:**

```bash
git clone [https://github.com/PedroHenrique1s/SyncPass.git](https://github.com/PedroHenrique1s/SyncPass.git)
cd SyncPass
