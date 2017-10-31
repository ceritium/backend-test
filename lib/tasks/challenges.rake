namespace :challenges do
  task rank1: :environment do
    User.rank1.each do |user|
      puts [user.name, user.crypted_name, user.group_count, user.group_names.split(",").to_s].join(" - ")
    end
  end

  task rank2: :environment do
    User.rank2.each do |user|
      puts [user.mapviews, user.group_name, user.name].join(" - ")
    end
  end

  task rank3: :environment do
    User.rank3.each do |user|
      percent = "#{format('%.2f', user.percent.to_f)}%"
      puts [user.mapviews, percent, user.group_name, user.name].join(" - ")
    end
  end
end
