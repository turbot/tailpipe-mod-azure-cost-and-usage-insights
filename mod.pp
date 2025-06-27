mod "azure_cost_and_usage_insights" {
  # hub metadata
  title         = "Azure Cost and Usage Insights"
  description   = "Monitor and analyze costs across your Azure subscriptions using pre-built dashboards for Azure Cost and Usage with Powerpipe and Tailpipe."
  color         = "#0089D6"
  documentation = file("./docs/index.md")
  icon          = "/images/mods/turbot/azure-cost-and-usage-insights.svg"
  categories    = ["azure", "cost", "dashboard", "public cloud"]
  database      = var.database

  opengraph {
    title       = "Powerpipe Mod for Azure Cost and Usage Insights"
    description = "Monitor and analyze costs across your Azure subscriptions using pre-built dashboards for Azure Cost and Usage with Powerpipe and Tailpipe."
    image       = "/images/mods/turbot/azure-cost-and-usage-insights-social-graphic.png"
  }
}
