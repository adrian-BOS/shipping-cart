module PricingRules
  class BulkDiscountRule < BaseRule
    def apply(cart_items)
      items = applicable_items(cart_items)
      return 0 if items.empty?

      total_quantity = items.sum(&:quantity)
      min_quantity = options[:min_quantity]
      discount_price = options[:discount_price]

      if total_quantity >= min_quantity
        total_quantity * discount_price
      else
        total_quantity * items.first.product.price
      end
    end
  end
end
