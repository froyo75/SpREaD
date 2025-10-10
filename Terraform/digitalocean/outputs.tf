# Output all instance name and public IPv4 addresses
output "droplet_public_ip_addresses" {
    description = "Droplets Public IPv4 Addresses"
    value       = {
        for droplet in digitalocean_droplet.instance:
          droplet.name => droplet.ipv4_address
    }
}

# Output all instance name and private IPv4 addresses
output "droplet_private_ip_addresses" {
    description = "Droplets Private IPv4 Addresses"
    value       = {
        for droplet in digitalocean_droplet.instance:
          droplet.name => droplet.ipv4_address_private
    }
}

# Output all instance name and hourly price
output "droplet_hourly_prices" {
    description = "Droplets Hourly Prices"
    value       = {
        for droplet in digitalocean_droplet.instance:
          droplet.name => format("%s$", droplet.price_hourly)
    }
}

# Output all instance name and monthly price
output "droplet_monthly_prices" {
    description = "Droplets Monthly Prices"
    value       = {
        for droplet in digitalocean_droplet.instance:
          droplet.name => format("%s$", droplet.price_monthly)
    }
}

# Generate inventory file for Ansible
resource "local_file" "ansible_inventory" {
    content = templatefile("hosts.tpl",{ content = tomap({
         for k, v in var.hosts:
            k => v.vps_domain
         })
     })
     filename = "${var.ansible_path}/${var.op_name}_inventory/hosts.yml"
}

# Backup inventory file for Ansible
resource "null_resource" "backup" {
    provisioner "local-exec" {
        command = <<EOT
        if [ -f "${var.ansible_path}/${var.op_name}_inventory/hosts.yml" ]; then
            cp ${var.ansible_path}/${var.op_name}_inventory/hosts.yml ${var.ansible_path}/${var.op_name}_inventory/backup_hosts.yml.$(date +%s)
        fi
        EOT
    }
}