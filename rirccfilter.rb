# This file is part of rirccfilter, distributed under the ISC license.
# For full terms see the included COPYING file.

require 'csv'
require 'netaddr'

class UsageError < StandardError
  def message
    %(\
#{File.basename($PROGRAM_NAME)} COMMAND [CC...]
Commands:
  cidr  Output IP ranges in CIDR address format.
  p2p   Output IP ranges in P2P plaintext format.)
  end
end

ex = 0
begin
  COMMAND = ARGV.shift
  CC = ARGV
  CC.each { |cc| raise "Invalid country code: #{cc}" unless cc.upcase.match?(/\A[A-Z]{2}\Z/) }
  CC.map!(&:upcase)
  counts = Hash.new(0)
  $stdin.each_line do |ln|
    flds = CSV.parse_line(ln, col_sep: '|', skip_blanks: true, skip_lines: /\A#/)
    next if flds.nil?
    if flds.size == 6 && flds[-1].eql?('summary')
      # this line is a header (summary)
      next
    elsif flds.size == 7
      # this line is a header (version)
      [%w[Version Registry Serial Records Startdate Enddate UTC-Offset], flds].transpose.each { |k, v| $stderr.puts("#{k}: #{v}") }
    elsif flds.size >= 8
      # this line is a record
      next if !CC.empty? && !CC.include?(flds[1])
      next unless flds[2].eql?('ipv4')

      counts[flds[1]] += 1
      net = NetAddr::CIDRv4.create(format('%s/%d', flds[3], 32 - Math.log2(Float(flds[4]))))
      case COMMAND
      when 'cidr'
        puts(net.to_s)
      when 'p2p'
        puts(format('%s%d:%s-%s', flds[1], counts[flds[1]], net.nth(1), net.nth(net.size - 2)))
      else
        raise UsageError
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
