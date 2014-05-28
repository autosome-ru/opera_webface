module Macroape::ScansHelper
  def scan_collection_table(task_results, task_params)
    collection_name = task_params.collection
    header = results_header_from_txt(task_results) + ['logo']
    lines = results_data_from_txt(task_results)
    lines = lines.map do |line|
      motif, similarity, shift, overlap, orientation, precise_mode = *line
      motif_info = motif + '<br>' + collection_motif_links(collection_name, motif) + '<br>' + uniprot_links(collection_name, motif)
      logo_path = collection_motif_image(collection_name, motif, orientation)
      [motif_info, similarity.to_f.round(5), shift, overlap, orientation, precise_mode, logo_path]
    end
    lines = lines.sort_by do |line|
      motif_info, similarity, shift, overlap, orientation, precise_mode, logo_path = *line
      1.0 - similarity
    end
    create_table(header, lines, table_html: {class: 'colorized macroape_scan_results'})
  end

end
