library(autometric)
library(crew)
library(targets)
library(tarchetypes)

controller <- crew_controller_local(
  name = "local",
  workers = 2,
  options_metrics = crew_options_metrics(
    path = "worker_log_directory/",
    seconds_interval = 1
  )
)

if (tar_active()) {
  controller$start()
  log_start(
    path = "log.txt",
    seconds = 1,
    pids = controller$pids()
  )
}

tar_option_set(controller = controller)

list(
  tar_target(name = sleep1, command = Sys.sleep(5)),
  tar_target(name = sleep2, command = Sys.sleep(5)),
  tar_target(name = sleep3, command = Sys.sleep(5)),
  tar_target(name = sleep4, command = Sys.sleep(5))
)