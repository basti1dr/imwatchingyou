require 'json'
require 'aws-sdk'
require 'pp'
require './lib/aws_connection.rb'

# This class get informations of AWS ec2 with SDK v2
class AwsEc2 < AwsConnection
  def initialize
    super
    @ec2client = Aws::EC2::Client.new(region: @region, credentials: @credentials)
  end

  def number_ec2
    list_ec2 = @ec2client.describe_instances
    number_ec2 = 0
    list_ec2.reservations.each do |reservation|
      number_ec2 += reservation.instances.length
    end
    number_ec2
  end

  def number_ec2_by_status(status)
    list_ec2 = @ec2client.describe_instances
    number_ec2 = 0
    list_ec2.reservations.each do |reservation|
      reservation.instances.each do |instance|
        number_ec2 += 1 if instance.state.name.eql?(status)
      end
    end
    number_ec2
  end

  def number_ec2_by_stage(stage)
    list_ec2 = @ec2client.describe_instances(
      filters: [
        {
          name: 'tag-value',
          values: [stage]
        }
      ],
      max_results: 500
    )

    number_ec2 = 0
    list_ec2.reservations.each do |reservation|
      number_ec2 += reservation.instances.length
    end
    number_ec2
  end

  def ec2_limit
    max_ec2 = ''
    resp = @ec2client.describe_account_attributes(
      attribute_names: ['max-instances']
    )
    resp.account_attributes.each do |element|
      max_ec2 = element.attribute_values.each.next.attribute_value
    end
    max_ec2.to_i
  end

  def number_elb
    elb = Aws::ElasticLoadBalancing::Client.new(region: @region, credentials: @credentials)
    elb.describe_load_balancers.load_balancer_descriptions.length
  end

  def events_ec2
    events = []

    instances_infos = @ec2client.describe_instance_status({
      include_all_instances: true,
      max_results: 500
    })

    instances_infos.instance_statuses.each do |instance|
      event = check_event(instance)
      events.push(event) unless event.eql?([])
    end
    events
  end

  def check_event(instance)
    event = []
    if instance['events'].any? && !(instance['events'][0]['description'].include? "[Completed]")
      event.push(
        [
          {
            'Node' => instance['instance_id'].to_s,
            'CheckID' => "#{instance['events'][0]['code']}",
            'Status' => 'critical'
          }
        ]
      )
    end
    event
  end

  def list_instances_id
    instances = []
    list_ec2 = @ec2client.describe_instances
    list_ec2.reservations.each do |reservation|
      reservation['instances'].each do |instance|
        instances.push(instance['instance_id'])
      end
    end
    instances
  end
end
