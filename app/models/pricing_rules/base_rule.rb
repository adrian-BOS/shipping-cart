module PricingRules
  class BaseRule
    attr_reader :product_code, :options

    def initialize(product_code, options = {})
      @product_code = product_code
      @options = options
    end

    def apply(cart_items)
      raise NotImplementedError, "Subclasses must implement #apply"
    end

    protected

    def applicable_items(cart_items)
      cart_items.select { |item| item.product.code == product_code }
    end
  end
end
