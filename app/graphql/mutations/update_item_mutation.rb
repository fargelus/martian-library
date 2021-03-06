# frozen_string_literal: true

module Mutations
  class UpdateItemMutation < Mutations::BaseMutation
    argument :id, ID, required: true
    argument :attributes, Types::ItemAttributes, required: true

    field :item, Types::ItemType, null: true
    field :errors, [String], null: true

    def resolve(id:, attributes:)
      check_authentication!

      item = Item.find(id)
      attributes = attributes.to_h.delete_if { |*, v| v.empty? }

      if item.update(attributes)
        MartianLibrarySchema.subscriptions.trigger('itemUpdated', {}, item)
        { item: item }
      else
        { errors: item.errors.full_messages }
      end
    end
  end
end
