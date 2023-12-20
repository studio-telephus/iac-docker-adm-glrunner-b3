module "container_glrunner_java11" {
  source    = "github.com/studio-telephus/tel-iac-modules-lxd.git//instance?ref=develop"
  name      = "container-glrunner-java11"
  image     = "images:debian/bookworm"
  profiles  = ["limits", "fs-dir", "nw-adm"]
  autostart = true
  nic = {
    name = "eth0"
    properties = {
      nictype        = "bridged"
      parent         = "adm-network"
      "ipv4.address" = "10.0.10.133"
    }
  }
  mount_dirs = [
    "${path.cwd}/filesystem-shared-ca-certificates",
    "${path.cwd}/filesystem",
  ]
  exec = {
    enabled    = true
    entrypoint = "/mnt/install.sh"
    environment = {
      RANDOM_STRING                  = "420e4798-5061-4ce1-9c9c-26f251a706a7"
      GITLAB_RUNNER_REGISTRATION_KEY = var.gitlab_runner_registration_key
      GIT_SA_USERNAME                = var.git_sa_username
      GIT_SA_TOKEN                   = var.git_sa_token
    }
  }
}
