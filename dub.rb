#!/usr/bin/env ruby

# Usage: ./dub.rb /iMovie/Libary /Original/File/Location
#
# Goes through an iMovie 10 library and replaces all the "Original Media" with
# hardlinks to the actual original media, in order to conserve disk space. Note
# that because they're hardlinks, if you copy the originals and the iMovie event
# to a new disk, you'll end up with two copies again and will have to re-run this
# tool.
#
# This assumes you've already imported the files into iMovie and waited for them
# all to be copied. This also assumes movie files in LIBRARY have unique matches 
# in ORIGINALS with the same filename!

require 'fileutils'

library = ARGV.shift
originals = ARGV.shift

fail "Library #{library} does not exist" unless library && File.exist?(library)
fail "Originals folder #{originals} does not exist" unless originals && File.exist?(originals)

# For each original file in the imovie library
Dir.glob(File.join(library, '**', 'Original Media', '*')) do |library_file|
  next unless File.file? library_file

  # Skip it if we've already replaced it with a hardlink
  next if File.stat(library_file).nlink > 1 || File.lstat(library_file).symlink?

  original = Dir.glob(File.join(originals, '**', File.basename(library_file))).first

  next unless original

  # Make sure file contents are identical
  next unless FileUtils.compare_file library_file, original
  
  puts "Linking #{library_file} => #{original}"
  FileUtils.rm_f library_file, verbose: true
  FileUtils.ln_s original, library_file, verbose: true
end
