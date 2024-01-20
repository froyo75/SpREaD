op_name = "rtX"

cdn_profile_name= "rtXCDN"

endpoints = {
  "azure-cdn-login-app-cloud" = {
        cdn_endpoint_name = "app-login"
        cdn_origin_hostname = "127.0.0.1"
        cdn_origin_hostname_header = "app-login"
  },
  "azure-cdn-logon-app-cloud" = {
        cdn_endpoint_name = "app-logon"
        cdn_origin_hostname = "127.0.0.1"
        cdn_origin_hostname_header = "app-logon"
  },
  "azure-cdn-www-app-cloud" = {
        cdn_endpoint_name = "app-www"
        cdn_origin_hostname = "127.0.0.1"
        cdn_origin_hostname_header = "app-www"
  },
  "azure-cdn-adfs-app-cloud" = {
        cdn_endpoint_name = "app-adfs"
        cdn_origin_hostname = "127.0.0.1"
        cdn_origin_hostname_header = "app-adfs"
  }
}