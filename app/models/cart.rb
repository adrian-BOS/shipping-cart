class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  def add_product(product_code)
    product = Product.find_by_code!(product_code)
    cart_item = cart_items.find_by(product: product)

    if cart_item
      cart_item.increment!(:quantity)
    else
      cart_items.create!(product: product, quantity: 1)
    end
  end

  def total_price
    return 0 if cart_items.empty?

    total = 0
    remaining_items = cart_items.to_a

    pricing_rules.each do |rule|
      applicable_items = rule.send(:applicable_items, remaining_items)
      next if applicable_items.empty?

      # Calculate price for items that match this rule
      rule_total = rule.apply(applicable_items)
      total += rule_total

      # Remove processed items from remaining items
      applicable_items.each do |item|
        remaining_items.delete(item)
      end
    end

    # Add remaining items at full price
    remaining_items.each do |item|
      total += item.quantity * item.product.price
    end

    total.round(2)
  end

  def item_count
    cart_items.sum(:quantity)
  end

  private

  def pricing_rules
    [
      PricingRules::BuyOneGetOneRule.new("GR1"), # Green Tea BOGO
      PricingRules::BulkDiscountRule.new("SR1", min_quantity: 3, discount_price: 4.50), # Strawberries bulk
      PricingRules::PercentageDiscountRule.new("CF1", min_quantity: 3, discount_percentage: 1.0/3) # Coffee discount
    ]
  end
end
