#!/bin/bash

./cleanup.sh
#declare an array in bash
declare -a instanceARR



mapfile -t instanceARR < <(aws ec2 run-instances --image-id $1 --count $2 --instance-type $3 --key-name $6 --security-group-ids $4 --subnet-id $5 --associate-public-ip-address --iam-instance-profile $7 --user-data file://install-webserver.sh --output table |grep InstanceId | sed "s/|//g"| sed "s/ //g" | sed "s/InstanceId//g") 
echo ${instanceARR[@]}

aws ec2 wait instance-running --instance-ids ${instanceARR[@]}
echo "instace are running"

aws elb create-load-balancer --load-balancer-name itmo544-ght-elb --listeners Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80 --subnets subnet-39aafd5c --security-groups sg-909b12f4 
echo -e "\nFinished launching ELB and sleeping 25 seconds"
for i in {0..25};do echo -ne'.'; sleep 1;done
echo "\n"
aws elb register-instances-with-load-balancer --load-balancer-name itmo544-ght-elb --instances ${instanceARR[@]}
aws elb configure-health-check --load-balancer-name itmo544-ght-elb --health-check Target=HTTP:80/index.html,Interval=30,UnhealthyThreshold=2,HealthyThreshold=2,Timeout=3

#create launch configuration
aws autoscaling create-launch-configuration --launch-configuration-name itmo544-launch-config --image-id ami-5189a661 --key-name itmo544-vbox --security-groups sg-909b12f4 --instance-type t2.micro --user-data file://install-webserver.sh --iam-instance-profile ght

#create autoscaling 
aws autoscaling create-auto-scaling-group --auto-scaling-group-name itmo-544-auto-scaling-group --launch-configuration-name itmo544-launch-config --load-balancer-names itmo544-ght-elb  --health-check-type ELB --min-size 3 --max-size 6 --desired-capacity 3 --default-cooldown 600 --health-check-grace-period 120 --vpc-zone-identifier subnet-39aafd5c


#create cloudwatch alarms
# add capacity
aws cloudwatch put-metric-alarm --alarm-name AddCapacity --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 120 --threshold 30 --comparison-operator GreaterThanOrEqualToThreshold --dimensions Name=AutoScalingGroupName,Value=itmo-544-auto-scaling-group --evaluation-periods 6 --alarm-action arn:aws:sns:us-west-2:111122223333:MyTopic --unit Percent


#remove capacity
aws cloudwatch put-metric-alarm --alarm-name RemoveCapacity --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 120 --threshold 10 --comparison-operator LessThanOrEqualToThreshold --dimensions Name=AutoScalingGroupName,Value=itmo-544-auto-scaling-group --evaluation-periods 6 --alarm-actions arn:aws:sns:us-west-2:111122223333:MyTopic --unit Percent


#Sleep 30
#!/bin/bash
#crate rds db &rr
aws rds create-db-instance --db-name guhaotiandb --engine mysql --db-instance-identifier itmo544-ght-db --db-instance-class db.t2.micro --allocated-storage 5 --master-username guhaotian --master-user-password 909690ght --vpc-security-group-ids sg-94e55cf0  --availability-zone us-west-2a 


aws rds wait db-instance-available --db-instance-identifier itmo544-ght-db

aws rds create-db-instance-read-replica --db-instance-identifier itmo544-ght-dbrr --source-db-instance-identifier itmo544-ght-db --db-instance-class db.t2.micro 
