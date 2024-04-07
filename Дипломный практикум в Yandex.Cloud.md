# Дипломный практикум в Yandex.Cloud
  * [Цели:](#цели)
  * [Этапы выполнения:](#этапы-выполнения)
     * [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
     * [Создание Kubernetes кластера](#создание-kubernetes-кластера)
     * [Создание тестового приложения](#создание-тестового-приложения)
     * [Подготовка cистемы мониторинга и деплой приложения](#подготовка-cистемы-мониторинга-и-деплой-приложения)
     * [Установка и настройка CI/CD](#установка-и-настройка-cicd)
  * [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
  * [Как правильно задавать вопросы дипломному руководителю?](#как-правильно-задавать-вопросы-дипломному-руководителю)

**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**

---
## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---
## Этапы выполнения:


### Создание облачной инфраструктуры



Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
Для облачного k8s используйте региональный мастер(неотказоустойчивый). Для self-hosted k8s минимизируйте ресурсы ВМ и долю ЦПУ. В обоих вариантах используйте прерываемые ВМ для worker nodes.
- Следует использовать версию [Terraform](https://www.terraform.io/) не старше 1.5.x .

Предварительная подготовка к установке и запуску Kubernetes кластера.

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:  
   а. Рекомендуемый вариант: S3 bucket в созданном ЯО аккаунте(создание бакета через TF)
   б. Альтернативный вариант:  [Terraform Cloud](https://app.terraform.io/)  
3. Создайте VPC с подсетями в разных зонах доступности.
4. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
5. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.




Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

---
### Создание Kubernetes кластера

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.

Это можно сделать двумя способами:

1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
  а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать **региональный** мастер kubernetes с размещением нод в разных 3 подсетях      
  б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)
  
Ожидаемый результат:

1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.

---
### Создание тестового приложения

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:

1. Рекомендуемый вариант:  
   а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.  
   б. Подготовьте Dockerfile для создания образа приложения.  
2. Альтернативный вариант:  
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

Ожидаемый результат:

1. Git репозиторий с тестовым приложением и Dockerfile.
2. Регистри с собранным docker image. В качестве регистри может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.

---
### Подготовка cистемы мониторинга и деплой приложения

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:
1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Способ выполнения:
1. Воспользовать пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). При желании можете собрать все эти приложения отдельно.
2. Для организации конфигурации использовать [qbec](https://qbec.io/), основанный на [jsonnet](https://jsonnet.org/). Обратите внимание на имеющиеся функции для интеграции helm конфигов и [helm charts](https://helm.sh/)
3. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте и настройте в кластере [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры. Альтернативный вариант 3 задания: вместо Terraform Cloud или atlantis настройте на автоматический запуск и применение конфигурации terraform из вашего git-репозитория в выбранной вами CI-CD системе при любом комите в main ветку. Предоставьте скриншоты работы пайплайна из CI/CD системы.

Ожидаемый результат:
1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
2. Http доступ к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ к тестовому приложению.

---
### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.

Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистри, а также деплой соответствующего Docker образа в кластер Kubernetes.

---
## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud или вашего CI-CD-terraform pipeline.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)



## Решение

### Создание облачной инфраструктуры


Конфигурация находится в папке [bucket](https://github.com/zatulik2606/Diplom/tree/main/bucket)





VM 


~~~

~~~

VPC 


~~~

~~~

Bucket

~~~
~~~

### Создание Kubernetes кластера






Скачиваем kubespray на локальную машину

~~~
git clone https://github.com/kubernetes-sigs/kubespray
~~~

Устанавливаю зависимости.( обрати внимание на версию pip и python д.б. не ниже 3.9)

~~~
sudo pip3.10 install -r requirements.txt
~~~

Если зависимости не установились ,то необходимо обновить версию python.

[Как обновить на 3.10 пример](https://www.rosehosting.com/blog/how-to-install-python-3-10-on-debian-11/) 


Скачиваем инвенторку.

~~~
 sudo cp -rfp inventory/sample inventory/mycluster
~~~

Задекларировал IP

~~~
declare -a IPS=(158.160.51.19 51.250.104.61 158.160.161.114)

~~~

Сделал конфиг hosts.yaml

~~~
CONFIG_FILE=inventory/mycluster/hosts.yaml python3.10 contrib/inventory_builder/inventory.py ${IPS[@]}


~~~

Изменил конфиг



~~~
root@debianv:~/diplom/k8s/kubespray# cat ~/diplom/k8s/kubespray/inventory/mycluster/hosts.yaml
all:
  hosts:
    node0:
      ansible_host: 158.160.51.19
        #ip: 158.160.51.19
        #access_ip: 158.160.51.19
      ansible_user: ubuntu  
    node1:
      ansible_host: 51.250.104.61
        #ip: 51.250.104.61
        #access_ip: 51.250.104.61
      ansible_user: ubuntu
    node2:
      ansible_host: 158.160.161.114
        #ip: 158.160.161.114
        #access_ip: 158.160.161.114
      ansible_user: ubuntu
  children:
    kube_control_plane:
      hosts:
        nodi0:
    kube_node:
      hosts:
        node1:
        node2:
    etcd:
      hosts:
        node0:
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}

~~~


Указал IP для внешнего подключения ( это ip control plane)
~~~
root@debianv:~/diplom/k8s/kubespray# cat /root/diplom/k8s/kubespray/inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml | grep suppl
supplementary_addresses_in_ssl_keys: [158.160.51.19]

~~~



Запустил playbook


~~~
ansible-playbook -i inventory/mycluster/hosts.yaml cluster.yml -b -v
~~~


Заходим на первую ВМ и проверим версию kube

~~~
ubuntu@node0:~$ sudo kubectl version
Client Version: v1.29.3
Kustomize Version: v5.0.4-0.20230601165947-6ce0bf390ce3
Server Version: v1.29.3


~~~

Проверяем ноды (если возникает ошибка с портом  ,то 

mkdir -p $HOME/.kube

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config 

sudo chown $(id -u):$(id -g) $HOME/.kube/config

))

~~~

ubuntu@node0:~$ sudo kubectl get nodes
NAME    STATUS   ROLES           AGE     VERSION
node0   Ready    control-plane   6m3s    v1.29.3
node1   Ready    <none>          5m12s   v1.29.3
node2   Ready    <none>          5m14s   v1.29.3


~~~

Смотрим Kubernetes кластер

~~~

~~~
Проверяем конфиги для доступа

<details>
ubuntu@node0:~$ cat ~/.kube/config
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJTkJ0N0NTcFZMK2N3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TkRBME1EY3hOVEF3TWpCYUZ3MHpOREEwTURVeE5UQTFNakJhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURqWmdsNXNQWVZZZ2lGZVJBcXNuMnBSaTVCRjlNMkVwWXJjM3pDTU9uM3BDWHBDZTE4bC9VcmE4Mk4KSVUyN3lUeTZ0bnJLOUNCV2FXQWwwWkRCMjNWdTlwTkdHRzNCdG1rNWFuZU1rMnh2L3B0RnVUYTQycm9UTS81UAp2TU00TWJtblBMMzhhaUpTVUQwdFppdkJQLzcrMmNlZEM1azFiVFAvd2g5NUVnL3dDTEFJbXpEcGJqYm1wRG0yCkVzRUJxeGNOa2FrdFI1SVBFbjIwSTdseTN5S1dsNWFsZXl0YVNSQ2ltT2dSNGhxOHJYbU1JR09BRUlJSlVEelAKTlNsdWtUQkQyR3grK3owdHR0TkVJcU5sTFEwQUNpMG56YTNCRDUzYTBwVzhtK3IxWkJONHlnOXlIWXc1andsbwozRjNIdGF6UEhCRFkxc3hhbk9tbnlSc3lMY3dQQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJUNFJFYWJGb0dGUUNNREVTMVpjc2lpNlJyZlJEQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQlVXTDMzWnBkMQpTcXFJeDZoU1ljL3dpNllIVUhpOE9BajI2WWM0NytBaWZVM0dMUzNQOFQyNEptUk9mVW12VGdTMHlILzIzMm5uCnp4YXQwT054VEFXRXNMSDExbFdIL0k0QXREeHpqUEExOFdSbmdGL1pqWDJHM0djVExmc0cvTHExd0dLWEh5L1UKVzF4S2t4akg5OXZwbjZ0ekoyamoyQzlBeXlyeFJ3Sm56bjFiaVE4UG9IcHNZUkJxci8zZWxyT0VUVGM5TlBCRgo1ZEFTakZXRCtzbU9OZG15ZTdRL0pxd3FnNXBVblBsOFVhY2QrRE1oNnFGSXdPdVpWYVlhU2hyUnJ2SDN0akJnCk1GSURQdi9JODNZN3BWUEQ5RHB1WFkrY2pDekI0RXBrcEJzY1gra3JXck9GL1Z3NDNlQnBnekI3R2J2YXk0SG8KVFdneS9haE9LVktiCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    server: https://127.0.0.1:6443
  name: cluster.local
contexts:
- context:
    cluster: cluster.local
    user: kubernetes-admin
  name: kubernetes-admin@cluster.local
current-context: kubernetes-admin@cluster.local
kind: Config
preferences: {}
users:
- name: kubernetes-admin
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURLVENDQWhHZ0F3SUJBZ0lJSkRXeXlDTHhTVUl3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TkRBME1EY3hOVEF3TWpCYUZ3MHlOVEEwTURjeE5UQTFNakZhTUR3eApIekFkQmdOVkJBb1RGbXQxWW1WaFpHMDZZMngxYzNSbGNpMWhaRzFwYm5NeEdUQVhCZ05WQkFNVEVHdDFZbVZ5CmJtVjBaWE10WVdSdGFXNHdnZ0VpTUEwR0NTcUdTSWIzRFFFQkFRVUFBNElCRHdBd2dnRUtBb0lCQVFEVXVmVDAKb2ZzcEZzeXJjbnVWdXY1NVlhbGZXOW9qUEZlcDBRWk5XbWxJdEJsMmdpVjBGY0VvMjVWVmgyN3V0NjF4SHBlKwoyNStqWG4rem1WMzNjbnpiME5WQzRGTUUvQXE5TnNnanBEMXg5ZEtYN1JqYXpYeXI4eE1JNHJ2dllQVVdvWnp2CmQxc0ZxemROcW9GUnZEU2dzUDhYM0RFN1Fua0JqZmRUYms0eDlzK1VVNzRveTM3MXlNVE94VTVJTmNyRFp0MDQKcy9JMVlzMHdSZU9DRGxCcENtaklQbytaTEs2NnJVS0RBYmd0QVpJUkNMb0I1ZUZGay9iWWl4bW45eXFXV1Vzcgp1QStjZGVDV3RraXlmM0lDNDFhbE5OZ1A0Q3JKWnZoY1A3cnk2U2E1aE14cTViNWtsZEt4WjFLTVZBVHUxZnpXCjFmRkltVCthekFtYlE5bERBZ01CQUFHalZqQlVNQTRHQTFVZER3RUIvd1FFQXdJRm9EQVRCZ05WSFNVRUREQUsKQmdnckJnRUZCUWNEQWpBTUJnTlZIUk1CQWY4RUFqQUFNQjhHQTFVZEl3UVlNQmFBRlBoRVJwc1dnWVZBSXdNUgpMVmx5eUtMcEd0OUVNQTBHQ1NxR1NJYjNEUUVCQ3dVQUE0SUJBUUNPWHJXTzRJM1J2L25ZajZMbWE3VGt3RWtzCityY3JHOTVkaWphMUtsek9RTTNPMWFTREhTdU8rU1VUK0hKVW5VelVhZmJ1dmJqbDdCbEFkelFhR0ZwSGpDYXEKUC8xd1BsVXJ2RTJpSnpXR20wSkpvN0hqR081U3B2N2V4a1Z5WHcwS0E3eCt5VjhWaVg5Y3ZkL2UyekVvZTFMRwoyNlJ6SWpFZWRteTBzbytmaW1xamNGNllQZHhVQ1ZueTFSVWU4WldNWWFtNndEcElyOXI5VFVFMGxSN0V2dm1IClZORU43c3FPQ1I0TytsY3pRYytxQ2lXd1lDRld5dnI4QXdZeVJDSzNRNTZUbVRiVXdKMW5iaVE2UjhNRGtMVTQKOC81ZGk0dU5uK3lxSzlETkpvcUdVajQwYmtmcFY3QlhqUVZ6SHNXMnRrRllhTmJNUGR5S2xUVjY4OVZ0Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcEFJQkFBS0NBUUVBMUxuMDlLSDdLUmJNcTNKN2xicitlV0dwWDF2YUl6eFhxZEVHVFZwcFNMUVpkb0lsCmRCWEJLTnVWVllkdTdyZXRjUjZYdnR1Zm8xNS9zNWxkOTNKODI5RFZRdUJUQlB3S3ZUYklJNlE5Y2ZYU2wrMFkKMnMxOHEvTVRDT0s3NzJEMUZxR2M3M2RiQmFzM1RhcUJVYncwb0xEL0Y5d3hPMEo1QVkzM1UyNU9NZmJQbEZPKwpLTXQrOWNqRXpzVk9TRFhLdzJiZE9MUHlOV0xOTUVYamdnNVFhUXBveUQ2UG1TeXV1cTFDZ3dHNExRR1NFUWk2CkFlWGhSWlAyMklzWnAvY3FsbGxMSzdnUG5IWGdsclpJc245eUF1TldwVFRZRCtBcXlXYjRYRCs2OHVrbXVZVE0KYXVXK1pKWFNzV2RTakZRRTd0WDgxdFh4U0prL21zd0ptMFBaUXdJREFRQUJBb0lCQUI3QlA5UDZjemh1am1xZgpJNVR6TXdWVGhFeEFHRnFOeDlMS1lKSGdaMlpXZTNQeHZ2NTRnck9vZzMrWkZBVzVVbjhQUURzY3Y0aThDZFJxCmNQWnNlL2EveTRWZXIwSUNPbjgrbzFMYjFQSmI2dldDRnR6VFpwbnBpNi8yTDl1YzlmSXVyV1RGcWNnNUI4YlgKeHRpTlVFS0hOR283c0haejF0RE51SnM4VUZ2U29uSi9ENm1rdDRFZStNNGhTK0V6U0Nhd1RRclJVcC8wV3ZnWgoraUdBTHJNTmtER1FnSkV1RHdDVnZvM2VRem5PdHY2RjhLVjJvR2J3TjBLdkhRa0FSK0NjbUVCYU5DaWRsaHo0CmxHL1BFYVI4aThVNmFpbGNjUEFjelVIejVSc3ZWZGZ6N1dVaFllTUtmcGZlNVlJTlY3dzhwRmFvWjZ3TFlFcFkKUlFNNmtza0NnWUVBMm4zTVlRR1NOTElNaGJ3OWVYd3BGK0VIckplNlIxSy9DZ2NuSEJJd3dRSlBJUldWZ0pEMQpKaE52OVdxK2huNVE4L2xDcEhMWFFNdm9WdVpBU3A5Q0djWnFERjVnYnhCRklEZUZwVENCTkxnTkZ0cGo5RnMxCk5UV2tTMEo4YUlsVGEyRFkxekZnU2NMRWJkckVJbUozVGh2NVJ1OTUxeXh4bC9GblY3RUNwb1VDZ1lFQStUN00Kc0dES05wS1A5eEMrbjlxK1NCdXFjWlA0TWxKSDBnLyttQUd6NUd3TUR3SjdMWVI4SitIOEJWRXlBZjR1Q3VxMQpiNjU0NU9YVjdpcnByMWFYenRZSEtRMjk5WlJpU0p4bEpzNmFsVWJIYjZYblc3cFRUYVIzQTdPVE0wL2czcElYCmx4QlMvQkJ5d2hHOW1ocTFka20weWVxVTk0cU5FcjVSU1R0bS95Y0NnWUVBb0ZOVEY1T3BqMVZmYnZyME9TTHMKbklNWnVJSVZ4S1JwWHBobEVHb2dzR0JiWkRHTVpLejUxcGpJdk5NNVAwT05iNWxtVjNtVmpneVNUc0hpUjErWgpoNFJhNlB5UDBxK2pxY0pVSlNUMGlwVEx0Z3RHOFZYRU0ybExSNVpmNSsxczh3dzcwWngveFdCUDl6UmlXOERaClBzMjBHMk02aXJRb0hwQ2Jmbk43T0drQ2dZRUFpdC8yNVAvSkxBY1Z1Qy9ZUnZGMnZHN04xV01CRStqTW83ck4Kdkp5V1Exd0FqQXh4M2JiSUJ1RGZyNGJDT21JSi9ZTXhmUHpWMTVSSVV1QU9QT2dleGR4ek9PaXpRelplWE43bgpiV3dJcmN3MkszdGhJYmI3MjNNYjdUQU5nTFd0TWRaczFucitBZnlZTkpIMTl2dVN5RW5oTmZCQytIcDJpRThLCnM2Y3BpRmtDZ1lCQzJOL3FuYWNaY0N5bFM4dS9VUnFEM3FXSlkxeTVBQnJtaGNpMmtua05SejlpMFFQVWdXSXQKL2o2aUlRVGRRZkhDRFhCT3VucURFUzdxOVFCVmhlT1dZMUM3cG1uSTI5Q2ZMeGVyTkl5VzZrdGVadWtJYW1LagpxSWhLbmltaHdEMElUVkZDY2JXNXg2aDZoRngrMXplbjNaeTA5YkQ0a2d1aVA3N0NuNmd5aGc9PQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo=

</details>


Проверяю pods.

~~~
ubuntu@node0:~$ sudo kubectl get pods --all-namespaces
NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-6c7b7dc5d8-5fh7f   1/1     Running   0          6m20s
kube-system   calico-node-28c5f                          1/1     Running   0          7m9s
kube-system   calico-node-b899x                          1/1     Running   0          7m9s
kube-system   calico-node-dv4r8                          1/1     Running   0          7m9s
kube-system   coredns-69db55dd76-wjlkk                   1/1     Running   0          5m45s
kube-system   coredns-69db55dd76-z247p                   1/1     Running   0          5m49s
kube-system   dns-autoscaler-6f4b597d8c-gxxjq            1/1     Running   0          5m46s
kube-system   kube-apiserver-node0                       1/1     Running   2          8m55s
kube-system   kube-controller-manager-node0              1/1     Running   2          8m54s
kube-system   kube-proxy-l2558                           1/1     Running   0          8m1s
kube-system   kube-proxy-rkrwm                           1/1     Running   0          8m1s
kube-system   kube-proxy-zsqxg                           1/1     Running   0          8m1s
kube-system   kube-scheduler-node0                       1/1     Running   1          8m54s
kube-system   nginx-proxy-node1                          1/1     Running   0          8m5s
kube-system   nginx-proxy-node2                          1/1     Running   0          8m3s
kube-system   nodelocaldns-bbm7v                         1/1     Running   0          5m45s
kube-system   nodelocaldns-dzrhp                         1/1     Running   0          5m45s
kube-system   nodelocaldns-vsvck                         1/1     Running   0          5m45s


~~~
