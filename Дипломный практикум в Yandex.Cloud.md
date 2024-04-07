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




terraform apply проходит без ошибок

~~~



~~~

terraform destroy проходит без ошибок


~~~

~~~


VM 


~~~

~~~

VPC 


~~~

~~~

Bucket

### Создание Kubernetes кластера



 VM создались.

 ~~~

 ~~~


Проверяем подключение 

~~~
ssh ubuntu@178.154.223.233
~~~

Добавляем на первую VM ключ от локальной для последующей авторизации( если надо - потом проверишь)

~~~
vim key 
~~~

В этот файл добавишь cat ~/.ssh/id_rsa


Потомо обязательно! сделать chmod 0600 key


Далее  ssh ipVM -i key и заходишь на др VM

~~~
ubuntu@node-0:~$ ssh 158.160.0.65 -i key
The authenticity of host '158.160.0.65 (158.160.0.65)' can't be established.
ECDSA key fingerprint is SHA256:tA+dbxcuy2QQmTxGODKQ/8r2xTFXksYFMeDglA6REXM.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '158.160.0.65' (ECDSA) to the list of known hosts.
Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.4.0-152-generic x86_64)

~~~


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
declare -a IPS=(62.84.118.139 158.160.81.15 158.160.152.69)

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
    node1:
      ansible_host: 62.84.118.139
        #ip: 62.84.118.139
        #access_ip: 62.84.118.139
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ~/.ssh/id_rsa   

    node2:
      ansible_host: 158.160.81.15
        #ip: 158.160.81.15
        #access_ip: 158.160.81.15
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ~/.ssh/id_rsa  
    node3:
      ansible_host: 158.160.152.69
        #ip: 158.160.152.69
        #access_ip: 158.160.152.69
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ~/.ssh/id_rsa  
  children:
    kube_control_plane:
      hosts:
        node1:
    kube_node:
      hosts:
        node2:
        node3:
    etcd:
      hosts:
        node1:
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}


~~~





Запустил playbook


~~~
ansible-playbook -i inventory/mycluster/hosts.yaml cluster.yml -b -v
~~~


Заходим на первую ВМ и проверим версию kube

~~~
ubuntu@node1:~$  sudo kubectl version
Client Version: v1.29.3
Kustomize Version: v5.0.4-0.20230601165947-6ce0bf390ce3
Server Version: v1.29.3

~~~

Проверяем ноды (если возникает ошибка с портом  ,то 

mkdir -p $HOME/.kube

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

sudo chown $(id -u):$(id -g) $HOME/.kube/config

)

~~~

ubuntu@node1:~$ sudo kubectl get nodes
NAME    STATUS   ROLES           AGE   VERSION
node1   Ready    control-plane   10m   v1.29.3
node2   Ready    <none>          10m   v1.29.3
node3   Ready    <none>          10m   v1.29.3

~~~

Смотрим Kubernetes кластер

~~~
ubuntu@node1:~$  kubectl get all --all-namespaces
NAMESPACE     NAME                                           READY   STATUS    RESTARTS   AGE
kube-system   pod/calico-kube-controllers-6c7b7dc5d8-phjxh   1/1     Running   0          8m55s
kube-system   pod/calico-node-bbjt9                          1/1     Running   0          9m39s
kube-system   pod/calico-node-bwtcc                          1/1     Running   0          9m39s
kube-system   pod/calico-node-d858r                          1/1     Running   0          9m39s
kube-system   pod/coredns-69db55dd76-7mjql                   1/1     Running   0          8m26s
kube-system   pod/coredns-69db55dd76-cq757                   1/1     Running   0          8m21s
kube-system   pod/dns-autoscaler-6f4b597d8c-4px7w            1/1     Running   0          8m23s
kube-system   pod/kube-apiserver-node1                       1/1     Running   1          11m
kube-system   pod/kube-controller-manager-node1              1/1     Running   2          11m
kube-system   pod/kube-proxy-djw7n                           1/1     Running   0          10m
kube-system   pod/kube-proxy-hvr6n                           1/1     Running   0          10m
kube-system   pod/kube-proxy-mw7c5                           1/1     Running   0          10m
kube-system   pod/kube-scheduler-node1                       1/1     Running   1          11m
kube-system   pod/nginx-proxy-node2                          1/1     Running   0          10m
kube-system   pod/nginx-proxy-node3                          1/1     Running   0          10m
kube-system   pod/nodelocaldns-bgx56                         1/1     Running   0          8m22s
kube-system   pod/nodelocaldns-qkfpr                         1/1     Running   0          8m22s
kube-system   pod/nodelocaldns-rcv6c                         1/1     Running   0          8m22s

NAMESPACE     NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
default       service/kubernetes   ClusterIP   10.233.0.1   <none>        443/TCP                  11m
kube-system   service/coredns      ClusterIP   10.233.0.3   <none>        53/UDP,53/TCP,9153/TCP   8m26s

