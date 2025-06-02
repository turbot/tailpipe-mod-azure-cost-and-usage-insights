# Cost and Usage: Cost by Subscription Dashboard

This dashboard provides a detailed breakdown of costs by Azure subscription, helping you understand spending patterns across your subscriptions.

## Overview

The dashboard includes:

- Total cost across selected subscriptions
- Number of subscriptions being analyzed
- Pie chart showing cost distribution across subscriptions
- Monthly cost trend line chart for each subscription
- Detailed table with subscription-level metrics

## Usage

1. Select one or more subscriptions to analyze using the dropdown at the top of the dashboard
2. View the summary metrics for total cost and number of subscriptions
3. Use the pie chart to visualize cost distribution across subscriptions
4. Analyze cost trends over time using the line chart
5. Review the detailed table for additional metrics like:
   - Total cost per subscription
   - Currency
   - Number of resource groups
   - Number of services
   - Number of resources

## Data Sources

This dashboard uses data from the `azure_cost_and_usage_details` table, which is populated by the Azure plugin for Tailpipe.

## Notes

- Costs are shown in the original currency of each subscription
- All costs are rounded to 2 decimal places
- The dashboard automatically updates as new cost data is collected
- The monthly trend chart helps identify seasonal patterns and cost growth 