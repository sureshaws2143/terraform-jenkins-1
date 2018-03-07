#!/bin/bash

# install Jenkins
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install -y jenkins

# wait for Jenkins to be started
while ! nc -z localhost 8080; do
    sleep 1
done

# wait for password file to be created
while [ ! -f /var/lib/jenkins/secrets/initialAdminPassword ]; do
    sleep 1
done

sleep 20

# read the initial Jenkins admin password
PASS=$(sudo bash -c "cat /var/lib/jenkins/secrets/initialAdminPassword")

# get CSRF token from Jenkins master
TOKEN=$(curl --user admin:$PASS -s http://localhost:8080/crumbIssuer/api/json | python -c 'import sys,json;j=json.load(sys.stdin);print j["crumbRequestField"] + "=" + j["crumb"]')

# enable JNLP on Jenkins master
curl --user admin:$PASS -d "$TOKEN" --data-urlencode "script=Jenkins.instance.setSlaveAgentPort(8000)" http://localhost:8080/scriptText

# change the password of admin of Jenkins
curl --user admin:$PASS -d "$TOKEN" --data-urlencode "script=hudson.model.User.current().addProperty(hudson.security.HudsonPrivateSecurityRealm.Details.fromPlainPassword('${jenkins_password}'))" http://localhost:8080/scriptText
