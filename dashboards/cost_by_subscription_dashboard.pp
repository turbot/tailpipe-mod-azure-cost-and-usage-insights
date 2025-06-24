dashboard "cost_and_usage_actual_cost_by_subscription_dashboard" {
  title         = "Azure Cost and Usage Actual: Cost by Subscription"
  documentation = file("./dashboards/docs/cost_and_usage_actual_cost_by_subscription_dashboard.md")

  tags = {
    type    = "Dashboard"
    service = "Azure/CostManagement"
  }

  container {
    input "cost_and_usage_actual_cost_by_subscription_dashboard_subscriptions" {
      title       = "Select subscriptions:"
      description = "Choose one or more Azure subscriptions to analyze."
      type        = "multiselect"
      width       = 4
      query       = query.cost_and_usage_actual_cost_by_subscription_dashboard_subscriptions_input
    }
  }

  container {
    card {
      width = 2
      query = query.cost_and_usage_actual_cost_by_subscription_dashboard_total_cost
      icon  = "attach_money"
      type  = "info"

      args = {
        "subscription_ids" = self.input.cost_and_usage_actual_cost_by_subscription_dashboard_subscriptions.value
      }
    }

    card {
      width = 2
      query = query.cost_and_usage_actual_cost_by_subscription_dashboard_total_subscriptions
      icon  = "groups"
      type  = "info"

      args = {
        "subscription_ids" = self.input.cost_and_usage_actual_cost_by_subscription_dashboard_subscriptions.value
      }
    }
  }

  container {
    chart {
      title = "Monthly Cost Trend"
      type  = "column"
      width = 12
      query = query.cost_and_usage_actual_cost_by_subscription_dashboard_monthly_cost_and_usage_actual_cost_by_subscription

      args = {
        "subscription_ids" = self.input.cost_and_usage_actual_cost_by_subscription_dashboard_subscriptions.value
      }

      legend {
        display = "none"
      }
    }
  }

  container {
    table {
      title = "Subscription Costs"
      width = 12
      query = query.cost_and_usage_actual_cost_by_subscription_dashboard_cost_and_usage_actual_cost_by_subscription_details

      args = {
        "subscription_ids" = self.input.cost_and_usage_actual_cost_by_subscription_dashboard_subscriptions.value
      }
    }
  }
}

# Query Definitions

query "cost_and_usage_actual_cost_by_subscription_dashboard_total_cost" {
  sql = <<-EOQ
    select
      'Total Cost (' || billing_currency || ')' as label,
      round(sum(cost_in_billing_currency), 2) as value
    from
      azure_cost_and_usage_actual
    where
      ('all' in ($1) or subscription_id in $1)
    group by
      billing_currency;
  EOQ

  param "subscription_ids" {}

  tags = {
    folder = "Hidden"
  }
}

query "cost_and_usage_actual_cost_by_subscription_dashboard_total_subscriptions" {
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

query "cost_and_usage_actual_cost_by_subscription_dashboard_monthly_cost_and_usage_actual_cost_by_subscription" {
  sql = <<-EOQ
    select
      strftime(date_trunc('month', date), '%b %Y') as "Month",
      subscription_name as "Subscription",
      round(sum(cost_in_billing_currency), 2) as "Total Cost"
    from
      azure_cost_and_usage_actual
    where
      ('all' in ($1) or subscription_id in $1)
    group by
      date_trunc('month', date),
      subscription_name
    order by
      date_trunc('month', date),
      sum(cost_in_billing_currency) desc;
  EOQ

  param "subscription_ids" {}

  tags = {
    folder = "Hidden"
  }
}

query "cost_and_usage_actual_cost_by_subscription_dashboard_cost_and_usage_actual_cost_by_subscription_details" {
  sql = <<-EOQ
    select
      subscription_name as "Subscription",
      round(sum(cost_in_billing_currency), 2) as "Total Cost"
    from
      azure_cost_and_usage_actual
    where
      ('all' in ($1) or subscription_id in $1)
    group by
      subscription_name
    order by
      sum(cost_in_billing_currency) desc;
  EOQ

  param "subscription_ids" {}

  tags = {
    folder = "Hidden"
  }
}

query "cost_and_usage_actual_cost_by_subscription_dashboard_subscriptions_input" {
  sql = <<-EOQ
    with subscription_ids as (
      select
        distinct on(subscription_id)
        subscription_id ||
        case
          when subscription_name is not null then ' (' || coalesce(subscription_name, '') || ')'
          else ''
        end as label,
        subscription_id as value
      from
        azure_cost_and_usage_actual
      where
        subscription_id is not null and subscription_id != ''
        and subscription_name is not null and subscription_name != ''
      order by label
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