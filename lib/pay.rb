require "pay/version"
require "pay/engine"
require "pay/errors"
require "pay/adapter"

module Pay
  autoload :Attributes, "pay/attributes"
  autoload :Env, "pay/env"
  autoload :NanoId, "pay/nano_id"
  autoload :Payment, "pay/payment"
  autoload :Receipts, "pay/receipts"
  autoload :Currency, "pay/currency"

  # Payment processors
  autoload :Braintree, "pay/braintree"
  autoload :FakeProcessor, "pay/fake_processor"
  autoload :Paddle, "pay/paddle"
  autoload :Stripe, "pay/stripe"

  autoload :Webhooks, "pay/webhooks"

  module Billable
    autoload :SyncCustomer, "pay/billable/sync_customer"
  end

  mattr_accessor :braintree_gateway

  mattr_accessor :model_parent_class
  @@model_parent_class = "ApplicationRecord"

  # Business details for receipts
  mattr_accessor :application_name
  mattr_accessor :business_address
  mattr_accessor :business_name
  mattr_accessor :business_logo
  mattr_accessor :support_email

  mattr_accessor :automount_routes
  @@automount_routes = true

  mattr_accessor :default_product_name
  @@default_product_name = "default"

  mattr_accessor :default_plan_name
  @@default_plan_name = "default"

  mattr_accessor :routes_path
  @@routes_path = "/pay"

  mattr_accessor :enabled_processors
  @@enabled_processors = [:stripe, :braintree, :paddle]

  mattr_accessor :emails
  @@emails = ActiveSupport::OrderedOptions.new
  @@emails.payment_action_required = true
  @@emails.receipt = true
  @@emails.refund = true
  # This only applies to Stripe, therefor we supply the second argument of price
  @@emails.subscription_renewing = ->(pay_subscription, price) {
    (price&.type == "recurring") && (price.recurring&.interval == "year")
  }

  def self.setup
    yield self
  end

  def self.send_email?(email_option, *remaining_args)
    config_option = emails.send(email_option)

    if config_option.respond_to?(:call)
      config_option.call(*remaining_args)
    else
      config_option
    end
  end
end
