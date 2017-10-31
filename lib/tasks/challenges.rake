namespace :challenges do
  task first: :environment do
    users = User.
      joins("LEFT JOIN groups_users ON user_id = users.id LEFT JOIN groups ON group_id = groups.id").
      select("users.name, users.created_at, count(groups.*) AS group_count, concat(string_agg(groups.name, ',')) AS group_names").
      group("users.name, users.created_at").
      order("group_count asc")

    users.each do |user|
      puts [user.name, user.crypted_name, user.group_count, user.group_names.split(",").to_s].join(" - ")
    end
  end

  task second: :environment do
    users = User.
      joins(:maps).
      joins(:groups).
      select("groups.name as group_name, users.name, sum(maps.mapviews) as mapviews").
      group("users.id, groups.id").
      order("group_name asc, mapviews desc")

    users.each do |user|
      puts [user.mapviews, user.group_name, user.name].join(" - ")
    end
  end

  task third: :environment do
    users = User.
      joins(:groups).
      joins(:maps).
      select("groups.name as group_name, users.name, SUM(maps.mapviews) as mapviews").
      # select("concat(round(SUM(maps.mapviews)/SUM(SUM(maps.mapviews)) OVER(PARTITION BY groups.id) * 100, 2), '%') as percent").
      select("SUM(maps.mapviews)/SUM(SUM(maps.mapviews)) OVER(PARTITION BY groups.id) * 100 as percent").
      group("users.id, groups.id").
      order("group_name asc, mapviews desc")

    users.each do |user|
      puts [user.mapviews, user.percent, user.group_name, user.name].join(" - ")
    end
  end
end
