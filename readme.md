#create the security group and then use the secrity group as part of the security group rules
aws ec2 create-security-group --group-name database --description "security group for database"

 aws ec2 authorize-security-group-ingress \
    --group-id sg-xxxxxxx \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0
===
aws ec2 authorize-security-group-ingress \
    --group-id sg-xxxxxxx \
    --protocol tcp \
    --port 28017
===
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxx  --source-group database --group-owner  609xxxxxxx --protocol all --port all
===

#create a key pair and download this into your computer to be used to access the ec2 resources
===
#create the ekscluster in public subnet using the script eksexistingvpc.yaml
#replace every value mark with xxx with your appropriate value
eksctl create cluster -f eksexistingvpc.yaml
