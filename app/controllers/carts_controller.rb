class CartsController < ApplicationController
  def show
    @cart = current_cart
    @products = Product.all
  end

  def add_item
    begin
      current_cart.add_product(params[:product_code])
      render json: {
        success: true,
        cart: cart_data,
        message: "Item added to cart"
      }
    rescue ActiveRecord::RecordNotFound
      render json: {
        success: false,
        message: "Product not found"
      }, status: 404
    rescue => e
      render json: {
        success: false,
        message: e.message
      }, status: 422
    end
  end

  def clear
    current_cart.cart_items.destroy_all
    render json: {
      success: true,
      cart: cart_data,
      message: "Cart cleared"
    }
  end

  private

  def cart_data
    {
      items: current_cart.cart_items.includes(:product).map do |item|
        original_subtotal = item.quantity * item.product.price
        discounted_subtotal = calculate_item_subtotal(item)
        promotion_info = get_promotion_info(item)

        {
          id: item.id,
          product_name: item.product.name,
          product_code: item.product.code,
          quantity: item.quantity,
          unit_price: item.product.price.to_f,
          original_subtotal: original_subtotal.to_f,
          discounted_subtotal: discounted_subtotal.to_f,
          has_discount: original_subtotal != discounted_subtotal,
          promotion_info: promotion_info
        }
      end,
      total_price: current_cart.total_price.to_f,
      item_count: current_cart.item_count
    }
  end
end
