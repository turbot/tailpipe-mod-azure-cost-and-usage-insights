dashboard "cost_by_subscription_dashboard" {
  title         = "Cost Management: Cost by Subscription"
  documentation = file("./dashboards/docs/cost_by_subscription_dashboard.md")

  tags = merge(
    local.azure_cost_management_insights_common_tags,
    {
      type = "Dashboard"
    }
  )

  container {
    input "cost_by_subscription_dashboard_subscriptions" {
      title       = "Select subscriptions:"
      description = "Choose one or more Azure subscriptions to analyze."
      type        = "multiselect"
      width       = 4
      query       = query.cost_by_subscription_dashboard_subscriptions_input
    }
  }

  container {
    # Summary Metrics
    card {
      width = 2
      query = query.cost_by_subscription_dashboard_total_cost
      icon  = "attach_money"
      type  = "info"

      args = {
        "subscription_ids" = self.input.cost_by_subscription_dashboard_subscriptions.value
      }
    }

    card {
      width = 2
      query = query.cost_by_subscription_dashboard_total_subscriptions
      icon  = "groups"
      type  = "info"

      args = {
        "subscription_ids" = self.input.cost_by_subscription_dashboard_subscriptions.value
      }
    }
  }

  container {
    # Graphs
    chart {
      title = "Cost by Subscription"
      type  = "pie"
      width = 6
      query = query.cost_by_subscription_dashboard_cost_by_subscription

      args = {
        "subscription_ids" = self.input.cost_by_subscription_dashboard_subscriptions.value
      }
    }

    chart {
      title = "Monthly Cost Trend by Subscription"
      type  = "line"
      width = 6
      query = query.cost_by_subscription_dashboard_monthly_cost_by_subscription

      args = {
        "subscription_ids" = self.input.cost_by_subscription_dashboard_subscriptions.value
      }
    }
  }

  container {
    # Tables
    chart {
      title = "Cost by Subscription Details"
      type  = "table"
      width = 12
      query = query.cost_by_subscription_dashboard_cost_by_subscription_details

      args = {
        "subscription_ids" = self.input.cost_by_subscription_dashboard_subscriptions.value
      }
    }
  }
}

# Queries

query "cost_by_subscription_dashboard_total_cost" {
  sql = <<-EOQ
    select
      'Total Cost (' || billing_currency || ')' as label,
      round(sum(cost_in_billing_currency), 2) as value
    from
      azure_cost_management
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

query "cost_by_subscription_dashboard_total_subscriptions" {
  sql = <<-EOQ
    select
      'Subscriptions' as label,
      count(distinct subscription_id) as value
    from
      azure_cost_management
    where
      ('all' in ($1) or subscription_id in $1);
  EOQ

  param "subscription_ids" {}

  tags = {
    folder = "Hidden"
  }
}

query "cost_by_subscription_dashboard_cost_by_subscription" {
  sql = <<-EOQ
    select
      subscription_name as "Subscription",
      round(sum(cost_in_billing_currency), 2) as "Total Cost"
    from
      azure_cost_management
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

query "cost_by_subscription_dashboard_monthly_cost_by_subscription" {
  sql = <<-EOQ
    select
      strftime(date_trunc('month', date), '%b %Y') as "Month",
      subscription_name as "Subscription",
      round(sum(cost_in_billing_currency), 2) as "Total Cost"
    from
      azure_cost_management
    where
      ('all' in ($1) or subscription_id in $1)
    group by
      date_trunc('month', date),
      subscription_name
    order by
      date_trunc('month', date),
      subscription_name;
  EOQ

  param "subscription_ids" {}

  tags = {
    folder = "Hidden"
  }
}

query "cost_by_subscription_dashboard_cost_by_subscription_details" {
  sql = <<-EOQ
    select
      subscription_name as "Subscription",
      round(sum(cost_in_billing_currency), 2) as "Total Cost",
      billing_currency as "Currency",
      count(distinct resource_group_name) as "Resource Groups",
      count(distinct consumed_service) as "Services",
      count(distinct resource_id) as "Resources"
    from
      azure_cost_management
    where
      ('all' in ($1) or subscription_id in $1)
    group by
      subscription_name,
      billing_currency
    order by
      sum(cost_in_billing_currency) desc;
  EOQ

  param "subscription_ids" {}

  tags = {
    folder = "Hidden"
  }
}

query "cost_by_subscription_dashboard_subscriptions_input" {
  sql = <<-EOQ
    select
      subscription_id as value,
      subscription_name as label
    from
      azure_cost_management
    group by
      subscription_id,
      subscription_name
    order by
      subscription_name;
  EOQ

  tags = {
    folder = "Hidden"
  }
} 