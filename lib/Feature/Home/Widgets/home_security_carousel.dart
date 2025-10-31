// 1. IMPORTAMOS O 'dart:async' PARA USAR O TIMER
import 'dart:async';
import 'package:flutter/material.dart';

const Color customYellow = Color(0xFFE0A800);

class HomeSecurityCarousel extends StatefulWidget {
  const HomeSecurityCarousel({super.key});

  @override
  State<HomeSecurityCarousel> createState() => _HomeSecurityCarouselState();
}

class _HomeSecurityCarouselState extends State<HomeSecurityCarousel> {
  late PageController _pageController;
  int _currentPageIndex = 0;

  // 2. DECLARAMOS A VARIÁVEL DO TIMER
  Timer? _timer;

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
    // 3. INICIAMOS O TIMER QUANDO A TELA É CRIADA
    _startTimer();
  }

  @override
  void dispose() {
    _pageController.dispose();
    // 4. PARAMOS O TIMER QUANDO A TELA É DESTRUÍDA (MUITO IMPORTANTE!)
    _timer?.cancel();
    super.dispose();
  }

  // 5. FUNÇÃO QUE CRIA E RODA O TIMER
  void _startTimer() {
    // Cancela qualquer timer anterior para evitar duplicatas
    _timer?.cancel();
    
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_pageController.hasClients) return; // Se o controller não estiver pronto, sai

      int nextPage = _currentPageIndex + 1;
      if (nextPage >= _securityTips.length) {
        nextPage = 0; // Volta para o início
      }

      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

        // 6. ADICIONAMOS O NotificationListener PARA PAUSAR O TIMER
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            // Se o usuário começar a arrastar manualmente
            if (notification is ScrollStartNotification &&
                notification.dragDetails != null) {
              _timer?.cancel();
            }
            // Se o usuário parar de arrastar
            else if (notification is ScrollEndNotification) {
              _startTimer();
            }
            return true; // Permite que a notificação continue
          },
          child: SizedBox(
            height: 180,
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
        ),
        const SizedBox(height: 30),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_securityTips.length, (index) {
            return _buildDotIndicator(isActive: index == _currentPageIndex);
          }),
        ),
      ],
    );
  }

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
          // 8. AJUSTEI O maxLines DA DESCRIÇÃO PARA CABER NO NOVO TAMANHO
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.3,
              ),
              maxLines: 4, // Aumentei de 3 para 4
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicator({required bool isActive}) {
    // ... (Esta função continua igual, sem mudanças)
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