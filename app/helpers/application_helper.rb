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
    content_tag(:small){
      (
        "(" +
        collection_motif_pcm_link(collection_name, motif).to_s +
        ", " +
        collection_motif_pwm_link(collection_name, motif).to_s +
        ")"
      ).html_safe
    }
  end
  def collection_motif_image_path(collection_name, motif, orientation)
    "/motif_collection/logo/#{collection_name}/#{motif}_#{orientation}.png"
  end
  def collection_motif_large_image_path(collection_name, motif, orientation)
    "/motif_collection/logo_large/#{collection_name}/#{motif}_#{orientation}.png"
  end
  def collection_motif_image_link(collection_name, motif, orientation, name = 'logo')
    link_to name, collection_motif_image_path(collection_name, motif, orientation)
  end
  def collection_motif_image(collection_name, motif, orientation)
    link_to(
      image_tag(collection_motif_image_path(collection_name, motif, orientation)),
      collection_motif_large_image_path(collection_name, motif, orientation)
    )
  end

  def motif_info(collection_name, motif)
    if [:hocomoco_12_core, :hocomoco_12_rsnp, :hocomoco_12_invivo, :hocomoco_12_invitro].include?(collection_name)
      motif_url = "https://hocomoco12.autosome.org/motif/#{motif}"
    elsif [:hocomoco_11_human, :hocomoco_11_mouse].include?(collection_name)
      motif_url = "https://hocomoco11.autosome.org/motif/#{motif}"
    elsif [:hocomoco_10_human, :hocomoco_10_mouse].include?(collection_name)
      motif_url = "https://hocomoco10.autosome.org/motif/#{motif}"
    elsif collection_name == :hocomoco # v9
      infos = /^(?<model_base>.+)_(?<model_type>f1|f2|do|si)$/.match(motif)
      motif_url = "https://autosome.org/HOCOMOCO/modelDetails.php?tf=#{infos[:model_base]}&model=#{infos[:model_type]}"
    else
      motif_url = nil
    end
    [ (motif_url ? link_to(motif, motif_url) : motif),
      collection_motif_links(collection_name, motif),
      uniprot_links(collection_name, motif),
    ].reject(&:blank?).join( tag(:br) )
  end

  def uniprot_mapping
    return @uniprot_mapping  if @uniprot_mapping
    @uniprot_mapping = begin
      result = Hash.new{|h,k| h[k] = Hash.new }
      @uniprot_mapping ||= File.readlines(Rails.root.join('public/uniprot_mapping.txt')).drop(1).map{|line|
        collection, motif, uniprot, entrezgene = line.strip.split("\t")
        result[collection.to_sym][motif] = uniprot.split(',')
      }
      result
    end
  end

  def annotation_by_h12_collection(collection_name)
    @cache_annotation_by_collection ||= {}
    @cache_annotation_by_collection[collection_name] ||= begin
      collection_suffix = collection_name.split('_').last.upcase
      annotation_fn = Rails.root.join("public/motif_collection/H12#{collection_suffix}_annotation.jsonl")
      File.readlines(annotation_fn).map{|l|
        JSON.parse(l)
      }.group_by{|d|
        d['name']
      }.transform_values{|grp|
        raise unless grp.size == 1
        grp.first
      }
    end
  end

  def uniprot_links(collection_name, motif)
    if [:hocomoco_11_human, :hocomoco_11_mouse, :hocomoco_10_human, :hocomoco_10_mouse].include?(collection_name)
      uniprot_name = motif[/^(?<uniprot>.+_HUMAN|.+_MOUSE)\..*/, :uniprot]
      return uniprot_link("#{uniprot_name}", uniprot_name)
    elsif [:hocomoco_12_core, :hocomoco_12_rsnp, :hocomoco_12_invivo, :hocomoco_12_invitro].include?(collection_name)
      uniprot_name = annotation_by_h12_collection(collection_name)[motif][:uniprot_id_human]
    end
    motif_id = motif.split.first # names in uniprot mapping aren't complete names but just first parts (e.g. `MA0512.1` for `MA0512.1 Rxra`)
    uniprot_names = uniprot_mapping[collection_name.to_sym][motif_id]
    return ''  unless uniprot_names
    uniprot_names.map{|uniprot_name|
      uniprot_link("#{uniprot_name}", uniprot_name)
      }.join("<br>").html_safe
  end

  def uniprot_link(name, uniprot_name)
    link_to(name, "https://uniprot.org/uniprot/#{uniprot_name}")
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

########################################################################

  NUCLEOTIDES = ['A', 'C', 'G', 'T']
  DINUCLEOTIDES = NUCLEOTIDES.product(NUCLEOTIDES).map(&:join)

  def format_matrix_as_table(matrix, arity:, round: nil)
    case arity
    when :mono
      letters = NUCLEOTIDES
    when :di
      letters = DINUCLEOTIDES
    else
      raise IllegalArgumentException, "Unknown arity `#{arity}`"
    end

    header = table_header(letters)
    body = table_body_for_matrix(matrix_rounded(matrix, round: round))

    content_tag(:table, (header + body).html_safe, class: 'output_matrix')
  end


  def table_header(column_names)
    content_tag(:thead){
      content_tag(:tr){
        [nil, *column_names].map{|column_name|
          content_tag(:th, column_name)
        }.join.html_safe
      }
    }
  end

  def table_body_for_matrix(matrix)
    content_tag(:tbody){
      matrix.each_with_index.map{|pos, index|
        content_tag(:tr){
          ['%02d' % (index + 1), *pos].map{|cell|
            content_tag(:td, cell)
          }.join.html_safe
        }
      }.join.html_safe
    }
  end

  def matrix_rounded(matrix, round:)
    return matrix   unless round
    matrix.map{|pos|
      pos.map{|el| el.round(round) }
    }
  end
end
