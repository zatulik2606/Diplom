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



### Решение






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
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJTFptdEE3RFlLZEl3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TkRBME1EZ3hPRE0yTkRKYUZ3MHpOREEwTURZeE9EUXhOREphTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUUQ0RXRjMS9YeVcvY29WNDJTbGNydVRWMVR2L2g5YzgvR2JwcTc3S0MrbDRzdGVKUEdueURtS29LSEEKWk9nWW1Ta01WQXFnN21sWE9iczhic2RqTEE5MWtjRW5wZW8vR3NWYjFZcGh4TjVKREtlcVcyemJ3TkRwZ1ZzcQp5RVZjUThkcy9lWE5QNjRadGQ1RmZyMjhyMW5XUllZWkxGYm5VRm90eXNTRXJtbWp0ZEVUbDBLdnRCSG5LMzRDCnlDc2ZpbXhWQ0xkeG9LamovUmtkZGNMTU1mZXBPVkM4Z0RuUVFhbWRBa0xzU2plOW9RTTNQSkt5TGVUeWZnOUsKV0pqWllKTzYvbW5jSzBZV0tiMXBZTDNRdXR4Y0NLemk5TW5vVEQ4TGt5WmtxdklQRk1SanRJOVNyaGI2bzluRgpJZDFCVnRlbVIwaE0rSEJHdkxIUFhnS0dMTVM1QWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJRRGF0d2YvWlAyUlhTWHBIZjJWYXFIVzJ3SjVqQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQjV5dG5oODdDWApRUkdIR3pOdm0rNlE0Nlo4N2Zsa0NxcWNYQnVsU3B1UEt5RS9rQmlrSTdlOTRlMnNNc0V4eU4vRTBBZHZST3JICmU4bWVRblJFNGJnZE1CNnNNZmEwSVYwVWovbk9IS2FZblhXQi9GVXg3UTNXNm5HazhWdDhoQStYanZOYjBtbXEKRGZ6MkhkMEUraktGall5ZlFrSFUwVXdtOHJpNmRLNHFrc0tIOWVQeUVDYUpMWERwUWtyVHhINytRQXAwd3I1ZwpZM2dEdnZ3TnNMK2tBRXpUNENSZUhWWWV6cmZ6U0V4cC85NVgvU0RDeXBRalI2TjhyblppcFZQdVdhYzR4L1FzCkQ5SXcvcU5udXNyTnllSlhZTDlqSUpoYzBoNVJLRmsxTXVRNzk2SGloaWdpQ3pwSGt3NlZ6emdCU3FwWXF5NDUKTElVUlhvQmg3T0pECi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
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
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURLVENDQWhHZ0F3SUJBZ0lJQWZFamdwRExWYnd3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TkRBME1EZ3hPRE0yTkRKYUZ3MHlOVEEwTURneE9EUXhORE5hTUR3eApIekFkQmdOVkJBb1RGbXQxWW1WaFpHMDZZMngxYzNSbGNpMWhaRzFwYm5NeEdUQVhCZ05WQkFNVEVHdDFZbVZ5CmJtVjBaWE10WVdSdGFXNHdnZ0VpTUEwR0NTcUdTSWIzRFFFQkFRVUFBNElCRHdBd2dnRUtBb0lCQVFEdDVCdlkKWnA4bmdieUFGZDRobmxGZ1A5a3JvS0phTDVHY0VzNEF5YUJPSFlzZCtVd2Foek95YVgraEk2YUVVQnAyNzl5Kwpia3dFK3dBbjgzQ1RSdGJKdkFsSmpiYStLa2htakpFdVNPWlFLYUVtayt2VDErSWVwMkdkbHdOTGNpZVZCZlZHCkVFQzhXTlZlcHRxL0d6aFBnbmladzF4ZXp0RS9zK3IvdWJ3NFZ1Q2hSaFdySTNINU9rU3ZMVUhveFY3NUpTQzcKajNuTUkwVTROcWFrOVh4V0pKTHoreERVbXVONHMxM1F1bnNPUDFPWmJueklTUWdla1lLSEtwajZRb1dwVXhxMgpLRCtSbFJRcTI3WGFlK3FmUENGTGpRajVVSnloZFFMQktoVitrQWJkYjE4OTRxc25ZUDVJVDdsSjkyWXJ1UU1wCkg5SUZQeWZVejV2RXRiaVRBZ01CQUFHalZqQlVNQTRHQTFVZER3RUIvd1FFQXdJRm9EQVRCZ05WSFNVRUREQUsKQmdnckJnRUZCUWNEQWpBTUJnTlZIUk1CQWY4RUFqQUFNQjhHQTFVZEl3UVlNQmFBRkFOcTNCLzlrL1pGZEplawpkL1pWcW9kYmJBbm1NQTBHQ1NxR1NJYjNEUUVCQ3dVQUE0SUJBUUI4N1RuMHZoOVJ1eWdiQWZQZi9oVVRvbEwxCjg2dm92RVN1RlpuVm9KNGFPd2V3M1FBMDREVVVubU1wSGNFWjFqWEtDdld6aFhuNzk2dDNmN3BJM2c4WGJjV2oKRHA4SXVmc3lvWXJGRjVEdi80TWZ2ckh3cXZVQnppQmJ4alpkK1ROeURCRnhjTnhjOXVqUmNOT0luWm1TR2VlSwpZM3JjUDRuTjdGTytlNXZORUVBTXhQSEEzUUxMK05DcTBsbTRPYThBNnlUVU80UlpWd0V4dDdoa2FDUkc3aGgrCjNpMUZISTlJd0k2cjhQN2NHN2FSR0dGcFhIWUd2dE0ydGdOek5RQ3RJMFVjVURtQ1hMS1BKcnlPaWUrVFQ1cEsKU0ZGbTNkUDRlNUtnbU9xN3lDZW04c3J0OFlUVkxVenA3R1V1aTlMQmZoQVYyemprVmg5ZVdmWGhJUDZUCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcEFJQkFBS0NBUUVBN2VRYjJHYWZKNEc4Z0JYZUlaNVJZRC9aSzZDaVdpK1JuQkxPQU1tZ1RoMkxIZmxNCkdvY3pzbWwvb1NPbWhGQWFkdS9jdm01TUJQc0FKL053azBiV3lid0pTWTIydmlwSVpveVJMa2ptVUNtaEpwUHIKMDlmaUhxZGhuWmNEUzNJbmxRWDFSaEJBdkZqVlhxYmF2eHM0VDRKNG1jTmNYczdSUDdQcS83bThPRmJnb1VZVgpxeU54K1RwRXJ5MUI2TVZlK1NVZ3U0OTV6Q05GT0RhbXBQVjhWaVNTOC9zUTFKcmplTE5kMExwN0RqOVRtVzU4CnlFa0lIcEdDaHlxWStrS0ZxVk1hdGlnL2taVVVLdHUxMm52cW56d2hTNDBJK1ZDY29YVUN3U29WZnBBRzNXOWYKUGVLckoyRCtTRSs1U2ZkbUs3a0RLUi9TQlQ4bjFNK2J4TFc0a3dJREFRQUJBb0lCQUVEOVFGNHVLdXl3Rkw4cApPallVK2taQkt5TXdEeXAwTkdOZS84aFhUT1FLVGljeUpBaGJSMVJHWGdlM3BaWWdEQnJTREl3NXRhcm1wM1JDCm5VNmUyNjdoSCtob1ByUlUrTktMTkY1Z3JBcmFWSndsYlJmQ3NwT05ScTIydzcrb3dBZUdTU3VLNVNTUFlEc3IKZWpjYlNKYndIZUpqN0tnNStCQmZKcVFXS2NWNTc2bmNBU29QTGFkRGVaNzFHWm5DK1hkWHpubERYbnE3djZBWgovczlweGFhKzRGZHBWVll2ZDFnL3JFRmRwRGRxZ0tTNitTbTJzSkIwL2dzWSt3WTRsRVZ5aVJQY2xRQnYxTE1ZCm0zeEhtaVlVU0JWMzhqbzRJekI0cWsrZ0oxRUU0UTEycXpTSHVIYzIzb1l2M3AzMXVRUVEvQVQrL210RmZRcDEKZEZoN0ZRRUNnWUVBK283Qndzem5KV0lCdlhyd2xHSml2R1Y0TFhNbFFORUVad0pEVWF6ZmQxd2ZLRzJWYzFzZApOQ0lGU21wRXJZVUtqd1Qzb2VTUG9ZZUVTclUxY2ZmN2dUWmFUbTY2cFpFaldyRDVUSloycjZMYktpTzVSa0gvCkVQd1htTUhEMEtzWW0waW1ad3JCTlpQYVh1enJ4cG9GK0lvSVZ0OEFUUWNJRE1EWGNPYTNmL2tDZ1lFQTh3N3IKSFhvRzRsaS91TkJIdy9ZVHFVcm9IcndtS2wzT01OdXM0bkpidVQ2VzBPMDFLVU51WkdzcllXWGNjWDd0OWdHbgpLQ1lTUDE0QnpQc0piUWFTbDVTQksxdTFUM2FtOUsvcCt5ZWJyRU5TV1o1Vkl6cDgwamJzN2xjWmg1eWRYZ3pJCktNVFJxTlpXZjE3WVUzMk01VjYrb0lsV0plZUN0akJOU2dLYTkrc0NnWUVBeGFvVnBnNXNWQXVMZitZYklaUzAKZkJnNHhQSlA4MkJ4N3FuVVhmelpscHB3WWo2QlpxMzh6Z0lBMW9JYmlDQ3JBY1ZUYnI2WHFVRDExdEk2Ulp6egpKeTZ2ODZ4YlJ2N0hPMmJlWmROVjhwMng5UDZWeloySEVla3UzRzRRZ3ZCWHl6bDNQVmM0c1lIaEJuNDJTMGw3CmFHWE15bXZIR3YxdkZsQ1VKaGQ5c0ZFQ2dZRUF0TCtEV0loR1ZreHBScWFjdDcxbklaM3l2K2hxK1ZhSTN3eDkKcEdnbWpidGRyRUM2SjlWZFlvL1AwcjVORUptem5CM2VrSnkvTlNCVGRudTRwcnNjaUZ5SE1oY2czZGIra1RmQQphR1VyL3c2UlR0UFB2RUxpVC9GSWdIV0ZKclB3MHQvdWVXTGtCd3BkaUpxZmhIYjVNQmtrNlgwMzh6Z1duQ1dQClZGcGJvOEVDZ1lBejhKQ3dOMkZLYk5rNWJtTzdhbUNBdTNGVTlSWjMrSjFxc0JTWlVoVGc2UHhjdjFRM0UrQVMKWWdFckpxL3hQdkc0MXVPaDZhVWQyclpQTjJLeDZQNmZXa2ZoZHJaWE5mVnFTWmhqbDRRb29lMktNUnpEZFVVSgp2MFV5NS9PYms2NUl4N0lqKzMrQ2h2UUV4MUhQcVo2QXdsZ2lTQm1oTmYvd3Brb2orbXlRSGc9PQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo=
</details>


