module SnpScansHelper
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
    "<tr>" + line.map{|el| "<#{tag}>#{el}</#{tag}>"}.join + "</tr>"
  end
  def table_from_txt(task_results, task_params)
    content = "<table>"
    content << line_to_row(results_header_from_txt(task_results), 'th')
    #content << line_to_row(results_header_from_txt(task_results) + ['logo'], 'th')
    results_data_from_txt(task_results).each { |line|
      [-1, -2, -3].each{|index| line[index] = line[index].to_f.round(5)}
      # motif = line.first
      # orientation = line[4]
      # line_augmented = line + [collection_motif_image(motif, orientation)]
      # line_augmented[0] += " " + collection_motif_links(motif, task_params.collection_background)
      # content << line_to_row(line_augmented, 'td')
      content << line_to_row(line, 'td')
    }
    content << "</table>"
    content.html_safe
  end
end
