control "aws_cloud_resources" do
  describe aws_ec2_instance(name: 'Prometheus') do
    its('tags') { should include(key: 'Name', value: 'Prometheus')}
    its('image_id') { should eq 'ami-0d137679f8243e9f8' }
    its('root_device_type') { should eq 'ebs'}
    its('root_device_name') { should eq '/dev/sda1'}
    its('architecture') { should eq 'x86_64'}
    its('virtualization_type') { should eq 'hvm'}
    its('key_name') { should eq 'djeche-insecure'}
  end

  describe aws_iam_role('prometheus_profile') do
    it { should exist }
    its('description') { should eq 'This profile is used to ensure prometheus can describe instances and grab config from the bucket'}
  end

  describe aws_iam_policy('prometheus_instance_profile') do
    it { should exist }
    its('attached_roles') { should include "prometheus_profile" }
    it { should be_attached }
    it { should have_statement(Action: ['s3:Get*','s3:ListBucket'], Effect: 'Allow', Sid: 's3Bucket') }
    it { should have_statement(Action: 'ec2:Describe*', Effect: 'Allow', Resource: '*', Sid: 'ec2Policy') }
  end

  describe aws_security_group(group_name: 'external_http_traffic') do
    it { should exist }
  end

  describe aws_s3_bucket_object(bucket_name: 'prometheus-config-store', key: 'prometheus/prometheus.yml') do
    it { should exist }
    it { should_not be_public }
  end

  describe aws_s3_bucket(bucket_name: 'prometheus-config-store') do
    it { should exist }
    it { should_not be_public }
  end
end