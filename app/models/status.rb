class Status < ActiveRecord::Base
    attr_accessible :content, :user_id
    belongs_to :user #return actional user object who created status

    validates :content, presence: true, length: {minimum: 2}

    validates :user_id, presence: true
end



