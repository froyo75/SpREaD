# Provides details about a CDN Endpoint
output "cdn_endpoints" {
    description = "Azure CDN Endpoints"
    value       = {
        for endpoint in azurerm_cdn_endpoint.cdn_endpoint:
          endpoint.name => format("Endpoint Hostname: %s.%s | Origin Hostname: %s | Origin Host Header: %s | location: %s", endpoint.name, var.cdn_domain, endpoint.origin.*.host_name[0], endpoint.origin_host_header, endpoint.location)
    }
}