Проверяю pods.

~~~
ubuntu@node0:~$ sudo kubectl get pods --all-namespaces
NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-6c7b7dc5d8-nmgkf   1/1     Running   0          4m58s
kube-system   calico-node-5pnhp                          1/1     Running   0          5m41s
kube-system   calico-node-hxkdc                          1/1     Running   0          5m41s
kube-system   calico-node-pctsb                          1/1     Running   0          5m41s
kube-system   coredns-69db55dd76-26699                   1/1     Running   0          4m25s
kube-system   coredns-69db55dd76-hwpmt                   1/1     Running   0          4m29s
kube-system   dns-autoscaler-6f4b597d8c-vn92w            1/1     Running   0          4m26s
kube-system   kube-apiserver-node0                       1/1     Running   1          7m18s
kube-system   kube-controller-manager-node0              1/1     Running   2          7m18s
kube-system   kube-proxy-rd7kz                           1/1     Running   0          6m28s
kube-system   kube-proxy-s4nnj                           1/1     Running   0          6m28s
kube-system   kube-proxy-vl5t6                           1/1     Running   0          6m28s
kube-system   kube-scheduler-node0                       1/1     Running   1          7m15s
kube-system   nginx-proxy-node1                          1/1     Running   0          6m30s
kube-system   nginx-proxy-node2                          1/1     Running   0          6m26s
kube-system   nodelocaldns-d9qtp                         1/1     Running   0          4m25s
kube-system   nodelocaldns-rr2n2                         1/1     Running   0          4m25s
kube-system   nodelocaldns-zcwfw                         1/1     Running   0          4m25s



~~~

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

## Решение

Создаем приложение на helm chart


~~~
ubuntu@node0:~/myapp$ helm create myapp-chart
Creating myapp-chart
~~~



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





