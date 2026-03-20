provider "yandex" {
  service_account_key_file = var.yc_token_path
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
}
provider "local" {}
provider "template" {}