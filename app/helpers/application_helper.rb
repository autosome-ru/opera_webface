module ApplicationHelper
  #def link_to(name = nil, options = nil, html_options = nil, &block)
  def show_image(ticket, filename, options = {})
    if SMBSMCore.check_content(ticket, filename)
      image_tag(show_from_scene_path(id: ticket, filename: filename), options)
    end
  end

  def download_link(name = nil, html_options = nil, ticket, filename, &block)
    if SMBSMCore.check_content(ticket, filename)
      link_to(name, download_from_scene_path(id: ticket, filename: filename), html_options, &block)
    end
  end

  def download_list(ticket, names_hash, html_options = nil)
    content = '<small>('
    content << names_hash.map {|name, filename| download_link(name, html_options, ticket, filename) }.compact.join(', ')
    content << ')</small>'
    content.html_safe
  end

  # hocomoco motif links
  def collection_motif_pcm_link(motif, name = 'pcm')
    link_to(name, "/pcm/#{motif}.pcm")
  end
  def collection_motif_pwm_link(motif, collection_background, name = 'pwm')
    link_to(name, "/pwm/#{collection_background}/#{motif}.pwm")
  end
  def collection_motif_links(motif, collection_background)
    "<small>(" + collection_motif_pcm_link(motif) + ", " + collection_motif_pwm_link(motif, collection_background) + ")</small>"
  end
  def collection_motif_image(motif, orientation)
    image_tag("hocomoco_logo/#{motif}_#{orientation}.png")
  end

  def notice_and_reload(redirect_url, timeout)
    result = ""
    result << "<div class=\"redirect_to\" data-url=#{redirect_url} data-timeout=#{timeout*1000}></div>"
    result << I18n.t('opera.reload_manually', timeout: timeout, redirect_url: redirect_url)
    result.html_safe
  end
end
