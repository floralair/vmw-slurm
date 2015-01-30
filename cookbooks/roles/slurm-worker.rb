name        'slurm-worker'
description 'Worker role for SLURM package deployment. It does not include setting up IP/FQDN, mounting and formatting local disks.'

run_list *%w[
  vmw-slurm
  vmw-slurm::worker
]

