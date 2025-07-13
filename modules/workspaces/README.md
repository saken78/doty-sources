# Módulo de Workspaces Avanzado

Este módulo implementa un sistema avanzado de workspaces basado en el proyecto ii-qs, que incluye todas las funcionalidades avanzadas como:

## Características Implementadas

### ✨ Funcionalidades Principales
- **Paginación de workspaces**: Muestra 10 workspaces por grupo/página
- **Iconos de aplicaciones**: Muestra el icono de la aplicación más grande en cada workspace
- **Animaciones suaves**: Transiciones fluidas entre workspaces
- **Indicadores visuales**: Diferentes estados para workspace activo, ocupado y vacío
- **Scroll para navegación**: Usa la rueda del mouse para cambiar workspaces
- **Shortcuts de teclado**: Atajo para mostrar/ocultar números de workspace

### 🎨 Elementos Visuales
- **Indicador de workspace activo**: Círculo destacado para el workspace actual
- **Agrupación visual**: Los workspaces ocupados se conectan visualmente
- **Iconos adaptativos**: Muestra iconos de aplicaciones o números según configuración
- **Puntos para workspaces vacíos**: Indicadores minimalistas para workspaces sin contenido

### ⚙️ Configuración
El módulo incluye un sistema de configuración completo:

```qml
ConfigOptions.bar.workspaces: {
    shown: 10,                    // Número de workspaces mostrados por grupo
    showAppIcons: true,           // Mostrar iconos de aplicaciones
    alwaysShowNumbers: false,     // Siempre mostrar números en lugar de iconos
    showNumberDelay: 300          // Delay para mostrar números (ms)
}
```

### 🔧 Servicios Auxiliares Incluidos

#### HyprlandData.qml
- Singleton que proporciona acceso a datos de Hyprland no disponibles en Quickshell
- Lista de ventanas, direcciones y monitores
- Actualización automática en eventos de Hyprland

#### AppSearch.qml
- Sistema de búsqueda y adivinación de iconos
- Sustituciones personalizadas para aplicaciones conocidas
- Búsqueda inteligente de iconos por nombre de clase

#### GlobalStates.qml
- Estados globales del sistema
- Gestión de shortcuts para mostrar números de workspace
- Control de timeouts y comportamientos

#### Appearance.qml
- Sistema de colores y theming
- Configuración de animaciones
- Valores de redondeo y fuentes

## 🚀 Uso

### Integración Básica
```qml
import "./workspaces"

Workspaces {
    bar: QtObject {
        property var screen: null // Tu objeto de pantalla
    }
    
    anchors {
        left: parent.left
        verticalCenter: parent.verticalCenter
        leftMargin: 20
    }
}
```

### Dependencias
- QtQuick
- QtQuick.Controls
- QtQuick.Layouts
- Quickshell.Hyprland
- Quickshell.Wayland
- Quickshell.Widgets
- Quickshell.Io
- Qt5Compat.GraphicalEffects

## 📁 Estructura del Módulo

```
modules/workspaces/
├── Workspaces.qml          # Componente principal
├── HyprlandData.qml        # Singleton - Datos de Hyprland
├── AppSearch.qml           # Singleton - Búsqueda de iconos
├── ConfigOptions.qml       # Singleton - Configuración
├── GlobalStates.qml        # Singleton - Estados globales
├── Appearance.qml          # Singleton - Theming y colores
├── StyledText.qml          # Componente de texto estilizado
├── color_utils.js          # Utilidades de color
├── qmldir                  # Registro de singletons
├── ExampleUsage.qml        # Ejemplo de uso
└── README.md               # Esta documentación
```

## 🎯 Funcionalidades Específicas

### Navegación con Mouse
- **Scroll**: Cambia entre workspaces usando la rueda del mouse
- **Botón trasero**: Alterna el workspace especial
- **Click**: Cambia directamente al workspace clickeado

### Indicadores Visuales
- **Workspace activo**: Indicador circular destacado con color primario
- **Workspaces ocupados**: Fondo semi-transparente conectado
- **Workspaces vacíos**: Sin indicador de fondo
- **Transiciones**: Animaciones suaves en todos los cambios de estado

### Sistema de Iconos
- **Detección automática**: Encuentra el icono apropiado para cada aplicación
- **Aplicación principal**: Muestra el icono de la ventana más grande
- **Fallback inteligente**: Sistema de respaldo para aplicaciones desconocidas
- **Sustituciones**: Mapeo personalizado para aplicaciones conocidas

El módulo está completamente integrado y listo para usar en tu proyecto Ambyst.