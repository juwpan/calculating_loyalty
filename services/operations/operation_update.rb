class OperationUpdate
  attr_reader :db, :payload

  def initialize(db, payload)
    @db = db
    @payload = payload
  end

  def update_operation
    db.transaction do
      db[:operations].where(id: operation[:id]).update(
        write_off: write_off,
        check_summ: new_total_summ,
        cashback: new_cashback,
        done: true
      )
    end
    operation
  end

  def write_off
    payload[:write_off]
  end

  def new_total_summ
    (total_summ - write_off).to_f.round(2)
  end

  def new_cashback
    (new_total_summ * (cashback_percent / 100)).round(2)
  end

  def cashback_percent
    operation[:cashback_percent].to_f.round(2)
  end

  def total_summ
    operation[:check_summ]
  end

  def operation
    @operation ||= find_operation
  end

  private

  def find_operation
    db[:operations].where(id: payload[:operation_id]).first
  end
end
