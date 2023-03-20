# Create new CDN endpoints with Azure 

resource "azurerm_resource_group" "azure_resource" {
    name     = var.op_name
    location = var.cdn_location
}

resource "azurerm_cdn_profile" "cdn_profile" {
    name                = var.cdn_profile_name
    location            = azurerm_resource_group.azure_resource.location
    resource_group_name = azurerm_resource_group.azure_resource.name
    sku                 = "Standard_Microsoft"
}

resource "azurerm_cdn_endpoint" "cdn_endpoint" {

    for_each = var.endpoints

    name                = each.value.cdn_endpoint_name
    profile_name        = azurerm_cdn_profile.cdn_profile.name
    location            = azurerm_resource_group.azure_resource.location
    resource_group_name = azurerm_resource_group.azure_resource.name
    origin_host_header  = format("%s.%s",each.value.cdn_origin_hostname_header, var.cdn_domain)
    querystring_caching_behaviour = "BypassCaching"
    is_http_allowed     = false
    is_https_allowed    = true

    origin {
        name      = each.value.cdn_endpoint_name
        host_name = each.value.cdn_origin_hostname
    }

    delivery_rule {
        name = "nocache"
        order = 1

        query_string_condition {
            operator = "Any"
        }

        url_path_condition {
            operator = "Any"
        }

        cache_expiration_action {
            behavior =  "BypassCache"
        }
    }
}