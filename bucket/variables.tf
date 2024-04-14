# Заменить на ID своего облака
# https://console.cloud.yandex.ru/cloud?section=overview
variable "cloud_id" {
  type = string
}

# Заменить на Folder своего облака
# https://console.cloud.yandex.ru/cloud?section=overview
variable "folder_id" {
  type = string
}

# Задаем tokken
variable "token" {
  type = string
}

# Заменить на ID своего образа
# ID можно узнать с помощью команды yc compute image list
variable "ubuntu-2004-lts" {
  default = "fd852pbtueis1q0pbt4o"
}

variable "subnet-zones" {
  type    = list(string)
  default = ["ru-central1-a", "ru-central1-b","ru-central1-d"]
}

variable "cidr" {
  type    = map(list(string))
  default = {
    stage = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]    
  }
}
