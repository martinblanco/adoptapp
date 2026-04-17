import 'package:adoptapp/screens/filtro_busqueda_page.dart';
import 'package:adoptapp/screens/mascotas/mascota_filtros.dart';
import 'package:adoptapp/entity/mascota.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FiltroPanel extends StatefulWidget {
  final ValueChanged<FiltrosMascota>? onFilterChanged;
  final FiltrosMascota filtrosActuales;

  const FiltroPanel(
      {Key? key, this.onFilterChanged, required this.filtrosActuales})
      : super(key: key);

  @override
  State<FiltroPanel> createState() => _FiltroPanelState();
}

class _FiltroPanelState extends State<FiltroPanel> {
  late FiltrosMascota _filtrosActuales;
  late bool _machoSelected;
  late bool _hembraSelected;

  @override
  void initState() {
    super.initState();
    _filtrosActuales = widget.filtrosActuales;
    _syncSexoSelection();
  }

  void _syncSexoSelection() {
    _machoSelected = _filtrosActuales.sexo == Sexo.macho;
    _hembraSelected = _filtrosActuales.sexo == Sexo.hembra;
  }

  void _notifyFilters() {
    widget.onFilterChanged?.call(_filtrosActuales);
  }

  void _togglePerros() {
    setState(() {
      _filtrosActuales =
          _filtrosActuales.copyWith(perros: !_filtrosActuales.perros);
    });
    _notifyFilters();
  }

  void _toggleGatos() {
    setState(() {
      _filtrosActuales =
          _filtrosActuales.copyWith(gatos: !_filtrosActuales.gatos);
    });
    _notifyFilters();
  }

  void _toggleMacho() {
    setState(() {
      _machoSelected = !_machoSelected;
      _applySexoFilter();
    });
    _notifyFilters();
  }

  void _toggleHembra() {
    setState(() {
      _hembraSelected = !_hembraSelected;
      _applySexoFilter();
    });
    _notifyFilters();
  }

  void _applySexoFilter() {
    Sexo sexo = Sexo.todos;
    if (_machoSelected && !_hembraSelected) {
      sexo = Sexo.macho;
    } else if (_hembraSelected && !_machoSelected) {
      sexo = Sexo.hembra;
    }

    _filtrosActuales = _filtrosActuales.copyWith(sexo: sexo);
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return FilterChip(
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
      avatar: icon != null
          ? Icon(
              icon,
              size: 13,
              color:
                  selected ? const Color(0xFF8A4A00) : const Color(0xFF5F6B7A),
            )
          : null,
      label: Text(
        label,
        style: TextStyle(
          color: selected ? const Color(0xFF8A4A00) : const Color(0xFF435062),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      selectedColor: const Color(0xFFFFE7CC),
      side: BorderSide(
        color: selected ? const Color(0xFFF4B36A) : const Color(0xFFD7DEE7),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6EBF2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: OutlinedButton.icon(
                onPressed: _abrirFiltros,
                icon: const Icon(Icons.tune_rounded, size: 16),
                label: const Text('Filtros'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF435062),
                  backgroundColor: const Color(0xFFF8FAFC),
                  visualDensity:
                      const VisualDensity(horizontal: -2, vertical: -2),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: const BorderSide(color: Color(0xFFD7DEE7)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFilterChip(
                  label: 'Perro',
                  selected: _filtrosActuales.perros,
                  onTap: _togglePerros,
                  icon: FontAwesomeIcons.dog,
                ),
                const SizedBox(height: 6),
                _buildFilterChip(
                  label: 'Macho',
                  selected: _machoSelected,
                  onTap: _toggleMacho,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFilterChip(
                  label: 'Gato',
                  selected: _filtrosActuales.gatos,
                  onTap: _toggleGatos,
                  icon: FontAwesomeIcons.cat,
                ),
                const SizedBox(height: 6),
                _buildFilterChip(
                  label: 'Hembra',
                  selected: _hembraSelected,
                  onTap: _toggleHembra,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _abrirFiltros() async {
    final resultado = await Navigator.push<FiltrosMascota>(
      context,
      MaterialPageRoute(
        builder: (context) => FiltrosPage(filtrosActuales: _filtrosActuales),
      ),
    );

    if (resultado != null) {
      setState(() {
        _filtrosActuales = resultado;
        _syncSexoSelection();
      });
      _notifyFilters();
    }
  }
}
