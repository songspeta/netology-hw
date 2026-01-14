#!/bin/bash
echo "Проверка от $(date):" >> ~/apt_cache_check.log
du -sh /var/cache/apt/archives >> ~/apt_cache_check.log
echo "------------------------" >> ~/apt_cache_check.log
