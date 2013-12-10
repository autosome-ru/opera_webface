module OperaHouseConfiguration  
  DRubyURI = 'druby://localhost:1111'
  
  OS = RUBY_PLATFORM.include?('linux') ? :LINUX : :WINDOWS
  case OS
  when :WINDOWS
    root_path = File.join('D:', 'programming', 'onemoreweb')
  when :LINUX
    root_path = '/home/ilya/programming'
  end
  
  OPERAHOUSE_PATH = File.join(root_path, 'opera_webface','lib')
  
  SCENE_PATH = File.join(root_path, 'opera_webface', 'scene')
  SCORES_PATH = File.join(OPERAHOUSE_PATH, 'scores')
  
  TICKETS_PATH = File.join(root_path, 'opera_webface', 'log', 'tickets')
  STORIES_PATH = File.join(root_path, 'opera_webface', 'log', 'stories')
  
  OPERA_PATH = Hash[ {"EvaluateSimilarity" => 'opera_evaluate_similarity.rb'}.map{|task_name, task_script| [task_name, File.join(SCORES_PATH, task_script)] } ]
  OVERTURE_PATH = Hash[ {"EvaluateSimilarity" => 'overture_evaluate_similarity.rb' }.map{|task_name, task_script| [task_name, File.join(SCORES_PATH, task_script)] } ]
  
  TICKETCONTROL_DELAY = 3600*24 # Time for ticket to die
  CHECKER_DELAY = 3600*24
  PERFORMER_DELAY = 1
  CLEANER_DELAY = 10 # time to mark finished operas as so
end
