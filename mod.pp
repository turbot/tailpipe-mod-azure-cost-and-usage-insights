mod "azure_cost_management_insights" {
  # hub metadata
  title         = "Azure Cost Management Insights"
  description   = "Monitor and analyze costs across your Azure subscriptions using pre-built dashboards for Azure Cost Management with Powerpipe and Tailpipe."
  color         = "#0072C6"
  documentation = file("./docs/index.md")
  icon          = "/images/mods/turbot/azure-cost-management-insights.svg"
  categories    = ["azure", "cost", "dashboard", "public cloud"]
  database      = var.database

  opengraph {
    title       = "Powerpipe Mod for Azure Cost Management Insights"
    description = "Monitor and analyze costs across your Azure subscriptions using pre-built dashboards for Azure Cost Management with Powerpipe and Tailpipe."
    image       = "/images/mods/turbot/azure-cost-management-insights-social-graphic.png"
  }
}
