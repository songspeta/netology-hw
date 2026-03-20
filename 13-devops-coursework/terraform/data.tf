# =============================================================================
# DATA SOURCES
# =============================================================================

# Получаем ID образа Ubuntu 24.04 LTS для всех ВМ
data "yandex_compute_image" "ubuntu" {
  family = var.image_family
}

# Получаем информацию о текущем облаке (cloud_id, folder_id, zone)
data "yandex_client_config" "client" {}