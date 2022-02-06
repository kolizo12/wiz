#create the security group and then use the secrity group as part of the security group rules
aws ec2 create-security-group --group-name database --description "security group for database"
```
 aws ec2 authorize-security-group-ingress \
    --group-id sg-xxxxxxx \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0
```
```
aws ec2 authorize-security-group-ingress \
    --group-id sg-xxxxxxx \
    --protocol tcp \
    --port 28017
```
```
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxx  --source-group database --group-owner  609xxxxxxx --protocol all --port all
```
#create a key pair and download this into your computer to be used to access the ec2 resources
#create the ekscluster in public subnet using the script eksexistingvpc.yaml
#replace every value mark with xxx with your appropriate value

```
eksctl create cluster -f eksexistingvpc.yaml
```

Create a mongod instance with an attache profile that give it access to all ec2 role 
```
aws ec2 run-instances --image-id ami-06cffe063efe892ad --instance-type t2.micro --key-name webapp --security-groups  database --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Mongodb}]' 

aws ec2 associate-iam-instance-profile --instance-id i-070afd4037ac924cf --iam-instance-profile Name=ec2instance
```
===
Create the volumes to be consumed by the mongod instance 
```
for x in {1..4}; do
aws ec2 create-volume --size 4 --availability-zone us-west-2c;
done > vols.txt
```

```
aws ec2 attach-volume --volume-id vol-xxxxxxxxxxxxx --instance-id i-xxxxxxxx --device /dev/sdj
aws ec2 attach-volume --volume-id vol-xxxxxxxxxxxxx --instance-id i-xxxxxxxx --device /dev/sdk
aws ec2 attach-volume --volume-id vol-xxxxxxxxxxxxx --instance-id i-xxxxxxxx --device /dev/sdl
aws ec2 attach-volume --volume-id vol-xxxxxxxxxxxxx --instance-id i-xxxxxxxx -- device /dev/sdm
```
===

#prepare the insance for monogod installation

===
```
sudo mdadm --verbose --create /dev/md0 --level=10 --chunk=256 --raid-devices=4 /dev/sdj /dev/sdk /dev/sdl /dev/sdm
echo ’DEVICE /dev/sdj /dev/sdk /dev/sdl /dev/sdm’ | sudo tee -a /etc/mdadm.conf
sudo mdadm --detail --scan | sudo tee -a /etc/mdadm.conf
```

```
sudo blockdev --setra 128 /dev/md0
sudo blockdev --setra 128 /dev/sdj
sudo blockdev --setra 128 /dev/sdk
sudo blockdev --setra 128 /dev/sdl
sudo blockdev --setra 128 /dev/sdm
```
===
```
sudo dd if=/dev/zero of=/dev/md0 bs=512 count=1
sudo pvcreate /dev/md0
sudo vgcreate vg1 /dev/md0
```
===
```
sudo lvcreate -l 90%vg -n data vg1
sudo lvcreate -l 5%vg -n log vg1
sudo lvcreate -l 5%vg -n journal vg1
```
===
```
sudo mke2fs -t ext4 -F /dev/vg1/data
sudo mke2fs -t ext4 -F /dev/vg1/log
sudo mke2fs -t ext4 -F /dev/vg1/journal

sudo mkdir /data
sudo mkdir /log
sudo mkdir /journal

echo '/dev/vg1/data /data ext4 defaults,auto,noatime,noexec 0 0' | sudo tee -a /etc/fstab
echo '/dev/vg1/log /log ext4 defaults,auto,noatime,noexec 0 0' | sudo tee -a /etc/fstab
echo '/dev/vg1/journal /journal ext4 defaults,auto,noatime,noexec 0 0' | sudo tee -a /etc/fstab
```
===
```
sudo mount /data
sudo mount /log
sudo mount /journal
```
===
```
sudo ln -s /journal /data/journal
```
===

Install mongodb
===
run
sudo vi /etc/yum.repos.d/mongodb-org-4.2.repo
add the entries
```
[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/4.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc
```
```
sudo yum install -y mongodb-org
```
===

change permissions
==
```
sudo chown mongod:mongod /data
sudo chown mongod:mongod /log
sudo chown mongod:mongod /journal
```
===

edit the /etc/mongod.conf
====
path:
  /log/mongod.log

storage:
  dbPath: /data

net:
  port: 27017
  bindIp: 0.0.0.0

#security and authorization
security:
  authorization: 'enabled'
===
```
sudo systemctl start mongod
```
