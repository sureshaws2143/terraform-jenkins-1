#!/bin/bash

# install Java
sudo apt-get install -y default-jre

# wait for Jenkins to be started
while ! nc -z ${jenkins_ip} 8080; do
    sleep 1
done

sleep 30

curl --user admin:${jenkins_password} -s http://${jenkins_ip}:8080/api/json

# download agent.jar from Jenkins master
wget http://${jenkins_ip}:8080/jnlpJars/jenkins-cli.jar

# create a new node as slave on Jenkins master
cat <<EOF | java -jar jenkins-cli.jar -s http://${jenkins_ip}:8080 -auth admin:${jenkins_password} create-node slave
<slave>
    <remoteFS>/opt/jenkins</remoteFS>
    <numExecutors>1</numExecutors>
    <launcher class="hudson.slaves.JNLPLauncher"/>
</slave>
EOF

# get CSRF token from Jenkins master
TOKEN=$(curl --user admin:${jenkins_password} -s http://${jenkins_ip}:8080/crumbIssuer/api/json | python -c 'import sys,json;j=json.load(sys.stdin);print j["crumbRequestField"] + "=" + j["crumb"]')

# get the secret for the Jenkins slave
SECRET=$(curl --user admin:${jenkins_password} -d "$TOKEN" --data-urlencode "script=println(hudson.model.Hudson.instance.slaves.get(0).getComputer().getJnlpMac())" http://${jenkins_ip}:8080/scriptText)

# download agent.jar from Jenkins master
wget http://${jenkins_ip}:8080/jnlpJars/agent.jar

# launch agent headlessly via JNLP
java -jar agent.jar -jnlpUrl http://${jenkins_ip}:8080/computer/slave/slave-agent.jnlp -secret $SECRET -workDir /opt/jenkins &