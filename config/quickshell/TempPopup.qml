import "services" as Services
import "components" as Components

Components.BaseStatPopup {
    title: "System Temperature"
    currentValue: Services.ShellData.temperature + "°C"
    historyData: Services.ShellData.tempHistory
}