NAMESPACE     NAME                          DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
kube-system   daemonset.apps/calico-node    3         3         3       3            3           kubernetes.io/os=linux   9m40s
kube-system   daemonset.apps/kube-proxy     3         3         3       3            3           kubernetes.io/os=linux   11m
kube-system   daemonset.apps/nodelocaldns   3         3         3       3            3           kubernetes.io/os=linux   8m22s

NAMESPACE     NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
kube-system   deployment.apps/calico-kube-controllers   1/1     1            1           8m56s
kube-system   deployment.apps/coredns                   2/2     2            2           8m27s
kube-system   deployment.apps/dns-autoscaler            1/1     1            1           8m25s

NAMESPACE     NAME                                                 DESIRED   CURRENT   READY   AGE
kube-system   replicaset.apps/calico-kube-controllers-6c7b7dc5d8   1         1         1       8m56s
kube-system   replicaset.apps/coredns-69db55dd76                   2         2         2       8m27s
kube-system   replicaset.apps/dns-autoscaler-6f4b597d8c            1         1         1       8m25s

~~~
Проверяем конфиги для доступа

<details>
yc-user@node1:~$ cat ~/.kube/config
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJUlJJZVZGSlFKYmN3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TkRBek1qa3hOREF5TXpWYUZ3MHpOREF6TWpjeE5EQTNNelZhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURKRWo1ZVBBVSs1QU91N205UXJlMHMvNm45NkhaWGptU0ZFWW5jdjVCN2lwZUpHSFExMEp4c2JWeHgKRmpRN0ZHU1FaUm5UNmx2TVB1VkpQcm5wZXkwT0xHei9KZXR1UmlKZFNQSXZwYm1WbW9HT0F1cUxTQVp2Wml3VApocVQ2Z2dMZ1IzK0lYV00rUkpQdEpRdm1WWGRtNnVvS1BCVGJpZFhwblM2MUIxTm9ySDBxcy9nNmRGekI5OUFTCjJmcHZhb0VHNytQWXY1VWJ4eCtFRm5EejBmNTEzd3NHVmpiOTFUQ1JzbG1NQVBvaEZYUTZtV3ZUT08yN2o1ZG4KQk9tMVJsbUFuaEhoaksyNDgvaFBEMFk1Y3NETDhQZ1NoN3Zpc0xYWDJDU29abHB2Y2JhWG1MOE1aT1U0K1dlawpGNXBLWlZOUUw4TE1ZT0p5dVFjZkl6L1EzNS9qQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJSa002TWNjcHEyN0hrWkRJUkxoZFBOams3a1BqQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRREFxS2Z5MHBtSQphUDNSM1pBMlhlbnpnV3JXVy9HTzdYR0FyNVhsYjloRFBhZjk5dGNNT3ZZaGhWQ01TLzhSTVhwUGRvUUpLTUhDCkI4Z1BEclVBNEo0WG5iVTl4RHZzakdrbUM0aTgydFJHTi9id2puUTNCcVd6UWZrK29PZFpEN0NXZWN5WXBQOW8KVlNmMFV1N3pneUJXcGNZNjBuamNEcVRoUFVmVnlkaDZFem5QWTl5MkNiOUVUUU5UYkpqTDdRcU5tU21XcUo3NwovbU5DM0JrVGlmWlI4Q0FjL0cvWFY3eVhQZWtRb1FvckNkMm1yMzlmRFA1ODF3SWczMWEzQXZEM1Z4QXZBelR1CkZwanV4VGR0bkVHSE10TVE5S0szNDFrUkU0eGlVcWt5SHQ5aVhVbStEVzVlRDYyeTk4RWtNQzhGT29zeVRMNm0Kcng2d25qOVY1UEZoCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
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
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURLVENDQWhHZ0F3SUJBZ0lJVVRVcm93dERwSU13RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TkRBek1qa3hOREF5TXpWYUZ3MHlOVEF6TWpreE5EQTNNelphTUR3eApIekFkQmdOVkJBb1RGbXQxWW1WaFpHMDZZMngxYzNSbGNpMWhaRzFwYm5NeEdUQVhCZ05WQkFNVEVHdDFZbVZ5CmJtVjBaWE10WVdSdGFXNHdnZ0VpTUEwR0NTcUdTSWIzRFFFQkFRVUFBNElCRHdBd2dnRUtBb0lCQVFEQlhnWjYKZWVxd3hwbXVDYlJvZ3dNWVpFMFNVZFhxL21aMVJCa25naTZlUlFvMDdjRnRUTTNTNVlvZHcyOE5ZTGVNL0tCZApHd1hub2JaK3BQRWx4TGkwNzhDMTJOOHlEanpLSG9PV2NidmpYTnRMUk5TbDZuVEtvWXAwMTluVG1Qa1lYRUhHCmticGtBMnA0cEFHTFRiRVNzd2k5SlhMTjF3QzdORjdmTGM3TWk1MzlRbFY3SnJid21WdzhoZ0NYUWUxaDdsL1UKMWtoa2JELzFOUkpxRjdWT0c5TFM5UnhVVE5OWXk3SC9GWWloendhb2lZdWY4N0VPZ0g0Snc5dTZITDF5ZXN3eQp3NXRGQ0x0VGk5aGxzUUdmbUN1MEJmdmxiK205NVFPU0U4T0M3NVBpY0NRUmdHd1VzSDB0dXhEZnFZWFpaMUkyCkk2RzNNL2NyM1UvbUhYNU5BZ01CQUFHalZqQlVNQTRHQTFVZER3RUIvd1FFQXdJRm9EQVRCZ05WSFNVRUREQUsKQmdnckJnRUZCUWNEQWpBTUJnTlZIUk1CQWY4RUFqQUFNQjhHQTFVZEl3UVlNQmFBRkdRem94eHltcmJzZVJrTQpoRXVGMDgyT1R1UStNQTBHQ1NxR1NJYjNEUUVCQ3dVQUE0SUJBUUF5RnQvNVlkbHFPYXRHSnRYWkF2elFrVi9oCkFQZ24wYUU1Z01VbnBuWkF4bEs0UjNxRW4ySE5yd1JOSlZiYUVOdW0xNDI0cm5QeTI3Q2JuSVMzN2hMbEhRdTMKNFpqWnd3SGQrNzFTVHZ6aWRQYkt4SGZwYjVuZ2ZJRXlhcVJpSjF5Q0F3ZFZrdHJEYjVGWDI5OXpRRGZVcHVKawoyVkRuWVdVYktIVUJmcnIxQlBzUEtCTTV1VHRzcHYyMnpBV2ZOVGk4cXFGMmtxdVhKQmlZRUNZQWh5TFM4T0NRClZrM3k3Ky96VnFJRjg4YXhtLzNUb0ZzaXJSRHdFOWYxY0k0Z0VxV2hDOEkzYkRsT1FOdjNWTU8rTzc4TENPbDAKaU1zWlRkaWJodUdncG1qTHFzcVdMbVEyUFh5WVVkWStaZ0l1SldyQ3UzMkp3K2pSZ2JFcEwvZ3RUcERkCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFb3dJQkFBS0NBUUVBd1Y0R2VubnFzTWFacmdtMGFJTURHR1JORWxIVjZ2NW1kVVFaSjRJdW5rVUtOTzNCCmJVek4wdVdLSGNOdkRXQzNqUHlnWFJzRjU2RzJmcVR4SmNTNHRPL0F0ZGpmTWc0OHloNkRsbkc3NDF6YlMwVFUKcGVwMHlxR0tkTmZaMDVqNUdGeEJ4cEc2WkFOcWVLUUJpMDJ4RXJNSXZTVnl6ZGNBdXpSZTN5M096SXVkL1VKVgpleWEyOEpsY1BJWUFsMEh0WWU1ZjFOWklaR3cvOVRVU2FoZTFUaHZTMHZVY1ZFelRXTXV4L3hXSW9jOEdxSW1MCm4vT3hEb0IrQ2NQYnVoeTljbnJNTXNPYlJRaTdVNHZZWmJFQm41Z3J0QVg3NVcvcHZlVURraFBEZ3UrVDRuQWsKRVlCc0ZMQjlMYnNRMzZtRjJXZFNOaU9odHpQM0s5MVA1aDErVFFJREFRQUJBb0lCQUMrc25QQkphc0dXMVlFQgpSNGVVOVlob0FsQ0grTFB0Y1Jsc1pyOUU2M1YrRkJ3a21sSDJZN0NoZzBIL1V6djdJb1lTS3YrSmtCVWgyN3F4CnMvcloyNmhRakRUSmVZMy8wS0VNa09qZ3RiQkN6cFpxSy91VUtLTmszSndlTThobHFOU0d1bmpZcVJuTGRjNjAKc09URmpPak5WMVE3RFdrT24xR0lnZk9JZWJvWUxHZnIvZk5HU2w1QkErVDQvWHpPdFlCY1U5TnRaTUt0ZGlhRQpSYnBKMWE5SjJiWFBkWTQzSlBBRjlpeWU3a05nM0tMVkxTYVAxMURYWEt2VzE4YlA2ejFJMVgwemFGbHRYUlB6Ckg4b1F3bEc4RjNzSEpSaGJQbnBPejdNVmFxdDJOamZLcDhYUWtlZGdXeUZMcmlUS25ZVlhXYTRnSHdDdzAyakwKcnRSN0JNa0NnWUVBNDh0YzlTTUtTOWkrVUhORlphM3dtTzYvZUhONnF2TFpxUUdYZENmSy93Smg2aUhqM2tRVgo0VXJOc0ZhdkV0T1ZyZlk0OGJIcjY4blRqTm5iNU5uVUIyTDdkdkwxZXZzUEdsM29naEZ6T3BlRXc0NGlSOXFlCkdrSmg3MUlUTngyV1RwWUtnNytKYXpLV3BVMEMvVmJDaElQQzFQbFF4eTg4dWJpb0VEV1VjNk1DZ1lFQTJVOWoKNzhXRjBMUitwT1g2Z1lpQ3NZZVhxSXgyOVQ5WVZlNFlidmtUNWNibXV2ajZnRXRsSUlWb0Yzc2lNVEszdHVBYgpET1VNRlB0dm1va2M2Mmt0VlN5TnBMQXZZWVQ3SkVnZHg4QUFHN2tySHdjMDJoczZaWGJ0dk52U1VpUWZha2IyCjh6empOQmNrR2hQaGdBNDZ4K3NRcHhyRFgxbThya01XOWp4LzVVOENnWUVBclo3UDBDdVA2blZkd1BYSzNBL3kKUks0Y0U5TjRtSmtXbXdFU2piN1Nzd0QrM2pSTWVKbE9UL1B5eUVlWmt2RGZzY0xzYmhOZExNOGN4Y3M3RmJlTgpLc0FmeCs2d2ViYW5NVUtJTjdMVEw4SlN0N1k2bktlZFA0aC9HcWhrNnVwTEtNU2xhUHR3NHRxaEJZYW9FNjJ2Ci9zNXFqbWNrVVZ6SW5RbUlWeXB2WnA4Q2dZQjJBNVpyVldLNWwvd2JBMFpLNkY3Sm1MQjArV3QwL3FTemJlMVkKL3UyZVlLbFhLdlduak1wcm9lZUlzUGM5cnFSMHJUb2pnNVJQSk1sVUxGaEhSRVE1T0V2bi8wS0wvRk1EUGlMbQpJdEFzUGlBNzVvYitWOEViN3oxbXpoNW5PM1RRRzUvck1zclV0Q2lIL1BuK3VEdVY3SU9Mckk0amp6RlhsZG0zCmVkMmZJd0tCZ0ZoSUQzNm5ESzd0QitTcGcxN0NGODRHVEZicURKUkNoZ0l6MkZuOVVlaVhWMVhUa0dzQ29ncDIKb1lNeitDZlJaeTVMVHdpMlBKK2liUEZYQWxmR1hBZGc5NmJTS0pYUm5PaDlVZWxVNGtTRmNyY3FCMkxBY2FObQpLb01VWVNDdjllUTR0S1dTRHJhR0JWS3VHdjVIS0VURWZiTndkZUVid1VsY0dEQWIwTFBrCi0tLS0tRU5EIFJTQSBQUklWQVRFIEtFWS0tLS0tCg==
</details>


