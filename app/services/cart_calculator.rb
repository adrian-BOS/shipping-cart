class CartCalculator
  attr_reader :cart

  def initialize(cart)
    @cart = cart
  end

  def calculate
    return 0 if cart.cart_items.empty?

    total = 0
    processed_items = []

    pricing_rules.each do |rule|
      rule_total = rule.apply(cart.cart_items)
      total += rule_total
      processed_items.concat(rule.send(:applicable_items, cart.cart_items))
    end

    # Add items not covered by any rule
    unprocessed_items = cart.cart_items - processed_items
    unprocessed_items.each do |item|
      total += item.quantity * item.product.price
    end

    total.round(2)
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
