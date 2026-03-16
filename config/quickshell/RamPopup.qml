import "services" as Services
import "components" as Components

Components.BaseStatPopup {
    title: "Memory Usage"
    currentValue: Services.ShellData.ramUsage
    historyData: Services.ShellData.ramHistory
    subValue: Services.ShellData.ramPerc + "%"
}
