module "container_adm_glrunner_b3" {
  source    = "github.com/studio-telephus/terraform-lxd-instance.git?ref=1.0.3"
  name      = "container-adm-glrunner-b3"
  image     = "images:debian/bookworm"
  profiles  = ["limits", "fs-dir", "nw-adm"]
  autostart = false
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
  exec_enabled = true
  exec         = "/mnt/install.sh"
  environment = {
    RANDOM_STRING                  = "420e4798-5061-4ce1-9c9c-26f251a706a7"
    GITLAB_RUNNER_REGISTRATION_KEY = var.gitlab_runner_registration_key
    GIT_SA_USERNAME                = var.git_sa_username
    GIT_SA_TOKEN                   = var.git_sa_token
  }
}
