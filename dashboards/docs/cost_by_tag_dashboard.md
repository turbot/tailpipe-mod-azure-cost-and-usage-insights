# Cost Management: Cost by Tag Dashboard

This dashboard provides a detailed breakdown of costs by Azure tags, helping you understand spending patterns based on your resource tagging strategy.

## Overview

The dashboard includes:

- Total cost across selected subscriptions
- Number of unique tags being analyzed
- Pie chart showing cost distribution across tags
- Monthly cost trend line chart for each tag
- Detailed table with tag-level metrics

## Usage

1. Select one or more subscriptions to analyze using the dropdown at the top of the dashboard
2. View the summary metrics for total cost and number of tags
3. Use the pie chart to visualize cost distribution across tags
4. Analyze cost trends over time using the line chart
5. Review the detailed table for additional metrics like:
   - Total cost per tag
   - Subscription name
   - Tag key and value
   - Currency
   - Number of resource groups
   - Number of services
   - Number of resources

## Data Sources

This dashboard uses data from the `azure_cost_management` table, which is populated by the Azure plugin for Tailpipe.

## Notes

- Costs are shown in the original currency of each subscription
- All costs are rounded to 2 decimal places
- The dashboard automatically updates as new cost data is collected
- The monthly trend chart helps identify seasonal patterns and cost growth
- This dashboard is particularly useful for:
  - Cost allocation and chargeback based on tags
  - Understanding spending patterns by environment, project, or team
  - Identifying resources that may be missing important tags
  - Validating the effectiveness of your tagging strategy 