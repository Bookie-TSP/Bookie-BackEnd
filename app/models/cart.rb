class Cart < ActiveRecord::Base
  belongs_to :member, dependent: :destroy
end
