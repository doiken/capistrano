set :stage, :staging

##
## Set Server Setting
##
for i in 1..2 do
  server "dev-deliver#{i}", roles: %w{ad imp}
end

##
## Global Setting
##
set :ssh_options, {
    :user => 'amoad'
}

