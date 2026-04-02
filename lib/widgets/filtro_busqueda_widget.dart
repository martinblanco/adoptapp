import 'package:adoptapp/screens/filtro_busqueda_page.dart';
import 'package:adoptapp/providers/filtro_provider.dart';
import 'package:adoptapp/screens/mascotas/mascota_filtros.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
    _filtrosActuales = widget.filtrosActuales;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => FiltroNotifier()..cargarProvincias(ctx),
      child: Consumer<FiltroNotifier>(
        builder: (context, filtro, _) => Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.orangeAccent[100],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _abrirFiltros,
              ),
              if (!filtro.isLoading)
                DropdownButton(
                  value: filtro.selectedProvincia,
                  onChanged: (newValue) {
                    if (newValue != null) {
                      filtro.setProvincia(newValue);
                      _filtrosActuales =
                          _filtrosActuales.copyWith(provincia: newValue.name);
                      widget.onFilterChanged?.call(_filtrosActuales);
                    }
                  },
                  items: filtro.provincias
                      .map((p) =>
                          DropdownMenuItem(value: p, child: Text(p.name)))
                      .toList(),
                )
              else
                const SizedBox(
                    width: 80,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2)),
              FilterChip(
                label: const Icon(FontAwesomeIcons.dog, size: 16),
                selected: filtro.isSelectedPerros,
                backgroundColor: Colors.orangeAccent,
                selectedColor: Colors.orange,
                onSelected: (_) {
                  filtro.togglePerros();
                  _filtrosActuales = _filtrosActuales.copyWith(
                    perros: filtro.isSelectedPerros,
                  );
                  widget.onFilterChanged?.call(_filtrosActuales);
                },
              ),
              FilterChip(
                label: const Icon(FontAwesomeIcons.cat, size: 16),
                selected: filtro.isSelectedGatos,
                backgroundColor: Colors.orangeAccent,
                selectedColor: Colors.orange,
                onSelected: (_) {
                  filtro.toggleGatos();
                  _filtrosActuales = _filtrosActuales.copyWith(
                    gatos: filtro.isSelectedGatos,
                  );
                  widget.onFilterChanged?.call(_filtrosActuales);
                },
              ),
            ],
          ),
        ),
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
      });
      widget.onFilterChanged?.call(_filtrosActuales);
    }
  }
}
