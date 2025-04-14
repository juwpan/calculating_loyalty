class CashbackCalculate
  attr_reader :user, :positions, :discount, :db

  def initialize(user, positions, discount, db)
    @db = db
    @user = user
    @discount = discount
    @positions = positions
  end

  def cashback_percent
    base = case loyalty_level
          when 1 then template[:cashback]
          when 2 then template[:cashback]
          when 3 then template[:cashback]
          else 0
          end
  
    extra = positions.sum do |p|
      p[:type] == 'increased_cashback' ? p[:value].to_f : 0
    end

    (base + extra).round(2)
  end

  def cashback_value
    loyalty_sum = positions.sum do |p|
      if p[:type] != 'noloyalty'
        (p[:price] * p[:quantity]) - p[:discount_summ]
      else
        0
      end
    end
  
    (loyalty_sum * cashback_percent / 100.0).round(2)
  end

  def allowed_write_off
    [total_loyalty_sum, user[:bonus].to_f].min.round(2)
  end

  private

  def loyalty_level
    @loyalty_level = user[:template_id] # 1 - Bronze, 2 - Silver, 3 - Gold
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

  def template
    @template = db[:templates].where(id: user[:template_id]).first
  end
end
