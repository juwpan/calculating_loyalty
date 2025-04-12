class OperationCalculate
  attr_reader :payload, :db

  def initialize(payload, db)
    @payload = payload
    @db = db
  end

  def call
    response_for_user
  end

  private

  def get_user
    @get_user = db[:users].where(id: payload[:user_id]).first
  end

  def loyalty_level
    get_user[:template_id] # 1 - Bronze, 2 - Silver, 3 - Gold
  end

  def get_positions_products
    payload[:positions]
  end

  def positions
    products = db[:products]

    @positions ||= get_positions_products.map do |p|
      product = products.where(id: p[:id]).first
      {
        id: p[:id],
        price: p[:price],
        quantity: p[:quantity],
        type: product&.dig(:type),
        value: product&.dig(:value),
        type_desc: check_type_desc(product),
        discount_percent: discount_percent_product(product),
        discount_summ: discount_sum(product, p[:price], p[:quantity])
      }
    end
  end

  def discount_percent_product(product)
    return 0.0 if product.nil? || product[:type] != 'discount'
    product[:value].to_f
  end

  def discount_sum(product, price, quantity)
    percent = discount_percent_product(product)
    ((price * quantity) * percent / 100.0).round(2)
  end

  def check_type_desc(product)
    return nil if product.nil?

    case product[:type]
    when 'discount' then "Дополнительная скидка #{product[:value]}%"
    when 'increased_cashback' then "Дополнительный кэшбек #{product[:value]}%"
    when 'noloyalty' then "Не участвует в системе лояльности"
    else nil
    end
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

  def total_loyalty_sum
    total_sum = positions.inject(0) do |memo, position|
      if position[:type] != 'noloyalty'
        memo += position[:price] * position[:quantity] - position[:discount_summ]
      end
      memo
    end

    total_sum.round(2)
  end

  def allowed_write_off
    [total_loyalty_sum, get_user[:bonus].to_f].min.round(2)
  end

  def template
    @template ||= db[:templates].where(id: loyalty_level).first
  end

  def cashback_percent
    base = case loyalty_level
           when 1 then 5
           when 2 then 5
           when 3 then 0
           else 0
           end
  
    extra = positions.sum do |p|
      p[:type] == 'increased_cashback' ? p[:value].to_f : 0
    end
  
    (base + extra).round(2)
  end

  def cashback_value
    @cashback_value = (total_with_discount * cashback_percent / 100.0).round(2)
  end

  def discount_percent
    return 0.0 if total_without_discount == 0
    @discount_percent = ((total_discount / total_without_discount) * 100).round(2)
  end

  def response_for_user
    user = get_user
    op_id = create_operation(user)
  
    build_response(user, op_id)
  end
  
  def create_operation(user)
    db.transaction do
      db[:operations].insert(
        user_id: user[:id],
        cashback: cashback_value,
        cashback_percent: cashback_percent,
        discount: total_discount,
        discount_percent: discount_percent,
        write_off: 0,
        check_summ: total_with_discount,
        done: false,
        allowed_write_off: allowed_write_off
      )
    end
  end
  
  def build_response(user, op_id)
    {
      status: 200,
      user: {
        id: user[:id],
        template_id: user[:template_id],
        name: user[:name],
        bonus: user[:bonus].to_f.round(2)
      },
      operation_id: op_id,
      summ: total_with_discount,
      positions: positions,
      discount: {
        summ: total_discount,
        value: "#{discount_percent}%"
      },
      cashback: {
        existed_summ: user[:bonus].to_f.round(2),
        allowed_summ: allowed_write_off,
        value: "#{cashback_percent}%",
        will_add: cashback_value
      }
    }
  end
end
