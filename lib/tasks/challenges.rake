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
      joins("LEFT JOIN groups_users ON groups_users.user_id = users.id RIGHT JOIN groups ON group_id = groups.id").
      select("groups.name as group_name, users.name, sum(maps.mapviews) as mapviews").
      group("users.id, groups.id").
      order("group_name asc, mapviews desc")

    users.each do |user|
      puts [user.mapviews, user.group_name, user.name].join(" - ")
    end
  end

  task third: :environment do
    sql = <<-SQL
      SELECT groups.name as group_name, 
              users.name, 
              sum(maps.mapviews) as umapviews, 
              g_maps.mapviews as gmapviews, 
              round((sum(maps.mapviews) * 100.0) / g_maps.mapviews, 2) as percent 
      FROM "users" 
      RIGHT JOIN maps ON users.id = maps.user_id 
      LEFT JOIN groups_users ON groups_users.user_id = users.id 
      RIGHT JOIN groups ON groups.id = group_id 
      LEFT JOIN (
        SELECT sum(maps.mapviews) as mapviews, 
               groups.name, 
               groups.id 
        FROM groups
        LEFT join groups_users on groups_users.group_id = groups.id 
        LEFT join maps on maps.user_id = groups_users.user_id 
        GROUP BY groups.id
      ) as g_maps ON g_maps.id = groups.id 
      GROUP BY users.id, groups.id, gmapviews 
      ORDER BY group_name asc, umapviews desc
    SQL

    users = User.find_by_sql(sql)

    users.each do |user|
      puts [user.umapviews, "#{user.percent}%", user.group_name, user.name].join(" - ")
    end
  end
end
