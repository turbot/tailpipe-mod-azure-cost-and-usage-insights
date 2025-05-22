# Cost Management: Cost by Tag Dashboard

This dashboard provides a detailed breakdown of Azure costs by tag value, helping you analyze and allocate spending based on custom tags across your subscriptions.

## Overview

The dashboard includes:

- Total cost across selected subscriptions and tag key
- Number of unique tag values being analyzed
- Column chart showing monthly cost trends by tag value
- Table of the top 10 tag values by total cost
- Detailed table with tag value, subscription, region, and cost breakdown

## Usage

1. Select one or more subscriptions to analyze using the dropdown at the top of the dashboard
2. Select a tag key to break down costs by tag values
3. View the summary metrics for total cost and number of tag values
4. Use the column chart to visualize monthly cost trends by tag value
5. Review the top 10 tag values by total cost
6. Explore the detailed table for a granular breakdown by tag value, subscription, and region

## Data Sources

This dashboard uses data from the `azure_cost_management` table, which is populated by the Azure plugin for Tailpipe. Tag data is sourced from the `tags` column in this table.

## Notes

- Costs are shown in the original currency of each subscription
- All costs are rounded to 2 decimal places
- The dashboard automatically updates as new cost data is collected
- Tag-based analysis is useful for cost allocation, chargeback, and identifying optimization opportunities 