require 'eventmachine'

EventMachine.run do
  puts "Starting EventMachine at #{Time.now}"

  finished_events = []

  EM.add_timer(2) do
    puts 'I waited 2 seconds to run'

    finished_events << true

    if finished_events.length == 2
      puts "Stopping EventMachine at #{Time.now}"
      EM.stop
    end
  end

  EM.add_timer(4) do
    puts 'I waited 4 seconds to run'

    finished_events << true

    if finished_events.length == 2
      puts "Stopping EventMachine at #{Time.now}"
      EM.stop
    end
  end

  puts 'I waited 0 seconds to run'
end
