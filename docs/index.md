# Azure Cost and Usage Insights Mod

[Tailpipe](https://tailpipe.io) is an open-source CLI tool that allows you to collect logs and query them with SQL.

[Microsoft Azure](https://azure.microsoft.com/) provides on-demand cloud computing platforms and APIs to authenticated customers on a metered pay-as-you-go basis.

The [Azure Cost and Usage Insights Mod](https://hub.powerpipe.io/mods/turbot/tailpipe-mod-azure-cost-and-usage-insights) contains pre-built dashboards which can be used to monitor and analyze costs across your Azure subscriptions using [Azure Cost and Usage](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/cost-mgt-best-practices) exports.

<img src="https://raw.githubusercontent.com/turbot/tailpipe-mod-azure-cost-and-usage-insights/main/docs/images/azure_cost_and_usage_overview_dashboard.png" width="50%" type="thumbnail"/>
<img src="https://raw.githubusercontent.com/turbot/tailpipe-mod-azure-cost-and-usage-insights/main/docs/images/azure_cost_and_usage_cost_by_service_dashboard.png" width="50%" type="thumbnail"/>
<img src="https://raw.githubusercontent.com/turbot/tailpipe-mod-azure-cost-and-usage-insights/main/docs/images/azure_cost_and_usage_cost_by_resource_group_dashboard.png" width="50%" type="thumbnail"/>

## Documentation

- **[Dashboards →](https://hub.powerpipe.io/mods/turbot/tailpipe-mod-azure-cost-and-usage-insights/dashboards)**

## Getting Started

Install Powerpipe from the [downloads](https://powerpipe.io/downloads) page:

```sh
# MacOS
brew install turbot/tap/powerpipe
```

```sh
# Linux or Windows (WSL)
sudo /bin/sh -c "$(curl -fsSL https://powerpipe.io/install/powerpipe.sh)"
```

This mod requires Azure Cost and Usage data to be collected using [Tailpipe](https://tailpipe.io) with the [Azure plugin](https://hub.tailpipe.io/plugins/turbot/azure):

- [Get started with the Azure plugin for Tailpipe →](https://hub.tailpipe.io/plugins/turbot/azure#getting-started)

Install the mod:

```sh
mkdir dashboards
cd dashboards
powerpipe mod install github.com/turbot/tailpipe-mod-azure-cost-and-usage-insights
```

### Browsing Dashboards

Start the dashboard server:

```sh
powerpipe server
```

Browse and view your dashboards at **http://localhost:9033**. 