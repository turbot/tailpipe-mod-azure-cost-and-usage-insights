# Cost Management: Cost by Service Dashboard

This dashboard provides a detailed breakdown of costs by Azure service, helping you understand which services are driving your cloud spending.

## Overview

The dashboard includes:

- Total cost across selected subscriptions
- Number of services being analyzed
- Pie chart showing cost distribution across services
- Monthly cost trend line chart for each service
- Detailed table with service-level metrics

## Usage

1. Select one or more subscriptions to analyze using the dropdown at the top of the dashboard
2. View the summary metrics for total cost and number of services
3. Use the pie chart to visualize cost distribution across services
4. Analyze cost trends over time using the line chart
5. Review the detailed table for additional metrics like:
   - Total cost per service
   - Subscription name
   - Currency
   - Number of resource groups
   - Number of resources

## Data Sources

This dashboard uses data from the `azure_cost_management` table, which is populated by the Azure plugin for Tailpipe.

## Notes

- Costs are shown in the original currency of each subscription
- All costs are rounded to 2 decimal places
- The dashboard automatically updates as new cost data is collected
- The monthly trend chart helps identify seasonal patterns and cost growth
- This dashboard is particularly useful for identifying which services are driving costs and where optimization opportunities might exist 