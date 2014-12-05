class Talk < Presenter
  @@list_of_talks = Array.new
  @@tracks = Array.new
  @@total_talk_duration = 0
  
  FIRST_HALF_SLOT_AVAIL_MINUTES = 180
  SECOND_HALF_SLOT_AVAIL_MINUTES = 240
  LIGHTNING_MINUTES = 5
  LUNCH_TIME_DURATION = 60
  TALKS_START_TIME = (9*60)
  
  attr_accessor :title, :duration, :time_slot

  def self.set_list_of_talks
    self.new("Amit","amit.a@gl.com","Writing Fast Tests Against Enterprise Rails",60)
    self.new("Amit","amit.a@gl.com","Overdoing it in Python",45)
    self.new("Amit","amit.a@gl.com","Lua for the Masses",30)
    self.new("Amit","amit.a@gl.com","Ruby Errors from Mismatched Gem Versions",45)
    self.new("Amit","amit.a@gl.com","Common Ruby Errors",45)
    self.new("Amit","amit.a@gl.com","Rails for Python Developers","lightning")
    self.new("Amit","amit.a@gl.com","Communicating Over Distance",60)
    self.new("Amit","amit.a@gl.com","Accounting-Driven Development",45)
    self.new("Amit","amit.a@gl.com","Woah",30)
    self.new("Amit","amit.a@gl.com","Sit Down and Write",30)
    self.new("Amit","amit.a@gl.com","Pair Programming vs Noise",45)
    self.new("Amit","amit.a@gl.com","Rails Magic",60)
    self.new("Amit","amit.a@gl.com","Ruby on Rails: Why We Should Move On",60)
    self.new("Amit","amit.a@gl.com","Clojure Ate Scala (on my project)",45)
    self.new("Amit","amit.a@gl.com","Programming in the Boondocks of Seattle",30)
    self.new("Amit","amit.a@gl.com","Ruby vs. Clojure for Back-End Development",30)
    self.new("Amit","amit.a@gl.com","Ruby on Rails Legacy App Maintenance",60)
    self.new("Amit","amit.a@gl.com","A World Without HackerNews",30)
    self.new("Amit","amit.a@gl.com","User Interface CSS in Rails Apps",30)

    puts "List of Talks inititated successfuly."
  end

  def initialize(name,email,title,duration,time_slot=0)
  	@name = name
  	@email = email
  	@title = title
  	@time_slot = time_slot
  	
    duration = LIGHTNING_MINUTES if (duration === "lightning")

    if duration <= SECOND_HALF_SLOT_AVAIL_MINUTES  
      @duration = duration
    else
      puts "Sorry! Given Talk '#{@title}' duration can not be exceed more than 240 minutes. Please change the duration to schedule this talk."
      return false
    end

    @@total_talk_duration = @@total_talk_duration + @duration.to_i
  	@@list_of_talks << self
  end

  def self.get_all_talks
    @@list_of_talks
  end

  def self.get_all_talks_by_duration
  	@@list_of_talks.group_by { |o| o.duration }.sort_by {|_key, value| _key}.reverse
  end

  def self.set_number_of_tracks
    total_avail_minutes = FIRST_HALF_SLOT_AVAIL_MINUTES+SECOND_HALF_SLOT_AVAIL_MINUTES
  	number_of_tracks = @@total_talk_duration.fdiv(total_avail_minutes).ceil

  	number_of_tracks.times do |n|
  		@@tracks << Track.new(FIRST_HALF_SLOT_AVAIL_MINUTES,SECOND_HALF_SLOT_AVAIL_MINUTES,LUNCH_TIME_DURATION) 	
  	end

  	number_of_tracks
  end

  def self.get_next_track(trackNumber,number_of_tracks)
  	if trackNumber < (number_of_tracks-1) 
  		trackNumber = trackNumber + 1
  	else
  		trackNumber = 0
  	end

  	trackNumber
  end

  def self.print_all_tracks
    final_list_of_talks_on_tracks = Array.new()

    final_list_of_talks_on_tracks << "\nTalks in All Tracks are: \n"

    @@tracks.each_with_index do |track,index|
      final_list_of_talks_on_tracks << "\nTrack #{index+1}"
      
      track.first_half["talks"].each do |talk|
        final_list_of_talks_on_tracks << "#{talk.time_slot} #{talk.title}"
      end

      final_list_of_talks_on_tracks << "12:00 PM Lunch Time"

      track.second_half["talks"].each do |talk|
        final_list_of_talks_on_tracks << "#{talk.time_slot} #{talk.title}"
      end

      if(track.total_talk_time_on_track > (FIRST_HALF_SLOT_AVAIL_MINUTES+SECOND_HALF_SLOT_AVAIL_MINUTES))
        final_list_of_talks_on_tracks << "05:00 PM Networking Event"
      else
        final_list_of_talks_on_tracks << "04:00 PM Networking Event"
      end
    end

    final_list_of_talks_on_tracks
  end

  def self.get_all_talks_in_tracks
    set_list_of_talks
  	list_talk_by_duration = get_all_talks_by_duration
  	trackNumber = 0
  	number_of_tracks = set_number_of_tracks

  	list_talk_by_duration.each do |index,value|
  		value.each do |value|
        total_avail_minutes_with_lunch = FIRST_HALF_SLOT_AVAIL_MINUTES+SECOND_HALF_SLOT_AVAIL_MINUTES+LUNCH_TIME_DURATION

				if (@@tracks[trackNumber].total_talk_time_on_track + value.duration) > (total_avail_minutes_with_lunch)
					trackNumber = get_next_track(trackNumber,number_of_tracks)
				end

        if (value.duration <= @@tracks[trackNumber].first_half["balance_duration"])          
          first_half_talk_timestamp = (@@tracks[trackNumber].first_half["blocked_duration"]+TALKS_START_TIME)*60
          value.time_slot = Time.at(first_half_talk_timestamp).utc.strftime("%I:%M %p")
          
          @@tracks[trackNumber].first_half["talks"] << value
          @@tracks[trackNumber].first_half["balance_duration"] = @@tracks[trackNumber].first_half["balance_duration"] - value.duration
          @@tracks[trackNumber].total_talk_time_on_track = @@tracks[trackNumber].total_talk_time_on_track + value.duration
          @@tracks[trackNumber].first_half["blocked_duration"] = @@tracks[trackNumber].first_half["blocked_duration"] + value.duration

        elsif (value.duration <= @@tracks[trackNumber].second_half["balance_duration"])
          second_half_talk_timestamp = (@@tracks[trackNumber].second_half["blocked_duration"]+TALKS_START_TIME+FIRST_HALF_SLOT_AVAIL_MINUTES+LUNCH_TIME_DURATION)*60
          value.time_slot = Time.at(second_half_talk_timestamp).utc.strftime("%I:%M %p")

          @@tracks[trackNumber].second_half["talks"] << value
          @@tracks[trackNumber].second_half["balance_duration"] = @@tracks[trackNumber].second_half["balance_duration"] - value.duration
          @@tracks[trackNumber].total_talk_time_on_track = @@tracks[trackNumber].total_talk_time_on_track + value.duration
          @@tracks[trackNumber].second_half["blocked_duration"] = @@tracks[trackNumber].second_half["blocked_duration"] + value.duration
        end

				trackNumber = get_next_track(trackNumber,number_of_tracks)
  		end
  	end

    puts print_all_tracks
  end
end
