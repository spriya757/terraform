#!/bin/bash
yum install -y git
wget https://www.atlassian.com/software/stash/downloads/binary/atlassian-bitbucket-6.0.9-x64.bin
chmod +x atlassian-bitbucket-6.0.9-x64.bin

cat > response.varfile << EOF
# install4j response file for Bitbucket 6.0.9
app.bitbucketHome=/var/atlassian/application-data/bitbucket
app.defaultInstallDir=/opt/atlassian/bitbucket/6.0.9
app.install.service$Boolean=true
httpPort=7990
installation.type=INSTALL
launch.application$Boolean=false
sys.adminRights$Boolean=true
sys.languageId=en
EOF

./atlassian-bitbucket-6.0.9-x64.bin -q -varfile response.varfile



MOUNT_LOCATION="/var/atlassian/application-data/bitbucket/shared"
MOUNT_TARGET="${mount-target-dns}"
yum update -y
yum install -y nfs-common git
mkdir -p $MOUNT_LOCATION
mount \
    -t nfs4 \
    -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 \
    $MOUNT_TARGET:/ $MOUNT_LOCATION

useradd -c "Atlassian Bitbucket" -u 1001 atlbitbucket
chown -R atlbitbucket:root /var/atlassian/application-data/bitbucket/shared

cat > /var/atlassian/application-data/bitbucket/shared/bitbucket.properties << EOF
setup.displayName=TEST
setup.license=AAABLg0ODAoPeNptUF1rwjAUfc+vCOxle4ikmcoUAtO2A6Gto1Wf9pKGq4a1acmHzH+/ars5hg8Xcu8595yT+1B4jRf+gNkE0+mc0TljOIw2mNFghiKw0qjWqUbzpXKll5/g8GMB5gTm6WOO45OovLjgKDRwfUTCAb9sE/pC2ASFjXZCukzUwMvmLFqjxKvSI1XWI9nUP3icClXdJdw8uDMekHXCHkfdijpBP6mUBG1hB8ZeWAx1WtqBFlpC/NUqc/4TakbYGK3NQWhle9WbAR6UBo+k7zbnFq7xw3Waxnm4WiSoP8Eq4stFWJBdHmzJW/6cERrkKSrijHdFkmAcMEbpFA1KHT9ZRXeh+zn7HIUTxoHhe1H9Zst8XYJZ77e2+zUnAXr3Rh6Fhf/3/wa50J6YMCwCFF4NiCsppKjv1UuTXrqAZt00GmeXAhQ0JfSpZAiZiA+2JTV5wnQfAnoNqA==X02f7
setup.sysadmin.username=admin
setup.sysadmin.password=admin@123
setup.sysadmin.displayName=adminuser
setup.sysadmin.emailAddress=admin@gmail.com
jdbc.driver=org.postgresql.Driver
jdbc.url=jdbc:postgresql://${bitbucket_db_endpoint}/bitbucket
jdbc.user=dbaadmin
jdbc.password=dbaadmin123
plugin.bitbucket-git.path.executable=/usr/bin/git
EOF

/opt/atlassian/bitbucket/6.0.9/bin/stop-bitbucket.sh
/opt/atlassian/bitbucket/6.0.9/bin/start-bitbucket.sh


