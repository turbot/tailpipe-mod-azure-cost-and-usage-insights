dashboard "cost_by_resource_group_dashboard" {
  title         = "Cost Management: Cost by Resource Group"
  documentation = file("./dashboards/docs/cost_by_resource_group_dashboard.md")

  tags = merge(
    local.azure_cost_management_insights_common_tags,
    {
      type = "Dashboard"
    }
  )

  container {
    input "cost_by_resource_group_dashboard_resource_groups" {
      title       = "Select resource groups:"
      description = "Choose one or more Azure resource groups to analyze."
      type        = "multiselect"
      width       = 4
      query       = query.cost_by_resource_group_dashboard_resource_groups_input
    }
  }

  container {
    # Summary Metrics
    card {
      width = 2
      query = query.cost_by_resource_group_dashboard_total_cost
      icon  = "attach_money"
      type  = "info"

      args = {
        "resource_group_names" = self.input.cost_by_resource_group_dashboard_resource_groups.value
      }
    }

    card {
      width = 2
      query = query.cost_by_resource_group_dashboard_total_resource_groups
      icon  = "groups"
      type  = "info"

      args = {
        "resource_group_names" = self.input.cost_by_resource_group_dashboard_resource_groups.value
      }
    }
  }

  container {
    # Graphs
    chart {
      title = "Cost by Resource Group"
      type  = "pie"
      width = 6
      query = query.cost_by_resource_group_dashboard_cost_by_resource_group

      args = {
        "resource_group_names" = self.input.cost_by_resource_group_dashboard_resource_groups.value
      }
    }

    chart {
      title = "Monthly Cost Trend by Resource Group"
      type  = "line"
      width = 6
      query = query.cost_by_resource_group_dashboard_monthly_cost_by_resource_group

      args = {
        "resource_group_names" = self.input.cost_by_resource_group_dashboard_resource_groups.value
      }
    }
  }

  container {
    # Tables
    chart {
      title = "Cost by Resource Group Details"
      type  = "table"
      width = 12
      query = query.cost_by_resource_group_dashboard_cost_by_resource_group_details

      args = {
        "resource_group_names" = self.input.cost_by_resource_group_dashboard_resource_groups.value
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
      azure_cost_management
    where
      ('all' in ($1) or resource_group_name in $1)
    group by
      billing_currency;
  EOQ

  param "resource_group_names" {}

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
      azure_cost_management
    where
      ('all' in ($1) or resource_group_name in $1);
  EOQ

  param "resource_group_names" {}

  tags = {
    folder = "Hidden"
  }
}

query "cost_by_resource_group_dashboard_cost_by_resource_group" {
  sql = <<-EOQ
    select
      resource_group_name as "Resource Group",
      round(sum(cost_in_billing_currency), 2) as "Total Cost"
    from
      azure_cost_management
    where
      ('all' in ($1) or resource_group_name in $1)
    group by
      resource_group_name
    order by
      sum(cost_in_billing_currency) desc;
  EOQ

  param "resource_group_names" {}

  tags = {
    folder = "Hidden"
  }
}

query "cost_by_resource_group_dashboard_monthly_cost_by_resource_group" {
  sql = <<-EOQ
    select
      strftime(date_trunc('month', date), '%b %Y') as "Month",
      resource_group_name as "Resource Group",
      round(sum(cost_in_billing_currency), 2) as "Total Cost"
    from
      azure_cost_management
    where
      ('all' in ($1) or resource_group_name in $1)
    group by
      date_trunc('month', date),
      resource_group_name
    order by
      date_trunc('month', date),
      resource_group_name;
  EOQ

  param "resource_group_names" {}

  tags = {
    folder = "Hidden"
  }
}

query "cost_by_resource_group_dashboard_cost_by_resource_group_details" {
  sql = <<-EOQ
    select
      subscription_name as "Subscription",
      resource_group_name as "Resource Group",
      round(sum(cost_in_billing_currency), 2) as "Total Cost",
      billing_currency as "Currency",
      count(distinct consumed_service) as "Services",
      count(distinct resource_id) as "Resources"
    from
      azure_cost_management
    where
      ('all' in ($1) or resource_group_name in $1)
    group by
      subscription_name,
      resource_group_name,
      billing_currency
    order by
      sum(cost_in_billing_currency) desc;
  EOQ

  param "resource_group_names" {}

  tags = {
    folder = "Hidden"
  }
}

query "cost_by_resource_group_dashboard_resource_groups_input" {
  sql = <<-EOQ
    select 'all' as value, 'All' as label
    union all
    select
      resource_group_name as value,
      resource_group_name as label
    from
      azure_cost_management
    group by
      resource_group_name
    order by
      label;
  EOQ

  tags = {
    folder = "Hidden"
  }
} 