module Macroape::ScansHelper
  def scan_collection_table(task_results, task_params, ticket)
    collection_name = task_params.collection
    header = results_header_from_txt(task_results) + ['logo']
    lines = results_data_from_txt(task_results)
    lines = lines.map do |line|
      motif, similarity, shift, overlap, orientation, precise_mode = *line
      motif_info = motif_info(collection_name, motif)
      logo_path = collection_motif_image(collection_name, motif, orientation)
      [motif_info, similarity.to_f.round(5), shift, overlap, orientation, precise_mode, logo_path]
    end
    lines = lines.sort_by do |line|
      motif_info, similarity, shift, overlap, orientation, precise_mode, logo_path = *line
      1.0 - similarity
    end

    download_links = download_list ticket, {'pcm' => 'query.pcm', 'ppm' => 'query.ppm', 'pwm' => 'query.pwm'}
    lines.unshift [ '<span class="query_motif">Query</span><br>' + download_links,
                    'N/A', 0, 'N/A', 'N/A', 'N/A',
                    link_to(
                      show_image(ticket, 'query_small.png'),
                      show_from_scene_path(id: ticket, filename: 'query_large.png')
                    )
                  ]
    create_table(header, lines, table_html: {class: 'colorized lighter-column-odd neutral-colors macroape_scan_results'})
  end

end
