#!/bin/bash
#openGuass自启脚本
su - omm <<EOF
gs_om -t start;
gs_om -t status;
exit;
EOF
