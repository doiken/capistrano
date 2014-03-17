set :stage, :production

##
## Set Server Setting
##
ad_servers = ENV['ADS'] # ADS="`seq -f "ad%g.amoad.jp" 1 26`"
for server in ad_servers do
  server server, roles: %w{ad}
end

imp_servers = ENV['IMPS'] # IMPS="`seq -f "imp%g" 3 14`"
for server in imp_servers do
  server server, roles: %w{imp}
end

##
## Global Setting
##
set :ssh_options, {
    user => 'amoad'
}
