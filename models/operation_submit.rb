class OperationSubmit
  attr_reader :payload, :db

  def initialize(payload, db)
    @payload = payload
    @db = db
  end

  def call
    current_operation = OperationUpdate.new(db, payload)
    return { status: 200, message: "Операция уже завершена." } if current_operation.operation[:done]

    operation = current_operation.update_operation
    user = user_repo.find(payload[:user][:id])

    build_response(OperationConfirm.new(user, operation, payload[:write_off]))
  end
  
  private

  def user_repo
    @user_repo ||= UserDataService.new(db)
  end

  def build_response(response_builder)
    response_builder.build_response_confirm
  end
end
