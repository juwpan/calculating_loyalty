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
    cashback = CashbackCalculate.new(user, positions, discount)
    operation_id = OperationCreate.new(db, user, cashback, discount, positions).create_operation

    OperationResponseBuilder.new(
      user: user,
      positions: positions,
      discount: discount,
      cashback: cashback,
      operation_id: operation_id
    ).build_response
  end

  def user_repo
    @user_repo ||= UserRepository.new(db)
  end

  def position_builder
    @position_builder ||= PositionBuilder.new(db, payload)
  end
end
