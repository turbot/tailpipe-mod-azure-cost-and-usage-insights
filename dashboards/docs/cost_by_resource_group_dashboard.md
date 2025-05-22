# Cost Management: Cost by Resource Group Dashboard

This dashboard provides a detailed breakdown of costs by Azure resource group, helping you understand spending patterns at the resource group level.

## Overview

The dashboard includes:

- Total cost across selected subscriptions
- Number of resource groups being analyzed
- Pie chart showing cost distribution across resource groups
- Monthly cost trend line chart for each resource group
- Detailed table with resource group-level metrics

## Usage

1. Select one or more subscriptions to analyze using the dropdown at the top of the dashboard
2. View the summary metrics for total cost and number of resource groups
3. Use the pie chart to visualize cost distribution across resource groups
4. Analyze cost trends over time using the line chart
5. Review the detailed table for additional metrics like:
   - Total cost per resource group
   - Subscription name
   - Currency
   - Number of services
   - Number of resources

## Data Sources

This dashboard uses data from the `azure_cost_management` table, which is populated by the Azure plugin for Tailpipe.

## Notes

- Costs are shown in the original currency of each subscription
- All costs are rounded to 2 decimal places
- The dashboard automatically updates as new cost data is collected
- The monthly trend chart helps identify seasonal patterns and cost growth
- Resource groups are a key organizational unit in Azure, making this dashboard useful for cost allocation and chargeback 