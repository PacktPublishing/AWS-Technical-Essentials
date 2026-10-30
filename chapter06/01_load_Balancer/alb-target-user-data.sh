#!/bin/bash
set -euxo pipefail

# The Chapter 5 AMI already contains Apache. This script adds only
# launch-specific content and does not require internet access.
systemctl enable --now httpd

TOKEN=$(curl -sf -X PUT \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" \
  http://169.254.169.254/latest/api/token)
INSTANCE_ID=$(curl -sf \
  -H "X-aws-ec2-metadata-token: ${TOKEN}" \
  http://169.254.169.254/latest/meta-data/instance-id)
AVAILABILITY_ZONE=$(curl -sf \
  -H "X-aws-ec2-metadata-token: ${TOKEN}" \
  http://169.254.169.254/latest/meta-data/placement/availability-zone)

cat > /var/www/html/index.html <<EOF_HTML
<!doctype html>
<html lang="en">
<head><meta charset="utf-8"><title>AWS Technical Essentials</title></head>
<body>
  <h1>Application Load Balancer target</h1>
  <p>Instance ID: ${INSTANCE_ID}</p>
  <p>Availability Zone: ${AVAILABILITY_ZONE}</p>
</body>
</html>
EOF_HTML

printf 'ok\n' > /var/www/html/health.html
