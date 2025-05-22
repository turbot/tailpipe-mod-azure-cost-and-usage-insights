dashboard "cost_by_service_dashboard" {
  title         = "Cost Management: Cost by Service"
  documentation = file("./dashboards/docs/cost_by_service_dashboard.md")

  tags = {
    type    = "Dashboard"
    service = "Azure/CostManagement"
  }

  container {
    input "cost_by_service_dashboard_services" {
      title       = "Select services:"
      description = "Choose one or more Azure services to analyze."
      type        = "multiselect"
      width       = 4
      query       = query.cost_by_service_dashboard_services_input
    }
  }

  container {
    # Summary Metrics
    card {
      width = 2
      query = query.cost_by_service_dashboard_total_cost
      icon  = "attach_money"
      type  = "info"

      args = {
        "service_names" = self.input.cost_by_service_dashboard_services.value
      }
    }

    card {
      width = 2
      query = query.cost_by_service_dashboard_total_services
      icon  = "apps"
      type  = "info"

      args = {
        "service_names" = self.input.cost_by_service_dashboard_services.value
      }
    }
  }

  container {
    # Graphs
    chart {
      title = "Cost by Service"
      type  = "pie"
      width = 6
      query = query.cost_by_service_dashboard_cost_by_service

      args = {
        "service_names" = self.input.cost_by_service_dashboard_services.value
      }
    }

    chart {
      title = "Monthly Cost Trend by Service"
      type  = "line"
      width = 6
      query = query.cost_by_service_dashboard_monthly_cost_by_service

      args = {
        "service_names" = self.input.cost_by_service_dashboard_services.value
      }
    }
  }

  container {
    # Tables
    chart {
      title = "Cost by Service Details"
      type  = "table"
      width = 12
      query = query.cost_by_service_dashboard_cost_by_service_details

      args = {
        "service_names" = self.input.cost_by_service_dashboard_services.value
      }
    }
  }
}

# Queries

query "cost_by_service_dashboard_total_cost" {
  sql = <<-EOQ
    select
      'Total Cost (' || billing_currency || ')' as label,
      round(sum(cost_in_billing_currency), 2) as value
    from
      azure_cost_management
    where
      ('all' in ($1) or consumed_service in $1)
    group by
      billing_currency;
  EOQ

  param "service_names" {}

  tags = {
    folder = "Hidden"
  }
}

query "cost_by_service_dashboard_total_services" {
  sql = <<-EOQ
    select
      'Services' as label,
      count(distinct consumed_service) as value
    from
      azure_cost_management
    where
      ('all' in ($1) or consumed_service in $1);
  EOQ

  param "service_names" {}

  tags = {
    folder = "Hidden"
  }
}

query "cost_by_service_dashboard_cost_by_service" {
  sql = <<-EOQ
    select
      consumed_service as "Service",
      round(sum(cost_in_billing_currency), 2) as "Total Cost"
    from
      azure_cost_management
    where
      ('all' in ($1) or consumed_service in $1)
    group by
      consumed_service
    order by
      sum(cost_in_billing_currency) desc;
  EOQ

  param "service_names" {}

  tags = {
    folder = "Hidden"
  }
}

query "cost_by_service_dashboard_monthly_cost_by_service" {
  sql = <<-EOQ
    select
      strftime(date_trunc('month', date), '%b %Y') as "Month",
      consumed_service as "Service",
      round(sum(cost_in_billing_currency), 2) as "Total Cost"
    from
      azure_cost_management
    where
      ('all' in ($1) or consumed_service in $1)
    group by
      date_trunc('month', date),
      consumed_service
    order by
      date_trunc('month', date),
      consumed_service;
  EOQ

  param "service_names" {}

  tags = {
    folder = "Hidden"
  }
}

query "cost_by_service_dashboard_cost_by_service_details" {
  sql = <<-EOQ
    select
      subscription_name as "Subscription",
      consumed_service as "Service",
      round(sum(cost_in_billing_currency), 2) as "Total Cost",
      billing_currency as "Currency",
      count(distinct resource_group_name) as "Resource Groups",
      count(distinct resource_id) as "Resources"
    from
      azure_cost_management
    where
      ('all' in ($1) or consumed_service in $1)
    group by
      subscription_name,
      consumed_service,
      billing_currency
    order by
      sum(cost_in_billing_currency) desc;
  EOQ

  param "service_names" {}

  tags = {
    folder = "Hidden"
  }
}

query "cost_by_service_dashboard_services_input" {
  sql = <<-EOQ
    select
      consumed_service as value,
      consumed_service as label
    from
      azure_cost_management
    group by
      consumed_service
    order by
      consumed_service;
  EOQ

  tags = {
    folder = "Hidden"
  }
} 