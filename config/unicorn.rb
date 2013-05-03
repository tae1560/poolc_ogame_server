root = "/home/tae1560/private/poolc_ogame_server/current"
working_directory root
pid "#{root}/tmp/pids/unicorn.pid"
stderr_path "#{root}/log/unicorn.log"
stdout_path "#{root}/log/unicorn.log"

listen "/tmp/unicorn.poolc_ogame_server.sock"
worker_processes 2
timeout 30