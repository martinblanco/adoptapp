import 'package:adoptapp/screens/mascotas/mascota_register_page.dart';
import 'package:flutter/material.dart';

class PublicacionOpcionesPage extends StatelessWidget {
  const PublicacionOpcionesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<_OptionItem> options = [
      _OptionItem(
        title: 'Poner en adopción',
        description: 'Publicá tu mascota para encontrarle hogar.',
        icon: Icons.pets,
        color: const Color(0xFFF97316),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterPet()),
          );
        },
      ),
      _OptionItem(
        title: 'Perdido',
        description: 'Difundí una mascota perdida rápidamente.',
        icon: Icons.search_off,
        color: const Color(0xFFDC2626),
        onTap: () => _showSoonMessage(context, 'Perdido'),
      ),
      _OptionItem(
        title: 'Agregar un servicio',
        description: 'Publicá paseador, cuidador o similar.',
        icon: Icons.handyman,
        color: const Color(0xFF2563EB),
        onTap: () => _showSoonMessage(context, 'Agregar un servicio'),
      ),
      _OptionItem(
        title: 'Agregar Veterinaria',
        description: 'Mostrá una veterinaria recomendada.',
        icon: Icons.local_hospital,
        color: const Color(0xFF16A34A),
        onTap: () => _showSoonMessage(context, 'Agregar Veterinaria'),
      ),
      _OptionItem(
        title: 'Agregar Petshop',
        description: 'Sumá una tienda para mascotas.',
        icon: Icons.storefront,
        color: const Color(0xFF7C3AED),
        onTap: () => _showSoonMessage(context, 'Agregar Petshop'),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFFFFBF6),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _OptionCard(
              option: options.first,
              isWide: true,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                itemCount: options.length - 1,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final option = options[index + 1];
                  return _OptionCard(option: option);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showSoonMessage(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title próximamente')),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({required this.option, this.isWide = false});

  final _OptionItem option;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: option.onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: isWide ? 130 : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: option.color.withValues(alpha: 0.35)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: isWide
              ? Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: option.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(option.icon, size: 30, color: option.color),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            option.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF4B5563),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: option.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(option.icon, size: 30, color: option.color),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      option.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      option.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4B5563),
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _OptionItem {
  const _OptionItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}
