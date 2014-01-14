module Macroape::ScansHelper
  def scan_collection_table(task_results, task_params)
    collection_name = task_params.collection
    table_from_txt(task_results, task_params, header: results_header_from_txt(task_results) + ['logo']) do |line|
      motif = line.first
      orientation = line[4]
      line_augmented = line + [collection_motif_image(collection_name, motif, orientation)]
      line_augmented[0] += " " + collection_motif_links(collection_name, motif)
      line_augmented
    end
  end
end
