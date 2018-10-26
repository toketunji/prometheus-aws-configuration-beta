filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/syslog

output.logstash:
  hosts: ["${logstash_hosts}"]
  loadbalance: true
  ssl.enabled: true
