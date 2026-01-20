import json
import time
import logging
from json_log_formatter import JSONFormatter

# Настраиваем JSON-логирование
formatter = JSONFormatter()
handler = logging.FileHandler('/var/log/app/app.log')
handler.setFormatter(formatter)
logger = logging.getLogger()
logger.addHandler(handler)
logger.setLevel(logging.INFO)

while True:
    log_entry = {
        "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
        "level": "INFO",
        "message": "User login",
        "user_id": 123,
        "action": "login",
        "status": "success"
    }
    logger.info(json.dumps(log_entry))
    time.sleep(5)