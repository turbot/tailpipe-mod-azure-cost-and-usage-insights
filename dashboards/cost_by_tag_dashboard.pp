dashboard "cost_by_tag_dashboard" {
  title = "Cost and Usage: Cost by Tag"
  documentation = file("./dashboards/docs/cost_by_tag_dashboard.md")

  tags = merge(
    local.azure_cost_and_usage_insights_common_tags,
    {
      type = "Dashboard"
      service = "Azure/CostManagement"
    }
  )

  input "cost_by_tag_dashboard_subscriptions" {
    title       = "Select subscriptions:"
    description = "Choose one or more Azure subscriptions to analyze."
    type        = "multiselect"
    query       = query.cost_by_tag_dashboard_subscriptions_input
    width       = 4
  }

  input "cost_by_tag_dashboard_tag_key" {
    title       = "Select a tag key:"
    description = "Select a tag key to analyze costs by tag values."
    type        = "select"
    query       = query.cost_by_tag_dashboard_tag_key_input
    width       = 4
  }

  container {
    # Combined card showing Total Cost with Currency
    card {
      width = 2
      query = query.cost_by_tag_dashboard_total_cost
      icon  = "attach_money"
      type  = "info"

      args = {
        "subscription_ids" = self.input.cost_by_tag_dashboard_subscriptions.value
        "tag_key"          = self.input.cost_by_tag_dashboard_tag_key.value
      }
    }

    card {
      width = 2
      query = query.cost_by_tag_dashboard_total_subscriptions
      icon  = "groups"
      type  = "info"

      args = {
        "subscription_ids" = self.input.cost_by_tag_dashboard_subscriptions.value
      }
    }

  }

  container {
    # Cost Trend and Key/Value Breakdown
    chart {
      title = "Monthly Cost by Tag Value"
      type  = "column"
      width = 6
      query = query.cost_by_tag_dashboard_monthly_cost

      args = {
        "subscription_ids" = self.input.cost_by_tag_dashboard_subscriptions.value
        "tag_key"          = self.input.cost_by_tag_dashboard_tag_key.value
      }

      legend {
        display = "none"
      }
    }

    chart {
      title = "Top 10 Tag Values"
      type  = "table"
      width = 6
      query = query.cost_by_tag_dashboard_top_10_tag_values

      args = {
        "subscription_ids" = self.input.cost_by_tag_dashboard_subscriptions.value,
        "tag_key"          = self.input.cost_by_tag_dashboard_tag_key.value
      }
    }

  }

  container {
    # Detailed Tables
    table {
      title = "Tag Value Costs"
      width = 12
      query = query.cost_by_tag_dashboard_tag_value_costs

      args = {
        "subscription_ids" = self.input.cost_by_tag_dashboard_subscriptions.value
        "tag_key"          = self.input.cost_by_tag_dashboard_tag_key.value
      }
    }
  }
}

# Query Definitions

query "cost_by_tag_dashboard_total_cost" {
  sql = <<-EOQ
    with tagged_resources as (
      select 
        resource_id,
        cost_in_billing_currency,
        billing_currency
      from 
        azure_cost_and_usage_actual
      where 
        tags is not null
        and array_contains(json_keys(tags), $2)
        and json_extract(tags, '$.' || $2) is not null
        and json_extract(tags, '$.' || $2) <> '""'
        and ('all' in ($1) or subscription_id in $1)
    )
    select
      'Total Cost (' || max(billing_currency) || ')' as label,
      round(sum(cost_in_billing_currency), 2) as value
    from
      tagged_resources;
  EOQ

  param "subscription_ids" {}
  param "tag_key" {}

  tags = {
    folder = "Hidden"
  }
}

query "cost_by_tag_dashboard_total_subscriptions" {
  sql = <<-EOQ
    select
      'Subscriptions' as label,
      count(distinct subscription_id) as value
    from
      azure_cost_and_usage_actual
    where
      ('all' in ($1) or subscription_id in $1);
  EOQ

  param "subscription_ids" {}

  tags = {
    folder = "Hidden"
  }
}


