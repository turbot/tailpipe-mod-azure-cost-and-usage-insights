dashboard "cost_by_resource_group_dashboard" {
  title         = "Cost and Usage: Cost by Resource Group"
  documentation = file("./dashboards/docs/cost_by_resource_group_dashboard.md")

  tags = merge(
    local.azure_cost_and_usage_insights_common_tags,
    {
      type    = "Dashboard"
      service = "AWS/CostManagement"
    }
  )

  container {
    input "cost_by_resource_group_dashboard_subscriptions" {
      title       = "Select subscriptions:"
      description = "Choose one or more Azure subscriptions to analyze."
      type        = "multiselect"
      width       = 4
      query       = query.cost_by_resource_group_dashboard_subscriptions_input
    }
  }

  container {
    card {
      width = 2
      query = query.cost_by_resource_group_dashboard_total_cost
      icon  = "attach_money"
      type  = "info"

      args = {
        "subscription_ids" = self.input.cost_by_resource_group_dashboard_subscriptions.value
      }
    }

    card {
      width = 2
      query = query.cost_by_resource_group_dashboard_total_subscriptions
      icon  = "account_tree"
      type  = "info"

      args = {
        "subscription_ids" = self.input.cost_by_resource_group_dashboard_subscriptions.value
      }
    }

    card {
      width = 2
      query = query.cost_by_resource_group_dashboard_total_resource_groups
      icon  = "groups"
      type  = "info"

      args = {
        "subscription_ids" = self.input.cost_by_resource_group_dashboard_subscriptions.value
      }
    }
  }

  container {
    chart {
      title = "Monthly Cost Trend"
      type  = "column"
      width = 6
      query = query.cost_by_resource_group_dashboard_monthly_cost

      args = {
        "subscription_ids" = self.input.cost_by_resource_group_dashboard_subscriptions.value
      }

      legend {
        display = "none"
      }
    }

    chart {
      title = "Top 10 Resource Groups"
      type  = "table"
      width = 6
      query = query.cost_by_resource_group_dashboard_top_10_resource_groups

      args = {
        "subscription_ids" = self.input.cost_by_resource_group_dashboard_subscriptions.value
      }
    }
  }

  container {
    table {
      title = "Resource Group Costs"
      width = 12
      query = query.cost_by_resource_group_dashboard_resource_group_costs

      args = {
        "subscription_ids" = self.input.cost_by_resource_group_dashboard_subscriptions.value
      }
    }
  }
}

# Queries

query "cost_by_resource_group_dashboard_total_cost" {
  sql = <<-EOQ
    select
      'Total Cost (' || billing_currency || ')' as label,
      round(sum(cost_in_billing_currency), 2) as value
    from
      azure_cost_and_usage_actual
    where
      ('all' in ($1) or subscription_id in $1)
    group by
      billing_currency
    limit 1;
  EOQ

  param "subscription_ids" {}

  tags = {
    folder = "Hidden"
  }
}

query "cost_by_resource_group_dashboard_total_subscriptions" {
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

query "cost_by_resource_group_dashboard_total_resource_groups" {
  sql = <<-EOQ
    select
      'Resource Groups' as label,
      count(distinct resource_group_name) as value
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

query "cost_by_resource_group_dashboard_monthly_cost" {
  sql = <<-EOQ
    select
      strftime(date_trunc('month', date), '%b %Y') as "Month",
      resource_group_name as "Resource Group",
      round(sum(cost_in_billing_currency), 2) as "Total Cost"
    from
      azure_cost_and_usage_actual
    where
      ('all' in ($1) or subscription_id in $1)
    group by
      date_trunc('month', date),
      resource_group_name
    order by
      date_trunc('month', date),
      sum(cost_in_billing_currency) desc;
  EOQ

  param "subscription_ids" {}

  tags = {
    folder = "Hidden"
  }
}

query "cost_by_resource_group_dashboard_top_10_resource_groups" {
  sql = <<-EOQ
    select
      resource_group_name as "Resource Group",
      round(sum(cost_in_billing_currency), 2) as "Total Cost"
    from
      azure_cost_and_usage_actual
    where
      ('all' in ($1) or subscription_id in $1)
    group by
      resource_group_name
    order by
      sum(cost_in_billing_currency) desc
    limit 10;
  EOQ

  param "subscription_ids" {}

  tags = {
    folder = "Hidden"
  }
}

query "cost_by_resource_group_dashboard_resource_group_costs" {
  sql = <<-EOQ
    select
      resource_group_name as "Resource Group",
      subscription_name as "Subscription",
      round(sum(cost_in_billing_currency), 2) as "Total Cost"
    from
      azure_cost_and_usage_actual
    where
      ('all' in ($1) or subscription_id in $1)
    group by
      resource_group_name,
      subscription_name
    order by
      sum(cost_in_billing_currency) desc;
  EOQ

  param "subscription_ids" {}

  tags = {
    folder = "Hidden"
  }
}

query "cost_by_resource_group_dashboard_subscriptions_input" {
  sql = <<-EOQ
    with subscription_ids as (
      select
        distinct on(subscription_id)
        subscription_id ||
        case
          when subscription_name is not null then ' (' || subscription_name || ')'
          else ''
        end as label,
        subscription_id as value
      from
        azure_cost_and_usage_actual
      order by
        subscription_id
    )
    select
      'All' as label,
      'all' as value
    union all
    select
      label,
      value
    from
      subscription_ids;
  EOQ

  tags = {
    folder = "Hidden"
  }
} 