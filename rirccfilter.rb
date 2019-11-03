# This file is part of rirccfilter, distributed under the ISC license.
# For full terms see the included COPYING file.

require 'csv'
require 'netaddr'

class UsageError < StandardError
  def message
    %(\
#{File.basename($PROGRAM_NAME)} COMMAND CC ...
Commands:
  cidr  Output IP ranges in CIDR address format.
  p2p   Output IP ranges in P2P plaintext format.)
  end
end

ex = 0
begin
  COMMAND = ARGV.shift
  CC = ARGV
  raise UsageError if !%w[cidr p2p].include?(COMMAND) || CC.empty?
  CC.each { |cc| raise "Invalid country code: #{cc}" unless cc.upcase.match?(/\A[A-Z]{2}\Z/) }
  CC.map!(&:upcase)
  $stdin.each_line.with_index(1) do |ln, ix|
    flds = CSV.parse_line(ln, col_sep: '|', skip_blanks: true, skip_lines: /\A#/)
    next if flds.nil?
    if flds.size == 6 && flds[-1].eql?('summary')
      # this line is a header (summary)
      nil
    elsif flds.size == 7
      # this line is a header (version)
      nil
    elsif flds.size >= 8
      # this line is a record
      if CC.include?(flds[1])
        if flds[2].eql?('ipv4')
          net = NetAddr::CIDRv4.create('%s/%d' % [flds[3], 32 - Math.log2(Float(flds[4]))])
          case COMMAND
          when 'cidr'
            puts(net.to_s)
          when 'p2p'
            puts("#{ix}:#{net.first}-#{net.last}")
          end
        end
      end
    else
      raise("Invalid input line: #{ln}")
    end
  end
rescue UsageError => e
  warn("Usage: #{e.message}")
  ex = 2
rescue => e
  warn("Error: #{e.message}")
  ex = 1
end
exit(ex)

# vim: et sw=2 ts=2
