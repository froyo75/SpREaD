# SpREaD

<img src="images/eagle.png" width="300px">

## Installation

**Terraform and Ansible are required**

### 1. Install Ansible & Terraform

#### Ansible
- Linux (https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
```shell
python3 -m pip install --user ansible
```
- OSX
```shell
brew install ansible
```

#### Terraform
- OSX : https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
- Linux: https://learn.hashicorp.com/tutorials/terraform/install-cli

### 2. Git clone this repo
```shell
git clone https://github.com/
```

### 3. Setup a new infrastructure
See the project's [wiki](https://github.com/froyo75/wiki) for more details.

## Usage
**Deploy a new infra**
```shell
./init-infra.sh <myinfra>.tfvars deploy
```
**Destroy the current infra**
```shell
./init-infra.sh <myinfra>.tfvars destroy
```