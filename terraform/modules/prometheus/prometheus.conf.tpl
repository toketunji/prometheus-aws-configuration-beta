global:
  scrape_interval:     1s
  evaluation_interval: 1s

scrape_configs:
  - job_name: 'node'
    ec2_sd_configs:
    - region: eu-west-1
      profile: "${ec2_instance_profile}"
      port: 9090
    relabel_configs:
     - source_labels: [__meta_ec2_tag_Name]
       regex: Prometheus
       action: keep