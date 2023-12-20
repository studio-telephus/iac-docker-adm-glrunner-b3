#!/usr/bin/env bash
: "${GITLAB_RUNNER_REGISTRATION_KEY?}"
: "${GIT_SA_USERNAME?}"
: "${GIT_SA_TOKEN?}"

##
echo "Install the base tools"

apt-get update
apt-get install -y \
 curl vim wget htop unzip gnupg2 \
 bash-completion git apt-transport-https ca-certificates \
 software-properties-common

## Run pre-install scripts
sh /mnt/setup-ca.sh


##
echo "Install GitLab Runner"

# Add the official GitLab repository
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | bash

# Disable skel & install
export GITLAB_RUNNER_DISABLE_SKEL=true
apt-get install gitlab-runner -y

echo "Register GitLab Runner"
gitlab-runner register \
    --non-interactive \
    --url https://gitlab.adm.acme.corp/gitlab \
    --registration-token "$GITLAB_RUNNER_REGISTRATION_KEY" \
    --tag-list "java11" \
    --executor shell

export cred_home="/home/gitlab-runner"

echo "Create GitLab credentials file"
cat << EOF > ${cred_home}/.my-git-credentials
https://${GIT_SA_USERNAME}:${GIT_SA_TOKEN}@gitlab.adm.acme.corp
EOF

echo "Set ownership & permissions of .my-git-credentials"
chmod 644 ${cred_home}/.my-git-credentials

echo "Add Github credentials to git global config file"
cat << EOF > ${cred_home}/.gitconfig
[credential]
	helper = store --file ${cred_home}/.my-git-credentials
[user]
	user = ${GIT_SA_USERNAME}
	email = ${GIT_SA_USERNAME}@mail.adm.acme.corp
EOF

echo "Set ownership & permissions"
chmod 644 ${cred_home}/.gitconfig
chown -R gitlab-runner:gitlab-runner /home/gitlab-runner

##
echo "Install JDK"

## Retrieve the latest Linux Corretto .tgz package by using a Permanent URL
wget https://corretto.aws/downloads/latest/amazon-corretto-11-x64-linux-jdk.tar.gz

mkdir -p /usr/lib/jvm/jdk-11
tar -xvf *.tar.gz -C /usr/lib/jvm/jdk-11 --strip-components 1
/usr/lib/jvm/jdk-11/bin/java -version

update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk-11/bin/java" 0
update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/jdk-11/bin/javac" 0
update-alternatives --set java /usr/lib/jvm/jdk-11/bin/java
update-alternatives --set javac /usr/lib/jvm/jdk-11/bin/javac

echo 'JAVA_HOME="/usr/lib/jvm/jdk-11"' >> /etc/environment

## Verify
java -version
