import QtQuick
import qs.modules.components
import qs.modules.theme
import qs.modules.services
import qs.modules.globals

ToggleButton {
  id: quotesButton
  buttonIcon: "This respect"
  tooltipText: "Quotes"

  onToggle: function () {
    if (GlobalStates.quotesOpen) {
      Visibilities.setActiveModule("");
    } else {
      Visibilities.setActiveModule("quotes");
    }
  }
}
