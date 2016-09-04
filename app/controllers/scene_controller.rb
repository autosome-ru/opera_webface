class SceneController < ApplicationController
  before_action :get_ticket, only: [:show, :download]

  def show
    filename = params[:filename]
    send_data SMBSMCore.get_content(@ticket, filename), filename: "#{@ticket}_#{filename}", type: MIME::Types.type_for(filename).first.try(:content_type), disposition: 'inline'
  end

  def download
    filename = params[:filename]
    send_data SMBSMCore.get_content(@ticket, filename), filename: "#{@ticket}_#{filename}", disposition: 'attachment'
  end

protected
  def get_ticket
    @ticket = params[:id].try(&:strip)
  end
end
