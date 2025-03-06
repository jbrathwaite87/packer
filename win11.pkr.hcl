# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2"
    }
  }
}

variable "resource_group" {
  type = string
  default = "managed-images-rg"
}

source "azure-arm" "autogenerated_1" {
  # Authentication and build settings

  polling_duration_timeout = "30m"
  location                 = "East US"
  use_azure_cli_auth       = "true"
  vm_size                  = "Standard_D8ds_v4"

  # Powershell script which adds a WinRM certificate to the Virtual Machine
  custom_script  = "powershell -ExecutionPolicy Unrestricted -NoProfile -NonInteractive -Command \"$userData = (Invoke-RestMethod -H @{'Metadata'='True'} -Method GET -Uri 'http://169.254.169.254/metadata/instance/compute/userData?api-version=2021-01-01&format=text'); $contents = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($userData)); set-content -path c:\\Windows\\Temp\\userdata.ps1 -value $contents; . c:\\Windows\\Temp\\userdata.ps1;\""
  user_data_file = "./userdata.ps1"

  # Base Image
  os_type         = "Windows"
  image_offer     = "Windows-11"
  image_publisher = "MicrosoftWindowsDesktop"
  image_sku       = "win11-24h2-avd"
  image_version   = "latest"

  # Output Image
  managed_image_name                = "windows-skip-kv-{{timestamp}}"
  managed_image_resource_group_name = var.resource_group

  # WinRM configuration
  communicator                = "winrm"
  skip_create_build_key_vault = true
  winrm_username              = "packer"
  winrm_password = "mIl0kAW5s"
  winrm_use_ssl               = true
  winrm_port = 5986

  # This example provides a self-signed certificate on the VM, so it not signed by a valid certificate authority.  With a user provided certificate authority one should be able to make this more secure if that's required as a policy
  winrm_insecure = true

}

build {
  sources = ["source.azure-arm.autogenerated_1"]

  provisoner "windows-update" {
    search_criteria = "IsInstalled=0"
    filters = [
      "exclude:$_.Title -like '*Preview*'",
      "include:$true"
    ]
    update_limit = 25
  }

  provisoner "windows-restart" {}

  # Sysprep
  provisioner "powershell" {
    inline = [
      "if( Test-Path $Env:SystemRoot\\windows\\system32\\Sysprep\\unattend.xml ){ rm $Env:SystemRoot\\windows\\system32\\Sysprep\\unattend.xml -Force}",
      "& $Env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /shutdown /quiet"
    ]
  }
}
