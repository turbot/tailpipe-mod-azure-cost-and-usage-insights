# Azure Cost Management Insights Mod

[Tailpipe](https://tailpipe.io) is an open-source CLI tool that allows you to collect logs and query them with SQL.

[Microsoft Azure](https://azure.microsoft.com/) is a cloud computing platform operated by Microsoft for application management via Microsoft-managed data centers.

The [Azure Cost Management Insights Mod](https://hub.powerpipe.io/mods/turbot/tailpipe-mod-azure-cost-management-insights) contains pre-built dashboards which can be used to monitor and analyze costs across your Azure subscriptions using [Azure Cost Management](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/cost-mgt-best-practices).

## Documentation

- **[Dashboards →](https://hub.powerpipe.io/mods/turbot/tailpipe-mod-azure-cost-management-insights/dashboards)**

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

This mod requires Azure Cost Management data to be collected using [Tailpipe](https://tailpipe.io) with the [Azure plugin](https://hub.tailpipe.io/plugins/turbot/azure):

- [Get started with the Azure plugin for Tailpipe →](https://hub.tailpipe.io/plugins/turbot/azure#getting-started)

Install the mod:

```sh
mkdir dashboards
cd dashboards
powerpipe mod install github.com/turbot/tailpipe-mod-azure-cost-management-insights
```

### Browsing Dashboards

Start the dashboard server:

```sh
powerpipe server
```

Browse and view your dashboards at **http://localhost:9033**. 