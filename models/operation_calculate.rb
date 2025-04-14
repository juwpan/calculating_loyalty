class OperationCalculate
  attr_reader :payload, :db

  def initialize(payload, db)
    @payload = payload
    @db = db
  end

  def call
    user = user_repo.find(payload[:user_id])
    positions = position_builder.positions
    discount = DiscountCalculate.new(positions: positions)
    cashback = CashbackCalculate.new(user, positions, discount, db)
    operation_id = operation(db, user, cashback, discount, positions).create_operation

    response(user, positions, discount, cashback, operation_id).build_response
  end

  private

  def user_repo
    @user_repo ||= UserDataService.new(db)
  end

  def position_builder
    @position_builder ||= ProductPositionBuilder.new(db, payload)
  end

  def response(user, positions, discount, cashback, operation_id)
    OperationDetailsBuilder.new(
      user: user,
      positions: positions,
      discount: discount,
      cashback: cashback,
      operation_id: operation_id
    )
  end

  def operation(db, user, cashback, discount, positions)
    OperationCreator.new(
      db: db,
      user: user,
      cashback: cashback,
      discount: discount,
      positions: positions
    )
  end
end
