# Cost and Usage: Overview Dashboard

This dashboard provides a comprehensive overview of your Azure costs across subscriptions, resource groups, services, and resources.

## Overview

The dashboard includes:

- Total cost across selected subscriptions
- Number of subscriptions being analyzed
- Monthly and daily cost trends
- Top 10 lists for:
  - Subscriptions by cost
  - Resource groups by cost
  - Services by cost
  - Resources by cost

## Usage

1. Select one or more subscriptions to analyze using the dropdown at the top of the dashboard
2. View the summary metrics for total cost and number of subscriptions
3. Analyze cost trends using the monthly and daily charts
4. Review the top 10 lists to identify areas of highest spending

## Data Sources

This dashboard uses data from the `azure_cost_and_usage_details` table, which is populated by the Azure plugin for Tailpipe.

## Notes

- Costs are shown in the original currency of the subscription
- All costs are rounded to 2 decimal places
- The dashboard automatically updates as new cost data is collected 