Проверяю pods.

~~~
yc-user@node1:~$ sudo kubectl get pods --all-namespaces
NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE
default       nginx-56fcf95486-g5rgm                     1/1     Running   0          3m39s
default       nginx-56fcf95486-rn4sc                     1/1     Running   0          3m39s
kube-system   calico-kube-controllers-6c7b7dc5d8-snwfw   1/1     Running   0          20m
kube-system   calico-node-72k6m                          1/1     Running   0          21m
kube-system   calico-node-l6tmj                          1/1     Running   0          21m
kube-system   calico-node-w9qpw                          1/1     Running   0          21m
kube-system   coredns-69db55dd76-7kz7g                   1/1     Running   0          20m
kube-system   coredns-69db55dd76-r5bk2                   1/1     Running   0          20m
kube-system   dns-autoscaler-6f4b597d8c-tcljb            1/1     Running   0          20m
kube-system   kube-apiserver-node1                       1/1     Running   1          23m
kube-system   kube-controller-manager-node1              1/1     Running   2          23m
kube-system   kube-proxy-hkthz                           1/1     Running   0          22m
kube-system   kube-proxy-hpggq                           1/1     Running   0          22m
kube-system   kube-proxy-jcgx9                           1/1     Running   0          22m
kube-system   kube-scheduler-node1                       1/1     Running   1          23m
kube-system   nginx-proxy-node2                          1/1     Running   0          22m
kube-system   nginx-proxy-node3                          1/1     Running   0          22m
kube-system   nodelocaldns-8wvtm                         1/1     Running   0          20m
kube-system   nodelocaldns-97nxj                         1/1     Running   0          20m
kube-system   nodelocaldns-rbf9s                         1/1     Running   0          20m

~~~
