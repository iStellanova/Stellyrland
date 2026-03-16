import "services" as Services
import "components" as Components

Components.BaseStatPopup {
    title: "CPU Usage"
    currentValue: Services.ShellData.cpuUsage + "%"
    historyData: Services.ShellData.cpuHistory
}
