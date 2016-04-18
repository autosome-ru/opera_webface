module OperaHouseConfiguration
  DRubyURI = 'druby://localhost:1111'

  root_path = File.expand_path("../../", __FILE__)

  OPERAHOUSE_PATH = File.join(root_path, 'lib')

  SCENE_PATH = File.join(root_path, 'scene')
  SCORES_PATH = File.join(OPERAHOUSE_PATH, 'scores')
  ASSETS_PATH = File.join(root_path, 'public')

  TICKETS_PATH = File.join(root_path, 'log', 'tickets')
  STORIES_PATH = File.join(root_path, 'log', 'stories')

  task_names = {
    'EvaluateSimilarity' => 'evaluate_similarity',
    'ScanCollection' => 'scan_collection',
    'SnpScan' => 'snp_scan',
    'MotifDiscovery' => 'motif_discovery',
    'MotifDiscoveryDi' => 'motif_discovery_di',
  }
  OVERTURE_PATH = Hash[ task_names.map{|task_name, task_script| [task_name, File.join(SCORES_PATH, 'overture', "overture_#{task_script}.rb")] } ]
  OPERA_PATH = Hash[ task_names.map{|task_name, task_script| [task_name, File.join(SCORES_PATH, 'opera', "opera_#{task_script}.rb")] } ]


  TICKETCONTROL_DELAY = 3600*24 # Time for ticket to die
  CHECKER_DELAY = 3600*24
  PERFORMER_DELAY = 1
  CLEANER_DELAY = 60 # time to mark finished operas as so
end
