<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
####### ChIPMunk - supplementary ruby-scripts ########
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

1. Introduction >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

This archive contains some useful ruby-scripts
to simplify typical (di)ChIPMunk usage including:
- executing ChIPMunk or ChIPHorde +
parsing the resulting output + 
producing separate motif files + motif LOGOs
- plotting motif logos using Discrete Information
 Content to scale letters

Ruby is a simple and powerful scripting language,
read more at http://www.ruby-lang.org/

The small-BiSMark xml motif-files produced by this machinery
are based on the following DTD:
http://autosome.ru/smallBiSMark/smallbismark.dtd


2. Prerequisites >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

The ChIPMunk-executing scripts are designed to 
allocate from 256Mb to 1Gb of memory to the Java VM.
It should allow to process up to tens of thousands of sequences
on any modern PC.

The scripts should work under most modern Windows/Linux 
environments if prerequisites are correctly satisfied.

This machinery requires: 
- Java Runtime Environment (JRE) for ChIPMunk (java.exe directory should be in your PATH)
- working ruby installation (either 1.8, 1.9 or 2.0)
- ImageMagick image manipulation library
- RMagick library (a ruby binding for ImageMagick)

For a Linux system these requirements can be satisfied 
using distribution-specific package manager.

For a Windows system at this moment the easiest way is to use 
Ruby 1.8.6 via the one-click RubyInstaller 
(http://www.ruby-lang.org/en/downloads/)
as well as RMagick 2.12.0 binary gem 
(http://rmagick.rubyforge.org/)

The RMagick package at 
http://rubyforge.org/frs/download.php/64917/RMagick-2.12.0-ImageMagick-6.5.6-8-Q8.zip
contains the detailed installation instructions and the ImageMagick for Windows.

There are some tricky points in installing RMagick for ruby 1.9/2.0 on Windows
(better follow additional guides - see google for instructions).

3. Checking your ruby-RMagick environment >>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

Before running the scripts you can easily check 
if everything is OK by typing:
 irb
(it will run interactive ruby shell) and then
 require 'RMagick'
which should give you 'true' output.

If it says 'false' or 'cannot find RMagick' then 
it seems there are some problems with the RMagick
or ImageMagick installation.


4. The tools within this package >>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

The scripts should run correctly when called from any 
directory. All examples are given in assumption that
they are called from the unpacked directory 
with the scripts and this readme-file.

The package includes some toy example data
and the following scripts:

1) run_chipmunk6.rb script (and run_dichipmunk6.rb)
which passes the parameters to the ChIPMunk (included) and
parses the output to create resulting files.

For example:
  ruby run_chipmunk6.rb test 10 6 yes 1.0 s:TEST_footprint.mfa

will create a motif 'test' and several accompanying files
(words, count and weight matrices, etc) using
following ChIPMunk parameters (refer to the ChIPMunk manual for a more
detailed description):
- searching for a motif of length 10 to 6, printing additional info, 
using ZOOPS segmentation coefficient of 1.0,
using TEST_footprint.mfa as a non-weighted input data set.

The .log file will contain all information on ChIPMunk run.
Several accompanying files with a self-describing names will be also produced.

3) pmflogo3.rb & dpmflogo3.rb scripts
are logo-creation scripts.

You can use these script:

- to produce motif logos from plain txt-files with count matrices 
(.pcm or .pat; .dpcm for dpmflogo3.rb),
xml-files, multi-fasta files (.fasta, .mfa, containing aligned words).
- to use different color schemes for the letters (two example schemes, 
ChIPMunk default and WebLogo-inspired are included).

By default pmflogo3 will use DIC-based letter scaling when there is
'counts' information available (for count-based matrices and word-lists).

You can run ruby pmflogo3.rb without the parameters to get a small
tip about the command-line format (it allows to select
the color scheme or the size of the resulting logo).

Check if it works correctly by running:
(a) 
  ruby pmflogo3.rb TEST_SP1.pat SP1.png

which should use the TEST_SP1.pat matrix to produce the SP1.png logo using
classic IC scaling.

(b)
  ruby pmflogo3.rb TEST_counts.pwm test.png

which should use the TEST_counts.pwm count matrix to 
produce the test.png motif logo using DIC-based letter scaling.

(c)
  ruby pmflogo3.rb TEST_seqs.txt test.png
or
  ruby pmflogo3.rb TEST_seqs.mfa test.png

to produce the test.png logo using word-lists from
the corresponding txt or multi-fasta file.

(d)
  ruby dpmflogo3.rb TEST_dinucleotide.dpcm test.png
  
will procude dinucleotide logo of the dinucleotide counts matrix.

4) run_chiphorde6.rb script,
which passes the parameters to ChIPHorde and
parses its output to create separate result files.

For example
  ruby run_chiphorde6.rb test 8:10,6:7,6:7 filter yes 1.0 s:TEST_footprint.mfa

will create a series of a three motifs using the following ChIPHorde parameters:
- searching for a strong motif of length 8 to 10, then 6 to 7, then 6 to 7; 
using 'filtering' strategy to exclude the sequences 
with good motif occurrences before the next search iteration,
printing additional info, using ZOOPS segmentation coefficient of 1.0, 
using TEST_footprint.mfa as the non-weighted input data set.

The .log file will contain all information regarding this ChIPHorde run.
Several accompanying files with a self-describing names will be also produced.
