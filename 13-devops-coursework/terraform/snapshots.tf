# =============================================================================
# SNAPSHOT SCHEDULE FOR ALL VM DISKS (Daily + 7 Days Retention)
# =============================================================================

# -----------------------------------------------------------------------------
# Collect ALL disk IDs using consistent for-loops
# -----------------------------------------------------------------------------
locals {

  # Собираем ВСЕ дисковые ID через for-loops
  bastion_disk_ids     = [for inst in yandex_compute_instance.bastion : inst.boot_disk.0.disk_id]
  web_disk_ids         = [for inst in yandex_compute_instance.web : inst.boot_disk.0.disk_id]
  prometheus_disk_ids  = [for inst in yandex_compute_instance.prometheus : inst.boot_disk.0.disk_id]
  grafana_disk_ids     = [for inst in yandex_compute_instance.grafana : inst.boot_disk.0.disk_id]
  elasticsearch_disk_ids = [for inst in yandex_compute_instance.elasticsearch : inst.boot_disk.0.disk_id]
  kibana_disk_ids      = [for inst in yandex_compute_instance.kibana : inst.boot_disk.0.disk_id]

  # Объединяем ВСЁ в один список
  all_disk_ids = concat(
    local.bastion_disk_ids,
    local.web_disk_ids,
    local.prometheus_disk_ids,
    local.grafana_disk_ids,
    local.elasticsearch_disk_ids,
    local.kibana_disk_ids
  )
}

# -----------------------------------------------------------------------------
# Single Snapshot Schedule for ALL disks
# -----------------------------------------------------------------------------
resource "yandex_compute_snapshot_schedule" "daily_backup" {
  name        = "${var.resource_prefix}-daily-backup-schedule"
  description = "Daily snapshot schedule for all VMs with 7 days retention"

  # Расписание: каждый день в 03:00
  schedule_policy {
    expression = "0 3 * * *"
  }

  # Хранить последние 7 снимков на каждый диск
  snapshot_count = 7

  # Параметры создаваемых снимков
  snapshot_spec {
    description = "Automated daily backup"
    labels = {
      backup-type = "daily"
      managed-by  = "terraform"
    }
  }

  # ВСЕ диски всех ВМ (из local.all_disk_ids)
  disk_ids = local.all_disk_ids
}