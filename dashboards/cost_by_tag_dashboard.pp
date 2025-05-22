dashboard "cost_by_tag_dashboard" {
  title         = "Cost Management: Cost by Tag"
  documentation = file("./dashboards/docs/cost_by_tag_dashboard.md")

  tags = {
    type    = "Dashboard"
    service = "Azure/CostManagement"
  }

  container {
    input "cost_by_tag_dashboard_tags" {
      title       = "Select tags:"
      description = "Choose one or more Azure tags to analyze."
      type        = "multiselect"
      width       = 4
      query       = query.cost_by_tag_dashboard_tags_input
    }
  }

  container {
    # Summary Metrics
    card {
      width = 2
      query = query.cost_by_tag_dashboard_total_cost
      icon  = "attach_money"
      type  = "info"

      args = {
        "tag_keys" = self.input.cost_by_tag_dashboard_tags.value
      }
    }

    card {
      width = 2
      query = query.cost_by_tag_dashboard_total_tags
      icon  = "local_offer"
      type  = "info"

      args = {
        "tag_keys" = self.input.cost_by_tag_dashboard_tags.value
      }
    }
  }

  container {
    # Graphs
    chart {
      title = "Cost by Tag"
      type  = "pie"
      width = 6
      query = query.cost_by_tag_dashboard_cost_by_tag

      args = {
        "tag_keys" = self.input.cost_by_tag_dashboard_tags.value
      }
    }

    chart {
      title = "Monthly Cost Trend by Tag"
      type  = "line"
      width = 6
      query = query.cost_by_tag_dashboard_monthly_cost_by_tag

      args = {
        "tag_keys" = self.input.cost_by_tag_dashboard_tags.value
      }
    }
  }

  container {
    # Tables
    chart {
      title = "Cost by Tag Details"
      type  = "table"
      width = 12
      query = query.cost_by_tag_dashboard_cost_by_tag_details

      args = {
        "tag_keys" = self.input.cost_by_tag_dashboard_tags.value
      }
    }
  }
}

# Queries

query "cost_by_tag_dashboard_total_cost" {
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

  param "tag_keys" {}

  tags = {
    folder = "Hidden"
  }
}

query "cost_by_tag_dashboard_total_tags" {
  sql = <<-EOQ
    select
      'Tags' as label,
      count(distinct tag_key) as value
    from (
      select 'env' as tag_key, tags from azure_cost_management where json_extract(tags, '$.env') is not null
      union
      select 'owner' as tag_key, tags from azure_cost_management where json_extract(tags, '$.owner') is not null
      union
      select 'cc' as tag_key, tags from azure_cost_management where json_extract(tags, '$.cc') is not null
      union
      select 'cost_center' as tag_key, tags from azure_cost_management where json_extract(tags, '$.cost_center') is not null
      union
      select 'manager' as tag_key, tags from azure_cost_management where json_extract(tags, '$.manager') is not null
      union
      select 'Environment' as tag_key, tags from azure_cost_management where json_extract(tags, '$.Environment') is not null
    ) tag_keys
    where
      ('all' in ($1) or tag_key in $1)
      and tags is not null
      and tags != '{}';
  EOQ

  param "tag_keys" {}

  tags = {
    folder = "Hidden"
  }
}

query "cost_by_tag_dashboard_cost_by_tag" {
  sql = <<-EOQ
    select
      tag_key || ': ' || tag_value as "Tag",
      round(sum(cost_in_billing_currency), 2) as "Total Cost"
    from (
      select 'env' as tag_key, json_extract(tags, '$.env') as tag_value, cost_in_billing_currency, subscription_id, tags
      from azure_cost_management
      where json_extract(tags, '$.env') is not null
      union all
      select 'owner' as tag_key, json_extract(tags, '$.owner') as tag_value, cost_in_billing_currency, subscription_id, tags
      from azure_cost_management
      where json_extract(tags, '$.owner') is not null
      union all
      select 'cc' as tag_key, json_extract(tags, '$.cc') as tag_value, cost_in_billing_currency, subscription_id, tags
      from azure_cost_management
      where json_extract(tags, '$.cc') is not null
      union all
      select 'cost_center' as tag_key, json_extract(tags, '$.cost_center') as tag_value, cost_in_billing_currency, subscription_id, tags
      from azure_cost_management
      where json_extract(tags, '$.cost_center') is not null
      union all
      select 'manager' as tag_key, json_extract(tags, '$.manager') as tag_value, cost_in_billing_currency, subscription_id, tags
      from azure_cost_management
      where json_extract(tags, '$.manager') is not null
      union all
      select 'Environment' as tag_key, json_extract(tags, '$.Environment') as tag_value, cost_in_billing_currency, subscription_id, tags
      from azure_cost_management
      where json_extract(tags, '$.Environment') is not null
    ) tag_costs
    where
      ('all' in ($1) or tag_key in $1)
      and tags is not null
      and tags != '{}'
    group by
      tag_key,
      tag_value
    order by
      sum(cost_in_billing_currency) desc;
  EOQ

  param "tag_keys" {}

  tags = {
    folder = "Hidden"
  }
}

