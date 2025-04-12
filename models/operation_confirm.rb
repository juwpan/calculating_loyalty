class OperationConfirm
  attr_reader :payload, :db

  def initialize(payload, db)
    @payload = payload
    @db = db
  end

  def call
    return { status: 200, message: "Operation already completed" } if operation[:done]

    update_operation
    response_for_user
  end

  private

  def update_operation
    db.transaction do
      db[:operations].where(id: operation[:id]).update(
        write_off: write_off,
        check_summ: new_total_summ,
        cashback: new_cashback,
        done: true
      )
    end
  end

  def get_user
    @get_user = db[:users].where(id: payload[:user][:id]).first
  end

  def operation
    @operation = db[:operations].where(id: payload[:operation_id]).first
  end

  def system_message
    "The operation is completed"
  end

  def total_summ
    @total_summ = operation[:check_summ]
  end

  def write_off
    @write_off = payload[:write_off]
  end

  def new_total_summ
    @new_total_summ = (total_summ - write_off).to_f.round(2)
  end

  def discount
    @discount = operation[:discount].to_f.round(2)
  end

  def discount_percent
    @discount_percent = operation[:discount_percent].to_f.round(2)
  end

  def cashback_percent
    @cashback_percent = operation[:cashback_percent].to_f.round(2)
  end

  def new_cashback
    @new_cashback = (new_total_summ * (cashback_percent / 100)).round(2)
  end

  def allowed_write_off
    @allowed_write_off = operation[:allowed_write_off].to_f.round(2)
  end

  def response_for_user
    {
      status: 200,
      system_message: system_message,
      operation: {
        user_id: get_user[:id],
        cashback: new_cashback,
        cashback_percent: cashback_percent,
        discount: discount,
        discount_percent: discount_percent,
        write_off: write_off,
        check_summ: new_total_summ,
        done: true,
        allowed_write_off: allowed_write_off
      }
    }
  end
end
