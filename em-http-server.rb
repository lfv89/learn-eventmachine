require 'byebug'
require 'rubygems'
require 'eventmachine'
require 'evma_httpserver'

class Foo
  include EM::Deferrable
end

class Bar
  include EM::Deferrable
end

class Handler < EventMachine::Connection
  include EventMachine::HttpServer

  def process_http_request
    @foo, @bar = @processes = [Foo.new, Bar.new]

    foo_process
    bar_process

    @foo.callback do
      puts 'Foo process is done'
    end

    @bar.callback do
      puts 'Bar process is done'
    end

    EM::PeriodicTimer.new(1) do
      send_response if all_processes_succeeded?
    end
  end

  private

  def foo_process
    EM::Timer.new(2) do
      @foo.set_deferred_status(:succeeded)
    end
  end

  def bar_process
    EM::Timer.new(2) do
      @bar.set_deferred_status(:succeeded)
    end
  end

  def all_processes_succeeded?
    @processes.all? { |deferred| deferred.instance_variable_get(:@deferred_status) == :succeeded }
  end

  def response
    @response ||= EventMachine::DelegatedHttpResponse.new(self)
  end

  def send_response
    return if @sent

    response.status = 200
    response.content = 'All processes is done'

    response.send_response
    @sent = true
  end
end

EventMachine::run do
  EventMachine::start_server("0.0.0.0", 8080, Handler)
  puts "Listening..."
end
