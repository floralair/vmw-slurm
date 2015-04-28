module Slurm_service_def
  def is_worker
    node.role?("slurm_worker")
  end

  def master_node_fqdn
    servers = all_providers_fqdn_for_role("slurm_master")
    Chef::Log.info("Master HPC nodes in cluster #{node[:cluster_name]} are: #{servers.inspect}")
    servers
  end

  def worker_node_fqdn
    servers = all_providers_fqdn_for_role("slurm_worker")
    Chef::Log.info("Worker HPC nodes in cluster #{node[:cluster_name]} are: #{servers.inspect}")
    servers
  end

#  def wait_for_slurm_nodes(in_ruby_block = true)
#    return if is_worker
#    run_in_ruby_block __method__, in_ruby_block do
#      set_action(HadoopCluster::ACTION_WAIT_FOR_SERVICE, node[:slurm][:slurm_worker])
#      worker_count = all_nodes_count({"role" => "slurm_worker"})
#      all_providers_for_service(node[:slurm][:slurm_worker], true, worker_count)      clear_action
#    end
#  end
end
