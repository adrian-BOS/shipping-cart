module PricingRules
  class PercentageDiscountRule < BaseRule
    def apply(cart_items)
      items = applicable_items(cart_items)
      return 0 if items.empty?

      total_quantity = items.sum(&:quantity)
      min_quantity = options[:min_quantity]
      discount_percentage = options[:discount_percentage]

      original_price = total_quantity * items.first.product.price

      if total_quantity >= min_quantity
        original_price * discount_percentage
      else
        original_price
      end
    end
  end
end
