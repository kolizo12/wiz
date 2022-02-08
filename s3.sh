aws s3api create-bucket \
    --bucket mongodbwiz \
    --region us-west-2 \
 --create-bucket-configuration LocationConstraint=us-west-2
#---
aws s3api put-bucket-policy --policy file://bucket-poliy --endpoint-url=https://mongodbwiz.s3.us-west-2.amazonaws.com --bucket  mongodbwiz
