variable "do_token" {}
variable "cloudflare_api_token" {}

variable "vm_count" {
  default = 1
}

provider "digitalocean" {
  token = var.do_token
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}


data "digitalocean_ssh_key" "ondrejsika" {
  name = "ondrejsika"
}

resource "digitalocean_droplet" "droplet" {
  count = var.vm_count

  image  = "docker-18-04"
  name   = "droplet${count.index}"
  region = "fra1"
  size   = "s-1vcpu-2gb"
  ssh_keys = [
    data.digitalocean_ssh_key.ondrejsika.id
  ]
}

resource "cloudflare_record" "droplet" {
  count = var.vm_count

  // zone sikademo.com
  zone_id   = "f2c00168a7ecd694bb1ba017b332c019"
  name   = "droplet${count.index}"
  value  = digitalocean_droplet.droplet[count.index].ipv4_address
  type   = "A"
  proxied = false
}


resource "cloudflare_record" "droplet_wildcard" {
  count = var.vm_count

  // zone sikademo.com
  zone_id   = "f2c00168a7ecd694bb1ba017b332c019"
  name   = "*.droplet${count.index}"
  value  = "droplet${count.index}.sikademo.com"
  type   = "CNAME"
  proxied = false
}
