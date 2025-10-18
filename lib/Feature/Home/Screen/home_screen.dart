import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:sync_pass/Feature/Login/Screen/login_screen.dart';
import 'package:sync_pass/Feature/Login/Services/auth_method.dart';
import 'package:sync_pass/Feature/Generator/Screen/generator_screen.dart';
import 'package:sync_pass/Feature/AddPass/Screen/add_pass_screen.dart';
import 'package:sync_pass/Feature/Passcode/Screen/passcode_screen.dart';

// Definindo a cor amarela customizada
const Color customYellow = Color(0xFFE0A800);

// Convertemos para StatefulWidget para buscar dados
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  int _currentPageIndex = 0;

  final List<Map<String, dynamic>> _securityTips = [
    {
      'icon': Icons.lightbulb_outline,
      'title': 'Use Senhas Fortes',
      'description': 'Combine letras maiúsculas, minúsculas, números e símbolos. Use o gerador de senhas!',
    },
    {
      'icon': Icons.shield_outlined,
      'title': 'Ative a Verificação em Duas Etapas (2FA)',
      'description': 'Sempre que possível, ative o 2FA para uma camada extra de segurança em suas contas.',
    },
    {
      'icon': Icons.phishing_outlined,
      'title': 'Cuidado com Phishing',
      'description': 'Nunca clique em links suspeitos ou forneça suas senhas por e-mail ou mensagens.',
    },
    {
      'icon': Icons.lock_reset_outlined,
      'title': 'Atualize Senhas Antigas',
      'description': 'Evite reutilizar senhas e troque senhas de serviços importantes periodicamente.',
    }
  ];

  @override
  void initState() {
    super.initState();
    // Inicializa o PageController aqui!
    _pageController = PageController(viewportFraction: 0.9, initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = GoogleSignInService.getCurrentUser();

    return Scaffold(
      backgroundColor: Colors.grey[100], // Um fundo mais suave
      appBar: AppBar(
        title: const Text(
          'SyncPass',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: customYellow.withAlpha(102),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black54),
            tooltip: 'Sair',
            onPressed: () async {
              await GoogleSignInService.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [  
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildUserInfoSection(user),
            ),
            
            const SizedBox(height: 20),
            _buildSecurityTipsCarousel(),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildMenuGrid(context),
            ),

            const SizedBox(height: 30), // Espaço no final
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoSection(User? user) {
    return Container(
      padding: const EdgeInsets.all(16), // <-- Padding reduzido
      decoration: BoxDecoration(
        color: Colors.white, // <-- Cor alterada para branco
        borderRadius: BorderRadius.circular(16),
        boxShadow: [ // Sombra suave para consistência
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 35, // <-- Raio reduzido
            backgroundColor: Colors.grey[200],
            backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
            child: user?.photoURL == null 
                ? const Icon(Icons.person, size: 35, color: Colors.grey) 
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            'Bem-vindo(a), ${user?.displayName?.split(' ')[0] ?? 'Usuário'}!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22, // <-- Fonte reduzida
              fontWeight: FontWeight.bold,
              color: Colors.black87, // <-- Cor alterada
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14, // <-- Fonte reduzida
              color: Colors.grey[700], // <-- Cor alterada
            ),
          ),
        ],
      ),
    );
  }

  // 2. Grid de menu com cards mais refinados.
  Widget _buildMenuGrid(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {'title': 'Minhas Senhas', 'icon': Icons.lock_outline, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PasscodeScreen()))},
      {'title': 'Nova Senha', 'icon': Icons.add_circle_outline, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPassScreen()))},
      {'title': 'Gerar Senha', 'icon': Icons.vpn_key_outlined, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GeneratorScreen()))},
      {'title': 'Anexar Arquivos', 'icon': Icons.folder_copy_outlined, 'onTap': () { /* Lógica de navegação */ }},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: menuItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2, // Proporção ajustada
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _buildMenuItemCard(
          title: item['title'],
          icon: item['icon'],
          onTap: item['onTap'],
        );
      },
    );
  }

  Widget _buildMenuItemCard({required String title, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(26),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: customYellow.withAlpha(26),
              child: Icon(icon, size: 28, color: customYellow),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityTipsCarousel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da Seção
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Dicas de Segurança',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // O Carrossel (PageView)
        SizedBox(
          height: 160, // Altura fixa para os cards
          child: PageView.builder(
            controller: _pageController,
            itemCount: _securityTips.length,
            onPageChanged: (index) {
              setState(() {
                _currentPageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final tip = _securityTips[index];
              return _buildSecurityTipCard(
                icon: tip['icon'],
                title: tip['title'],
                description: tip['description'],
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // Os Indicadores (pontos)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_securityTips.length, (index) {
            return _buildDotIndicator(isActive: index == _currentPageIndex);
          }),
        ),
      ],
    );
  }

  Widget _buildSecurityTipCard({required IconData icon, required String title, required String description}) {
    return Container(
      // Espaçamento entre os cards (metade do que não é viewportFraction)
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26), // Sombra suave
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: customYellow.withAlpha(26), // Fundo amarelo suave
            child: Icon(icon, size: 22, color: customYellow),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.3, // Espaçamento entre linhas
            ),
            maxLines: 3, // Limita a 3 linhas
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicator({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isActive ? 24.0 : 8.0, // Ponto ativo é mais largo
      decoration: BoxDecoration(
        color: isActive ? customYellow : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

}