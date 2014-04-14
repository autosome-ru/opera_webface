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
  def collection_motif_pcm_link(collection_name, motif, name = 'pcm')
    link_to(name, "/motif_collection/pcm/#{collection_name}/#{motif}.pcm")
  end
  def collection_motif_pwm_link(collection_name, motif, name = 'pwm')
    link_to(name, "/motif_collection/pwm/#{collection_name}/#{motif}.pwm")
  end
  def collection_motif_links(collection_name, motif)
    "<small>(" + collection_motif_pcm_link(collection_name, motif) + ", " + collection_motif_pwm_link(collection_name, motif) + ")</small>"
  end
  def collection_motif_image_path(collection_name, motif, orientation)
    "/motif_collection/logo/#{collection_name}/#{motif}_#{orientation}.png"
  end
  def collection_motif_image_link(collection_name, motif, orientation, name = 'logo')
    link_to name, collection_motif_image_path(collection_name, motif, orientation)
  end
  def collection_motif_image(collection_name, motif, orientation)
    image_tag(collection_motif_image_path(collection_name, motif, orientation))
  end

  def notice_and_reload(redirect_url, timeout)
    result = ""
    result << "<div class=\"redirect_to\" data-url=#{redirect_url} data-timeout=#{timeout*1000}></div>"
    result << I18n.t('opera.reload_manually', timeout: timeout, redirect_url: redirect_url)
    result.html_safe
  end

###############
# parse table #
#################################################################

  def params_from_txt(task_results)
    task_results.each_line.select{|l| l.start_with?('#') }[0..-2]
  end
  def results_header_from_txt(task_results)
    task_results.each_line.select{|l| l.start_with?('#') }.last[1..-1].split("\t")
  end
  def results_data_from_txt(task_results)
    task_results.each_line.reject{|l| l.start_with?('#') }.map{|l| l.rstrip.split("\t") }
  end
  def line_to_row(line, tag = 'td')
    content_tag :tr do
      line.map{|el|
        content_tag(tag){ el.to_s.html_safe }
      }.join.html_safe
    end
  end
  def create_table(header, lines, options = {})
    content_tag :table, options[:table_html] do
      content = content_tag(:thead) { line_to_row(header, 'th') }
      content << content_tag(:tbody) { lines.map{|line| line_to_row(line, 'td') }.join.html_safe }
      content.html_safe
    end
  end
end
