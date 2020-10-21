module API
  module ErrorFormatter
    def self.call message, _backtrace, _options, _env, _original_exception
      {status: "error", errors: message}.to_json
    end
  end
end
