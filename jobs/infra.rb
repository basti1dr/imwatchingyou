current_valuation = 0
current_karma = 0

SCHEDULER.every '5s' do
  last_valuation = current_valuation
  last_karma     = current_karma
  current_valuation = rand(100)
  current_karma     = rand(200000)

  awsInfo = AwsInfo.new()

  allS3 = awsInfo.listS3

  numberS3 = awsInfo.getNumberBucketS3


  send_event('welcome', {text: allS3 })

  send_event('valuation', { current: current_valuation, last: last_valuation })
  send_event('karma', { current: current_karma, last: last_karma })
  send_event('ec2number',   { value: awsInfo.getNumberEc2, max: awsInfo.getEc2Limit })
end

### Rafraichissement du bloc AWS
SCHEDULER.every '5m', :first_in => 0 do |job|
  AWS.config(aws_conf)
  aws_support = AWS::Support::Client.new
  aws_costgain_dollar = 0
  aws_trustedadvisor_checks = aws_support.describe_trusted_advisor_checks({:language => 'en'})

  if aws_trustedadvisor_checks.has_key?(:checks)
    aws_trustedadvisor_checks[:checks].each do |check|
      aws_trustedadvisor_checksum = aws_support.describe_trusted_advisor_check_summaries({ :check_ids => [check[:id]] })
      if check[:category] == "cost_optimizing" and aws_trustedadvisor_checksum[:summaries].first[:status] != "ok"
        aws_costgain_dollar += aws_trustedadvisor_checksum[:summaries].first[:category_specific_summary][:cost_optimizing][:estimated_monthly_savings].to_i if ! aws_trustedadvisor_checksum[:summaries].first[:category_specific_summary][:cost_optimizing].nil?
      end
    end
  end

  ec2 = AWS::EC2.new
  instances = {} if instances.nil?
  instances['integ']   = 0
  instances['preprod'] = 0
  instances['prod']    = 0
  instances['total']   = 0

  AWS.memoize do
    ec2.instances.each_with_index do |instance, index|
      unless instance.status == :terminated
        tags = instance.tags.to_h
        if ! tags['env'].nil?
          case tags['env']
          when 'integ'
            instances['integ'] += 1
          when 'preprod'
            instances['preprod'] += 1
          when 'prod'
            instances['prod'] += 1
          end
        end
      end
    end
    instances['total'] += ec2.instances.count
  end

  string_aws = [] if string_aws.nil?
  string_aws.push({ label: 'Instances EC2', value: instances['total'] })
  string_aws.push({ label: 'Preprod', value: instances['preprod'] })
  string_aws.push({ label: 'Prod', value: instances['prod'] })
  string_aws.push({ label: 'Integ', value: instances['integ'] })
  string_aws.push({ label: 'Gains possibles', value: "#{aws_costgain_dollar} $" })

  send_event("aws_resume", { items: string_aws, alerts: 0 })
end
### Rafraichissement du bloc AWS
