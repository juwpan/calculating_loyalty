class OperationCreate
  attr_reader :db, :user, :cashback, :discount, :positions

  def initialize(db: , user: , cashback: , discount: , positions: )
    @db = db
    @user = user
    @cashback = cashback
    @discount = discount
    @positions = positions
  end

  def create_operation
    db.transaction do
      db[:operations].insert(
        user_id: user[:id],
        cashback: cashback.cashback_value,
        cashback_percent: cashback.cashback_percent,
        discount: discount.total_discount,
        discount_percent: discount.discount_percent,
        write_off: 0,
        check_summ: discount.total_with_discount,
        done: false,
        allowed_write_off: cashback.allowed_write_off
      )
    end
  end
end