query "cost_by_tag_dashboard_monthly_cost" {
  sql = <<-EOQ
    with tagged_resources as (
      select
        resource_id,
        date_trunc('month', date) as month,
        cost_in_billing_currency,
        json_extract(tags, '$.' || $2) as tag_value
      from
        azure_cost_and_usage_actual r
      where
        ('all' in ($1) or subscription_id in $1)
        and tags is not null
        and array_contains(json_keys(tags), $2)
        and json_extract(tags, '$.' || $2) is not null
        and json_extract(tags, '$.' || $2) <> '""'
    )
    select
      strftime(month, '%b %Y') as "Month",
      replace(tag_value, '"', '') as "Series",
      round(sum(cost_in_billing_currency), 2) as "Total Cost"
    from
      tagged_resources
    group by
      month,
      tag_value
    having
      sum(cost_in_billing_currency) > 0
    order by
      month,
      sum(cost_in_billing_currency) desc;
  EOQ

  param "subscription_ids" {}
  param "tag_key" {}

  tags = {
    folder = "Hidden"
  }
}

query "cost_by_tag_dashboard_top_10_tag_values" {
  sql = <<-EOQ
    with parsed_entries as (
      select
        unnest(json_keys(tags)) as tag_key,
        json_extract(tags, '$.' || unnest(json_keys(tags))) as tag_value,
        subscription_id,
        cost_in_billing_currency
      from
        azure_cost_and_usage_actual
      where
        tags is not null
        and ('all' in ($1) or subscription_id in $1)
    ),
    filtered_entries as (
      select
        tag_key,
        tag_value,
        cost_in_billing_currency
      from
        parsed_entries
      where
        tag_key = $2
        and tag_value <> '""'
    ),
    tag_costs as (
      select
        replace(tag_value, '"', '') as tag_display,
        sum(cost_in_billing_currency) as cost
      from
        filtered_entries
      group by
        tag_display
    )
    select
      tag_display as "Tag Value",
      round(cost, 2) as "Total Cost"
    from
      tag_costs
    order by
      cost desc
    limit 10;
  EOQ

  param "subscription_ids" {}
  param "tag_key" {}

  tags = {
    folder = "Hidden"
  }
}

query "cost_by_tag_dashboard_tag_value_costs" {
  sql = <<-EOQ
    with parsed_entries as (
      select
        unnest(json_keys(tags)) as tag_key,
        json_extract(tags, '$.' || unnest(json_keys(tags))) as tag_value,
        resource_id,
        subscription_id,
        cost_in_billing_currency,
        resource_location
      from
        azure_cost_and_usage_actual
      where
        tags is not null
        and ('all' in ($1) or subscription_id in $1)
    ),
    filtered_entries as (
      select
        tag_key,
        tag_value,
        resource_id,
        subscription_id,
        cost_in_billing_currency,
        resource_location
      from
        parsed_entries
      where
        tag_key = $2
        and tag_value <> '""'
    ),
    grouped_costs as (
      select
        replace(tag_value, '"', '') as tag_display,
        subscription_id,
        coalesce(resource_location, 'global') as region,
        sum(cost_in_billing_currency) as cost
      from
        filtered_entries
      group by
        tag_display,
        subscription_id,
        region
    )
    select
      tag_display as "Tag Value",
      subscription_id as "Subscription",
      region as "Region",
      round(cost, 2) as "Total Cost"
    from
      grouped_costs
    order by
      cost desc;
  EOQ

  param "subscription_ids" {}
  param "tag_key" {}

  tags = {
    folder = "Hidden"
  }
}

query "cost_by_tag_dashboard_subscriptions_input" {
  sql = <<-EOQ
    select 'all' as value, 'All' as label
    union all
    select
      subscription_id as value,
      subscription_name as label
    from
      azure_cost_and_usage_actual
    where
      subscription_id is not null and subscription_id != ''
      and subscription_name is not null and subscription_name != ''
    group by
      subscription_id,
      subscription_name
    order by
      label;
  EOQ

  tags = {
    folder = "Hidden"
  }
}

query "cost_by_tag_dashboard_tag_key_input" {
  sql = <<-EOQ
    select distinct
      t.tag_key as label,
      t.tag_key as value
    from
      azure_cost_and_usage_actual,
      unnest(json_keys(tags)) as t(tag_key)
    where
      tags is not null
      and t.tag_key <> ''
      and json_extract(tags, '$.' || t.tag_key) <> '""'
    order by
      label;
  EOQ

  tags = {
    folder = "Hidden"
  }
}
