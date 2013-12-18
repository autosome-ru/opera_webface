module SMBSMCore
  def self.get_content(ticket, what); theatre.get_content(ticket, what)  rescue nil;  end
end

class SceneController < ApplicationController
  def show
    ticket = params[:id]
    filename = params[:filename]
    send_data SMBSMCore.get_content(ticket, filename), filename: "#{ticket}_#{filename}", type: MIME::Types.type_for(filename), disposition: 'inline'
  end

  def download
    ticket = params[:id]
    filename = params[:filename]
    send_data SMBSMCore.get_content(ticket, filename), filename: "#{ticket}_#{filename}", disposition: 'attachment'
  end
end
