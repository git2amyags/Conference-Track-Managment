class Track
	attr_accessor :talks, :total_talk_time_on_track, :first_half, :second_half

	def initialize(first_half_avail_minutes,second_half_avail_minutes,initial_talk_time_duration)
		@first_half = {"blocked_duration"=>0,"balance_duration"=>first_half_avail_minutes,"talks"=>Array.new}
		@second_half = {"blocked_duration"=>0,"balance_duration"=>second_half_avail_minutes,"talks"=>Array.new}
		@total_talk_time_on_track = initial_talk_time_duration
	end
end