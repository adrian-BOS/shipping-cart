class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private

  def current_cart
    if session[:cart_id].present?
      @current_cart ||= Cart.find_by(id: session[:cart_id])
    end

    if @current_cart.nil?
      @current_cart = Cart.create!
      session[:cart_id] = @current_cart.id
    end

    @current_cart
  end

  def calculate_item_subtotal(cart_item)
    # Find which pricing rule applies to this item
    pricing_rules.each do |rule|
      if rule.send(:applicable_items, [ cart_item ]).any?
        return rule.apply([ cart_item ])
      end
    end

    # No rule applies, return original price
    cart_item.quantity * cart_item.product.price
  end

  def get_promotion_info(cart_item)
    pricing_rules.each do |rule|
      if rule.send(:applicable_items, [ cart_item ]).any?
        case rule
        when PricingRules::BuyOneGetOneRule
          if cart_item.quantity == 1
            return {
              type: "bogo",
              current: cart_item.quantity,
              needed: 1,
              message: "Buy 1 Get 1 Free! You get 1 free item",
              active: true
            }
          elsif cart_item.quantity >= 2
            free_items = cart_item.quantity / 2
            return {
              type: "bogo",
              current: cart_item.quantity,
              needed: 1,
              message: "Buy 1 Get 1 Free! You get #{ActionController::Base.helpers.pluralize(free_items, 'free item')}",
              active: true
            }
          end
        when PricingRules::BulkDiscountRule
          min_quantity = rule.options[:min_quantity]
          if cart_item.quantity < min_quantity
            return {
              type: "bulk",
              current: cart_item.quantity,
              needed: min_quantity,
              message: "Add #{min_quantity - cart_item.quantity} more for €#{rule.options[:discount_price]} each",
              active: false
            }
          else
            return {
              type: "bulk",
              current: cart_item.quantity,
              needed: min_quantity,
              message: "Bulk discount applied! €#{rule.options[:discount_price]} each",
              active: true
            }
          end
        when PricingRules::PercentageDiscountRule
          min_quantity = rule.options[:min_quantity]
          if cart_item.quantity < min_quantity
            return {
              type: "percentage",
              current: cart_item.quantity,
              needed: min_quantity,
              message: "Add #{min_quantity - cart_item.quantity} more for #{((1 - rule.options[:discount_percentage]) * 100).round}% off",
              active: false
            }
          else
            return {
              type: "percentage",
              current: cart_item.quantity,
              needed: min_quantity,
              message: "Percentage discount applied! #{((1 - rule.options[:discount_percentage]) * 100).round}% off",
              active: true
            }
          end
        end
      end
    end
    nil
  end

  def pricing_rules
    [
      PricingRules::BuyOneGetOneRule.new("GR1"), # Green Tea BOGO
      PricingRules::BulkDiscountRule.new("SR1", min_quantity: 3, discount_price: 4.50), # Strawberries bulk
      PricingRules::PercentageDiscountRule.new("CF1", min_quantity: 3, discount_percentage: 1.0/3) # Coffee discount
    ]
  end

  helper_method :current_cart, :calculate_item_subtotal, :get_promotion_info
end
