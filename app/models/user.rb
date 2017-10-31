class User < ActiveRecord::Base
  attr_accessible :name, :groups
  has_many :maps
  has_and_belongs_to_many :groups

  def crypted_name
    name.crypt(created_at.to_s)
  end

  class << self
    def rank1
      joins("LEFT JOIN groups_users ON user_id = users.id LEFT JOIN groups ON group_id = groups.id").
      # Concat group_names to avoid nil, we expect always a string
      # Another option is return a postgres array and convert it to a ruby array, but in this case is easier to handle it as a string.
      select("users.name, users.created_at, count(groups.*) AS group_count, concat(string_agg(groups.name, ',')) AS group_names").
      group("users.name, users.created_at").
      order("group_count asc")
    end

    def rank2
      joins(:maps).
      joins(:groups).
      select("groups.name as group_name, users.name, sum(maps.mapviews) as mapviews").
      group("users.id, groups.id").
      order("group_name asc, mapviews desc")
    end

    def rank3
      joins(:groups).
      joins(:maps).
      select("groups.name as group_name, users.name, SUM(maps.mapviews) as mapviews").
      # We could format the `percent` with SQL but I prefer the number with decimals and format it in the view.
      # select("concat(round(SUM(maps.mapviews)/SUM(SUM(maps.mapviews)) OVER(PARTITION BY groups.id) * 100, 2), '%') as percent").
      select("SUM(maps.mapviews)/SUM(SUM(maps.mapviews)) OVER(PARTITION BY groups.id) * 100 as percent").
      group("users.id, groups.id").
      order("group_name asc, mapviews desc")
    end
  end
end
