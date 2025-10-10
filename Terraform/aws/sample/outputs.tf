# Output all instance id, public/private IPv4 addresses, DNS names and regions
output "ec2_infos" {
    description = "EC2 Infos"
    value       = {
        for ec2 in aws_instance.instance:
          ec2.id => format("Instance Name: %s | Instance Type: %s | Public IP address: %s | Private IP address: %s | Public DNS name: %s | Private DNS name: %s | Region: %s", ec2.tags["Name"], ec2.instance_type, ec2.public_ip, ec2.private_ip, ec2.public_dns, ec2.private_dns, ec2.availability_zone)
    }
}

# Output all instance id and EIP addresses
output "ec2_eips" {
    description = "EC2 EIP addresses"
    value       = {
        for ec2 in aws_eip.eip:
          ec2.id => format("EIP Name: %s | Public IP address: %s", ec2.tags["Name"], ec2.public_ip)
    }
}

# Output all instance id and security groups
output "ec2_security_groups" {
    description = "EC2 Security Groups"
    value       = {
        for ec2 in aws_instance.instance:
          ec2.id => format("Security Group Name: %s | Security Groups ID: %s", join("", ec2.security_groups), join("", ec2.vpc_security_group_ids))
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