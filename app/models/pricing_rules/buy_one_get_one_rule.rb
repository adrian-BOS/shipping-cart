module PricingRules
  class BuyOneGetOneRule < BaseRule
    def apply(cart_items)
      items = applicable_items(cart_items)
      return 0 if items.empty?

      total_quantity = items.sum(&:quantity)
      # For BOGO: every 2 items, you pay for 1
      # If you have 1 item, you get 1 free (total 2 items for price of 1)
      # If you have 2 items, you pay for 1 (total 2 items for price of 1)
      # If you have 3 items, you pay for 2 (total 3 items for price of 2)
      paid_quantity = (total_quantity + 1) / 2
      price_per_item = items.first.product.price

      paid_quantity * price_per_item
    end
  end
end
