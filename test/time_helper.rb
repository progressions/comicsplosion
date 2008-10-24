
  def weeks_ago num
    num.weeks.ago.to_s(:db)
  end
  
  def days_ago num
    num.days.ago.to_s(:db)
  end
    
  def tomorrow
    1.day.from_now.to_s(:db)
  end
  
  def today
    Time.now.to_s(:db)
  end
  
  def yesterday
    1.day.ago.to_s(:db)
  end
