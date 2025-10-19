import 'package:flutter/material.dart';

// Cor customizada
const Color customYellow = Color(0xFFE0A800);

class HomeSecurityCarousel extends StatefulWidget {
  const HomeSecurityCarousel({super.key});

  @override
  State<HomeSecurityCarousel> createState() => _HomeSecurityCarouselState();
}

class _HomeSecurityCarouselState extends State<HomeSecurityCarousel> {
  late PageController _pageController;
  int _currentPageIndex = 0;

  // A lista de dicas agora mora dentro do estado deste widget
  final List<Map<String, dynamic>> _securityTips = [
    {
      'icon': Icons.lightbulb_outline,
      'title': 'Use Senhas Fortes',
      'description':
          'Combine letras maiúsculas, minúsculas, números e símbolos. Use o gerador de senhas!',
    },
    {
      'icon': Icons.shield_outlined,
      'title': 'Ative a Verificação em Duas Etapas (2FA)',
      'description':
          'Sempre que possível, ative o 2FA para uma camada extra de segurança em suas contas.',
    },
    {
      'icon': Icons.phishing_outlined,
      'title': 'Cuidado com Phishing',
      'description':
          'Nunca clique em links suspeitos ou forneça suas senhas por e-mail ou mensagens.',
    },
    {
      'icon': Icons.lock_reset_outlined,
      'title': 'Atualize Senhas Antigas',
      'description':
          'Evite reutilizar senhas e troque senhas de serviços importantes periodicamente.',
    }
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9, initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              // Usando o método privado para construir o card
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
            // Usando o método privado para construir o indicador
            return _buildDotIndicator(isActive: index == _currentPageIndex);
          }),
        ),
      ],
    );
  }

  // Método que era `_buildSecurityTipCard`
  Widget _buildSecurityTipCard(
      {required IconData icon,
      required String title,
      required String description}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.all(16.0),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: customYellow.withAlpha(26),
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
              height: 1.3,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Método que era `_buildDotIndicator`
  Widget _buildDotIndicator({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isActive ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? customYellow : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}