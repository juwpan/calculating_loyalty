class UserDataService
  attr_reader :db

  def initialize(db)
    @db = db
  end

  def find(user_id)
    db[:users].where(id: user_id).first
  end
end
