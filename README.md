# README

This is OperaHouse webface which allows users to run our lab's computational-heavy tools using web form. Our lab is specialized on sequence and motif analysis so our tools have some stuff to simplifing this kind of tasks.

## Setup
In order to setup opera house you'd check several points:

* Place motif collections onto their place in `public/motif_collections/` folder.
Each of subfolders pcm/pwm/thresholds/logo have its own subsubfolders: hocomoco/homer/swissregulon/jaspar/selex. These collection-specific folders should contain motifs in plain text formats (extensions: .pcm/.pwm/.ppm) or motif specific information: (.thr/_direct.png/_revcomp.png). Make sure that no other files are in these folders (no `.keep` files, they break tools)

* Check for the latest versions of Java-tools (`scan-collection.jar`, `multi-SNP-scan.jar`). They should be placed in public folder.

## Run and restart
In order to run webface do:

* `cd path_to_app && bundle install`

* `echo "cd path_to_app && source path_to_ruby_dir && rvm use 2.0 do bundle exec rails s -e production -p 80 -d" | sudo bash -i`

This command can be scheduled with root's `sudo crontab -e`. It'd be runned under root if you want to use port 80.

* If you change overture files - restart not only webface but also opera house itself (it will be restarted automatically by webface)
