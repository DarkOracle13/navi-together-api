# frozen_string_literal: true

require 'json'
require 'sequel'

module Cryal
  # Model for Location data
  class Plan < Sequel::Model
    many_to_one :room
    one_to_many :waypoints

    plugin :uuid, field: :plan_id
    plugin :timestamps, update_on_create: true

    # mass assignment prevention
    plugin :whitelist_security
    set_allowed_columns :plan_name, :plan_description

    # Secure getters and setters
    def plan_description
        SecureDB.decrypt(plan_description_secure)
      end
  
    def plan_description=(plaintext)
        self.plan_description_secure = SecureDB.encrypt(plaintext)
    end

    def to_json(*args)
      {
        plan_id: plan_id,
        plan_name: plan_name,
        plan_description: description,
        created_at: created_at,
        updated_at: updated_at
      }.to_json(*args)
    end

  end
end