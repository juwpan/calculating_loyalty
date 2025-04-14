class OperationDetailsBuilder
  attr_reader :user, :operation_id, :positions, :discount, :cashback

  def initialize(user: ,  positions: , discount: , cashback: , operation_id: )
    @user = user
    @operation_id = operation_id
    @positions = positions
    @discount = discount
    @cashback = cashback
  end

  def build_response
    {
      status: 200,
      user: {
        id: user[:id],
        template_id: user[:template_id],
        name: user[:name],
        bonus: user[:bonus].to_f.round(2)
      },
      operation_id: operation_id,
      summ: discount.total_with_discount,
      positions: positions,
      discount: {
        summ: discount.total_discount,
        value: "#{discount.discount_percent}%"
      },
      cashback: {
        existed_summ: user[:bonus].to_f.round(2),
        allowed_summ: cashback.allowed_write_off,
        value: "#{cashback.cashback_percent}%",
        will_add: cashback.cashback_value
      }
    }
  end
end
