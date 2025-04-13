class DiscountCalculate
  attr_reader :price, :quantity, :product, :positions
  
  def initialize(price: nil, quantity: nil, product: nil, positions: nil)
    if positions
      @positions = positions
    else
      @price = price
      @quantity = quantity
      @product = product
    end
  end

  def discount_percent_product
    return 0.0 if product.nil? || product[:type] != 'discount'
    product[:value].to_f
  end

  def discount_sum
    percent = discount_percent_product
    ((price * quantity) * percent / 100.0).round(2)
  end

  def discount_percent
    return 0.0 if total_without_discount == 0
    @discount_percent = ((total_discount / total_without_discount) * 100).round(2)
  end

  def total_discount
    positions.sum { |p| p[:discount_summ] }.round(2)
  end

  def total_without_discount
    positions.sum { |p| p[:price] * p[:quantity] }.round(2)
  end

  def total_with_discount
    (total_without_discount - total_discount).round(2)
  end
end