query "cost_by_tag_dashboard_monthly_cost_by_tag" {
  sql = <<-EOQ
    select
      strftime(date_trunc('month', date), '%b %Y') as "Month",
      tag_key || ': ' || tag_value as "Tag",
      round(sum(cost_in_billing_currency), 2) as "Total Cost"
    from (
      select date, 'env' as tag_key, json_extract(tags, '$.env') as tag_value, cost_in_billing_currency, subscription_id, tags
      from azure_cost_management
      where json_extract(tags, '$.env') is not null
      union all
      select date, 'owner' as tag_key, json_extract(tags, '$.owner') as tag_value, cost_in_billing_currency, subscription_id, tags
      from azure_cost_management
      where json_extract(tags, '$.owner') is not null
      union all
      select date, 'cc' as tag_key, json_extract(tags, '$.cc') as tag_value, cost_in_billing_currency, subscription_id, tags
      from azure_cost_management
      where json_extract(tags, '$.cc') is not null
      union all
      select date, 'cost_center' as tag_key, json_extract(tags, '$.cost_center') as tag_value, cost_in_billing_currency, subscription_id, tags
      from azure_cost_management
      where json_extract(tags, '$.cost_center') is not null
      union all
      select date, 'manager' as tag_key, json_extract(tags, '$.manager') as tag_value, cost_in_billing_currency, subscription_id, tags
      from azure_cost_management
      where json_extract(tags, '$.manager') is not null
      union all
      select date, 'Environment' as tag_key, json_extract(tags, '$.Environment') as tag_value, cost_in_billing_currency, subscription_id, tags
      from azure_cost_management
      where json_extract(tags, '$.Environment') is not null
    ) tag_costs
    where
      ('all' in ($1) or tag_key in $1)
      and tags is not null
      and tags != '{}'
    group by
      date_trunc('month', date),
      tag_key,
      tag_value
    order by
      date_trunc('month', date),
      tag_key,
      tag_value;
  EOQ

  param "tag_keys" {}

  tags = {
    folder = "Hidden"
  }
}

query "cost_by_tag_dashboard_cost_by_tag_details" {
  sql = <<-EOQ
    select
      subscription_name as "Subscription",
      tag_key as "Tag Key",
      tag_value as "Tag Value",
      round(sum(cost_in_billing_currency), 2) as "Total Cost",
      billing_currency as "Currency",
      count(distinct resource_group_name) as "Resource Groups",
      count(distinct consumed_service) as "Services",
      count(distinct resource_id) as "Resources"
    from (
      select subscription_name, 'env' as tag_key, json_extract(tags, '$.env') as tag_value, billing_currency, cost_in_billing_currency, resource_group_name, consumed_service, resource_id, subscription_id, tags
      from azure_cost_management
      where json_extract(tags, '$.env') is not null
      union all
      select subscription_name, 'owner' as tag_key, json_extract(tags, '$.owner') as tag_value, billing_currency, cost_in_billing_currency, resource_group_name, consumed_service, resource_id, subscription_id, tags
      from azure_cost_management
      where json_extract(tags, '$.owner') is not null
      union all
      select subscription_name, 'cc' as tag_key, json_extract(tags, '$.cc') as tag_value, billing_currency, cost_in_billing_currency, resource_group_name, consumed_service, resource_id, subscription_id, tags
      from azure_cost_management
      where json_extract(tags, '$.cc') is not null
      union all
      select subscription_name, 'cost_center' as tag_key, json_extract(tags, '$.cost_center') as tag_value, billing_currency, cost_in_billing_currency, resource_group_name, consumed_service, resource_id, subscription_id, tags
      from azure_cost_management
      where json_extract(tags, '$.cost_center') is not null
      union all
      select subscription_name, 'manager' as tag_key, json_extract(tags, '$.manager') as tag_value, billing_currency, cost_in_billing_currency, resource_group_name, consumed_service, resource_id, subscription_id, tags
      from azure_cost_management
      where json_extract(tags, '$.manager') is not null
      union all
      select subscription_name, 'Environment' as tag_key, json_extract(tags, '$.Environment') as tag_value, billing_currency, cost_in_billing_currency, resource_group_name, consumed_service, resource_id, subscription_id, tags
      from azure_cost_management
      where json_extract(tags, '$.Environment') is not null
    ) tag_costs
    where
      ('all' in ($1) or tag_key in $1)
      and tags is not null
      and tags != '{}'
    group by
      subscription_name,
      tag_key,
      tag_value,
      billing_currency
    order by
      sum(cost_in_billing_currency) desc;
  EOQ

  param "tag_keys" {}

  tags = {
    folder = "Hidden"
  }
}

query "cost_by_tag_dashboard_tags_input" {
  sql = <<-EOQ
    select
      tag_key as value,
      tag_key as label
    from (
      select 'env' as tag_key from azure_cost_management where json_extract(tags, '$.env') is not null
      union
      select 'owner' as tag_key from azure_cost_management where json_extract(tags, '$.owner') is not null
      union
      select 'cc' as tag_key from azure_cost_management where json_extract(tags, '$.cc') is not null
      union
      select 'cost_center' as tag_key from azure_cost_management where json_extract(tags, '$.cost_center') is not null
      union
      select 'manager' as tag_key from azure_cost_management where json_extract(tags, '$.manager') is not null
      union
      select 'Environment' as tag_key from azure_cost_management where json_extract(tags, '$.Environment') is not null
    ) tag_keys
    group by
      tag_key
    order by
      tag_key;
  EOQ

  tags = {
    folder = "Hidden"
  }
} 