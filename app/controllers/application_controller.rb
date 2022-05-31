class ApplicationController < ActionController::Base
    def hello
        render html: "Git Gud"
    end
end
