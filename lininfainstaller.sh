#!/bin/sh

#Script arguments
domainHost=${1}
domainName=${2}
domainUser=${3}
domainPassword=${4}
nodeName=${5}
nodePort=${6}

dbType=${7}
dbName=${8}
dbUser=${9}
dbPassword=${10}
dbHost=${11}
dbPort=${12}

sitekeyKeyword=${13}

joinDomain=${14}
osUserName=${15}

storageName=${16}
storageKey=${17}

domainLicenseURL=${18}

#Usage
if [ $# -ne 18 ]
then
	lininfainstaller.sh domainHost domainName domainUser domainPassword nodeName nodePort dbType dbName dbUser dbPassword dbHost dbPort sitekeyKeyword joinDomain  osUserName storageName storageKey domainLicenseURL
fi

#DEBUG remove it later
echo $domainHost $domainName $domainUser $domainPassword $nodeName $nodePort $dbType $dbName $dbUser $dbPassword $dbHost $dbPort $sitekeyKeyword $joinDomain $osUserName $storageName $storageKey $domainLicenseURL

yum -y update &>/dev/null

dbaddress=$dbHost:$dbPort
hostname=`hostname`

informaticaopt=/opt/Informatica
infainstallerloc=$informaticaopt/Archive/server
utilityhome=$informaticaopt/Archive/utilities

infainstallionlocown=/home/Informatica
mkdir -p $infainstallionlocown/10.1.1
ln -s -t /home/$osUserName/Informatica $infainstallionlocown

infainstallionloc=\\/home\\/Informatica\\/10.1.1
defaultkeylocation=$infainstallionloc\\/isp\\/config\\/keys
licensekeylocation=\\/opt\\/Informatica\\/license.key

JRE_HOME="$infainstallerloc/source/java/jre"
export JRE_HOME		
PATH="$JRE_HOME/bin":"$PATH"
export PATH

chmod -R 777 $JRE_HOME

cloudsupportenable=1
if [ "$domainLicenseURL" != "nolicense" -a $joinDomain -eq 0 ]
then
	cloudsupportenable=0
	cd $utilityhome
	java -jar iadutility.jar downloadHttpUrlFile -url $domainLicenseURL -localpath $informaticaopt/license.key
fi


createDomain=1
if [ $joinDomain -eq 1 ]
then
    createDomain=0
	# This is buffer time for master node to start
	sleep 600
else
	cd $utilityhome
    java -jar iadutility.jar createAzureFileShare -storageaccesskey $storageKey -storagename $storageName
fi


yum -y install cifs-utils
mountDir=/mnt/infaaeshare
mkdir $mountDir
mount -t cifs //$storageName.file.core.windows.net/infaaeshare $mountDir -o vers=3.0,username=$storageName,password=$storageKey,dir_mode=0777,file_mode=0777
echo //$storageName.file.core.windows.net/infaaeshare $mountDir cifs vers=3.0,username=$storageName,password=$storageKey,dir_mode=0777,file_mode=0777 >> /etc/fstab


sed -i s/^LICENSE_KEY_LOC=.*/LICENSE_KEY_LOC=$licensekeylocation/ $infainstallerloc/SilentInput.properties

sed -i s/^USER_INSTALL_DIR=.*/USER_INSTALL_DIR=$infainstallionloc/ $infainstallerloc/SilentInput.properties

sed -i s/^CREATE_DOMAIN=.*/CREATE_DOMAIN=$createDomain/ $infainstallerloc/SilentInput.properties

sed -i s/^JOIN_DOMAIN=.*/JOIN_DOMAIN=$joinDomain/ $infainstallerloc/SilentInput.properties

sed -i s/^CLOUD_SUPPORT_ENABLE=.*/CLOUD_SUPPORT_ENABLE=$cloudsupportenable/ $infainstallerloc/SilentInput.properties

sed -i s/^ENABLE_USAGE_COLLECTION=.*/ENABLE_USAGE_COLLECTION=1/ $infainstallerloc/SilentInput.properties

sed -i s/^KEY_DEST_LOCATION=.*/KEY_DEST_LOCATION=$defaultkeylocation/ $infainstallerloc/SilentInput.properties

sed -i s/^PASS_PHRASE_PASSWD=.*/PASS_PHRASE_PASSWD=$sitekeyKeyword/ $infainstallerloc/SilentInput.properties

sed -i s/^SERVES_AS_GATEWAY=.*/SERVES_AS_GATEWAY=1/ $infainstallerloc/SilentInput.properties

sed -i s/^DB_TYPE=.*/DB_TYPE=$dbType/ $infainstallerloc/SilentInput.properties

sed -i s/^DB_UNAME=.*/DB_UNAME=$dbUser/ $infainstallerloc/SilentInput.properties

sed -i s/^DB_PASSWD=.*/DB_PASSWD=$dbPassword/ $infainstallerloc/SilentInput.properties

sed -i s/^DB_SERVICENAME=.*/DB_SERVICENAME=$dbName/ $infainstallerloc/SilentInput.properties

sed -i s/^DB_ADDRESS=.*/DB_ADDRESS=$dbaddress/ $infainstallerloc/SilentInput.properties

sed -i s/^DOMAIN_NAME=.*/DOMAIN_NAME=$domainName/ $infainstallerloc/SilentInput.properties

sed -i s/^NODE_NAME=.*/NODE_NAME=$nodeName/ $infainstallerloc/SilentInput.properties

sed -i s/^DOMAIN_PORT=.*/DOMAIN_PORT=$nodePort/ $infainstallerloc/SilentInput.properties

sed -i s/^JOIN_NODE_NAME=.*/JOIN_NODE_NAME=$nodeName/ $infainstallerloc/SilentInput.properties

sed -i s/^JOIN_HOST_NAME=.*/JOIN_HOST_NAME=$hostname/ $infainstallerloc/SilentInput.properties

sed -i s/^JOIN_DOMAIN_PORT=.*/JOIN_DOMAIN_PORT=$nodePort/ $infainstallerloc/SilentInput.properties

sed -i s/^DOMAIN_USER=.*/DOMAIN_USER=$domainUser/ $infainstallerloc/SilentInput.properties

sed -i s/^DOMAIN_HOST_NAME=.*/DOMAIN_HOST_NAME=$domainHost/ $infainstallerloc/SilentInput.properties

sed -i s/^DOMAIN_PSSWD=.*/DOMAIN_PSSWD=$domainPassword/ $infainstallerloc/SilentInput.properties

sed -i s/^DOMAIN_CNFRM_PSSWD=.*/DOMAIN_CNFRM_PSSWD=$domainPassword/ $infainstallerloc/SilentInput.properties

cd $infainstallerloc
echo Y Y | sh silentinstall.sh 


chown -R $osUserName $infainstallionlocown
chown -R $osUserName $informaticaopt 
chown -R $osUserName $mountDir