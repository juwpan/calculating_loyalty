class PositionBuilder
  attr_reader :db, :payload

  def initialize(db, payload)
    @db = db
    @payload = payload
  end

  def positions
    products = db[:products]

    @positions ||= get_positions_products.map do |p|
      product = products.where(id: p[:id]).first
      discount_calc = DiscountCalculate.new(price: p[:price], quantity: p[:quantity], product: product)
      
      {
        id: p[:id],
        price: p[:price],
        quantity: p[:quantity],
        type: product&.dig(:type),
        value: product&.dig(:value),
        type_desc: check_type_desc(product),
        discount_percent: discount_calc.discount_percent_product,
        discount_summ: discount_calc.discount_sum
      }
    end
  end

  private

  def check_type_desc(product)
    return nil if product.nil?

    case product[:type]
    when 'discount' then "Дополнительная скидка #{product[:value]}%"
    when 'increased_cashback' then "Дополнительный кэшбек #{product[:value]}%"
    when 'noloyalty' then "Не участвует в системе лояльности"
    else nil
    end
  end

  def get_positions_products
    @get_positions_products = payload[:positions]
  end
end
