#!/bin/bash

yum update
yum -y install nginx

TOKEN=$(curl -X PUT -s "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
PUBLIC_HOSTNAME=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-hostname)
PUBLIC_IPV4=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)

cat <<-EOF > /usr/share/nginx/html/index.html
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Document</title>
    </head>
    <body>
        <h1>Instance ID: ${INSTANCE_ID}</h1>
        <h1>Public Hostname: ${PUBLIC_HOSTNAME}</h1>
        <h1>Public IPv4: ${PUBLIC_IPV4}</h1>
    </body>
    </html>
EOF

systemctl start nginx
systemctl enable nginx
