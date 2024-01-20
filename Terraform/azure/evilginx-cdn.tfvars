op_name = "rtX"

cdn_profile_name= "rtXCDN"

endpoints = {
  "azure-cdn-loginapp-com" = {
        cdn_endpoint_name = "app-login"
        cdn_origin_hostname = "127.0.0.1"
        cdn_origin_hostname_header = "app-login"
  },
  "azure-cdn-wwwapp-com" = {
        cdn_endpoint_name = "app-www"
        cdn_origin_hostname = "127.0.0.1"
        cdn_origin_hostname_header = "app-www"
  },
  "azure-cdn-aadcdnapp-com" = {
        cdn_endpoint_name = "app-aadcdn"
        cdn_origin_hostname = "127.0.0.1"
        cdn_origin_hostname_header = "app-aadcdn"
  }
}