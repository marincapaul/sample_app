class ApplicationController < ActionController::Base
    include SessionsHelper
    
    def hello
        render html: "Git Gud"
    end
end
