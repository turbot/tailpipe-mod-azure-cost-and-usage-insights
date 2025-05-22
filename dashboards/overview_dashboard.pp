dashboard "overview_dashboard" {
  title         = "Cost Management: Overview"
  documentation = file("./dashboards/docs/overview_dashboard.md")

  tags = merge(
    local.azure_cost_management_insights_common_tags,
    {
      type = "Dashboard"
    }
  )

  container {
    input "overview_dashboard_subscriptions" {
      title       = "Select subscriptions:"
      description = "Choose one or more Azure subscriptions to analyze."
      type        = "multiselect"
      width       = 4
      query       = query.overview_dashboard_subscriptions_input
    }
  }

  container {
    # Summary Metrics
    card {
      width = 2
      query = query.overview_dashboard_total_cost
      icon  = "attach_money"
      type  = "info"

      args = {
        "subscription_ids" = self.input.overview_dashboard_subscriptions.value
      }
    }

    card {
      width = 2
      query = query.overview_dashboard_total_subscriptions
      icon  = "groups"
      type  = "info"

      args = {
        "subscription_ids" = self.input.overview_dashboard_subscriptions.value
      }
    }
  }

  container {
    # Graphs
    chart {
      title = "Monthly Cost Trend"
      type  = "column"
      width = 6
      query = query.overview_dashboard_monthly_cost

      args = {
        "subscription_ids" = self.input.overview_dashboard_subscriptions.value
      }

      legend {
        display = "none"
      }
    }

    chart {
      title = "Daily Cost Trend"
      type  = "line"
      width = 6
      query = query.overview_dashboard_daily_cost

      args = {
        "subscription_ids" = self.input.overview_dashboard_subscriptions.value
      }

      legend {
        display = "none"
      }
    }
  }

  container {
    # Tables
    chart {
      title = "Top 10 Subscriptions"
      type  = "table"
      width = 6
      query = query.overview_dashboard_top_10_subscriptions

      args = {
        "subscription_ids" = self.input.overview_dashboard_subscriptions.value
      }
    }

    chart {
      title = "Top 10 Resource Groups"
      type  = "table"
      width = 6
      query = query.overview_dashboard_top_10_resource_groups

      args = {
        "subscription_ids" = self.input.overview_dashboard_subscriptions.value
      }
    }

    chart {
      title = "Top 10 Services"
      type  = "table"
      width = 6
      query = query.overview_dashboard_top_10_services

      args = {
        "subscription_ids" = self.input.overview_dashboard_subscriptions.value
      }
    }

    chart {
      title = "Top 10 Resources"
      type  = "table"
      width = 6
      query = query.overview_dashboard_top_10_resources

      args = {
        "subscription_ids" = self.input.overview_dashboard_subscriptions.value
      }
    }
  }
}

# Queries

query "overview_dashboard_total_cost" {
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

query "overview_dashboard_total_subscriptions" {
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

query "overview_dashboard_monthly_cost" {
  sql = <<-EOQ
    select
      strftime(date_trunc('month', date), '%b %Y') as "Month",
      round(sum(cost_in_billing_currency), 2) as "Total Cost"
    from
      azure_cost_management
    where
      ('all' in ($1) or subscription_id in $1)
    group by
      date_trunc('month', date)
    order by
      date_trunc('month', date);
  EOQ

  param "subscription_ids" {}

  tags = {
    folder = "Hidden"
  }
}

query "overview_dashboard_daily_cost" {
  sql = <<-EOQ
    select
      strftime(date_trunc('day', date), '%Y-%m-%d') as "Date",
      round(sum(cost_in_billing_currency), 2) as "Total Cost"
    from
      azure_cost_management
    where
      ('all' in ($1) or subscription_id in $1)
    group by
      date_trunc('day', date)
    order by
      date_trunc('day', date);
  EOQ

  param "subscription_ids" {}

  tags = {
    folder = "Hidden"
  }
}

query "overview_dashboard_top_10_subscriptions" {
  sql = <<-EOQ
    select
      subscription_name as "Subscription",
      round(sum(cost_in_billing_currency), 2) as "Total Cost",
      billing_currency as "Currency"
    from
      azure_cost_management
    where
      ('all' in ($1) or subscription_id in $1)
    group by
      subscription_name,
      billing_currency
    order by
      sum(cost_in_billing_currency) desc
    limit 10;
  EOQ

  param "subscription_ids" {}

  tags = {
    folder = "Hidden"
  }
}

query "overview_dashboard_top_10_resource_groups" {
  sql = <<-EOQ
    select
      resource_group_name as "Resource Group",
      round(sum(cost_in_billing_currency), 2) as "Total Cost",
      billing_currency as "Currency"
    from
      azure_cost_management
    where
      ('all' in ($1) or subscription_id in $1)
    group by
      resource_group_name,
      billing_currency
    order by
      sum(cost_in_billing_currency) desc
    limit 10;
  EOQ

  param "subscription_ids" {}

  tags = {
    folder = "Hidden"
  }
}

query "overview_dashboard_top_10_services" {
  sql = <<-EOQ
    select
      consumed_service as "Service",
      round(sum(cost_in_billing_currency), 2) as "Total Cost",
      billing_currency as "Currency"
    from
      azure_cost_management
    where
      ('all' in ($1) or subscription_id in $1)
    group by
      consumed_service,
      billing_currency
    order by
      sum(cost_in_billing_currency) desc
    limit 10;
  EOQ

  param "subscription_ids" {}

  tags = {
    folder = "Hidden"
  }
}

query "overview_dashboard_top_10_resources" {
  sql = <<-EOQ
    select
      resource_id as "Resource",
      round(sum(cost_in_billing_currency), 2) as "Total Cost",
      billing_currency as "Currency"
    from
      azure_cost_management
    where
      ('all' in ($1) or subscription_id in $1)
    group by
      resource_id,
      billing_currency
    order by
      sum(cost_in_billing_currency) desc
    limit 10;
  EOQ

  param "subscription_ids" {}

  tags = {
    folder = "Hidden"
  }
}

query "overview_dashboard_subscriptions_input" {
  sql = <<-EOQ
    select 'all' as value, 'All' as label
    union all
    select
      subscription_id as value,
      subscription_name as label
    from
      azure_cost_management
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