# Create, Install and Configure AWS EC2 using Ansible

# Get SSH key
data "aws_key_pair" "current_ssh_key" {
  key_name = var.aws_ssh_key_name
}

/*# Add a new SSH key
resource "aws_key_pair" "default_ssh_key" {
  key_name   = var.aws_ssh_key_name
  public_key = file(var.aws_ssh_public_key)
}*/

# Create EC2 instance
resource "aws_instance" "instance" {
  for_each = var.hosts
  
  ami                    = each.value.aws_image
  instance_type          = each.value.aws_type
  key_name               = var.aws_ssh_key_name
  security_groups        = [each.value.vps_service_type]
  monitoring = true
  tags = {
    Name = format("%s-%s-%s", var.op_name, each.value.aws_name, each.value.vps_service_type)
    Environment = each.value.aws_environment
  }

  # Configure EC2 instance
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = <<-EOT
      ANSIBLE_PATH=${var.ansible_path}
      export ANSIBLE_CONFIG=$ANSIBLE_PATH/ansible.cfg
      INVENTORY_PATH=$ANSIBLE_PATH/${var.op_name}_inventory
      HOSTS_FILE_PATH=$INVENTORY_PATH/hosts.yml
      HOST_VARS_FILE_PATH=$INVENTORY_PATH/host_vars/${each.key}
      VPS_SERVICE_TYPE=${each.value.vps_service_type}
      VPS_DNS_PROVIDER=${each.value.vps_dns_provider}
      ANSIBLE_PLAYBOOK_SERVICE=$ANSIBLE_PATH/init-$VPS_SERVICE_TYPE.yml
      SSH_DELAY=30
      SSH_PRIVATE_KEY_FILE=$(realpath ${var.aws_ssh_private_key})
      mkdir -p $INVENTORY_PATH/{group_vars,host_vars}
      echo -e "# global vars\nansible_port: 22\nansible_ssh_private_key_file: $SSH_PRIVATE_KEY_FILE" > $INVENTORY_PATH/group_vars/all
      cp host_vars.tpl $HOST_VARS_FILE_PATH
      sed -i -e 's!^\(ansible_host:\)\(.*\)!\1 ${self.public_ip}!g' $HOST_VARS_FILE_PATH
      sed -i -e 's!^\(ansible_user:\)\(.*\)!\1 ${each.value.ansible_user}!g' $HOST_VARS_FILE_PATH
      sed -i -e 's!^\(ansible_port:\)\(.*\)!\1 ${each.value.ansible_port}!g' $HOST_VARS_FILE_PATH
      sed -i -e 's!^\(server_domain:\)\(.*\)!\1 ${each.value.vps_domain}!g' $HOST_VARS_FILE_PATH
      sed -i -e 's!^\(sshd_port:\)\(.*\)!\1 ${each.value.vps_sshd_port}!g' $HOST_VARS_FILE_PATH
      sed -i -e 's!^\(ssh_authorized_keys_folder:\)\(.*\)!\1 ${each.value.vps_ssh_authorized_keys_folder}!g' $HOST_VARS_FILE_PATH
      sed -i -e 's!^\(authorized_key_options:\)\(.*\)!\1 ${each.value.vps_authorized_key_options}!g' $HOST_VARS_FILE_PATH
      sed -i -e 's!^\(admin_email_address:\)\(.*\)!\1 ${each.value.vps_admin_email_address}!g' $HOST_VARS_FILE_PATH
      sed -i -e 's!^\(timezone:\)\(.*\)!\1 ${each.value.vps_timezone}!g' $HOST_VARS_FILE_PATH
      sed -i -e 's!^\(service_type:\)\(.*\)!\1 ${each.value.vps_service_type}!g' $HOST_VARS_FILE_PATH
      sed -i -e 's!^\(dns_template:\)\(.*\)!\1 ${each.value.vps_dns_template}!g' $HOST_VARS_FILE_PATH
      sed -i -e 's!^\(dkim_domain_key:\)\(.*\)!\1 ${each.value.vps_smtp_dkim_domain_key}!g' $HOST_VARS_FILE_PATH
      sed -i -e 's!^\(dkim_selector:\)\(.*\)!\1 ${each.value.vps_smtp_dkim_selector}!g' $HOST_VARS_FILE_PATH
      sed -i -e 's!^\(c2_framework:\)\(.*\)!\1 ${each.value.vps_c2_framework}!g' $HOST_VARS_FILE_PATH
      sed -i -e 's!^\(c2_mode:\)\(.*\)!\1 ${each.value.vps_c2_mode}!g' $HOST_VARS_FILE_PATH

      sleep $SSH_DELAY

      ansible-playbook -i $INVENTORY_PATH --limit ${each.key} $ANSIBLE_PATH/init-vps.yml
      sed -i -e 's!^\(ansible_port:\)\(.*\)!\1 ${each.value.vps_sshd_port}!g' $HOST_VARS_FILE_PATH

      if [[ ! -z $VPS_DNS_PROVIDER ]];then
        DNS_GLUE_RECORDS=${each.value.vps_glue_record}
        if [[ $DNS_GLUE_RECORDS == "true" ]];then
          ansible -i $INVENTORY_PATH -m import_role -a name=$ANSIBLE_PATH/roles/configure_${each.value.vps_dns_provider}_glue_records -e "dns_api_key=${var.dns_token}" ${each.key}
        else
          ansible -i $INVENTORY_PATH -m import_role -a name=$ANSIBLE_PATH/roles/configure_${each.value.vps_dns_provider}_dns_records -e "dns_api_key=${var.dns_token}" ${each.key}
        fi
      fi

      if [[ ! -z $VPS_SERVICE_TYPE && -f $ANSIBLE_PLAYBOOK_SERVICE ]];then
        ansible-playbook -i $INVENTORY_PATH -e c2_framework=${each.value.vps_c2_framework} --limit ${each.key} $ANSIBLE_PLAYBOOK_SERVICE
      fi
    EOT
  }
}

# Create EIP addresses for EC2 instances
resource "aws_eip" "eip" {
    for_each = aws_instance.instance
    instance = each.value.id
    vpc = true
    tags = {
        Name = format("%s-%s", var.op_name, each.value.id)
    }

    # Setup EIP addresses for EC2 instances in Ansible inventory
    provisioner "local-exec" {
        interpreter = ["/bin/bash", "-c"]
        command = <<-EOT
          ANSIBLE_PATH=${var.ansible_path}
          INVENTORY_PATH=$ANSIBLE_PATH/${var.op_name}_inventory
          HOST_VARS_FILE_PATH=$INVENTORY_PATH/host_vars/*
          sed -i -e 's!^\(ansible_host:\)\(\s${each.value.public_ip}\)!\1 ${self.public_ip}!g' $HOST_VARS_FILE_PATH
        EOT
    }

    depends_on = [aws_instance.instance]
}