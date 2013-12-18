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
  ASSETS_PATH = File.join(SCORES_PATH, 'assets')
  
  TICKETS_PATH = File.join(root_path, 'opera_webface', 'log', 'tickets')
  STORIES_PATH = File.join(root_path, 'opera_webface', 'log', 'stories')
  
  task_names = {'EvaluateSimilarity' => 'evaluate_similarity',
                'ScanCollection' => 'scan_collection' }
  OVERTURE_PATH = Hash[ task_names.map{|task_name, task_script| [task_name, File.join(SCORES_PATH, 'overture', "overture_#{task_script}.rb")] } ]
  OPERA_PATH = Hash[ task_names.map{|task_name, task_script| [task_name, File.join(SCORES_PATH, 'opera', "opera_#{task_script}.rb")] } ]
  
  
  TICKETCONTROL_DELAY = 3600*24 # Time for ticket to die
  CHECKER_DELAY = 3600*24
  PERFORMER_DELAY = 1
  CLEANER_DELAY = 60 # time to mark finished operas as so
end
