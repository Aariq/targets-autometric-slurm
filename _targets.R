library(autometric)
library(crew)
library(crew.cluster)
library(targets)
library(tarchetypes)

controller_local <- crew_controller_local(
  name = "local",
  workers = 2,
  options_metrics = crew_options_metrics(
    path = "worker_log_directory/",
    seconds_interval = 1
  )
)

controller_hpc <- crew_controller_slurm(
  name = "hpc",
  workers = 2,
  seconds_idle = 500, 
  slurm_partition = "standard",
  slurm_time_minutes = 2000, 
  slurm_log_output = "logs/crew_log_%A.out",
  slurm_log_error = "logs/crew_log_%A.err",
  slurm_memory_gigabytes_per_cpu = 5,
  slurm_cpus_per_task = 1,
  script_lines = c(
    "#SBATCH --account kristinariemer",
    "module load R"
  )
)

group <- crew_controller_group(controller_local, controller_hpc)

if (tar_active()) {
  group$start()
  log_start(
    path = "log.txt",
    seconds = 1,
    pids = group$pids()
  )
}

slurm_host <- Sys.getenv("SLURM_SUBMIT_HOST")
hpc <- grepl("hpc\\.arizona\\.edu", slurm_host) & !grepl("ood", slurm_host)

tar_option_set(controller = group, resources = tar_resources(
  crew = tar_resources_crew(controller = ifelse(hpc, "hpc", "local"))
))

list(
  tar_target(name = sleep1, command = Sys.sleep(5)),
  tar_target(name = sleep2, command = Sys.sleep(5)),
  tar_target(name = sleep3, command = Sys.sleep(5)),
  tar_target(name = sleep4, command = Sys.sleep(5))
)