class OperationConfirm
  attr_reader :operation, :user, :write_off_from_payload

  def initialize(user, operation, write_off_from_payload)
    @user = user
    @operation = operation
    @write_off_from_payload = write_off_from_payload
  end

  def build_response_confirm
    {
      status: 200,
      system_message: system_message,
      operation: {
        user_id: user[:id],
        cashback: format_value(operation[:cashback]),
        cashback_percent: format_value(operation[:cashback_percent]),
        discount: discount,
        discount_percent: discount_percent,
        write_off: format_value(write_off_from_payload),
        check_summ: format_value(operation[:check_summ]),
        done: true,
        allowed_write_off: allowed_write_off
      }
    }
  end

  private

  def discount
    @discount = operation[:discount].to_f.round(2)
  end

  def discount_percent
    @discount_percent = operation[:discount_percent].to_f.round(2)
  end

  def allowed_write_off
    @allowed_write_off = operation[:allowed_write_off].to_f.round(2)
  end

  def system_message
    "Операция завершена успешно"
  end

  def format_value(value)
    value.is_a?(Numeric) ? value.to_f.round(2) : value
  end
end
