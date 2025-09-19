import QtQuick
import QtQuick.Controls
import Quickshell
import qs.modules.theme
import qs.modules.components
import qs.config

OptionsMenu {
    id: root

    required property var menuHandle
    property bool isOpen: false

    // Configuración específica para menús contextuales
    menuWidth: 160
    itemHeight: 32

    // Función para limpiar texto problemático
    function cleanMenuText(text) {
        if (!text || text === "") return "";
        
        // Convertir a string
        text = String(text);
        
        // Simplemente eliminar ":/// " del comienzo si está presente
        if (text.startsWith(":/// ")) {
            text = text.substring(5);
        }
        
        // Limpiar espacios y retornar
        return text.trim();
    }

    // Función para validar si un icono es compatible con la fuente Phosphor
    function isValidIcon(icon) {
        if (!icon || icon === "") return false;
        
        // Los iconos válidos de Phosphor son caracteres únicos
        // Los iconos del sistema suelen ser rutas o nombres largos
        if (icon.length > 4) return false;
        if (icon.includes("/") || icon.includes(".") || icon.includes(":")) return false;
        
        return true;
    }

    // Función para detectar si un icono es una imagen
    function isImageIcon(icon) {
        if (!icon || icon === "") return false;
        
        // Detectar rutas de archivo de imagen comunes
        if (icon.includes("/") || icon.includes(".")) return true;
        if (icon.startsWith("file://") || icon.startsWith("http")) return true;
        if (icon.length > 10) return true; // Nombres largos suelen ser rutas
        
        return false;
    }

    // Opener para acceder a los hijos del QsMenuHandle
    QsMenuOpener {
        id: menuOpener
        menu: root.menuHandle

        onChildrenChanged: {
            console.log("Menu children changed, count:", children ? children.values.length : "null");
        }
    }

    // Convertir los QsMenuEntry a formato compatible con OptionsMenu
    items: {
        console.log("Building menu items...");
        console.log("menuHandle:", root.menuHandle);
        console.log("menuOpener.children:", menuOpener.children);

        if (!menuOpener.children || !menuOpener.children.values) {
            console.log("No children values available");
            return [];
        }

        let menuItems = [];
        console.log("Children count:", menuOpener.children.values.length);

        for (let i = 0; i < menuOpener.children.values.length; i++) {
            let entry = menuOpener.children.values[i];
            console.log("Entry", i, ":", entry, "isSeparator:", entry ? entry.isSeparator : "null", "text:", entry ? entry.text : "null", "icon:", entry ? entry.icon : "null");

            if (entry) {
                // Manejar separadores como lo hace Caelestia
                if (entry.isSeparator) {
                    menuItems.push({
                        text: "",
                        icon: "",
                        enabled: false,
                        isSeparator: true,
                        onTriggered: function () {} // Sin acción para separadores
                    });
                } else {
                    // Limpiar el texto
                    let originalText = entry.text;
                    let cleanText = cleanMenuText(originalText);
                    
                    // Determinar tipo de icono
                    let iconToUse = "";
                    let useImageIcon = false;
                    
                    if (entry.icon) {
                        if (isValidIcon(entry.icon)) {
                            // Es un icono de fuente válido
                            iconToUse = entry.icon;
                            useImageIcon = false;
                        } else if (isImageIcon(entry.icon)) {
                            // Es una imagen
                            iconToUse = entry.icon;
                            useImageIcon = true;
                        }
                        // Si no es válido como fuente ni como imagen, se omite
                    }

                    // Debug detallado del procesamiento de texto e iconos
                    if (originalText !== cleanText) {
                        console.log("Text cleaned - Original:", originalText, "-> Clean:", cleanText);
                    }
                    if (entry.icon) {
                        console.log("Icon processed - Original:", entry.icon, "-> Used:", iconToUse, "isImage:", useImageIcon);
                    }

                    // Omitir entradas sin texto válido y sin iconos
                    if (cleanText === "" && iconToUse === "") {
                        console.log("Skipping entry with no valid text or icon:", originalText);
                        continue;
                    }

                    menuItems.push({
                        text: cleanText,
                        icon: iconToUse,
                        isImageIcon: useImageIcon,
                        enabled: entry.enabled !== false,
                        isSeparator: false,
                        onTriggered: function () {
                            console.log("Triggering menu item:", cleanText);
                            if (entry.triggered) {
                                entry.triggered();
                            }
                            root.close();
                        }
                    });
                }
            }
        }
        console.log("Final menu items count:", menuItems.length);
        return menuItems;
    }

    // Funciones de control
    function open() {
        console.log("Opening context menu...");
        console.log("menuHandle:", menuHandle);
        console.log("Has menu:", !!menuHandle);

        isOpen = true;
        popup();
    }

    function close() {
        console.log("Closing context menu");
        isOpen = false;
        visible = false;
    }
}
